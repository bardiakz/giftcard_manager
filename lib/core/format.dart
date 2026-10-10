import 'package:flutter/widgets.dart';
import 'package:shamsi_date/shamsi_date.dart';

const _latin = '0123456789';
const _persian = '۰۱۲۳۴۵۶۷۸۹';
const _arabic = '٠١٢٣٤٥٦٧٨٩';

/// Latin digits -> Persian digits.
String toFaDigits(String s) {
  final b = StringBuffer();
  for (final r in s.runes) {
    final ch = String.fromCharCode(r);
    final i = _latin.indexOf(ch);
    b.write(i >= 0 ? _persian[i] : ch);
  }
  return b.toString();
}

/// Persian / Arabic-Indic digits -> Latin digits.
String toEnDigits(String s) {
  final b = StringBuffer();
  for (final r in s.runes) {
    final ch = String.fromCharCode(r);
    var i = _persian.indexOf(ch);
    if (i < 0) i = _arabic.indexOf(ch);
    b.write(i >= 0 ? _latin[i] : ch);
  }
  return b.toString();
}

String groupDigits(String digits) => digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );

bool isFa(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'fa';

/// Formats a number for display in the current language's digits.
String localDigits(BuildContext context, Object value) =>
    isFa(context) ? toFaDigits('$value') : '$value';

String _p2(int n) => n.toString().padLeft(2, '0');

/// Date as Shamsi (Jalali) or Gregorian, in Persian or Latin digits.
/// [fa] only controls the digits; [jalali] controls the calendar.
String fmtDate(DateTime d, {required bool fa, required bool jalali}) {
  final String text;
  if (jalali) {
    final j = Jalali.fromDateTime(d);
    text = '${j.year}/${_p2(j.month)}/${_p2(j.day)}';
  } else {
    text = '${d.year}-${_p2(d.month)}-${_p2(d.day)}';
  }
  return fa ? toFaDigits(text) : text;
}

String fmtDateTime(DateTime d, {required bool fa, required bool jalali}) {
  final time = '${_p2(d.hour)}:${_p2(d.minute)}';
  return '${fmtDate(d, fa: fa, jalali: jalali)}  ${fa ? toFaDigits(time) : time}';
}
