import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giftcard_manager/core/input_formatters.dart';

TextEditingValue v(String text, [int? cursor]) => TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: cursor ?? text.length),
    );

void main() {
  const whole = AmountInputFormatter(decimals: 0, persian: false);
  const cents = AmountInputFormatter(decimals: 2, persian: false);
  const faWhole = AmountInputFormatter(decimals: 0, persian: true);

  test('groups every three digits', () {
    final r = whole.formatEditUpdate(v(''), v('1234'));
    expect(r.text, '1,234');
    expect(r.selection.baseOffset, 5);
    expect(
        whole.formatEditUpdate(v('123,456'), v('123,4567')).text, '1,234,567');
  });

  test('Persian output and Persian input', () {
    expect(faWhole.formatEditUpdate(v(''), v('1234567')).text, '۱٬۲۳۴٬۵۶۷');
    expect(whole.formatEditUpdate(v(''), v('۱۲۳۴')).text, '1,234');
  });

  test('decimals are limited and only one separator is kept', () {
    expect(cents.formatEditUpdate(v(''), v('1234.567')).text, '1,234.56');
    expect(cents.formatEditUpdate(v(''), v('1.2.3')).text, '1.23');
    expect(cents.formatEditUpdate(v(''), v('12.')).text, '12.');
    expect(cents.formatEditUpdate(v(''), v('.5')).text, '0.5');
    expect(whole.formatEditUpdate(v(''), v('12.5')).text, '125');
  });

  test('leading zeros and empty input', () {
    expect(whole.formatEditUpdate(v(''), v('007')).text, '7');
    expect(whole.formatEditUpdate(v('1'), v('')).text, '');
  });

  test('cursor stays next to the edited digit', () {
    // "1,234" with the cursor after the 1, user types 9 -> "19,234" with the
    // cursor right after the 9.
    final r = whole.formatEditUpdate(v('1,234', 1), v('19,234', 2));
    expect(r.text, '19,234');
    expect(r.selection.baseOffset, 2);
  });

  test('backspace over a separator removes the digit before it', () {
    // "1,234", cursor after the comma, backspace.
    final r = whole.formatEditUpdate(v('1,234', 2), v('1234', 1));
    expect(r.text, '234');
    expect(r.selection.baseOffset, 0);
  });
}
