import 'package:flutter/material.dart';
import 'package:giftcard_manager/l10n/app_localizations.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../core/format.dart';

const _monthsFa = [
  'فروردین',
  'اردیبهشت',
  'خرداد',
  'تیر',
  'مرداد',
  'شهریور',
  'مهر',
  'آبان',
  'آذر',
  'دی',
  'بهمن',
  'اسفند',
];
const _monthsEn = [
  'Farvardin',
  'Ordibehesht',
  'Khordad',
  'Tir',
  'Mordad',
  'Shahrivar',
  'Mehr',
  'Aban',
  'Azar',
  'Dey',
  'Bahman',
  'Esfand',
];
// Persian weeks start on Saturday and end on Friday.
const _weekFa = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];
const _weekEn = ['Sa', 'Su', 'Mo', 'Tu', 'We', 'Th', 'Fr'];

/// Expiry date picker: a Shamsi (Jalali) calendar or the Material Gregorian
/// one, depending on [jalali].
Future<DateTime?> pickExpiry(
  BuildContext context,
  DateTime? initial, {
  required bool jalali,
}) {
  final now = DateTime.now();
  if (jalali) {
    return showDialog<DateTime>(
      context: context,
      builder: (_) => JalaliDatePickerDialog(initial: initial ?? now),
    );
  }
  final first = DateTime(now.year - 5);
  final last = DateTime(now.year + 20);
  var init = initial ?? now;
  if (init.isBefore(first)) init = first;
  if (init.isAfter(last)) init = last;
  return showDatePicker(
    context: context,
    initialDate: init,
    firstDate: first,
    lastDate: last,
  );
}

class JalaliDatePickerDialog extends StatefulWidget {
  const JalaliDatePickerDialog({super.key, required this.initial});
  final DateTime initial;

  @override
  State<JalaliDatePickerDialog> createState() => _JalaliDatePickerDialogState();
}

class _JalaliDatePickerDialogState extends State<JalaliDatePickerDialog> {
  late final Jalali _today;
  late final int _minYear;
  late final int _maxYear;
  late Jalali _selected;
  late int _vy; // visible year
  late int _vm; // visible month (1-12)

  @override
  void initState() {
    super.initState();
    _today = Jalali.now();
    _minYear = _today.year - 5;
    _maxYear = _today.year + 20;
    _selected = Jalali.fromDateTime(widget.initial);
    _vy = _selected.year.clamp(_minYear, _maxYear).toInt();
    _vm = _selected.month;
  }

  void _go(int months) {
    setState(() {
      final idx = _vy * 12 + (_vm - 1) + months;
      var y = idx ~/ 12;
      var m = idx % 12 + 1;
      if (y < _minYear) {
        y = _minYear;
        m = 1;
      }
      if (y > _maxYear) {
        y = _maxYear;
        m = 12;
      }
      _vy = y;
      _vm = m;
    });
  }

  /// Arrow that points toward the start side for "previous" and the end side
  /// for "next", in both LTR and RTL. Drawn LTR so the glyph is never flipped
  /// twice.
  Widget _nav({
    required bool previous,
    required bool double,
    required int months,
  }) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final pointsLeft = previous != rtl;
    final icon = double
        ? (pointsLeft
            ? Icons.keyboard_double_arrow_left
            : Icons.keyboard_double_arrow_right)
        : (pointsLeft ? Icons.chevron_left : Icons.chevron_right);
    return IconButton(
      visualDensity: VisualDensity.compact,
      icon: Directionality(
        textDirection: TextDirection.ltr,
        child: Icon(icon),
      ),
      onPressed: () => _go(months),
    );
  }

  bool _isSelected(int day) =>
      _selected.year == _vy && _selected.month == _vm && _selected.day == day;

  bool _isToday(int day) =>
      _today.year == _vy && _today.month == _vm && _today.day == day;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final fa = isFa(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    String d(int n) => fa ? toFaDigits('$n') : '$n';

    final first = Jalali(_vy, _vm, 1);
    // Saturday = column 0 (DateTime.weekday: Mon=1 ... Sun=7).
    final lead = (first.toDateTime().weekday + 1) % 7;
    final days = first.monthLength;
    final rows = ((lead + days) / 7).ceil();

    Widget cell(int day, int col) {
      if (day < 1 || day > days) return const SizedBox(height: 40);
      final selected = _isSelected(day);
      final today = _isToday(day);
      return Padding(
        padding: const EdgeInsets.all(2),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => setState(() => _selected = Jalali(_vy, _vm, day)),
          child: Container(
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? scheme.primary : null,
              border:
                  today && !selected ? Border.all(color: scheme.primary) : null,
            ),
            child: Text(
              d(day),
              style: TextStyle(
                fontWeight: selected ? FontWeight.w700 : null,
                color: selected
                    ? scheme.onPrimary
                    : (col == 6 ? scheme.error : null), // Friday
              ),
            ),
          ),
        ),
      );
    }

    return AlertDialog(
      title: Text(l.expiry),
      contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _nav(previous: true, double: true, months: -12),
                _nav(previous: true, double: false, months: -1),
                Expanded(
                  child: Text(
                    '${(fa ? _monthsFa : _monthsEn)[_vm - 1]} ${d(_vy)}',
                    textAlign: TextAlign.center,
                    style: text.titleSmall,
                  ),
                ),
                _nav(previous: false, double: false, months: 1),
                _nav(previous: false, double: true, months: 12),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                for (final w in (fa ? _weekFa : _weekEn))
                  Expanded(
                    child: Center(
                      child: Text(
                        w,
                        style: text.labelSmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            for (var r = 0; r < rows; r++)
              Row(
                children: [
                  for (var c = 0; c < 7; c++)
                    Expanded(child: cell(r * 7 + c - lead + 1, c)),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        TextButton(
          onPressed: () => setState(() {
            _selected = _today;
            _vy = _today.year;
            _vm = _today.month;
          }),
          child: Text(l.today),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selected.toDateTime()),
          child: Text(l.save),
        ),
      ],
    );
  }
}
