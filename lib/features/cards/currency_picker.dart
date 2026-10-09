import 'package:flutter/material.dart';
import 'package:giftcard_manager/l10n/app_localizations.dart';

import '../../core/format.dart';
import '../../core/money.dart';

/// Searchable currency list. Common currencies are pinned on top.
Future<Currency?> pickCurrency(BuildContext context, Currency selected) =>
    showModalBottomSheet<Currency>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _CurrencySheet(selected: selected),
    );

class _CurrencySheet extends StatefulWidget {
  const _CurrencySheet({required this.selected});
  final Currency selected;

  @override
  State<_CurrencySheet> createState() => _CurrencySheetState();
}

class _CurrencySheetState extends State<_CurrencySheet> {
  static const _pinned = ['IRR', 'USD', 'EUR', 'GBP', 'AED', 'TRY'];

  String _query = '';

  // Treat Arabic ي/ك as the Persian ی/ک so either keyboard finds matches.
  String _norm(String s) =>
      s.toLowerCase().replaceAll('ي', 'ی').replaceAll('ك', 'ک');

  bool _matches(Currency c, String q) =>
      q.isEmpty || _norm('${c.code} ${c.nameEn} ${c.nameFa}').contains(q);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final fa = isFa(context);
    final scheme = Theme.of(context).colorScheme;
    final q = _norm(_query.trim());

    final pinned = [
      for (final code in _pinned)
        if (_matches(Currency.byCode(code), q)) Currency.byCode(code),
    ];
    final rest = Currency.all
        .where((c) => !_pinned.contains(c.code) && _matches(c, q))
        .toList()
      ..sort((a, b) => a.code.compareTo(b.code));
    final items = [...pinned, ...rest];

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              autofocus: false,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: '${l.currency} · ${l.search}',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Icon(Icons.search_off, size: 48))
                : ListView.builder(
                    controller: controller,
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final c = items[i];
                      final selected = c == widget.selected;
                      final lastPinned = q.isEmpty && i == pinned.length - 1;
                      return Column(
                        children: [
                          ListTile(
                            selected: selected,
                            leading: SizedBox(
                              width: 52,
                              child: Text(
                                c.code,
                                textDirection: TextDirection.ltr,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            title: Text(c.name(fa)),
                            subtitle: fa && !c.isIranian ? Text(c.nameEn) : null,
                            trailing: selected
                                ? Icon(Icons.check, color: scheme.primary)
                                : null,
                            onTap: () => Navigator.pop(context, c),
                          ),
                          if (lastPinned) const Divider(height: 1),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
