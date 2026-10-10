import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:giftcard_manager/l10n/app_localizations.dart';

import '../../core/money.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import 'amount_sheet.dart';
import 'card_dialogs.dart';
import 'wallet_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String _query = '';

  List<String> _ids(Iterable<CardView> cards) =>
      [for (final v in cards) v.card.id];

  /// Drag and drop within the active cards. Used-up cards stay below them.
  void _onReorder(List<CardView> allActive, List<CardView> allSpent,
      int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final ids = _ids(allActive);
    ids.insert(newIndex, ids.removeAt(oldIndex));
    ref.read(actionsProvider).reorder([...ids, ..._ids(allSpent)]);
  }

  void _move(
      List<CardView> allActive, List<CardView> allSpent, int index, int delta) {
    final ids = _ids(allActive);
    ids.insert(index + delta, ids.removeAt(index));
    ref.read(actionsProvider).reorder([...ids, ..._ids(allSpent)]);
  }

  Future<void> _showMenu(
    CardView v,
    List<CardView> allActive,
    List<CardView> allSpent,
  ) async {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final index = allActive.indexWhere((x) => x.card.id == v.card.id);
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l.editCard),
              onTap: () => Navigator.pop(ctx, 'edit'),
            ),
            if (index > 0)
              ListTile(
                leading: const Icon(Icons.arrow_upward),
                title: Text(l.moveUp),
                onTap: () => Navigator.pop(ctx, 'up'),
              ),
            if (index >= 0 && index < allActive.length - 1)
              ListTile(
                leading: const Icon(Icons.arrow_downward),
                title: Text(l.moveDown),
                onTap: () => Navigator.pop(ctx, 'down'),
              ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: scheme.error),
              title: Text(l.delete, style: TextStyle(color: scheme.error)),
              onTap: () => Navigator.pop(ctx, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'edit':
        context.push('/card/${v.card.id}/edit');
      case 'up':
        _move(allActive, allSpent, index, -1);
      case 'down':
        _move(allActive, allSpent, index, 1);
      case 'delete':
        await confirmDeleteCard(context, ref.read(actionsProvider), v.card.id);
    }
  }

  Widget _card(
    CardView v,
    List<CardView> allActive,
    List<CardView> allSpent, {
    bool dimmed = false,
  }) =>
      WalletCard(
        view: v,
        dimmed: dimmed,
        onTap: () => context.push('/card/${v.card.id}'),
        onQuickSpend: v.balance > 0
            ? () => recordAmount(
                context, ref.read(actionsProvider), v, AmountMode.spend)
            : null,
        onMore: () => _showMenu(v, allActive, allSpent),
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cards = ref.watch(cardsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/card/new'),
        icon: const Icon(Icons.add),
        label: Text(l.addCard),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(l.appTitle),
            actions: [
              IconButton(
                tooltip: l.settings,
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),
          cards.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) =>
                SliverFillRemaining(child: Center(child: Text('$e'))),
            data: (list) {
              if (list.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(),
                );
              }
              // `list` is already in the user's order.
              final allActive = list.where((v) => v.balance > 0).toList();
              final allSpent = list.where((v) => v.balance <= 0).toList();
              final q = _query.trim().toLowerCase();
              bool match(CardView v) =>
                  q.isEmpty || v.card.name.toLowerCase().contains(q);
              final active = allActive.where(match).toList();
              final spent = allSpent.where(match).toList();
              // Dragging is off while a search filter is applied.
              final canReorder = q.isEmpty;

              return SliverMainAxisGroup(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList.list(
                      children: [
                        _Totals(cards: list),
                        if (list.length > 5)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: TextField(
                              onChanged: (v) => setState(() => _query = v),
                              decoration: InputDecoration(
                                hintText: l.search,
                                prefixIcon: const Icon(Icons.search),
                                isDense: true,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverReorderableList(
                      itemCount: active.length,
                      onReorder: (o, n) =>
                          _onReorder(allActive, allSpent, o, n),
                      proxyDecorator: (child, index, animation) =>
                          ScaleTransition(
                        scale: animation.drive(
                            Tween<double>(begin: 1, end: 1.03)
                                .chain(CurveTween(curve: Curves.easeOut))),
                        child: Material(
                          color: Colors.transparent,
                          child: child,
                        ),
                      ),
                      itemBuilder: (context, i) {
                        final v = active[i];
                        return ReorderableDelayedDragStartListener(
                          key: ValueKey(v.card.id),
                          index: i,
                          enabled: canReorder,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _card(v, allActive, allSpent),
                          ),
                        );
                      },
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    sliver: SliverList.list(
                      children: [
                        if (spent.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
                            child: Text(
                              l.spentSection,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        for (final v in spent)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _card(v, allActive, allSpent, dimmed: true),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Totals extends ConsumerWidget {
  const _Totals({required this.cards});
  final List<CardView> cards;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final fmt = moneyFormatOf(context, ref);
    final mask = ref.watch(settingsProvider.select((s) => s.maskBalances));
    final totals = <Currency, int>{};
    for (final v in cards) {
      totals.update(v.card.currency, (t) => t + v.balance,
          ifAbsent: () => v.balance);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.total, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final e in totals.entries)
                Chip(
                  label: Text(mask ? '••••••' : fmt.format(e.value, e.key)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.card_giftcard, size: 72, color: scheme.primary),
          const SizedBox(height: 16),
          Text(l.noCardsTitle, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(l.noCardsBody, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push('/card/new'),
            icon: const Icon(Icons.add),
            label: Text(l.addCard),
          ),
        ],
      ),
    );
  }
}
