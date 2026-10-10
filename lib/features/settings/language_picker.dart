import 'package:flutter/material.dart';
import 'package:giftcard_manager/l10n/app_localizations.dart';

import '../../core/languages.dart';

/// Lets the user pick any supported language. Returns the language code, or
/// null if dismissed. The list is built from
/// AppLocalizations.supportedLocales, so a new language shows up here as soon
/// as its ARB file exists; a search box appears when there are many.
Future<String?> showLanguagePicker(BuildContext context, String current) =>
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _LanguageSheet(current: current),
    );

class _LanguageSheet extends StatefulWidget {
  const _LanguageSheet({required this.current});
  final String current;

  @override
  State<_LanguageSheet> createState() => _LanguageSheetState();
}

class _LanguageSheetState extends State<_LanguageSheet> {
  static const _searchThreshold = 8;

  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final locales = AppLocalizations.supportedLocales;
    final showSearch = locales.length > _searchThreshold;
    final q = _query.trim().toLowerCase();
    final items = locales
        .where((loc) =>
            q.isEmpty ||
            loc.languageCode.contains(q) ||
            nativeLanguageName(loc).toLowerCase().contains(q))
        .toList();
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    Widget check(bool on) =>
        on ? Icon(Icons.check, color: scheme.primary) : const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(l.language,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
            ),
            if (showSearch)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: l.search,
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                  ),
                ),
              ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final loc in items)
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(nativeLanguageName(loc)),
                      trailing: check(widget.current == loc.languageCode),
                      onTap: () => Navigator.pop(context, loc.languageCode),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
