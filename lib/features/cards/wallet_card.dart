import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:giftcard_manager/l10n/app_localizations.dart';

import '../../core/format.dart';
import '../../core/money.dart';
import '../../data/models.dart';
import '../../data/providers.dart';

/// Every gradient is dark enough for white text to keep a contrast ratio of
/// at least ~5:1 at both ends, in light and dark theme alike.
const cardPalette = <List<Color>>[
  [Color(0xFF0F766E), Color(0xFF115E59)],
  [Color(0xFF4338CA), Color(0xFF312E81)],
  [Color(0xFFBE185D), Color(0xFF9D174D)],
  [Color(0xFFC2410C), Color(0xFF9A3412)],
  [Color(0xFF1D4ED8), Color(0xFF1E3A8A)],
  [Color(0xFF15803D), Color(0xFF166534)],
  [Color(0xFF7E22CE), Color(0xFF581C87)],
  [Color(0xFF334155), Color(0xFF1E293B)],
];

/// Used for used-up cards instead of fading them: fading white text over a
/// light background made it unreadable.
const _dimmedColors = [Color(0xFF64748B), Color(0xFF475569)];

const _textStrong = Colors.white;
const _textSoft = Color(0xE6FFFFFF); // 90% white

/// Balance that counts up/down smoothly when it changes.
class AnimatedBalance extends ConsumerWidget {
  const AnimatedBalance({
    super.key,
    required this.minor,
    required this.currency,
    this.style,
    this.cardId,
  });

  final int minor;
  final Currency currency;
  final TextStyle? style;

  /// When set, this card's own show/hide state (the eye button) applies.
  final String? cardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = moneyFormatOf(context, ref);
    final globalMask =
        ref.watch(settingsProvider.select((s) => s.maskBalances));
    final id = cardId;
    final visible = id == null
        ? !globalMask
        : ref.watch(
            balanceVisibilityProvider.select((m) => m[id] ?? !globalMask));
    return TweenAnimationBuilder<int>(
      tween: IntTween(end: minor),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (_, value, __) => Text(
        visible ? fmt.format(value, currency) : '••••••',
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class WalletCard extends ConsumerWidget {
  const WalletCard({
    super.key,
    required this.view,
    this.onTap,
    this.dimmed = false,
    this.onQuickSpend,
    this.onMore,
  });

  final CardView view;
  final VoidCallback? onTap;
  final bool dimmed;

  /// Shows a "record purchase" shortcut button on the card when set.
  final VoidCallback? onQuickSpend;

  /// Shows a ⋮ button on the card when set.
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final card = view.card;
    final colors =
        dimmed ? _dimmedColors : cardPalette[card.colorIndex % cardPalette.length];
    final exp = expiryOf(card.expiry);
    final badge = switch (exp.state) {
      ExpiryState.expired => l.expired,
      ExpiryState.today => l.expiresToday,
      ExpiryState.soon => l.expiresInDays(localDigits(context, exp.days)),
      _ => null,
    };
    final globalMask =
        ref.watch(settingsProvider.select((s) => s.maskBalances));
    final balanceVisible = ref.watch(
        balanceVisibilityProvider.select((m) => m[card.id] ?? !globalMask));
    final text = Theme.of(context).textTheme;
    const radius = BorderRadius.all(Radius.circular(24));

    return Hero(
      tag: 'card-${card.id}',
      child: Material(
        color: Colors.transparent,
        child: Ink(
          height: 172,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: colors,
            ),
            // Keeps the card edge visible against a dark background.
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            boxShadow: [
              BoxShadow(
                color: colors.last.withValues(alpha: 0.4),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          card.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.titleMedium?.copyWith(
                            color: _textStrong,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            badge,
                            style: text.labelSmall?.copyWith(
                              color: _textStrong,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (onMore != null)
                        IconButton(
                          tooltip: l.moreOptions,
                          onPressed: onMore,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                              width: 32, height: 32),
                          iconSize: 22,
                          icon: const Icon(Icons.more_vert,
                              color: _textStrong),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l.balance,
                                  style: text.labelMedium
                                      ?.copyWith(color: _textSoft),
                                ),
                                const SizedBox(width: 2),
                                IconButton(
                                  tooltip: balanceVisible
                                      ? l.hideBalance
                                      : l.showBalance,
                                  onPressed: () => ref
                                      .read(balanceVisibilityProvider.notifier)
                                      .toggle(card.id),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints.tightFor(
                                      width: 32, height: 20),
                                  iconSize: 18,
                                  icon: Icon(
                                    balanceVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: _textSoft,
                                  ),
                                ),
                              ],
                            ),
                            AnimatedBalance(
                              minor: view.balance,
                              currency: card.currency,
                              cardId: card.id,
                              style: text.headlineMedium?.copyWith(
                                color: _textStrong,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (onQuickSpend != null) ...[
                        const SizedBox(width: 8),
                        Tooltip(
                          message: l.spend,
                          child: Material(
                            color: Colors.black.withValues(alpha: 0.28),
                            shape: const CircleBorder(
                              side: BorderSide(color: Colors.white54),
                            ),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: onQuickSpend,
                              child: const SizedBox(
                                width: 44,
                                height: 44,
                                child: Icon(Icons.shopping_bag_outlined,
                                    color: _textStrong),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: view.ratio,
                      minHeight: 6,
                      backgroundColor: Colors.white30,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
