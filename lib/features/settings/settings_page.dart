import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:giftcard_manager/l10n/app_localizations.dart';

import '../../core/auth.dart';
import '../../core/money.dart';
import '../../data/providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    final fmt = moneyFormatOf(context, ref);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(l.language, style: text.titleSmall),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'system', label: Text(l.languageSystem)),
                  ButtonSegment(value: 'fa', label: Text(l.languageFa)),
                  ButtonSegment(value: 'en', label: Text(l.languageEn)),
                ],
                selected: {s.language},
                onSelectionChanged: (v) => n.setLanguage(v.first),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
            child: Text(l.calendar, style: text.titleSmall),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'auto', label: Text(l.calendarAuto)),
                  ButtonSegment(value: 'jalali', label: Text(l.calendarShamsi)),
                  ButtonSegment(
                      value: 'gregorian', label: Text(l.calendarGregorian)),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
            child: Text(l.iranUnit, style: text.titleSmall),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<IranUnit>(
                segments: [
                  ButtonSegment(value: IranUnit.toman, label: Text(l.toman)),
                  ButtonSegment(value: IranUnit.rial, label: Text(l.rial)),
                ],
                selected: {fmt.unit},
                onSelectionChanged: (v) => n.setIranUnit(v.first),
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
