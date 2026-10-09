import 'currency_table.dart';
import 'format.dart';

/// How Iranian amounts are displayed. Amounts are always *stored* in Rial.
enum IranUnit { toman, rial }

class Currency {
  const Currency(
    this.code,
    this.digits,
    this.symbol,
    this.nameEn,
    this.nameFa, {
    String? unitFa,
  }) : unitFa = unitFa ?? nameFa;

  final String code;

  /// Number of minor-unit digits (cents). IRR/JPY have none, KWD has three.
  final int digits;

  /// Symbol used in English ("$"); equals the ISO code when there is no
  /// unambiguous symbol.
  final String symbol;
  final String nameEn;
  final String nameFa;

  /// Label shown after the amount in Persian ("دلار").
  final String unitFa;

  bool get isIranian => code == 'IRR';
  String name(bool fa) => fa ? nameFa : nameEn;

  @override
  bool operator ==(Object other) => other is Currency && other.code == code;

  @override
  int get hashCode => code.hashCode;

  static const irr = Currency(
      'IRR', 0, '', 'Iran (Toman / Rial)', 'ایران (تومان / ریال)');
  static const usd =
      Currency('USD', 2, r'$', 'US Dollar', 'دلار آمریکا', unitFa: 'دلار');

  /// IRR and USD first, then the rest of the ISO table.
  static final List<Currency> all = [irr, usd, ..._fromTable(kCurrencyTable)];
  static final Map<String, Currency> _byCode = {for (final c in all) c.code: c};

  static Currency byCode(String code) => _byCode[code] ?? irr;

  static List<Currency> _fromTable(String table) {
    final out = <Currency>[];
    for (final raw in table.split('\n')) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      final p = line.split('|');
      final code = p[0];
      out.add(Currency(
        code,
        int.parse(p[1]),
        p[2].isEmpty ? code : p[2],
        p[3],
        p[4],
        unitFa: (p.length > 5 && p[5].isNotEmpty) ? p[5] : null,
      ));
    }
    return out;
  }
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
    // Letter-only labels (e.g. "KWD") need a space; symbols ("$") don't.
    final gap = RegExp(r'[A-Za-z]$').hasMatch(u) ? ' ' : '';
    return '$sign$u$gap$n';
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
