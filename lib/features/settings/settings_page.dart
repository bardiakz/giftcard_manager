import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:giftcard_manager/l10n/app_localizations.dart';

import '../../core/auth.dart';
import '../../core/format.dart';
import '../../core/languages.dart';
import '../../core/money.dart';
import '../../data/providers.dart';
import '../cards/currency_picker.dart';
import 'language_picker.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    final text = Theme.of(context).textTheme;
    final langCode =
        effectiveLanguageCode(s.language, AppLocalizations.supportedLocales);

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l.language),
            subtitle: Text(nativeLanguageName(Locale(langCode))),
            trailing: const Icon(Icons.arrow_drop_down),
            onTap: () async {
              final choice = await showLanguagePicker(context, langCode);
              if (choice != null) n.setLanguage(choice);
            },
          ),
          ListTile(
            leading: const Icon(Icons.paid_outlined),
            title: Text(l.currency),
            subtitle: Text(
              '${Currency.byCode(s.defaultCurrency).code} · ${Currency.byCode(s.defaultCurrency).name(isFa(context))}',
            ),
            trailing: const Icon(Icons.arrow_drop_down),
            onTap: () async {
              final choice = await pickCurrency(
                context,
                Currency.byCode(s.defaultCurrency),
              );
              if (choice != null) n.setDefaultCurrency(choice.code);
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
            child: Text(l.calendarDefault, style: text.titleSmall),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                      value: 'gregorian', label: Text(l.calendarGregorian)),
                  ButtonSegment(value: 'jalali', label: Text(l.calendarShamsi)),
                ],
                selected: {s.calendar},
                onSelectionChanged: (v) => n.setCalendar(v.first),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
            child: Text(l.theme, style: text.titleSmall),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'system', label: Text(l.themeSystem)),
                  ButtonSegment(value: 'light', label: Text(l.themeLight)),
                  ButtonSegment(value: 'dark', label: Text(l.themeDark)),
                ],
                selected: {s.themeMode},
                onSelectionChanged: (v) => n.setThemeMode(v.first),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<bool>(
            future: Auth.available(),
            builder: (context, snap) {
              final available = snap.data ?? false;
              return SwitchListTile(
                title: Text(l.appLock),
                subtitle: Text(available ? l.appLockSub : l.appLockUnavailable),
                value: s.appLock && available,
                onChanged: available
                    ? (v) async {
                        // Make sure the user can actually pass the prompt
                        // before turning the lock on.
                        if (v && !await Auth.require(l.authReason)) return;
                        n.setAppLock(v);
                      }
                    : null,
              );
            },
          ),
          SwitchListTile(
            title: Text(l.maskBalances),
            subtitle: Text(l.maskBalancesSub),
            value: s.maskBalances,
            onChanged: n.setMaskBalances,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.verified_user_outlined, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(l.privacyNote, style: text.bodyMedium)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
