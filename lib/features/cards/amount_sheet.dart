import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:giftcard_manager/l10n/app_localizations.dart';

import '../../core/format.dart';
import '../../core/money.dart';
import '../../data/models.dart';
import '../../data/providers.dart';

enum AmountMode { spend, topUp }

/// Returns the id of the created ledger entry, or null if dismissed.
Future<String?> showAmountSheet(
  BuildContext context,
  CardView view,
  AmountMode mode,
) =>
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => AmountSheet(view: view, mode: mode),
    );

class AmountSheet extends ConsumerStatefulWidget {
  const AmountSheet({super.key, required this.view, required this.mode});
  final CardView view;
  final AmountMode mode;

  @override
  ConsumerState<AmountSheet> createState() => _AmountSheetState();
}

class _AmountSheetState extends ConsumerState<AmountSheet> {
  static const _maxDigits = 12;

  String _digits = '';
  int? _exact; // set by "Spend all" so odd Rial remainders aren't lost
  bool _busy = false;
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  bool get _isSpend => widget.mode == AmountMode.spend;

  void _press(String d) {
    setState(() {
      _exact = null;
      final next = (_digits + d).replaceFirst(RegExp(r'^0+'), '');
      if (next.length <= _maxDigits) _digits = next;
    });
  }

  void _backspace() => setState(() {
        _exact = null;
        if (_digits.isNotEmpty) {
          _digits = _digits.substring(0, _digits.length - 1);
        }
      });

  Future<void> _confirm(int minor) async {
    setState(() => _busy = true);
    try {
      final e = await ref.read(actionsProvider).addEntry(
            widget.view.card.id,
            _isSpend ? EntryType.spend : EntryType.topUp,
            _isSpend ? -minor : minor,
            note: _note.text.trim(),
          );
      if (mounted) Navigator.of(context).pop(e.id);
    } on InsufficientBalance {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _key(String label, VoidCallback onTap,
      {VoidCallback? onLong, IconData? icon}) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: SizedBox(
          height: 56,
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: scheme.surfaceContainerHighest,
              foregroundColor: scheme.onSurface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            onLongPress: onLong,
            child: icon != null
                ? Icon(icon)
                : Text(label, style: Theme.of(context).textTheme.titleLarge),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final fmt = moneyFormatOf(context, ref);
    final cur = widget.view.card.currency;
    final scheme = Theme.of(context).colorScheme;
    final fa = isFa(context);

    final minor = _exact ?? digitsToMinor(_digits, cur, fmt.unit);
    final after =
        _isSpend ? widget.view.balance - minor : widget.view.balance + minor;
    final invalid = minor <= 0 || after < 0;
    String label(String d) => fa ? toFaDigits(d) : d;

    Widget row(List<String> keys) => Row(
          children: [for (final k in keys) _key(label(k), () => _press(k))],
        );

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_isSpend ? l.spend : l.topUp,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(
              fmt.format(minor, cur),
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              l.balanceAfter(fmt.format(after, cur)),
              style: TextStyle(
                color: after < 0 ? scheme.error : scheme.onSurfaceVariant,
              ),
            ),
            if (_isSpend)
              TextButton(
                onPressed: widget.view.balance > 0
                    ? () => setState(() {
                          _digits = '';
                          _exact = widget.view.balance;
                        })
                    : null,
                child: Text(l.spendAll),
              ),
            const SizedBox(height: 8),
            TextField(
              controller: _note,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: l.noteOptional,
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            row(['1', '2', '3']),
            row(['4', '5', '6']),
            row(['7', '8', '9']),
            Row(
              children: [
                _key(label('00'), () => _press('00')),
                _key(label('0'), () => _press('0')),
                _key('', _backspace,
                    icon: Icons.backspace_outlined,
                    onLong: () => setState(() {
                          _exact = null;
                          _digits = '';
                        })),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: invalid || _busy ? null : () => _confirm(minor),
                child: Text(l.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
