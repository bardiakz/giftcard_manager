#!/usr/bin/env bash
set -euo pipefail
SRC="${1:?usage: bash setup.sh <path-to-unzipped-giftcard_manager>}"
[ -f pubspec.yaml ] && [ -d android ] || { echo "Run this inside the flutter create project"; exit 1; }

# Dart sources, tests, config (replaces the generated lib/ and test/)
rm -rf lib test
cp -r "$SRC/lib" lib
cp -r "$SRC/test" test
cp "$SRC/pubspec.yaml" "$SRC/l10n.yaml" "$SRC/analysis_options.yaml" .
mkdir -p assets/fonts

# Vazirmatn font (if a download fails, add the file by hand)
base=https://raw.githubusercontent.com/rastikerdar/vazirmatn/master/fonts/ttf
for w in Regular Medium Bold; do
  [ -f "assets/fonts/Vazirmatn-$w.ttf" ] || \
    curl -fsSL "$base/Vazirmatn-$w.ttf" -o "assets/fonts/Vazirmatn-$w.ttf" || \
    echo "!! Could not download Vazirmatn-$w.ttf - put it in assets/fonts/ manually"
done

# MainActivity: keep the generated package line, swap in FlutterFragmentActivity + FLAG_SECURE
KT=$(find android/app/src/main -name MainActivity.kt | head -n1)
[ -n "$KT" ] || { echo "MainActivity.kt not found (Java template?)"; exit 1; }
PKG=$(grep -m1 '^package ' "$KT")
{ echo "$PKG"; echo; grep -v '^//' "$SRC/android_notes/MainActivity.kt"; } > "$KT"

# Manifest: biometric permission, Persian app label, no backups
MF=android/app/src/main/AndroidManifest.xml
grep -q USE_BIOMETRIC "$MF" || perl -0pi -e 's|<application|<uses-permission android:name="android.permission.USE_BIOMETRIC"/>\n    <application|' "$MF"
perl -0pi -e 's|android:label="[^"]*"|android:label="کارت‌های هدیه"|' "$MF"
grep -q allowBackup "$MF" || perl -0pi -e 's|<application|<application\n        android:allowBackup="false"\n        android:fullBackupContent="false"|' "$MF"

# minSdk 23 (flutter_secure_storage)
for g in android/app/build.gradle.kts android/app/build.gradle; do
  [ -f "$g" ] && perl -pi -e 's/flutter\.minSdkVersion/23/' "$g"
done

flutter pub get
echo "Done. Next: flutter analyze && flutter test && flutter run"
