import 'package:flutter_test/flutter_test.dart';
import 'package:giftcard_manager/core/format.dart';

void main() {
  // Nowruz 1400 fell on 21 March 2021.
  final nowruz = DateTime(2021, 3, 21);

  test('Shamsi vs Gregorian', () {
    expect(fmtDate(nowruz, fa: false, jalali: true), '1400/01/01');
    expect(fmtDate(nowruz, fa: false, jalali: false), '2021-03-21');
  });

  test('digits follow the language, calendar follows the setting', () {
    expect(fmtDate(nowruz, fa: true, jalali: true), '۱۴۰۰/۰۱/۰۱');
    expect(fmtDate(nowruz, fa: true, jalali: false), '۲۰۲۱-۰۳-۲۱');
  });

  test('date and time', () {
    final d = DateTime(2021, 3, 21, 9, 5);
    expect(fmtDateTime(d, fa: false, jalali: true), '1400/01/01  09:05');
    expect(fmtDateTime(d, fa: true, jalali: true), '۱۴۰۰/۰۱/۰۱  ۰۹:۰۵');
  });
}
