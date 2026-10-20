import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:giftcard_manager/l10n/app_localizations.dart';

import '../../core/auth.dart';
import '../../core/format.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import 'amount_sheet.dart';
import 'card_dialogs.dart';
import 'wallet_card.dart';

class CardDetailPage extends ConsumerWidget {
  const CardDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final actions = ref.read(actionsProvider);
    final view = ref
        .watch(cardsProvider)
        .valueOrNull
        ?.where((v) => v.card.id == id)
        .firstOrNull;
    if (view == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final card = view.card;
    final entries = ref.watch(entriesProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(card.name),
        actions: [
          IconButton(
            tooltip: l.editCard,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/card/$id/edit'),
          ),
          IconButton(
            tooltip: l.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () => confirmDeleteCard(context, actions, id,
                beforeDelete: () => context.pop()),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          WalletCard(view: view),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: view.balance > 0
                      ? () => recordAmount(context, actions, view, AmountMode.spend)
                      : null,
                  icon: const Icon(Icons.remove),
                  label: Text(l.spend),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () =>
                      recordAmount(context, actions, view, AmountMode.topUp),
                  icon: const Icon(Icons.add),
                  label: Text(l.topUp),
                ),
              ),
            ],
          ),
          if (card.expiry != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  const Icon(Icons.event_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(l.expiresOn(fmtDate(card.expiry!,
                      fa: isFa(context), jalali: card.isJalali))),
                ],
              ),
            ),
          if (card.hasNumber || card.hasPin)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SecretsPanel(cardId: id),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 8),
            child:
                Text(l.history, style: Theme.of(context).textTheme.titleMedium),
          ),
          entries.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('$e'),
            data: (es) => _History(entries: es, view: view),
          ),
        ],
      ),
    );
  }
}

class _History extends ConsumerWidget {
  const _History({required this.entries, required this.view});
  final List<Entry> entries;
  final CardView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final fmt = moneyFormatOf(context, ref);
    final actions = ref.read(actionsProvider);
    final reversed = reversedIds(entries);
    final scheme = Theme.of(context).colorScheme;
    final fa = isFa(context);
    final jalali = view.card.isJalali;

    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: Text(l.noHistory)),
      );
    }

    String label(EntryType t) => switch (t) {
          EntryType.initial => l.entryInitial,
          EntryType.spend => l.entrySpend,
          EntryType.topUp => l.entryTopUp,
          EntryType.adjustment => l.entryAdjustment,
          EntryType.reversal => l.entryReversal,
        };
    IconData icon(EntryType t) => switch (t) {
          EntryType.initial => Icons.flag_outlined,
          EntryType.spend => Icons.shopping_bag_outlined,
          EntryType.topUp => Icons.add_card_outlined,
          EntryType.adjustment => Icons.tune,
          EntryType.reversal => Icons.undo,
        };

    return Column(
      children: [
        for (final e in entries)
          Builder(builder: (context) {
            final voided = reversed.contains(e.id);
            final muted = voided ? scheme.outline : null;
            final style = voided
                ? TextStyle(
                    color: muted, decoration: TextDecoration.lineThrough)
                : null;
            final amount =
                '${e.delta >= 0 ? '+' : '−'}${fmt.format(e.delta.abs(), view.card.currency)}';
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: scheme.secondaryContainer,
                child: Icon(icon(e.type),
                    size: 20, color: muted ?? scheme.onSecondaryContainer),
              ),
              title: Text(
                e.note.isEmpty
                    ? label(e.type)
                    : '${label(e.type)} · ${e.note}',
                style: style,
              ),
              subtitle: Text(fmtDateTime(e.createdAt, fa: fa, jalali: jalali)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    amount,
                    style: (style ?? const TextStyle()).copyWith(
                      fontWeight: FontWeight.w600,
                      color: voided
                          ? muted
                          : (e.delta >= 0 ? (Theme.of(context).brightness == Brightness.dark
                              ? Colors.green.shade300
                              : Colors.green.shade800) : null),
                    ),
                  ),
                  if (canReverse(e, reversed))
                    IconButton(
                      tooltip: l.undo,
                      icon: const Icon(Icons.undo, size: 20),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          await actions.reverse(view.card.id, e.id);
                        } on InsufficientBalance {
                          messenger.showSnackBar(
                              SnackBar(content: Text(l.cannotUndo)));
                        }
                      },
                    ),
                ],
              ),
            );
          }),
      ],
    );
  }
}

/// Card number / PIN: hidden by default, biometric-gated, auto-hides, and the
/// clipboard is cleared 30 seconds after copying.
class SecretsPanel extends ConsumerStatefulWidget {
  const SecretsPanel({super.key, required this.cardId});
  final String cardId;

  @override
  ConsumerState<SecretsPanel> createState() => _SecretsPanelState();
}

class _SecretsPanelState extends ConsumerState<SecretsPanel> {
  static const _seconds = 10;

  String? _number;
  String? _pin;
  int _left = 0;
  Timer? _timer;
  Timer? _clipTimer;

  bool get _shown => _number != null;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _reveal() async {
    final l = AppLocalizations.of(context)!;
    if (!await Auth.require(l.revealReason)) return;
    final s = await ref.read(dbProvider).secrets(widget.cardId);
    if (!mounted) return;
    setState(() {
      _number = s.number;
      _pin = s.pin;
      _left = _seconds;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_left <= 1) {
        _hide();
      } else {
        setState(() => _left--);
      }
    });
  }

  void _hide() {
    _timer?.cancel();
    if (mounted) {
      setState(() {
        _number = null;
        _pin = null;
      });
    }
  }

  void _copy(String value) {
    final l = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l.copied)));
    _clipTimer?.cancel();
    _clipTimer = Timer(const Duration(seconds: 30),
        () => Clipboard.setData(const ClipboardData(text: '')));
  }

  Widget _row(IconData icon, String value, String masked) => Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _shown ? value : masked,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.start,
              style: const TextStyle(letterSpacing: 1.5),
            ),
          ),
          if (_shown && value.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy, size: 20),
              onPressed: () => _copy(value),
            ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final view = ref
        .watch(cardsProvider)
        .valueOrNull
        ?.where((v) => v.card.id == widget.cardId)
        .firstOrNull;
    final card = view?.card;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lock_outline, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l.secrets,
                      style: Theme.of(context).textTheme.titleSmall),
                ),
                TextButton(
                  onPressed: _shown ? _hide : _reveal,
                  child: Text(_shown ? l.hide : l.reveal),
                ),
              ],
            ),
            if (card?.hasNumber ?? false)
              _row(Icons.credit_card, _number ?? '', '•••• •••• •••• ••••'),
            if (card?.hasPin ?? false)
              _row(Icons.password, _pin ?? '', '••••••'),
            if (_shown) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(value: _left / _seconds, minHeight: 3),
              const SizedBox(height: 4),
              Text(
                l.hidesIn(localDigits(context, _left)),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
