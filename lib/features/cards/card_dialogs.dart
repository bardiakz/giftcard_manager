import 'package:flutter/material.dart';
import 'package:giftcard_manager/l10n/app_localizations.dart';

import '../../data/models.dart';
import '../../data/providers.dart';
import 'amount_sheet.dart';

/// Opens the amount keypad for [view] and, if something was saved, shows an
/// undo snackbar. Used from both the home list and the card page.
Future<void> recordAmount(
  BuildContext context,
  CardActions actions,
  CardView view,
  AmountMode mode,
) async {
  final l = AppLocalizations.of(context)!;
  final entryId = await showAmountSheet(context, view, mode);
  if (entryId == null || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content:
            Text(mode == AmountMode.spend ? l.spendRecorded : l.topUpRecorded),
        action: SnackBarAction(
          label: l.undo,
          onPressed: () async {
            try {
              await actions.reverse(view.card.id, entryId);
            } on InsufficientBalance {
              messenger.showSnackBar(SnackBar(content: Text(l.cannotUndo)));
            }
          },
        ),
      ),
    );
}

/// Asks for confirmation, then deletes the card and its whole history.
/// [beforeDelete] runs after the user confirms (e.g. to leave the card page).
Future<void> confirmDeleteCard(
  BuildContext context,
  CardActions actions,
  String cardId, {
  VoidCallback? beforeDelete,
}) async {
  final l = AppLocalizations.of(context)!;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.deleteCardTitle),
      content: Text(l.deleteCardBody),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
        FilledButton(
            onPressed: () => Navigator.pop(ctx, true), child: Text(l.delete)),
      ],
    ),
  );
  if (ok != true) return;
  beforeDelete?.call();
  await actions.deleteCard(cardId);
}
