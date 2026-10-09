import 'package:flutter_test/flutter_test.dart';
import 'package:giftcard_manager/data/models.dart';

Entry entry(String id, EntryType t, int delta, {String? ref}) => Entry(
      id: id,
      cardId: 'c',
      type: t,
      delta: delta,
      createdAt: DateTime(2026),
      refId: ref,
    );

void main() {
  final initial = entry('i', EntryType.initial, 100000);
  final spend = entry('s1', EntryType.spend, -25000);
  final topUp = entry('t1', EntryType.topUp, 5000);

  group('ledger', () {
    test('balance is the sum of deltas', () {
      expect(balanceOf([initial, spend, topUp]), 80000);
    });

    test('a reversal restores the balance and marks the entry reversed', () {
      final rev = entry('r1', EntryType.reversal, 25000, ref: 's1');
      expect(balanceOf([initial, spend, rev]), 100000);
      expect(reversedIds([initial, spend, rev]), {'s1'});
    });

    test('canReverse rules', () {
      final rev = entry('r1', EntryType.reversal, 25000, ref: 's1');
      final reversed = reversedIds([initial, spend, rev]);
      expect(canReverse(initial, reversed), isFalse);
      expect(canReverse(rev, reversed), isFalse);
      expect(canReverse(spend, reversed), isFalse);
      expect(canReverse(topUp, reversed), isTrue);
    });

    test('entry survives a map round trip', () {
      final back = Entry.fromMap(spend.toMap());
      expect(back.id, spend.id);
      expect(back.type, EntryType.spend);
      expect(back.delta, -25000);
    });
  });

  group('CardView', () {
    final card = GiftCard(
      id: 'c',
      name: 'Test',
      currencyCode: 'IRR',
      colorIndex: 0,
      createdAt: DateTime(2026),
    );
    test('ratio is balance / funded, clamped', () {
      expect(CardView(card, 50, 200).ratio, 0.25);
      expect(CardView(card, 0, 0).ratio, 0);
      expect(CardView(card, 300, 200).ratio, 1);
    });
  });

  group('expiry', () {
    final now = DateTime(2026, 10, 8);
    test('states', () {
      expect(expiryOf(null, now: now).state, ExpiryState.none);
      expect(expiryOf(DateTime(2026, 10, 7), now: now).state,
          ExpiryState.expired);
      expect(
          expiryOf(DateTime(2026, 10, 8), now: now).state, ExpiryState.today);
      final soon = expiryOf(DateTime(2026, 10, 20), now: now);
      expect(soon.state, ExpiryState.soon);
      expect(soon.days, 12);
      expect(expiryOf(DateTime(2026, 12, 1), now: now).state, ExpiryState.ok);
    });
  });
}
