import 'core/app_preset.dart';
import 'main.dart';

/// Entry point for Google Play Store release.
/// Default settings on first launch:
/// - Language: English (en)
/// - Default Card Currency: USD ($)
/// - Default Calendar: Gregorian
void main() {
  runGiftCardApp(AppPreset.playStore);
}
