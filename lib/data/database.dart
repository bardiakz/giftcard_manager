import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../core/crypto.dart';
import 'models.dart';

final _rng = Random.secure();

String newId() => '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}'
    '${_rng.nextInt(1 << 31).toRadixString(36)}';

/// SQLite persistence. Money lives in an append-only ledger; card numbers and
/// PINs are AES-GCM encrypted per field.
class AppDatabase {
  AppDatabase._(this._db, this._cipher);

  final Database _db;
  final FieldCipher _cipher;

  static Future<AppDatabase> open() async {
    final cipher = await FieldCipher.load();
    final db = await openDatabase(
      p.join(await getDatabasesPath(), 'giftcards.db'),
      version: 2,
      onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON'),
      onCreate: (d, _) async {
        await d.execute('''
          CREATE TABLE cards (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            currency TEXT NOT NULL,
            color INTEGER NOT NULL,
            expiry INTEGER,
            number_enc TEXT NOT NULL DEFAULT '',
            pin_enc TEXT NOT NULL DEFAULT '',
            calendar TEXT NOT NULL DEFAULT 'gregorian',
            created_at INTEGER NOT NULL
          )''');
        await d.execute('''
          CREATE TABLE entries (
            id TEXT PRIMARY KEY,
            card_id TEXT NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
            type TEXT NOT NULL,
            delta INTEGER NOT NULL,
            note TEXT NOT NULL DEFAULT '',
            created_at INTEGER NOT NULL,
            ref_id TEXT
          )''');
        await d.execute('CREATE INDEX idx_entries_card ON entries(card_id)');
        await d.execute('CREATE INDEX idx_entries_ref ON entries(ref_id)');
        // The ledger is append-only: rows can be deleted only by deleting the
        // whole card (cascade), never edited.
        await d.execute('''
          CREATE TRIGGER entries_immutable BEFORE UPDATE ON entries
          BEGIN SELECT RAISE(ABORT, 'ledger entries are immutable'); END''');
      },
      onUpgrade: (d, oldVersion, _) async {
        if (oldVersion < 2) {
          await d.execute(
              "ALTER TABLE cards ADD COLUMN calendar TEXT NOT NULL DEFAULT 'gregorian'");
        }
      },
    );
    return AppDatabase._(db, cipher);
  }

  Future<List<CardView>> cardViews() async {
    final rows = await _db.rawQuery('''
      SELECT c.id, c.name, c.currency, c.color, c.expiry, c.calendar, c.created_at,
             (c.number_enc != '') AS has_number,
             (c.pin_enc != '') AS has_pin,
             COALESCE(SUM(e.delta), 0) AS balance,
             COALESCE(SUM(CASE
               WHEN e.type IN ('initial', 'topUp')
                AND NOT EXISTS (SELECT 1 FROM entries r WHERE r.ref_id = e.id)
               THEN e.delta END), 0) AS funded
      FROM cards c
      LEFT JOIN entries e ON e.card_id = c.id
      GROUP BY c.id
      ORDER BY c.created_at DESC''');
    return [
      for (final r in rows)
        CardView(
          GiftCard(
            id: r['id']! as String,
            name: r['name']! as String,
            currencyCode: r['currency']! as String,
            colorIndex: (r['color']! as num).toInt(),
            calendar: r['calendar']! as String,
            createdAt: DateTime.fromMillisecondsSinceEpoch(
                (r['created_at']! as num).toInt()),
            expiry: r['expiry'] == null
                ? null
                : DateTime.fromMillisecondsSinceEpoch(
                    (r['expiry']! as num).toInt()),
            hasNumber: (r['has_number']! as num) != 0,
            hasPin: (r['has_pin']! as num) != 0,
          ),
          (r['balance']! as num).toInt(),
          (r['funded']! as num).toInt(),
        ),
    ];
  }

  Future<List<Entry>> entries(String cardId) async {
    final rows = await _db.query(
      'entries',
      where: 'card_id = ?',
      whereArgs: [cardId],
      orderBy: 'created_at DESC, rowid DESC',
    );
    return rows.map(Entry.fromMap).toList();
  }

  Future<String> addCard({
    required String name,
    required String currencyCode,
    required int colorIndex,
    required int initialMinor,
    DateTime? expiry,
    String calendar = 'gregorian',
    String number = '',
    String pin = '',
  }) async {
    final id = newId();
    final numberEnc = await _cipher.encrypt(number);
    final pinEnc = await _cipher.encrypt(pin);
    final now = DateTime.now();
    await _db.transaction((t) async {
      await t.insert('cards', {
        'id': id,
        'name': name,
        'currency': currencyCode,
        'color': colorIndex,
        'expiry': expiry?.millisecondsSinceEpoch,
        'calendar': calendar,
        'number_enc': numberEnc,
        'pin_enc': pinEnc,
        'created_at': now.millisecondsSinceEpoch,
      });
      await t.insert(
        'entries',
        Entry(
          id: newId(),
          cardId: id,
          type: EntryType.initial,
          delta: initialMinor,
          createdAt: now,
        ).toMap(),
      );
    });
    return id;
  }

  Future<void> updateCard({
    required String id,
    required String name,
    required int colorIndex,
    DateTime? expiry,
    String calendar = 'gregorian',
    String number = '',
    String pin = '',
  }) async {
    final numberEnc = await _cipher.encrypt(number);
    final pinEnc = await _cipher.encrypt(pin);
    await _db.update(
      'cards',
      {
        'name': name,
        'color': colorIndex,
        'expiry': expiry?.millisecondsSinceEpoch,
        'calendar': calendar,
        'number_enc': numberEnc,
        'pin_enc': pinEnc,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteCard(String id) =>
      _db.delete('cards', where: 'id = ?', whereArgs: [id]);

  Future<({String number, String pin})> secrets(String cardId) async {
    final rows = await _db.query(
      'cards',
      columns: ['number_enc', 'pin_enc'],
      where: 'id = ?',
      whereArgs: [cardId],
    );
    if (rows.isEmpty) return (number: '', pin: '');
    return (
      number: await _cipher.decrypt(rows.first['number_enc']! as String),
      pin: await _cipher.decrypt(rows.first['pin_enc']! as String),
    );
  }

  Future<int> _balance(DatabaseExecutor t, String cardId) async {
    final r = await t.rawQuery(
        'SELECT COALESCE(SUM(delta), 0) AS b FROM entries WHERE card_id = ?',
        [cardId]);
    return (r.first['b']! as num).toInt();
  }

  /// Appends a ledger entry. Throws [InsufficientBalance] if it would take the
  /// balance below zero.
  Future<Entry> addEntry(
    String cardId,
    EntryType type,
    int delta, {
    String note = '',
  }) async {
    final entry = Entry(
      id: newId(),
      cardId: cardId,
      type: type,
      delta: delta,
      note: note,
      createdAt: DateTime.now(),
    );
    await _db.transaction((t) async {
      if (await _balance(t, cardId) + delta < 0) {
        throw const InsufficientBalance();
      }
      await t.insert('entries', entry.toMap());
    });
    return entry;
  }

  /// Undoes an entry by appending its mirror image (never edits history).
  Future<void> reverse(String entryId) async {
    await _db.transaction((t) async {
      final rows =
          await t.query('entries', where: 'id = ?', whereArgs: [entryId]);
      if (rows.isEmpty) return;
      final e = Entry.fromMap(rows.first);
      if (e.type == EntryType.initial || e.type == EntryType.reversal) return;
      final done = await t.query('entries',
          where: 'ref_id = ?', whereArgs: [entryId], limit: 1);
      if (done.isNotEmpty) return;
      if (await _balance(t, e.cardId) - e.delta < 0) {
        throw const InsufficientBalance();
      }
      await t.insert(
        'entries',
        Entry(
          id: newId(),
          cardId: e.cardId,
          type: EntryType.reversal,
          delta: -e.delta,
          createdAt: DateTime.now(),
          refId: entryId,
        ).toMap(),
      );
    });
  }
}
