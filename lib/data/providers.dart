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
    this.language,
    this.iranUnit,
    this.themeMode = 'system',
    this.calendar = 'gregorian',
    this.appLock = false,
    this.maskBalances = false,
  });

  /// Language code the user picked, or null = not chosen yet (the device
  /// language is used if supported, Persian otherwise).
  final String? language;

  /// null = not chosen yet: Toman for Persian, Rial otherwise.
  final IranUnit? iranUnit;
  final bool appLock;
  final bool maskBalances;

  /// 'system' | 'light' | 'dark'
  final String themeMode;

  /// Default calendar for NEW cards: 'gregorian' | 'jalali'. Each card keeps
  /// its own calendar, chosen when it is created.
  final String calendar;

  Settings copyWith({
    String? language,
    IranUnit? iranUnit,
    bool? appLock,
    bool? maskBalances,
    String? themeMode,
    String? calendar,
  }) =>
      Settings(
        language: language ?? this.language,
        iranUnit: iranUnit ?? this.iranUnit,
        appLock: appLock ?? this.appLock,
        maskBalances: maskBalances ?? this.maskBalances,
        themeMode: themeMode ?? this.themeMode,
        calendar: calendar ?? this.calendar,
      );
}

class SettingsNotifier extends Notifier<Settings> {
  SharedPreferences get _p => ref.read(prefsProvider);

  @override
  Settings build() {
    final u = _p.getString('iran_unit');
    return Settings(
      // Older builds stored 'system'; that now simply means "not chosen".
      language: (_p.getString('language') == 'system')
          ? null
          : _p.getString('language'),
      iranUnit: IranUnit.values.where((e) => e.name == u).firstOrNull,
      appLock: _p.getBool('app_lock') ?? false,
      maskBalances: _p.getBool('mask_balances') ?? false,
      themeMode: _p.getString('theme_mode') ?? 'system',
      // Older builds stored 'auto'; Gregorian is the default now.
      calendar: _p.getString('calendar') == 'jalali' ? 'jalali' : 'gregorian',
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

  void setThemeMode(String v) {
    _p.setString('theme_mode', v);
    state = state.copyWith(themeMode: v);
  }

  void setCalendar(String v) {
    _p.setString('calendar', v);
    state = state.copyWith(calendar: v);
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

  /// Applies a new order right away (so the list doesn't jump back while the
  /// database write finishes), then saves it. [ids] is the full order.
  Future<void> reorder(List<String> ids) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final byId = {for (final v in current) v.card.id: v};
    state = AsyncData([
      for (final id in ids)
        if (byId[id] != null) byId[id]!,
      ...current.where((v) => !ids.contains(v.card.id)),
    ]);
    try {
      await ref.read(dbProvider).reorderCards(ids);
    } catch (_) {
      ref.invalidateSelf(); // fall back to what is really stored
    }
  }
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
    String calendar = 'gregorian',
    String number = '',
    String pin = '',
  }) async {
    await _db.addCard(
      name: name,
      currencyCode: currencyCode,
      colorIndex: colorIndex,
      initialMinor: initialMinor,
      expiry: expiry,
      calendar: calendar,
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
    String calendar = 'gregorian',
    String number = '',
    String pin = '',
  }) async {
    await _db.updateCard(
      id: id,
      name: name,
      colorIndex: colorIndex,
      expiry: expiry,
      calendar: calendar,
      number: number,
      pin: pin,
    );
    _touch(id);
  }

  Future<void> deleteCard(String id) async {
    await _db.deleteCard(id);
    _touch();
  }

  Future<void> reorder(List<String> ids) =>
      _ref.read(cardsProvider.notifier).reorder(ids);

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
