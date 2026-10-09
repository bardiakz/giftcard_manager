import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:giftcard_manager/l10n/app_localizations.dart';

import '../../core/format.dart';
import '../../core/money.dart';
import '../../data/models.dart';
import '../../data/providers.dart';

const cardPalette = <List<Color>>[
  [Color(0xFF0F766E), Color(0xFF0D9488)],
  [Color(0xFF3730A3), Color(0xFF6366F1)],
  [Color(0xFF9D174D), Color(0xFFDB2777)],
  [Color(0xFF9A3412), Color(0xFFEA580C)],
  [Color(0xFF1E40AF), Color(0xFF2563EB)],
  [Color(0xFF166534), Color(0xFF16A34A)],
  [Color(0xFF6B21A8), Color(0xFF9333EA)],
  [Color(0xFF1F2937), Color(0xFF475569)],
];

/// Balance that counts up/down smoothly when it changes.
class AnimatedBalance extends ConsumerWidget {
  const AnimatedBalance({
    super.key,
    required this.minor,
    required this.currency,
    this.style,
  });

  final int minor;
  final Currency currency;
  final TextStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = moneyFormatOf(context, ref);
    final mask = ref.watch(settingsProvider.select((s) => s.maskBalances));
    return TweenAnimationBuilder<int>(
      tween: IntTween(end: minor),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (_, value, __) => Text(
        mask ? '••••••' : fmt.format(value, currency),
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
  });

  final CardView view;
  final VoidCallback? onTap;
  final bool dimmed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final card = view.card;
    final colors = cardPalette[card.colorIndex % cardPalette.length];
    final exp = expiryOf(card.expiry);
    final badge = switch (exp.state) {
      ExpiryState.expired => l.expired,
      ExpiryState.today => l.expiresToday,
      ExpiryState.soon => l.expiresInDays(localDigits(context, exp.days)),
      _ => null,
    };
    final text = Theme.of(context).textTheme;
    const radius = BorderRadius.all(Radius.circular(24));

    return Opacity(
      opacity: dimmed ? 0.55 : 1,
      child: Hero(
        tag: 'card-${card.id}',
        child: Material(
          color: Colors.transparent,
          child: Ink(
            height: 168,
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: colors,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withValues(alpha: 0.35),
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
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              badge,
                              style: text.labelSmall
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      l.balance,
                      style: text.labelMedium?.copyWith(color: Colors.white70),
                    ),
                    AnimatedBalance(
                      minor: view.balance,
                      currency: card.currency,
                      style: text.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: view.ratio,
                        minHeight: 6,
                        backgroundColor: Colors.white24,
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
      ),
    );
  }
}
