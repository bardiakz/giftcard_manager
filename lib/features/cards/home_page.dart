import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:giftcard_manager/l10n/app_localizations.dart';

import '../../core/money.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import 'wallet_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String _query = '';

  int _byExpiry(CardView a, CardView b) {
    final ea = a.card.expiry ?? DateTime(9999);
    final eb = b.card.expiry ?? DateTime(9999);
    final c = ea.compareTo(eb);
    return c != 0 ? c : b.card.createdAt.compareTo(a.card.createdAt);
  }

  Widget _tile(CardView v, {bool dimmed = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: WalletCard(
          view: v,
          dimmed: dimmed,
          onTap: () => context.push('/card/${v.card.id}'),
        ),
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
              final q = _query.trim().toLowerCase();
              final filtered = list
                  .where((v) =>
                      q.isEmpty || v.card.name.toLowerCase().contains(q))
                  .toList();
              final active = filtered.where((v) => v.balance > 0).toList()
                ..sort(_byExpiry);
              final spent = filtered.where((v) => v.balance <= 0).toList();

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
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
                    for (final v in active) _tile(v),
                    if (spent.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
                        child: Text(
                          l.spentSection,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      for (final v in spent) _tile(v, dimmed: true),
                    ],
                  ],
                ),
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
          Text(l.noCardsTitle,
              style: Theme.of(context).textTheme.titleLarge),
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
