import 'dart:ui';

/// Native names shown in the language picker. A language only appears in the
/// picker once it has an ARB file (see AppLocalizations.supportedLocales);
/// add its name here if it is missing, otherwise the ISO code is shown.
const kNativeLanguageNames = <String, String>{
  'fa': 'فارسی',
  'en': 'English',
  'ar': 'العربية',
  'tr': 'Türkçe',
  'az': 'Azərbaycanca',
  'ku': 'کوردی',
  'ur': 'اردو',
  'ps': 'پښتو',
  'ru': 'Русский',
  'uk': 'Українська',
  'de': 'Deutsch',
  'fr': 'Français',
  'es': 'Español',
  'it': 'Italiano',
  'pt': 'Português',
  'nl': 'Nederlands',
  'sv': 'Svenska',
  'pl': 'Polski',
  'hi': 'हिन्दी',
  'zh': '中文',
  'ja': '日本語',
  'ko': '한국어',
};

String nativeLanguageName(Locale locale) =>
    kNativeLanguageNames[locale.languageCode] ??
    locale.languageCode.toUpperCase();

/// The language the app uses when set to "System": the device language if it
/// is supported, Persian otherwise (same rule as the locale resolution in
/// app.dart).
Locale resolveDeviceLocale(Iterable<Locale> supported) {
  final device = PlatformDispatcher.instance.locale;
  for (final s in supported) {
    if (s.languageCode == device.languageCode) return s;
  }
  return const Locale('fa');
}

/// The language in effect: the saved one if it is still supported, otherwise
/// the device language (or Persian).
String effectiveLanguageCode(String? saved, Iterable<Locale> supported) {
  if (saved != null && supported.any((s) => s.languageCode == saved)) {
    return saved;
  }
  return resolveDeviceLocale(supported).languageCode;
}
