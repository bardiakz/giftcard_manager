import 'core/app_preset.dart';
import 'main.dart';

/// Entry point for Myket release.
/// Default settings on first launch:
/// - Language: Persian (fa)
/// - Default Card Currency: Iran (Toman / IRR)
/// - Iranian Unit: Toman
/// - Default Calendar: Jalali (Shamsi)
void main() {
  runGiftCardApp(AppPreset.myket);
}
