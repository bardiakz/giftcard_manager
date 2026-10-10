import 'package:flutter/foundation.dart';

import '../core/money.dart';

enum EntryType { initial, spend, topUp, adjustment, reversal }

/// One immutable ledger line. [delta] is signed: spends are negative.
@immutable
class Entry {
  const Entry({
    required this.id,
    required this.cardId,
    required this.type,
    required this.delta,
    required this.createdAt,
    this.note = '',
    this.refId,
  });

  final String id;
  final String cardId;
  final EntryType type;
  final int delta;
  final String note;
  final DateTime createdAt;

  /// For reversals: the entry being reversed.
  final String? refId;

  Map<String, Object?> toMap() => {
        'id': id,
        'card_id': cardId,
        'type': type.name,
        'delta': delta,
        'note': note,
        'created_at': createdAt.millisecondsSinceEpoch,
        'ref_id': refId,
      };

  factory Entry.fromMap(Map<String, Object?> m) => Entry(
        id: m['id']! as String,
        cardId: m['card_id']! as String,
        type: EntryType.values.byName(m['type']! as String),
        delta: (m['delta']! as num).toInt(),
        note: (m['note'] as String?) ?? '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            (m['created_at']! as num).toInt()),
        refId: m['ref_id'] as String?,
      );
}

@immutable
class GiftCard {
  const GiftCard({
    required this.id,
    required this.name,
    required this.currencyCode,
    required this.colorIndex,
    required this.createdAt,
    this.expiry,
    this.hasNumber = false,
    this.hasPin = false,
    this.calendar = 'gregorian',
  });

  final String id;
  final String name;
  final String currencyCode;
  final int colorIndex;
  final DateTime createdAt;
  final DateTime? expiry;
  final bool hasNumber;
  final bool hasPin;

  /// Calendar this card's dates are shown in: 'gregorian' | 'jalali'.
  final String calendar;

  bool get isJalali => calendar == 'jalali';

  Currency get currency => Currency.byCode(currencyCode);
}

/// A card plus its derived money figures.
@immutable
class CardView {
  const CardView(this.card, this.balance, this.funded);

  final GiftCard card;

  /// Sum of all ledger deltas.
  final int balance;

  /// Starting credit plus (non-reversed) top-ups; used for the progress bar.
  final int funded;

  double get ratio =>
      funded <= 0 ? 0.0 : (balance / funded).clamp(0.0, 1.0).toDouble();
}

class InsufficientBalance implements Exception {
  const InsufficientBalance();
  @override
  String toString() => 'InsufficientBalance';
}

// ── Ledger rules (pure, unit-tested) ─────────────────────────────────────

int balanceOf(Iterable<Entry> entries) =>
    entries.fold(0, (sum, e) => sum + e.delta);

Set<String> reversedIds(Iterable<Entry> entries) => {
      for (final e in entries)
        if (e.type == EntryType.reversal && e.refId != null) e.refId!,
    };

bool canReverse(Entry e, Set<String> reversed) =>
    e.type != EntryType.initial &&
    e.type != EntryType.reversal &&
    !reversed.contains(e.id);

// ── Expiry ───────────────────────────────────────────────────────────────

enum ExpiryState { none, ok, soon, today, expired }

@immutable
class ExpiryInfo {
  const ExpiryInfo(this.state, this.days);
  final ExpiryState state;
  final int days;
}

ExpiryInfo expiryOf(DateTime? expiry, {DateTime? now}) {
  if (expiry == null) return const ExpiryInfo(ExpiryState.none, 0);
  final n = now ?? DateTime.now();
  final days = DateTime.utc(expiry.year, expiry.month, expiry.day)
      .difference(DateTime.utc(n.year, n.month, n.day))
      .inDays;
  if (days < 0) return ExpiryInfo(ExpiryState.expired, days);
  if (days == 0) return ExpiryInfo(ExpiryState.today, days);
  if (days <= 30) return ExpiryInfo(ExpiryState.soon, days);
  return ExpiryInfo(ExpiryState.ok, days);
}
