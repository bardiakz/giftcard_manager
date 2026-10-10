import 'package:flutter/services.dart';

import 'format.dart';

/// Live thousands separators for amount fields: typing 1234567 shows
/// 1,234,567 (or ۱٬۲۳۴٬۵۶۷ when [persian] is true).
///
/// - Accepts Latin, Persian and Arabic-Indic digits.
/// - Allows at most one decimal separator ('.' or '٫') and at most [decimals]
///   fraction digits (none when [decimals] is 0).
/// - Keeps the cursor next to the digit it was next to, and backspace over a
///   separator also removes the digit before it.
class AmountInputFormatter extends TextInputFormatter {
  const AmountInputFormatter({required this.decimals, required this.persian});

  final int decimals;
  final bool persian;

  static const _maxIntDigits = 15;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var raw = toEnDigits(newValue.text);
    var cursor = newValue.selection.isValid
        ? newValue.selection.extentOffset
        : raw.length;
    cursor = cursor.clamp(0, raw.length).toInt();

    // Backspace right after a separator: remove the digit before it as well,
    // otherwise nothing would visibly happen.
    if (newValue.selection.isCollapsed &&
        oldValue.selection.isCollapsed &&
        oldValue.selection.baseOffset == cursor + 1 &&
        oldValue.text.length == newValue.text.length + 1 &&
        cursor > 0) {
      final deleted = oldValue.text[cursor];
      if (deleted == ',' || deleted == '٬') {
        raw = raw.substring(0, cursor - 1) + raw.substring(cursor);
        cursor -= 1;
      }
    }

    // Keep only digits and one decimal separator, remembering where each kept
    // character was so the cursor can be placed afterwards.
    final ints = <(String, int)>[];
    final fracs = <(String, int)>[];
    int? dotAt;
    for (var i = 0; i < raw.length; i++) {
      final c = raw[i];
      final code = c.codeUnitAt(0);
      if (code >= 48 && code <= 57) {
        if (dotAt == null) {
          if (ints.length < _maxIntDigits) ints.add((c, i));
        } else if (fracs.length < decimals) {
          fracs.add((c, i));
        }
      } else if ((c == '.' || c == '٫') && decimals > 0 && dotAt == null) {
        dotAt = i;
      }
    }
    while (ints.length > 1 && ints.first.$1 == '0') {
      ints.removeAt(0);
    }

    if (ints.isEmpty && dotAt == null) return const TextEditingValue();

    var text = ints.isEmpty ? '0' : groupDigits(ints.map((e) => e.$1).join());
    if (dotAt != null) text = '$text.${fracs.map((e) => e.$1).join()}';

    // Cursor: keep the same number of digits/decimal-point after it.
    final after = ints.where((e) => e.$2 >= cursor).length +
        fracs.where((e) => e.$2 >= cursor).length +
        ((dotAt != null && dotAt >= cursor) ? 1 : 0);
    var pos = text.length;
    var remaining = after;
    while (remaining > 0 && pos > 0) {
      pos--;
      if (text[pos] != ',') remaining--;
    }
    if (pos > 0 && text[pos - 1] == ',') pos--;

    if (persian) {
      text = toFaDigits(text).replaceAll(',', '٬').replaceAll('.', '٫');
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: pos),
    );
  }
}
