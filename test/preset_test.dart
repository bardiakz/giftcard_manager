import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftcard_manager/core/app_preset.dart';
import 'package:giftcard_manager/core/money.dart';
import 'package:giftcard_manager/data/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('App Presets in giftcard_manager', () {
    test('Play Store preset defaults to English, USD, and Gregorian calendar',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          presetProvider.overrideWithValue(AppPreset.playStore),
        ],
      );
      addTearDown(container.dispose);

      final settings = container.read(settingsProvider);
      expect(settings.language, 'en');
      expect(settings.defaultCurrency, 'USD');
      expect(settings.calendar, 'gregorian');
    });

    test('Cafe Bazaar preset defaults to Persian, Toman (IRR), and Jalali calendar',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          presetProvider.overrideWithValue(AppPreset.bazaar),
        ],
      );
      addTearDown(container.dispose);

      final settings = container.read(settingsProvider);
      expect(settings.language, 'fa');
      expect(settings.defaultCurrency, 'IRR');
      expect(settings.iranUnit, IranUnit.toman);
      expect(settings.calendar, 'jalali');
    });

    test('Myket preset defaults to Persian, Toman (IRR), and Jalali calendar',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          presetProvider.overrideWithValue(AppPreset.myket),
        ],
      );
      addTearDown(container.dispose);

      final settings = container.read(settingsProvider);
      expect(settings.language, 'fa');
      expect(settings.defaultCurrency, 'IRR');
      expect(settings.iranUnit, IranUnit.toman);
      expect(settings.calendar, 'jalali');
    });

    test('User preferences persist across launches and override build presets',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Launch 1: Play Store build (defaults to English & USD)
      final container1 = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          presetProvider.overrideWithValue(AppPreset.playStore),
        ],
      );
      expect(container1.read(settingsProvider).language, 'en');
      expect(container1.read(settingsProvider).defaultCurrency, 'USD');

      // User changes language to Persian and currency to EUR
      container1.read(settingsProvider.notifier).setLanguage('fa');
      container1.read(settingsProvider.notifier).setDefaultCurrency('EUR');

      expect(container1.read(settingsProvider).language, 'fa');
      expect(container1.read(settingsProvider).defaultCurrency, 'EUR');
      container1.dispose();

      // Launch 2: Relaunching the same Play Store build
      final container2 = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          presetProvider.overrideWithValue(AppPreset.playStore),
        ],
      );
      addTearDown(container2.dispose);

      // Must retain user's saved preferences
      expect(container2.read(settingsProvider).language, 'fa');
      expect(container2.read(settingsProvider).defaultCurrency, 'EUR');
    });

    test('resetToPreset reverts back to market preset defaults', () async {
      SharedPreferences.setMockInitialValues({
        'language': 'fa',
        'default_currency': 'IRR',
        'calendar': 'jalali',
      });
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          presetProvider.overrideWithValue(AppPreset.playStore),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(settingsProvider).language, 'fa');
      expect(container.read(settingsProvider).defaultCurrency, 'IRR');

      container.read(settingsProvider.notifier).resetToPreset();

      expect(container.read(settingsProvider).language, 'en');
      expect(container.read(settingsProvider).defaultCurrency, 'USD');
      expect(container.read(settingsProvider).calendar, 'gregorian');
    });
  });
}
