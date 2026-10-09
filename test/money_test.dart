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
