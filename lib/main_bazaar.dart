import 'core/app_preset.dart';
import 'main.dart';

/// Entry point for Cafe Bazaar release.
/// Default settings on first launch:
/// - Language: Persian (fa)
/// - Default Card Currency: Iran (Toman / IRR)
/// - Iranian Unit: Toman
/// - Default Calendar: Jalali (Shamsi)
void main() {
  runGiftCardApp(AppPreset.bazaar);
}
