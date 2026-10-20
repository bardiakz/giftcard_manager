import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftcard_manager/data/models.dart';
import 'package:giftcard_manager/data/providers.dart';
import 'package:giftcard_manager/features/cards/wallet_card.dart';
import 'package:giftcard_manager/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('WalletCard layout and overflow tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    for (final locale in [const Locale('en'), const Locale('fa')]) {
      for (final scale in [1.0, 1.15, 1.3, 1.5]) {
        testWidgets(
            'renders without overflow in ${locale.languageCode} at scale $scale',
            (tester) async {
          final card = GiftCard(
            id: 'test-card-1',
            name: 'Amazon Gift Card',
            currencyCode: 'USD',
            colorIndex: 0,
            createdAt: DateTime.now(),
            expiry: DateTime.now().add(const Duration(days: 2)),
          );
          final view = CardView(card, 5000, 5000);

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                prefsProvider.overrideWithValue(prefs),
              ],
              child: MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: locale,
                theme: ThemeData(
                  useMaterial3: true,
                  fontFamily: 'Vazirmatn',
                ),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(scale),
                  ),
                  child: child!,
                ),
                home: Scaffold(
                  body: Center(
                    child: WalletCard(
                      view: view,
                      onQuickSpend: () {},
                      onMore: () {},
                    ),
                  ),
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}
