import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:giftcard_manager/l10n/app_localizations.dart';

import '../../core/auth.dart';
import '../../core/format.dart';
import '../../core/input_formatters.dart';
import '../../core/money.dart';
import '../../data/providers.dart';
import 'currency_picker.dart';
import 'date_picker.dart';
import 'wallet_card.dart';

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
  String _calendar = 'gregorian';
  bool _hidePin = true;
  bool _loading = false;
  bool _saving = false;

  bool get _editing => widget.editId != null;

  @override
  void initState() {
    super.initState();
    // New cards start with the default calendar from Settings.
    _calendar = ref.read(settingsProvider).calendar;
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
      _calendar = c.calendar;
      _loading = false;
    });
  }

  /// Decimal digits allowed when typing an amount. Iranian amounts are typed
  /// as whole Toman/Rial.
  int _decimalsFor(Currency c) => c.isIranian ? 0 : c.digits;

  /// Re-applies the separators after the currency (and so the allowed
  /// decimals) changed.
  void _reformatAmount(bool fa) {
    final f =
        AmountInputFormatter(decimals: _decimalsFor(_currency), persian: fa);
    _amount.value = f.formatEditUpdate(TextEditingValue.empty, _amount.value);
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
        calendar: _calendar,
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
        calendar: _calendar,
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
    final jalali = _calendar == 'jalali';
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
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l.fieldRequired
                        : null,
                  ),
                  gap,
                  InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: _editing
                        ? null
                        : () async {
                            final c = await pickCurrency(context, _currency);
                            if (c != null) {
                              setState(() => _currency = c);
                              _reformatAmount(fa);
                            }
                          },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l.currency,
                        enabled: !_editing,
                        suffixIcon:
                            _editing ? null : const Icon(Icons.arrow_drop_down),
                      ),
                      child: Text(
                        '${_currency.code} · ${_currency.name(fa)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
                      keyboardType: TextInputType.numberWithOptions(
                          decimal: _decimalsFor(_currency) > 0),
                      inputFormatters: [
                        AmountInputFormatter(
                            decimals: _decimalsFor(_currency), persian: fa),
                      ],
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
                  Text(l.calendar,
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                            value: 'gregorian',
                            label: Text(l.calendarGregorian)),
                        ButtonSegment(
                            value: 'jalali', label: Text(l.calendarShamsi)),
                      ],
                      selected: {_calendar},
                      onSelectionChanged: (v) =>
                          setState(() => _calendar = v.first),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event_outlined),
                    title: Text(_expiry == null
                        ? l.noExpiry
                        : l.expiresOn(
                            fmtDate(_expiry!, fa: fa, jalali: jalali))),
                    trailing: _expiry == null
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _expiry = null),
                          ),
                    onTap: () async {
                      final d =
                          await pickExpiry(context, _expiry, jalali: jalali);
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
