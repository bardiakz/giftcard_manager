import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:giftcard_manager/l10n/app_localizations.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../../core/auth.dart';
import '../../core/format.dart';
import '../../core/money.dart';
import '../../data/providers.dart';
import 'wallet_card.dart';

const _jalaliMonths = [
  'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
  'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند',
];

/// Jalali date picker in Persian, Material picker otherwise.
Future<DateTime?> pickExpiry(BuildContext context, DateTime? initial) {
  final now = DateTime.now();
  if (!isFa(context)) {
    return showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 15),
    );
  }
  return showDialog<DateTime>(
    context: context,
    builder: (_) => _JalaliPickerDialog(initial: initial ?? now),
  );
}

class _JalaliPickerDialog extends StatefulWidget {
  const _JalaliPickerDialog({required this.initial});
  final DateTime initial;

  @override
  State<_JalaliPickerDialog> createState() => _JalaliPickerDialogState();
}

class _JalaliPickerDialogState extends State<_JalaliPickerDialog> {
  late int _y;
  late int _m;
  late int _d;
  late final int _minYear;

  @override
  void initState() {
    super.initState();
    final j = Jalali.fromDateTime(widget.initial);
    _y = j.year;
    _m = j.month;
    _d = j.day;
    _minYear = Jalali.now().year - 1;
  }

  int get _daysInMonth => Jalali(_y, _m, 1).monthLength;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final years = [for (var y = _minYear; y <= _minYear + 16; y++) y];
    final day = _d.clamp(1, _daysInMonth).toInt();

    return AlertDialog(
      title: Text(l.expiry),
      content: Row(
        children: [
          Expanded(
            child: DropdownButton<int>(
              isExpanded: true,
              value: _y.clamp(years.first, years.last).toInt(),
              items: [
                for (final y in years)
                  DropdownMenuItem(
                      value: y, child: Text(toFaDigits('$y'))),
              ],
              onChanged: (v) => setState(() => _y = v!),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: DropdownButton<int>(
              value: _m,
              isExpanded: true,
              items: [
                for (var m = 1; m <= 12; m++)
                  DropdownMenuItem(value: m, child: Text(_jalaliMonths[m - 1])),
              ],
              onChanged: (v) => setState(() => _m = v!),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<int>(
              isExpanded: true,
              value: day,
              items: [
                for (var d = 1; d <= _daysInMonth; d++)
                  DropdownMenuItem(value: d, child: Text(toFaDigits('$d'))),
              ],
              onChanged: (v) => setState(() => _d = v!),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, Jalali(_y, _m, day).toDateTime()),
          child: Text(l.save),
        ),
      ],
    );
  }
}

class CardFormPage extends ConsumerStatefulWidget {
  const CardFormPage({super.key, this.editId});
  final String? editId;

  @override
  ConsumerState<CardFormPage> createState() => _CardFormPageState();
}

class _CardFormPageState extends ConsumerState<CardFormPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _number = TextEditingController();
  final _pin = TextEditingController();
  final _amount = TextEditingController();

  Currency _currency = Currency.irr;
  int _color = 0;
  DateTime? _expiry;
  bool _hidePin = true;
  bool _loading = false;
  bool _saving = false;

  bool get _editing => widget.editId != null;

  @override
  void initState() {
    super.initState();
    if (_editing) {
      _loading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _number.dispose();
    _pin.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    final l = AppLocalizations.of(context)!;
    final view = ref
        .read(cardsProvider)
        .valueOrNull
        ?.where((v) => v.card.id == widget.editId)
        .firstOrNull;
    if (view == null) {
      if (mounted) context.pop();
      return;
    }
    final c = view.card;
    if ((c.hasNumber || c.hasPin) && !await Auth.require(l.revealReason)) {
      if (mounted) context.pop();
      return;
    }
    final s = await ref.read(dbProvider).secrets(c.id);
    if (!mounted) return;
    setState(() {
      _name.text = c.name;
      _number.text = s.number;
      _pin.text = s.pin;
      _currency = c.currency;
      _color = c.colorIndex;
      _expiry = c.expiry;
      _loading = false;
    });
  }

  Future<void> _save(IranUnit unit) async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final actions = ref.read(actionsProvider);
    if (_editing) {
      await actions.updateCard(
        id: widget.editId!,
        name: _name.text.trim(),
        colorIndex: _color,
        expiry: _expiry,
        number: _number.text.trim(),
        pin: _pin.text.trim(),
      );
    } else {
      await actions.addCard(
        name: _name.text.trim(),
        currencyCode: _currency.code,
        colorIndex: _color,
        initialMinor: parseInput(_amount.text, _currency, unit)!,
        expiry: _expiry,
        number: _number.text.trim(),
        pin: _pin.text.trim(),
      );
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final fmt = moneyFormatOf(context, ref);
    final fa = isFa(context);
    final scheme = Theme.of(context).colorScheme;
    const gap = SizedBox(height: 16);

    return Scaffold(
      appBar: AppBar(title: Text(_editing ? l.editCard : l.addCard)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  TextFormField(
                    controller: _name,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: l.cardName),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? l.fieldRequired : null,
                  ),
                  gap,
                  DropdownButtonFormField<Currency>(
                    initialValue: _currency,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: l.currency),
                    items: [
                      for (final c in Currency.all)
                        DropdownMenuItem(
                          value: c,
                          child: Text('${c.code} · ${c.name(fa)}'),
                        ),
                    ],
                    onChanged:
                        _editing ? null : (v) => setState(() => _currency = v!),
                  ),
                  if (_currency.isIranian) ...[
                    gap,
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<IranUnit>(
                        segments: [
                          ButtonSegment(
                              value: IranUnit.toman, label: Text(l.toman)),
                          ButtonSegment(
                              value: IranUnit.rial, label: Text(l.rial)),
                        ],
                        selected: {fmt.unit},
                        onSelectionChanged: (s) => ref
                            .read(settingsProvider.notifier)
                            .setIranUnit(s.first),
                      ),
                    ),
                  ],
                  if (!_editing) ...[
                    gap,
                    TextFormField(
                      controller: _amount,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: InputDecoration(
                        labelText: l.startingCredit,
                        suffixText: fmt.unitLabel(_currency).trim(),
                      ),
                      validator: (v) {
                        final n = parseInput(v ?? '', _currency, fmt.unit);
                        return (n == null || n <= 0) ? l.invalidAmount : null;
                      },
                    ),
                  ],
                  gap,
                  Text(l.color, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (var i = 0; i < cardPalette.length; i++)
                        Semantics(
                          button: true,
                          selected: _color == i,
                          label: '${l.color} ${i + 1}',
                          child: GestureDetector(
                            onTap: () => setState(() => _color = i),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient:
                                    LinearGradient(colors: cardPalette[i]),
                                border: _color == i
                                    ? Border.all(
                                        color: scheme.onSurface, width: 3)
                                    : null,
                              ),
                              child: _color == i
                                  ? const Icon(Icons.check,
                                      size: 20, color: Colors.white)
                                  : null,
                            ),
                          ),
                        ),
                    ],
                  ),
                  gap,
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event_outlined),
                    title: Text(_expiry == null
                        ? l.noExpiry
                        : l.expiresOn(fmtDate(_expiry!, fa: fa))),
                    trailing: _expiry == null
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _expiry = null),
                          ),
                    onTap: () async {
                      final d = await pickExpiry(context, _expiry);
                      if (d != null) setState(() => _expiry = d);
                    },
                  ),
                  gap,
                  TextFormField(
                    controller: _number,
                    textDirection: TextDirection.ltr,
                    autocorrect: false,
                    enableSuggestions: false,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: l.cardNumber),
                  ),
                  gap,
                  TextFormField(
                    controller: _pin,
                    textDirection: TextDirection.ltr,
                    obscureText: _hidePin,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      labelText: l.secretCode,
                      suffixIcon: IconButton(
                        icon: Icon(_hidePin
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _hidePin = !_hidePin),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: _saving ? null : () => _save(fmt.unit),
                    child: Text(l.save),
                  ),
                ],
              ),
            ),
    );
  }
}
