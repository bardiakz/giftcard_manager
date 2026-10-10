// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Gift Cards';

  @override
  String get noCardsTitle => 'No cards yet';

  @override
  String get noCardsBody =>
      'Add your first gift card and always know what\'s left on it.';

  @override
  String get addCard => 'Add card';

  @override
  String get editCard => 'Edit card';

  @override
  String get cardName => 'Card name';

  @override
  String get cardNumber => 'Card number (optional)';

  @override
  String get secretCode => 'Password or PIN (optional)';

  @override
  String get currency => 'Currency';

  @override
  String get startingCredit => 'Starting credit';

  @override
  String get expiry => 'Expiry date';

  @override
  String get noExpiry => 'No expiry date';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deleteCardTitle => 'Delete card?';

  @override
  String get deleteCardBody =>
      'This card and its whole history will be permanently deleted.';

  @override
  String get balance => 'Balance';

  @override
  String get total => 'Total';

  @override
  String get spend => 'Record purchase';

  @override
  String get topUp => 'Top up';

  @override
  String balanceAfter(String amount) {
    return 'Balance after: $amount';
  }

  @override
  String get spendAll => 'Spend all';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get history => 'History';

  @override
  String get noHistory => 'No transactions yet';

  @override
  String get entryInitial => 'Starting credit';

  @override
  String get entrySpend => 'Purchase';

  @override
  String get entryTopUp => 'Top-up';

  @override
  String get entryAdjustment => 'Adjustment';

  @override
  String get entryReversal => 'Reversal';

  @override
  String get undo => 'Undo';

  @override
  String get spendRecorded => 'Purchase recorded';

  @override
  String get topUpRecorded => 'Credit added';

  @override
  String get secrets => 'Private details';

  @override
  String get reveal => 'Reveal';

  @override
  String get hide => 'Hide';

  @override
  String get copied => 'Copied';

  @override
  String hidesIn(String seconds) {
    return 'Hides in ${seconds}s';
  }

  @override
  String get authReason => 'Verify it\'s you to open the app';

  @override
  String get revealReason => 'Verify it\'s you to see card details';

  @override
  String get unlockTitle => 'App locked';

  @override
  String get unlockButton => 'Unlock';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageFa => 'فارسی';

  @override
  String get languageEn => 'English';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get calendar => 'Calendar';

  @override
  String get calendarDefault => 'Default calendar for new cards';

  @override
  String get calendarAuto => 'Automatic';

  @override
  String get calendarShamsi => 'Shamsi';

  @override
  String get calendarGregorian => 'Gregorian';

  @override
  String get today => 'Today';

  @override
  String get iranUnit => 'Iranian currency unit';

  @override
  String get toman => 'Toman';

  @override
  String get rial => 'Rial';

  @override
  String get appLock => 'App lock';

  @override
  String get appLockSub => 'Fingerprint, face or screen lock';

  @override
  String get appLockUnavailable => 'No screen lock is set up on this device';

  @override
  String get maskBalances => 'Hide balances';

  @override
  String get maskBalancesSub => 'Amounts are shown as dots';

  @override
  String get expired => 'Expired';

  @override
  String get expiresToday => 'Expires today';

  @override
  String expiresInDays(String days) {
    return '$days days left';
  }

  @override
  String expiresOn(String date) {
    return 'Expires $date';
  }

  @override
  String get privacyNote =>
      'Everything stays on this device. No account, no internet, no ads.';

  @override
  String get search => 'Search';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get invalidAmount => 'Enter a valid amount';

  @override
  String get color => 'Color';

  @override
  String get cannotUndo => 'Can\'t undo with the current balance';

  @override
  String get spentSection => 'Used up';
}
