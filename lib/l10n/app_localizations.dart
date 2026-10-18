import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fa')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'GiftCard Tracker'**
  String get appTitle;

  /// No description provided for @noCardsTitle.
  ///
  /// In en, this message translates to:
  /// **'No cards yet'**
  String get noCardsTitle;

  /// No description provided for @noCardsBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first gift card and always know what\'s left on it.'**
  String get noCardsBody;

  /// No description provided for @addCard.
  ///
  /// In en, this message translates to:
  /// **'Add card'**
  String get addCard;

  /// No description provided for @editCard.
  ///
  /// In en, this message translates to:
  /// **'Edit card'**
  String get editCard;

  /// No description provided for @cardName.
  ///
  /// In en, this message translates to:
  /// **'Card name'**
  String get cardName;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card number (optional)'**
  String get cardNumber;

  /// No description provided for @secretCode.
  ///
  /// In en, this message translates to:
  /// **'Password or PIN (optional)'**
  String get secretCode;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @startingCredit.
  ///
  /// In en, this message translates to:
  /// **'Starting credit'**
  String get startingCredit;

  /// No description provided for @expiry.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get expiry;

  /// No description provided for @noExpiry.
  ///
  /// In en, this message translates to:
  /// **'No expiry date'**
  String get noExpiry;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete card?'**
  String get deleteCardTitle;

  /// No description provided for @deleteCardBody.
  ///
  /// In en, this message translates to:
  /// **'This card and its whole history will be permanently deleted.'**
  String get deleteCardBody;

  /// No description provided for @moveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get moveUp;

  /// No description provided for @moveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get moveDown;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @spend.
  ///
  /// In en, this message translates to:
  /// **'Record purchase'**
  String get spend;

  /// No description provided for @topUp.
  ///
  /// In en, this message translates to:
  /// **'Top up'**
  String get topUp;

  /// No description provided for @balanceAfter.
  ///
  /// In en, this message translates to:
  /// **'Balance after: {amount}'**
  String balanceAfter(String amount);

  /// No description provided for @spendAll.
  ///
  /// In en, this message translates to:
  /// **'Spend all'**
  String get spendAll;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noHistory;

  /// No description provided for @entryInitial.
  ///
  /// In en, this message translates to:
  /// **'Starting credit'**
  String get entryInitial;

  /// No description provided for @entrySpend.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get entrySpend;

  /// No description provided for @entryTopUp.
  ///
  /// In en, this message translates to:
  /// **'Top-up'**
  String get entryTopUp;

  /// No description provided for @entryAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Adjustment'**
  String get entryAdjustment;

  /// No description provided for @entryReversal.
  ///
  /// In en, this message translates to:
  /// **'Reversal'**
  String get entryReversal;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @spendRecorded.
  ///
  /// In en, this message translates to:
  /// **'Purchase recorded'**
  String get spendRecorded;

  /// No description provided for @topUpRecorded.
  ///
  /// In en, this message translates to:
  /// **'Credit added'**
  String get topUpRecorded;

  /// No description provided for @secrets.
  ///
  /// In en, this message translates to:
  /// **'Private details'**
  String get secrets;

  /// No description provided for @reveal.
  ///
  /// In en, this message translates to:
  /// **'Reveal'**
  String get reveal;

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @hidesIn.
  ///
  /// In en, this message translates to:
  /// **'Hides in {seconds}s'**
  String hidesIn(String seconds);

  /// No description provided for @authReason.
  ///
  /// In en, this message translates to:
  /// **'Verify it\'s you to open the app'**
  String get authReason;

  /// No description provided for @revealReason.
  ///
  /// In en, this message translates to:
  /// **'Verify it\'s you to see card details'**
  String get revealReason;

  /// No description provided for @unlockTitle.
  ///
  /// In en, this message translates to:
  /// **'App locked'**
  String get unlockTitle;

  /// No description provided for @unlockButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlockButton;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageFa.
  ///
  /// In en, this message translates to:
  /// **'فارسی'**
  String get languageFa;

  /// No description provided for @languageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @calendarDefault.
  ///
  /// In en, this message translates to:
  /// **'Default calendar for new cards'**
  String get calendarDefault;

  /// No description provided for @calendarAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get calendarAuto;

  /// No description provided for @calendarShamsi.
  ///
  /// In en, this message translates to:
  /// **'Shamsi'**
  String get calendarShamsi;

  /// No description provided for @calendarGregorian.
  ///
  /// In en, this message translates to:
  /// **'Gregorian'**
  String get calendarGregorian;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @iranUnit.
  ///
  /// In en, this message translates to:
  /// **'Iranian currency unit'**
  String get iranUnit;

  /// No description provided for @toman.
  ///
  /// In en, this message translates to:
  /// **'Toman'**
  String get toman;

  /// No description provided for @rial.
  ///
  /// In en, this message translates to:
  /// **'Rial'**
  String get rial;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get appLock;

  /// No description provided for @appLockSub.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint, face or screen lock'**
  String get appLockSub;

  /// No description provided for @appLockUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No screen lock is set up on this device'**
  String get appLockUnavailable;

  /// No description provided for @maskBalances.
  ///
  /// In en, this message translates to:
  /// **'Hide balances'**
  String get maskBalances;

  /// No description provided for @maskBalancesSub.
  ///
  /// In en, this message translates to:
  /// **'Amounts are shown as dots'**
  String get maskBalancesSub;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @expiresToday.
  ///
  /// In en, this message translates to:
  /// **'Expires today'**
  String get expiresToday;

  /// No description provided for @expiresInDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String expiresInDays(String days);

  /// No description provided for @expiresOn.
  ///
  /// In en, this message translates to:
  /// **'Expires {date}'**
  String expiresOn(String date);

  /// No description provided for @privacyNote.
  ///
  /// In en, this message translates to:
  /// **'Everything stays on this device. No account, no internet, no ads.'**
  String get privacyNote;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get invalidAmount;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @cannotUndo.
  ///
  /// In en, this message translates to:
  /// **'Can\'t undo with the current balance'**
  String get cannotUndo;

  /// No description provided for @spentSection.
  ///
  /// In en, this message translates to:
  /// **'Used up'**
  String get spentSection;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
