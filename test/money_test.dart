import 'package:flutter_test/flutter_test.dart';
import 'package:giftcard_manager/core/format.dart';
import 'package:giftcard_manager/core/money.dart';

void main() {
  const enToman = MoneyFormat(fa: false, unit: IranUnit.toman);
  const enRial = MoneyFormat(fa: false, unit: IranUnit.rial);
  const faToman = MoneyFormat(fa: true, unit: IranUnit.toman);

  group('MoneyFormat', () {
    test('Rial is stored, Toman is displayed /10', () {
      expect(enToman.format(12500, Currency.irr), '1,250 Toman');
      expect(enRial.format(12500, Currency.irr), '12,500 Rial');
    });

    test('Persian digits, separators and unit', () {
      expect(faToman.format(12500, Currency.irr), '۱٬۲۵۰ تومان');
    });

    test('odd Rial remainder is not lost in Toman view', () {
      expect(enToman.format(12505, Currency.irr), '1,250.5 Toman');
    });

    test('foreign currency uses minor units', () {
      expect(enToman.format(1250, Currency.usd), r'$12.50');
      expect(faToman.format(1250, Currency.usd), '۱۲٫۵۰ دلار');
      expect(enToman.format(-1250, Currency.usd), r'-$12.50');
    });
  });

  group('currency table', () {
    test('codes are unique and the common ones exist', () {
      final codes = Currency.all.map((c) => c.code).toList();
      expect(codes.toSet().length, codes.length);
      expect(codes.length, greaterThan(120));
      for (final c in ['IRR', 'USD', 'EUR', 'GBP', 'JPY', 'KWD', 'CAD', 'AED']) {
        expect(codes, contains(c));
      }
    });

    test('minor digits follow ISO 4217', () {
      expect(Currency.byCode('JPY').digits, 0);
      expect(Currency.byCode('KWD').digits, 3);
      expect(Currency.byCode('EUR').digits, 2);
    });

    test('lookup is stable and equal by code', () {
      expect(Currency.byCode('USD'), Currency.usd);
      expect(Currency.byCode('EUR'), Currency.byCode('EUR'));
    });

    test('formatting: symbols attach, codes get a space', () {
      expect(enToman.format(1250, Currency.byCode('JPY')), '¥1,250');
      expect(enToman.format(12345, Currency.byCode('KWD')), 'KWD 12.345');
      expect(enToman.format(1250, Currency.byCode('EUR')), '€12.50');
      expect(faToman.format(1250, Currency.byCode('GBP')), '۱۲٫۵۰ پوند');
    });

    test('parsing respects the currency decimals', () {
      expect(parseInput('1500', Currency.byCode('JPY'), IranUnit.toman), 1500);
      expect(parseInput('1.5', Currency.byCode('JPY'), IranUnit.toman), isNull);
      expect(parseInput('1.234', Currency.byCode('KWD'), IranUnit.toman), 1234);
    });
  });

  group('parseInput', () {
    test('accepts Persian digits and separators', () {
      expect(parseInput('۱۲٬۵۰۰', Currency.irr, IranUnit.toman), 125000);
      expect(parseInput('1,250', Currency.irr, IranUnit.rial), 1250);
    });

    test('decimals follow the currency', () {
      expect(parseInput('12.5', Currency.usd, IranUnit.toman), 1250);
      expect(parseInput('12.555', Currency.usd, IranUnit.toman), isNull);
      expect(parseInput('1.5', Currency.irr, IranUnit.toman), 15);
      expect(parseInput('1.5', Currency.irr, IranUnit.rial), isNull);
    });

    test('rejects garbage', () {
      expect(parseInput('abc', Currency.irr, IranUnit.toman), isNull);
      expect(parseInput('', Currency.irr, IranUnit.toman), isNull);
    });
  });

  group('keypad entry', () {
    test('digitsToMinor', () {
      expect(digitsToMinor('1250', Currency.usd, IranUnit.toman), 1250);
      expect(digitsToMinor('500', Currency.irr, IranUnit.toman), 5000);
      expect(digitsToMinor('500', Currency.irr, IranUnit.rial), 500);
      expect(digitsToMinor('', Currency.irr, IranUnit.toman), 0);
    });
  });

  group('digits', () {
    test('conversion both ways', () {
      expect(toFaDigits('1,250.5'), '۱,۲۵۰.۵');
      expect(toEnDigits('۱۲٣'), '123');
    });
  });
}
