import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftcard_manager/data/models.dart';
import 'package:giftcard_manager/data/providers.dart';
import 'package:giftcard_manager/features/cards/home_page.dart';
import 'package:giftcard_manager/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeCardsNotifier extends CardsNotifier {
  _FakeCardsNotifier(this._cards);
  final List<CardView> _cards;

  @override
  Future<List<CardView>> build() async => _cards;
}

void main() {
  group('totalBalanceId and visibility provider', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('toggles total balance visibility with maskBalances false', () {
      final container = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(balanceVisibilityProvider.notifier);

      expect(container.read(balanceVisibilityProvider)[totalBalanceId], isNull);

      notifier.toggle(totalBalanceId);
      expect(
          container.read(balanceVisibilityProvider)[totalBalanceId], isFalse);

      notifier.toggle(totalBalanceId);
      expect(container.read(balanceVisibilityProvider)[totalBalanceId], isTrue);
    });

    test('toggles and auto-hides total balance when maskBalances is true', () {
      final container = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      container.read(settingsProvider.notifier).setMaskBalances(true);

      final notifier = container.read(balanceVisibilityProvider.notifier);
      expect(container.read(balanceVisibilityProvider)[totalBalanceId], isNull);

      notifier.toggle(totalBalanceId);
      expect(container.read(balanceVisibilityProvider)[totalBalanceId], isTrue);
    });
  });

  group('HomePage totals visibility widget tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    Widget buildTestApp({
      required List<CardView> cards,
      bool maskBalances = false,
    }) {
      return ProviderScope(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          cardsProvider.overrideWith(() => _FakeCardsNotifier(cards)),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            if (maskBalances) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(settingsProvider.notifier).setMaskBalances(true);
              });
            }
            return const MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('en'),
              home: Scaffold(body: HomePage()),
            );
          },
        ),
      );
    }

    testWidgets('toggles total visibility via eye button and chip',
        (tester) async {
      final card = GiftCard(
        id: 'c1',
        name: 'Amazon',
        currencyCode: 'USD',
        colorIndex: 0,
        createdAt: DateTime.now(),
      );
      final cards = [CardView(card, 5000, 5000)];

      await tester.pumpWidget(buildTestApp(cards: cards));
      await tester.pumpAndSettle();

      // Initially unmasked: balance should be shown
      expect(find.text(r'$50.00'), findsWidgets);
      expect(find.byIcon(Icons.visibility_off_outlined), findsWidgets);

      // Tap the total eye button (the first visibility icon on the page)
      final totalEyeButton = find.byTooltip('Hide balance').first;
      await tester.tap(totalEyeButton);
      await tester.pumpAndSettle();

      // Total chip is now masked
      expect(find.text('••••••'), findsWidgets);

      // Tap the ActionChip to unmask
      await tester.tap(find.byType(ActionChip).first);
      await tester.pumpAndSettle();

      // Unmasked again
      expect(find.text(r'$50.00'), findsWidgets);
    });

    testWidgets('unmasks total balance when maskBalances is true initially',
        (tester) async {
      await prefs.setBool('mask_balances', true);
      final card = GiftCard(
        id: 'c1',
        name: 'Amazon',
        currencyCode: 'USD',
        colorIndex: 0,
        createdAt: DateTime.now(),
      );
      final cards = [CardView(card, 5000, 5000)];

      await tester.pumpWidget(buildTestApp(cards: cards));
      await tester.pumpAndSettle();

      // Total chips and card balances start masked
      expect(find.text('••••••'), findsWidgets);

      // Tap the total eye button (tooltip is 'Show balance')
      final totalEyeButton = find.byTooltip('Show balance').first;
      await tester.tap(totalEyeButton);
      await tester.pumpAndSettle();

      // Total balance is unmasked
      expect(find.text(r'$50.00'), findsWidgets);
    });
  });
}
