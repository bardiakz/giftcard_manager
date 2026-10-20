import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/app_preset.dart';
import 'data/database.dart';
import 'data/providers.dart';

/// Common bootstrap procedure across all market flavors and entry points.
Future<void> runGiftCardApp(AppPreset preset) async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final db = await AppDatabase.open();
  runApp(
    ProviderScope(
      overrides: [
        presetProvider.overrideWithValue(preset),
        prefsProvider.overrideWithValue(prefs),
        dbProvider.overrideWithValue(db),
      ],
      child: const GiftCardApp(),
    ),
  );
}

Future<void> main() async {
  await runGiftCardApp(AppPreset.fromEnvironment());
}
