import 'money.dart';

enum Market {
  playStore('playstore'),
  bazaar('bazaar'),
  myket('myket'),
  generic('generic');

  final String value;
  const Market(this.value);

  static Market fromString(String? val) {
    if (val == null) return Market.generic;
    return Market.values.firstWhere(
      (m) => m.value.toLowerCase() == val.toLowerCase(),
      orElse: () => Market.generic,
    );
  }
}

class AppPreset {
  final Market market;
  final String defaultLanguage; // 'en' or 'fa'
  final String defaultCurrency; // 'USD' or 'IRR'
  final IranUnit defaultIranUnit; // IranUnit.toman or IranUnit.rial
  final String defaultCalendar; // 'gregorian' or 'jalali'
  final String name;

  const AppPreset({
    required this.market,
    required this.defaultLanguage,
    required this.defaultCurrency,
    required this.defaultIranUnit,
    required this.defaultCalendar,
    required this.name,
  });

  /// Google Play Store preset: English + USD + Gregorian
  static const playStore = AppPreset(
    market: Market.playStore,
    defaultLanguage: 'en',
    defaultCurrency: 'USD',
    defaultIranUnit: IranUnit.toman,
    defaultCalendar: 'gregorian',
    name: 'Google Play Store',
  );

  /// Cafe Bazaar preset: Persian + Toman (IRR) + Shamsi (Jalali)
  static const bazaar = AppPreset(
    market: Market.bazaar,
    defaultLanguage: 'fa',
    defaultCurrency: 'IRR',
    defaultIranUnit: IranUnit.toman,
    defaultCalendar: 'jalali',
    name: 'Cafe Bazaar',
  );

  /// Myket preset: Persian + Toman (IRR) + Shamsi (Jalali)
  static const myket = AppPreset(
    market: Market.myket,
    defaultLanguage: 'fa',
    defaultCurrency: 'IRR',
    defaultIranUnit: IranUnit.toman,
    defaultCalendar: 'jalali',
    name: 'Myket',
  );

  /// Resolves preset dynamically from environment variables (--dart-define / --dart-define-from-file)
  factory AppPreset.fromEnvironment() {
    const marketEnv = String.fromEnvironment('MARKET');
    const langEnv = String.fromEnvironment('DEFAULT_LANG');
    const currEnv = String.fromEnvironment('DEFAULT_CURRENCY');
    const calEnv = String.fromEnvironment('DEFAULT_CALENDAR');

    final market = Market.fromString(marketEnv);

    if (market == Market.playStore) {
      return AppPreset(
        market: Market.playStore,
        defaultLanguage: langEnv.isNotEmpty ? langEnv : 'en',
        defaultCurrency: currEnv.isNotEmpty ? currEnv : 'USD',
        defaultIranUnit: IranUnit.toman,
        defaultCalendar: calEnv.isNotEmpty ? calEnv : 'gregorian',
        name: 'Google Play Store',
      );
    } else if (market == Market.bazaar) {
      return AppPreset(
        market: Market.bazaar,
        defaultLanguage: langEnv.isNotEmpty ? langEnv : 'fa',
        defaultCurrency: currEnv.isNotEmpty ? currEnv : 'IRR',
        defaultIranUnit: IranUnit.toman,
        defaultCalendar: calEnv.isNotEmpty ? calEnv : 'jalali',
        name: 'Cafe Bazaar',
      );
    } else if (market == Market.myket) {
      return AppPreset(
        market: Market.myket,
        defaultLanguage: langEnv.isNotEmpty ? langEnv : 'fa',
        defaultCurrency: currEnv.isNotEmpty ? currEnv : 'IRR',
        defaultIranUnit: IranUnit.toman,
        defaultCalendar: calEnv.isNotEmpty ? calEnv : 'jalali',
        name: 'Myket',
      );
    }

    return AppPreset(
      market: Market.generic,
      defaultLanguage: langEnv.isNotEmpty ? langEnv : 'en',
      defaultCurrency: currEnv.isNotEmpty ? currEnv : 'USD',
      defaultIranUnit: IranUnit.toman,
      defaultCalendar: calEnv.isNotEmpty ? calEnv : 'gregorian',
      name: 'Default',
    );
  }
}
