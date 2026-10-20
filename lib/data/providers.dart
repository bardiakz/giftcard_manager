import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_preset.dart';
import '../core/format.dart';
import '../core/money.dart';
import 'database.dart';
import 'models.dart';
import 'dart:async';

final prefsProvider =
    Provider<SharedPreferences>((_) => throw UnimplementedError());
final dbProvider = Provider<AppDatabase>((_) => throw UnimplementedError());
final presetProvider = Provider<AppPreset>((_) => AppPreset.fromEnvironment());

// ── Settings ─────────────────────────────────────────────────────────────

@immutable
class Settings {
  const Settings({
    this.language,
    this.iranUnit,
    this.defaultCurrency = 'USD',
    this.themeMode = 'system',
    this.calendar = 'gregorian',
    this.appLock = false,
    this.maskBalances = false,
  });

  /// Language code the user picked, or null = not chosen yet.
  final String? language;

  /// null = not chosen yet: Toman for Persian, Rial otherwise.
  final IranUnit? iranUnit;

  /// Default currency for new cards: 'USD', 'IRR', etc.
  final String defaultCurrency;

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
    String? defaultCurrency,
    bool? appLock,
    bool? maskBalances,
    String? themeMode,
    String? calendar,
  }) =>
      Settings(
        language: language ?? this.language,
        iranUnit: iranUnit ?? this.iranUnit,
        defaultCurrency: defaultCurrency ?? this.defaultCurrency,
        appLock: appLock ?? this.appLock,
        maskBalances: maskBalances ?? this.maskBalances,
        themeMode: themeMode ?? this.themeMode,
        calendar: calendar ?? this.calendar,
      );
}

class SettingsNotifier extends Notifier<Settings> {
  SharedPreferences get _p => ref.read(prefsProvider);
  AppPreset get _preset => ref.read(presetProvider);

  @override
  Settings build() {
    final u = _p.getString('iran_unit');
    final savedLang = _p.getString('language');
    final savedCalendar = _p.getString('calendar');

    return Settings(
      // Older builds stored 'system'; that now simply means "not chosen".
      language: (savedLang == 'system')
          ? null
          : (savedLang ?? _preset.defaultLanguage),
      iranUnit: IranUnit.values.where((e) => e.name == u).firstOrNull ??
          _preset.defaultIranUnit,
      defaultCurrency:
          _p.getString('default_currency') ?? _preset.defaultCurrency,
      appLock: _p.getBool('app_lock') ?? false,
      maskBalances: _p.getBool('mask_balances') ?? false,
      themeMode: _p.getString('theme_mode') ?? 'system',
      calendar: savedCalendar == 'jalali'
          ? 'jalali'
          : (savedCalendar == 'gregorian'
              ? 'gregorian'
              : _preset.defaultCalendar),
    );
  }

  void setLanguage(String v) {
    _p.setString('language', v);
    state = state.copyWith(language: v);
  }

  void setDefaultCurrency(String v) {
    _p.setString('default_currency', v);
    state = state.copyWith(defaultCurrency: v);
  }

  void setIranUnit(IranUnit v) {
    _p.setString('iran_unit', v.name);
    state = state.copyWith(iranUnit: v);
  }

  void resetToPreset() {
    _p.remove('language');
    _p.remove('iran_unit');
    _p.remove('default_currency');
    _p.remove('calendar');
    ref.invalidateSelf();
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

/// Balance visibility key used for the total balance override.
const totalBalanceId = '__total__';

/// Per-card and total override of balance visibility, kept for this session only.
/// An id without an entry follows the global "Hide balances" setting.
class BalanceVisibilityNotifier extends Notifier<Map<String, bool>> {
  static const _autoHide = Duration(seconds: 10);
  final _timers = <String, Timer>{};

  @override
  Map<String, bool> build() {
    // Changing the global setting starts everything fresh.
    ref.listen(settingsProvider.select((s) => s.maskBalances), (_, __) {
      for (final t in _timers.values) {
        t.cancel();
      }
      _timers.clear();
      state = const {};
    });
    ref.onDispose(() {
      for (final t in _timers.values) {
        t.cancel();
      }
    });
    return const {};
  }

  /// Flips one card. A balance that is hidden by default hides itself again
  /// after a few seconds.
  void toggle(String id) {
    final globalMask = ref.read(settingsProvider).maskBalances;
    final show = !(state[id] ?? !globalMask);
    _timers.remove(id)?.cancel();
    state = {...state, id: show};
    if (show && globalMask) {
      _timers[id] = Timer(_autoHide, () {
        _timers.remove(id);
        state = {...state}..remove(id);
      });
    }
  }
}

final balanceVisibilityProvider =
    NotifierProvider<BalanceVisibilityNotifier, Map<String, bool>>(
        BalanceVisibilityNotifier.new);
