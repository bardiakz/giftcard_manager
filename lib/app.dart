import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:giftcard_manager/l10n/app_localizations.dart';

import 'data/providers.dart';
import 'features/cards/card_detail_page.dart';
import 'features/cards/card_form_page.dart';
import 'features/cards/home_page.dart';
import 'features/lock/lock_gate.dart';
import 'features/settings/settings_page.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const HomePage(),
      routes: [
        GoRoute(path: 'settings', builder: (_, __) => const SettingsPage()),
        GoRoute(path: 'card/new', builder: (_, __) => const CardFormPage()),
        GoRoute(
          path: 'card/:id',
          builder: (_, s) => CardDetailPage(id: s.pathParameters['id']!),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (_, s) =>
                  CardFormPage(editId: s.pathParameters['id']),
            ),
          ],
        ),
      ],
    ),
  ],
);

ThemeData _theme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF4F46E5),
    brightness: brightness,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'Vazirmatn',
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

class GiftCardApp extends ConsumerWidget {
  const GiftCardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(settingsProvider.select((s) => s.language));
    final mode = ref.watch(settingsProvider.select((s) => s.themeMode));
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      onGenerateTitle: (c) => AppLocalizations.of(c)!.appTitle,
      locale: lang == null ? null : Locale(lang),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // Unsupported device languages fall back to Persian.
      localeResolutionCallback: (device, supported) {
        if (device != null) {
          for (final s in supported) {
            if (s.languageCode == device.languageCode) return s;
          }
        }
        return const Locale('fa');
      },
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: switch (mode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      builder: (context, child) =>
          LockGate(child: child ?? const SizedBox.shrink()),
    );
  }
}
