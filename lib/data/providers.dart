import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/format.dart';
import '../core/money.dart';
import 'database.dart';
import 'models.dart';

final prefsProvider =
    Provider<SharedPreferences>((_) => throw UnimplementedError());
final dbProvider = Provider<AppDatabase>((_) => throw UnimplementedError());

// ── Settings ─────────────────────────────────────────────────────────────

@immutable
class Settings {
  const Settings({
    this.language = 'system',
    this.iranUnit,
    this.appLock = false,
    this.maskBalances = false,
  });

  /// 'system' | 'fa' | 'en'
  final String language;

  /// null = not chosen yet: Toman for Persian, Rial otherwise.
  final IranUnit? iranUnit;
  final bool appLock;
  final bool maskBalances;

  Settings copyWith({
    String? language,
    IranUnit? iranUnit,
    bool? appLock,
    bool? maskBalances,
  }) =>
      Settings(
        language: language ?? this.language,
        iranUnit: iranUnit ?? this.iranUnit,
        appLock: appLock ?? this.appLock,
        maskBalances: maskBalances ?? this.maskBalances,
      );
}

class SettingsNotifier extends Notifier<Settings> {
  SharedPreferences get _p => ref.read(prefsProvider);

  @override
  Settings build() {
    final u = _p.getString('iran_unit');
    return Settings(
      language: _p.getString('language') ?? 'system',
      iranUnit: IranUnit.values.where((e) => e.name == u).firstOrNull,
      appLock: _p.getBool('app_lock') ?? false,
      maskBalances: _p.getBool('mask_balances') ?? false,
    );
  }

  void setLanguage(String v) {
    _p.setString('language', v);
    state = state.copyWith(language: v);
  }

  void setIranUnit(IranUnit v) {
    _p.setString('iran_unit', v.name);
    state = state.copyWith(iranUnit: v);
  }

  void setAppLock(bool v) {
    _p.setBool('app_lock', v);
    state = state.copyWith(appLock: v);
  }

  void setMaskBalances(bool v) {
    _p.setBool('mask_balances', v);
    state = state.copyWith(maskBalances: v);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);

/// Money formatter for the current language and Toman/Rial choice.
MoneyFormat moneyFormatOf(BuildContext context, WidgetRef ref) {
  final fa = isFa(context);
  final unit = ref.watch(settingsProvider.select((s) => s.iranUnit)) ??
      (fa ? IranUnit.toman : IranUnit.rial);
  return MoneyFormat(fa: fa, unit: unit);
}

// ── Data ─────────────────────────────────────────────────────────────────

class CardsNotifier extends AsyncNotifier<List<CardView>> {
  @override
  Future<List<CardView>> build() => ref.watch(dbProvider).cardViews();
}

final cardsProvider =
    AsyncNotifierProvider<CardsNotifier, List<CardView>>(CardsNotifier.new);

final entriesProvider = FutureProvider.autoDispose.family<List<Entry>, String>(
  (ref, cardId) => ref.watch(dbProvider).entries(cardId),
);

/// All writes go through here so providers are refreshed consistently.
class CardActions {
  CardActions(this._ref);
  final Ref _ref;

  AppDatabase get _db => _ref.read(dbProvider);

  void _touch([String? cardId]) {
    _ref.invalidate(cardsProvider);
    if (cardId != null) _ref.invalidate(entriesProvider(cardId));
  }

  Future<void> addCard({
    required String name,
    required String currencyCode,
    required int colorIndex,
    required int initialMinor,
    DateTime? expiry,
    String number = '',
    String pin = '',
  }) async {
    await _db.addCard(
      name: name,
      currencyCode: currencyCode,
      colorIndex: colorIndex,
      initialMinor: initialMinor,
      expiry: expiry,
      number: number,
      pin: pin,
    );
    _touch();
  }

  Future<void> updateCard({
    required String id,
    required String name,
    required int colorIndex,
    DateTime? expiry,
    String number = '',
    String pin = '',
  }) async {
    await _db.updateCard(
      id: id,
      name: name,
      colorIndex: colorIndex,
      expiry: expiry,
      number: number,
      pin: pin,
    );
    _touch(id);
  }

  Future<void> deleteCard(String id) async {
    await _db.deleteCard(id);
    _touch();
  }

  Future<Entry> addEntry(
    String cardId,
    EntryType type,
    int delta, {
    String note = '',
  }) async {
    final e = await _db.addEntry(cardId, type, delta, note: note);
    _touch(cardId);
    return e;
  }

  Future<void> reverse(String cardId, String entryId) async {
    await _db.reverse(entryId);
    _touch(cardId);
  }
}

final actionsProvider = Provider<CardActions>(CardActions.new);
