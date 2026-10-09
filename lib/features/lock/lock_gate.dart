import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:giftcard_manager/l10n/app_localizations.dart';

import '../../core/auth.dart';
import '../../data/providers.dart';

/// Covers the app with a lock screen at launch and after being in the
/// background for longer than [_grace].
class LockGate extends ConsumerStatefulWidget {
  const LockGate({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<LockGate> createState() => _LockGateState();
}

class _LockGateState extends ConsumerState<LockGate>
    with WidgetsBindingObserver {
  static const _grace = Duration(seconds: 20);

  bool _locked = false;
  bool _busy = false;
  DateTime? _leftAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (ref.read(settingsProvider).appLock) {
      _locked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The system auth prompt itself pauses/resumes the app; ignore that.
    if (_busy) return;
    if (state == AppLifecycleState.paused) {
      _leftAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final left = _leftAt;
      _leftAt = null;
      if (left != null &&
          !_locked &&
          ref.read(settingsProvider).appLock &&
          DateTime.now().difference(left) > _grace) {
        setState(() => _locked = true);
        _unlock();
      }
    }
  }

  Future<void> _unlock() async {
    if (_busy || !mounted) return;
    _busy = true;
    final ok = await Auth.require(AppLocalizations.of(context)!.authReason);
    _busy = false;
    if (ok && mounted) setState(() => _locked = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_locked) Positioned.fill(child: _LockScreen(onUnlock: _unlock)),
      ],
    );
  }
}

class _LockScreen extends StatelessWidget {
  const _LockScreen({required this.onUnlock});
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 64, color: scheme.primary),
            const SizedBox(height: 16),
            Text(l.unlockTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onUnlock,
              icon: const Icon(Icons.fingerprint),
              label: Text(l.unlockButton),
            ),
          ],
        ),
      ),
    );
  }
}
