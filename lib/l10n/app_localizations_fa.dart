// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'کارت‌های هدیه';

  @override
  String get noCardsTitle => 'هنوز کارتی ندارید';

  @override
  String get noCardsBody =>
      'اولین کارت هدیه‌تان را اضافه کنید تا همیشه بدانید چقدر اعتبار باقی مانده است.';

  @override
  String get addCard => 'افزودن کارت';

  @override
  String get editCard => 'ویرایش کارت';

  @override
  String get cardName => 'نام کارت';

  @override
  String get cardNumber => 'شماره کارت (اختیاری)';

  @override
  String get secretCode => 'رمز یا پین (اختیاری)';

  @override
  String get currency => 'واحد پول';

  @override
  String get startingCredit => 'اعتبار اولیه';

  @override
  String get expiry => 'تاریخ انقضا';

  @override
  String get noExpiry => 'بدون تاریخ انقضا';

  @override
  String get save => 'ذخیره';

  @override
  String get cancel => 'انصراف';

  @override
  String get delete => 'حذف';

  @override
  String get deleteCardTitle => 'کارت حذف شود؟';

  @override
  String get deleteCardBody => 'کارت و تمام تاریخچه‌اش برای همیشه حذف می‌شود.';

  @override
  String get moveUp => 'انتقال به بالا';

  @override
  String get moveDown => 'انتقال به پایین';

  @override
  String get moreOptions => 'گزینه‌های بیشتر';

  @override
  String get balance => 'موجودی';

  @override
  String get total => 'مجموع';

  @override
  String get spend => 'ثبت خرید';

  @override
  String get topUp => 'افزایش اعتبار';

  @override
  String balanceAfter(String amount) {
    return 'موجودی پس از ثبت: $amount';
  }

  @override
  String get spendAll => 'کل موجودی';

  @override
  String get noteOptional => 'توضیح (اختیاری)';

  @override
  String get history => 'تاریخچه';

  @override
  String get noHistory => 'هنوز تراکنشی ثبت نشده';

  @override
  String get entryInitial => 'اعتبار اولیه';

  @override
  String get entrySpend => 'خرید';

  @override
  String get entryTopUp => 'افزایش اعتبار';

  @override
  String get entryAdjustment => 'اصلاح موجودی';

  @override
  String get entryReversal => 'لغو تراکنش';

  @override
  String get undo => 'بازگردانی';

  @override
  String get spendRecorded => 'خرید ثبت شد';

  @override
  String get topUpRecorded => 'اعتبار افزوده شد';

  @override
  String get secrets => 'اطلاعات محرمانه';

  @override
  String get reveal => 'نمایش';

  @override
  String get hide => 'پنهان کردن';

  @override
  String get copied => 'کپی شد';

  @override
  String hidesIn(String seconds) {
    return 'پنهان شدن تا $seconds ثانیه دیگر';
  }

  @override
  String get authReason => 'برای باز کردن برنامه هویت خود را تأیید کنید';

  @override
  String get revealReason => 'برای دیدن اطلاعات کارت هویت خود را تأیید کنید';

  @override
  String get unlockTitle => 'برنامه قفل است';

  @override
  String get unlockButton => 'باز کردن قفل';

  @override
  String get settings => 'تنظیمات';

  @override
  String get language => 'زبان';

  @override
  String get languageSystem => 'سیستم';

  @override
  String get languageFa => 'فارسی';

  @override
  String get languageEn => 'English';

  @override
  String get theme => 'پوسته';

  @override
  String get themeSystem => 'سیستم';

  @override
  String get themeLight => 'روشن';

  @override
  String get themeDark => 'تاریک';

  @override
  String get calendar => 'تقویم';

  @override
  String get calendarDefault => 'تقویم پیش‌فرض کارت‌های جدید';

  @override
  String get calendarAuto => 'خودکار';

  @override
  String get calendarShamsi => 'شمسی';

  @override
  String get calendarGregorian => 'میلادی';

  @override
  String get today => 'امروز';

  @override
  String get iranUnit => 'واحد پول ایران';

  @override
  String get toman => 'تومان';

  @override
  String get rial => 'ریال';

  @override
  String get appLock => 'قفل برنامه';

  @override
  String get appLockSub => 'با اثر انگشت، چهره یا قفل صفحه';

  @override
  String get appLockUnavailable => 'قفل صفحه روی این دستگاه فعال نیست';

  @override
  String get maskBalances => 'پنهان کردن موجودی‌ها';

  @override
  String get maskBalancesSub => 'مبلغ‌ها به‌صورت نقطه نمایش داده می‌شوند';

  @override
  String get expired => 'منقضی شده';

  @override
  String get expiresToday => 'امروز منقضی می‌شود';

  @override
  String expiresInDays(String days) {
    return '$days روز تا انقضا';
  }

  @override
  String expiresOn(String date) {
    return 'انقضا: $date';
  }

  @override
  String get privacyNote =>
      'همهٔ اطلاعات فقط روی همین دستگاه می‌ماند. بدون حساب کاربری، بدون اینترنت، بدون تبلیغات.';

  @override
  String get search => 'جستجو';

  @override
  String get fieldRequired => 'این فیلد لازم است';

  @override
  String get invalidAmount => 'مبلغ معتبر وارد کنید';

  @override
  String get color => 'رنگ';

  @override
  String get cannotUndo => 'با موجودی فعلی امکان بازگردانی نیست';

  @override
  String get spentSection => 'تمام‌شده';
}
