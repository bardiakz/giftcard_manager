# Gift Card Manager

> Private, 100% offline gift card balance tracker.

<p align="center">
  <img src="assets/store/feature_graphic_1024x500.png" alt="Gift Card Manager" width="100%" />
</p>

A clean, distraction-free utility to track balances, purchases, and expiration dates for your gift cards and vouchers. Built with privacy and local encryption by design.

---

## Features

- **100% Offline & Private:** Zero network permissions. No analytics, no tracking SDKs, no external servers, and no ads.
- **On-Device Encryption:** Card numbers, PINs, and sensitive fields are encrypted in local SQLite storage (AES via `cryptography` + hardware-backed `flutter_secure_storage`).
- **App Lock & Biometrics:** Optional biometric/screen lock protection (`local_auth` / `BiometricPrompt`).
- **Screenshot Protection:** Android `FLAG_SECURE` enabled in release mode prevents leaks in the recent-apps switcher or screen capture.
- **Quick Logging:** One-tap purchase logging, balance adjustment, and instant history undo.
- **Multi-Currency & Calendars:** Full ISO 4217 currencies, Iranian Toman/Rial support, and Gregorian & Jalali (Shamsi) date pickers.
- **Custom Wallet:** Color-coded cards, drag-and-drop reordering, and balance visibility toggle.

---

## Screenshots

<p align="center">
  <img src="screenshots/en/01_home_wallet.png" width="23%" alt="Home Wallet" />
  <img src="screenshots/en/02_record_purchase.png" width="23%" alt="Record Purchase" />
  <img src="screenshots/en/03_card_details.png" width="23%" alt="Card Details" />
  <img src="screenshots/en/04_settings.png" width="23%" alt="Settings" />
</p>

---

## Tech Stack

- **Framework:** Flutter (Dart 3)
- **State Management:** Riverpod (`flutter_riverpod`)
- **Navigation:** GoRouter
- **Database:** SQLite (`sqflite`) with field-level cipher
- **Security:** `flutter_secure_storage`, `cryptography`, `local_auth`
- **Typography:** Vazirmatn

---

## Building from Source

Presets configure market defaults (language, currency, calendar) at compile time via `--dart-define-from-file`:

### Google Play Store (English · USD · Gregorian)
```bash
flutter build appbundle --dart-define-from-file=config/playstore.json
```

### Cafe Bazaar (Persian · Toman · Jalali)
```bash
flutter build apk --dart-define-from-file=config/bazaar.json
```

### Myket (Persian · Toman · Jalali)
```bash
flutter build apk --dart-define-from-file=config/myket.json
```

### Development
```bash
flutter run
```

---

## Release Signing

Release builds check for `android/key.properties`:

```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=/path/to/upload-keystore.jks
```

*Note: `key.properties` and `*.jks`/`*.keystore` files are strictly ignored by git and must never be committed.*

---

## Privacy Policy

See [PRIVACY_POLICY.md](PRIVACY_POLICY.md). All data remains strictly on the local device. No user data is collected, stored remotely, or transmitted.
