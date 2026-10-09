import 'format.dart';

/// How Iranian amounts are displayed. Amounts are always *stored* in Rial.
enum IranUnit { toman, rial }

class Currency {
  const Currency(
    this.code,
    this.digits,
    this.symbol,
    this.unitFa,
    this.nameFa,
    this.nameEn,
  );

  final String code;

  /// Number of minor-unit digits (cents). IRR has none.
  final int digits;
  final String symbol;
  final String unitFa;
  final String nameFa;
  final String nameEn;

  bool get isIranian => code == 'IRR';
  String name(bool fa) => fa ? nameFa : nameEn;

  static const irr = Currency(
      'IRR', 0, '', '', 'ایران (تومان / ریال)', 'Iran (Toman / Rial)');
  static const usd = Currency('USD', 2, r'$', 'دلار', 'دلار آمریکا', 'US Dollar');
  static const eur = Currency('EUR', 2, '€', 'یورو', 'یورو', 'Euro');
  static const gbp =
      Currency('GBP', 2, '£', 'پوند', 'پوند انگلیس', 'British Pound');
  static const tryLira =
      Currency('TRY', 2, '₺', 'لیر', 'لیر ترکیه', 'Turkish Lira');
  static const aed =
      Currency('AED', 2, 'AED ', 'درهم', 'درهم امارات', 'UAE Dirham');

  static const all = [irr, usd, eur, gbp, tryLira, aed];

  static Currency byCode(String code) =>
      all.firstWhere((c) => c.code == code, orElse: () => irr);
}

/// Formats minor-unit integers for display.
class MoneyFormat {
  const MoneyFormat({required this.fa, required this.unit});

  final bool fa;
  final IranUnit unit;

  String unitLabel(Currency c) {
    if (c.isIranian) {
      return unit == IranUnit.toman
          ? (fa ? 'تومان' : 'Toman')
          : (fa ? 'ریال' : 'Rial');
    }
    return fa ? c.unitFa : c.symbol;
  }

  /// Number only, no unit, no sign.
  String number(int minor, Currency c) {
    final abs = minor.abs();
    String whole;
    var frac = '';
    if (c.isIranian) {
      if (unit == IranUnit.toman) {
        whole = (abs ~/ 10).toString();
        if (abs % 10 != 0) frac = (abs % 10).toString();
      } else {
        whole = abs.toString();
      }
    } else {
      var p = 1;
      for (var i = 0; i < c.digits; i++) {
        p *= 10;
      }
      whole = (abs ~/ p).toString();
      if (c.digits > 0) frac = (abs % p).toString().padLeft(c.digits, '0');
    }
    var s = groupDigits(whole);
    if (frac.isNotEmpty) s = '$s.$frac';
    return fa ? toFaDigits(s).replaceAll(',', '٬').replaceAll('.', '٫') : s;
  }

  String format(int minor, Currency c) {
    final sign = minor < 0 ? '-' : '';
    final n = number(minor, c);
    final u = unitLabel(c);
    if (c.isIranian || fa) return '$sign$n $u';
    return '$sign$u$n';
  }
}

/// Parses user-typed text (any digit script, any grouping) to minor units.
/// Returns null when the text isn't a valid amount for [c].
int? parseInput(String text, Currency c, IranUnit unit) {
  final t = toEnDigits(text.trim())
      .replaceAll(RegExp('[,\u066C\u060C\\s]'), '')
      .replaceAll('\u066B', '.');
  if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(t)) return null;
  final parts = t.split('.');
  final whole = int.tryParse(parts[0]);
  if (whole == null) return null;
  final frac = parts.length > 1 ? parts[1] : '';

  if (c.isIranian) {
    if (unit == IranUnit.rial) return frac.isEmpty ? whole : null;
    if (frac.isEmpty) return whole * 10;
    return frac.length == 1 ? whole * 10 + int.parse(frac) : null;
  }
  if (frac.length > c.digits) return null;
  var p = 1;
  for (var i = 0; i < c.digits; i++) {
    p *= 10;
  }
  final fracMinor = frac.isEmpty ? 0 : int.parse(frac.padRight(c.digits, '0'));
  return whole * p + fracMinor;
}

/// Terminal-style keypad entry: typing 1,2,5 for USD gives $1.25; for Iranian
/// currency the digits are whole Toman/Rial in the chosen unit.
int digitsToMinor(String digits, Currency c, IranUnit unit) {
  if (digits.isEmpty) return 0;
  final v = int.parse(digits);
  return (c.isIranian && unit == IranUnit.toman) ? v * 10 : v;
}
