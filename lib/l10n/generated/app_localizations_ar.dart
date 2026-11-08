// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'يلو فاست كول';

  @override
  String get appVersion => 'يلو فاست كول الإصدار 1.1.0';

  @override
  String get appTagline => 'اعرف من المتصل';

  @override
  String get onboardingSkip => 'تخطٍّ';

  @override
  String get onboardingGetStarted => 'ابدأ الآن';

  @override
  String get onboardingSlide1Title => 'اعرف من المتصل';

  @override
  String get onboardingSlide1Subtitle =>
      'تعرّف على الأرقام المجهولة فوراً ولن تتساءل بعد الآن عمَّن يتصل بك.';

  @override
  String get onboardingSlide2Title => 'احظر الإزعاج والاحتيال';

  @override
  String get onboardingSlide2Subtitle =>
      'حماية تلقائية من مكالمات التسويق والاحتيال والمكالمات الآلية — قبل أن يرنّ هاتفك.';

  @override
  String get onboardingSlide3Title => 'خصوصيتك محمية';

  @override
  String get onboardingSlide3Subtitle =>
      'بياناتك مشفّرة من طرف إلى طرف. تبقى أنت من يتحكّم — احذف رقمك أو أخفه في أي وقت.';

  @override
  String get ok => 'حسناً';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get close => 'إغلاق';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get continueAction => 'متابعة';

  @override
  String get done => 'تم';

  @override
  String get next => 'التالي';

  @override
  String get back => 'رجوع';

  @override
  String get search => 'بحث';

  @override
  String get unknown => 'غير معروف';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get errorGeneric => 'حدث خطأ ما';

  @override
  String get failed => 'فشلت العملية';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get justNow => 'الآن';

  @override
  String get phoneTitle => 'أدخل رقم هاتفك';

  @override
  String get phoneSubtitle =>
      'سنرسل إليك رمز التحقق عبر الرسائل القصيرة أو واتساب.';

  @override
  String get phoneFieldLabel => 'رقم الهاتف';

  @override
  String get phoneFieldHint => '750 123 4567';

  @override
  String get phoneInvalid => 'رقم الهاتف غير صحيح';

  @override
  String get channelSms => 'رسالة نصية';

  @override
  String get channelWhatsapp => 'واتساب';

  @override
  String get sendCode => 'إرسال الرمز';

  @override
  String get termsAndPrivacyAgree =>
      'بمتابعتك فإنك توافق على شروط الاستخدام وسياسة الخصوصية.';

  @override
  String get otpTitle => 'رمز التحقق';

  @override
  String otpSentVia(String channel) {
    return 'أرسلنا رمزاً مكوناً من 6 أرقام عبر $channel إلى ';
  }

  @override
  String get otpDevMode => 'وضع المطوّر — رمزك:';

  @override
  String get otpUse => 'استخدم';

  @override
  String otpResendIn(int seconds) {
    return 'إعادة إرسال الرمز خلال $seconds ث';
  }

  @override
  String get otpResend => 'إعادة إرسال الرمز';

  @override
  String get otpVerify => 'تحقّق';

  @override
  String get otpCodeSentAgain => 'تم إرسال الرمز مجدداً';

  @override
  String get otpWrongCode => 'الرمز غير صحيح';

  @override
  String get nameTitle => 'ما اسمك؟';

  @override
  String get nameSubtitle => 'هذا هو الاسم الذي سيراه الآخرون عند اتصالك بهم.';

  @override
  String get nameFieldLabel => 'الاسم الكامل';

  @override
  String get nameValidationShort => 'أدخل اسمك';

  @override
  String get nameValidationLong => 'الاسم طويل جداً';

  @override
  String get finish => 'إنهاء';

  @override
  String get gmailTitle => 'اربط حساب جيميل';

  @override
  String get gmailSubtitle =>
      'اختياري. ربط حساب جوجل يساعد على استعادة حسابك ويُحسّن اقتراحات المتصلين.';

  @override
  String get gmailContinueWith => 'المتابعة باستخدام جوجل';

  @override
  String get gmailSkip => 'تخطٍّ الآن';

  @override
  String gmailSignInFailed(String error) {
    return 'فشل تسجيل الدخول بجوجل: $error';
  }

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navProtect => 'الحماية';

  @override
  String get navPremium => 'بريميوم';

  @override
  String get homeHello => 'مرحباً،';

  @override
  String get homeHelloFallbackName => 'صديقي';

  @override
  String get homeSettingsTooltip => 'الإعدادات';

  @override
  String homeSearchesLeft(int remaining, int limit) {
    return '$remaining من $limit عمليات بحث متبقية';
  }

  @override
  String get homeSearchHint => 'ابحث عن أي رقم هاتف أو اسم…';

  @override
  String get homeQuickActions => 'إجراءات سريعة';

  @override
  String get homeActionContacts => 'جهات الاتصال';

  @override
  String get homeActionContactsSubtitle => 'على هذا الجهاز';

  @override
  String get homeActionHistory => 'السجل';

  @override
  String get homeActionHistorySubtitle => 'المكالمات الأخيرة';

  @override
  String get homeActionBlock => 'حظر';

  @override
  String get homeActionBlockSubtitle => 'إدارة القائمة';

  @override
  String get homeActionPremium => 'بريميوم';

  @override
  String get homeActionPremiumSubtitle => 'بدون إعلانات';

  @override
  String get homeRecentCalls => 'المكالمات الأخيرة';

  @override
  String get homeSeeAll => 'عرض الكل';

  @override
  String get homeRecentEmptyTitle => 'لا توجد مكالمات حديثة بعد';

  @override
  String get homeRecentEmptyBody =>
      'اسمح بالوصول إلى الهاتف من شاشة السجل لعرض مكالماتك هنا.';

  @override
  String get homeRecentLoadFailedTitle => 'تعذّر تحميل سجل المكالمات';

  @override
  String get homeRecentLoadFailedBody =>
      'اسحب لأسفل في شاشة السجل لإعادة المحاولة.';

  @override
  String get homeWatchAdPlusOne => 'شاهد إعلاناً +1';

  @override
  String get homeWatchAdSuccess => 'تمت إضافة عملية بحث +1 — يمكنك البحث الآن.';

  @override
  String get homeWatchAdFail => 'تعذّرت إضافة المكافأة.';

  @override
  String get homeStatSpamBlocked => 'تم حظر الإزعاج';

  @override
  String get homeStatIdentified => 'تم التعرّف';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get sectionGeneral => 'عام';

  @override
  String get sectionCallsAndCallerId => 'المكالمات وهوية المتصل';

  @override
  String get sectionBlockAndSpam => 'الحظر والمكالمات المزعجة';

  @override
  String get sectionSupport => 'الدعم';

  @override
  String get sectionAccount => 'الحساب';

  @override
  String get yourName => 'اسمك';

  @override
  String get tileEditProfile => 'تعديل الملف الشخصي';

  @override
  String get tileCalls => 'المكالمات';

  @override
  String get tileTheme => 'المظهر';

  @override
  String get tileLanguage => 'اللغة';

  @override
  String get tileNotifications => 'الإشعارات';

  @override
  String get shareLocation => 'مشاركة موقعي';

  @override
  String get shareLocationSubtitle =>
      'أرسل موقعك للمساعدة في تحديد المكالمات المزعجة في منطقتك.';

  @override
  String get shareLocationDialogTitle => 'هل تريد مشاركة موقعك؟';

  @override
  String get shareLocationDialogBody =>
      'يستخدم يلو فاست كول موقعك للتعرف على الأرقام المزعجة النشطة في منطقتك. يمكنك إيقاف ذلك في أي وقت.';

  @override
  String get shareLocationNotNow => 'ليس الآن';

  @override
  String get shareLocationAllow => 'سماح';

  @override
  String get locationGetting => 'جارٍ تحديد موقعك…';

  @override
  String locationSaved(String lat, String lng) {
    return 'تم حفظ الموقع: $lat، $lng';
  }

  @override
  String get locationBlockedTitle => 'تم حظر إذن الموقع';

  @override
  String get locationBlockedBody =>
      'لقد رفضت سابقاً إذن الوصول إلى الموقع. للسماح به الآن، افتح صفحة أذونات التطبيق ثم اضغط على «الموقع ← سماح».';

  @override
  String get openPermissions => 'فتح الأذونات';

  @override
  String get callerIdOverlay => 'عرض هوية المتصل';

  @override
  String get callerIdOverlaySubtitle =>
      'عرض معلومات المتصل أثناء المكالمات الواردة';

  @override
  String get afterCallScreen => 'شاشة ما بعد المكالمة';

  @override
  String get afterCallScreenSubtitle => 'عرض تفاصيل المتصل عند انتهاء المكالمة';

  @override
  String get showAlternateNumbers => 'عرض الأرقام البديلة';

  @override
  String get showAlternateNumbersSubtitle =>
      'عرض الأرقام الأخرى المرتبطة بجهة الاتصال';

  @override
  String get defaultCallScreener => 'فارز المكالمات الافتراضي';

  @override
  String get setAsDefaultCallScreener => 'تعيين كفارز افتراضي للمكالمات';

  @override
  String get callScreenerActive => 'مُفعّل';

  @override
  String get callScreenerOff => 'متوقّف';

  @override
  String get callScreenerSetSuccess =>
      'تم تعيين يلو فاست كول كفارز افتراضي للمكالمات.';

  @override
  String get callScreenerSetFailure =>
      'تعذّر التعيين كافتراضي. حاول من إعدادات النظام.';

  @override
  String get blockSpam => 'حظر المكالمات المزعجة';

  @override
  String get blockSpamSubtitle => 'رفض المكالمات المُبلَّغ عنها كمزعجة';

  @override
  String get blockScam => 'حظر الاحتيال';

  @override
  String get blockScamSubtitle => 'رفض المكالمات المُصنَّفة كاحتيال أو نصب';

  @override
  String get silenceUnknown => 'كتم المتصلين المجهولين';

  @override
  String get silenceUnknownSubtitle =>
      'إرسال الأرقام المجهولة إلى البريد الصوتي';

  @override
  String get intlSpamFilter => 'فلتر المكالمات الدولية المزعجة';

  @override
  String get intlSpamFilterSubtitle => 'حظر الأرقام الأجنبية المشبوهة';

  @override
  String get manageBlockList => 'إدارة قائمة الحظر';

  @override
  String get helpCenter => 'مركز المساعدة';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountTitle => 'هل تريد حذف الحساب؟';

  @override
  String get deleteAccountBody =>
      'سيتم حذف حسابك وتسجيل خروجك من هذا الجهاز. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get accountDeleted => 'تم حذف الحساب.';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeSystem => 'النظام';

  @override
  String get languageDialogTitle => 'اللغة';

  @override
  String languageSetTo(String language) {
    return 'تم تعيين اللغة إلى $language.';
  }

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get notificationsSheetSubtitle =>
      'عرض تنبيهات للمكالمات المحظورة وبلاغات الإزعاج وتحديثات التطبيق.';

  @override
  String get enableNotifications => 'تفعيل الإشعارات';

  @override
  String get openSystemSettings => 'فتح إعدادات النظام';

  @override
  String get notificationsOn => 'مُفعّلة';

  @override
  String get notificationsOff => 'متوقّفة';

  @override
  String get chooseFromGallery => 'الاختيار من المعرض';

  @override
  String get takeAPhoto => 'التقاط صورة';

  @override
  String get profilePictureUpdated => 'تم تحديث صورة الملف الشخصي';

  @override
  String couldNotSetPicture(String error) {
    return 'تعذّر تعيين الصورة: $error';
  }

  @override
  String get contactsTitle => 'جهات اتصالي';

  @override
  String get contactsSyncNow => 'مزامنة الآن';

  @override
  String contactsSyncFailed(String error) {
    return 'فشلت المزامنة: $error';
  }

  @override
  String contactsUploadedCount(int count) {
    return 'تم رفع $count جهة اتصال';
  }

  @override
  String get contactsSearchHint => 'ابحث عن اسم أو رقم…';

  @override
  String get contactsEmpty => 'لا توجد جهات اتصال على هذا الجهاز.';

  @override
  String contactsNoMatches(String query) {
    return 'لا نتائج لـ \"$query\".';
  }

  @override
  String contactsLastUpload(int count, String time) {
    return 'آخر رفع: $count جهة اتصال في $time';
  }

  @override
  String get contactsNotUploaded =>
      'لم تتم المزامنة بعد — اضغط أيقونة السحابة للمزامنة.';

  @override
  String get contactsNoPhone => '— لا يوجد رقم —';

  @override
  String get contactsNoName => '(بدون اسم)';

  @override
  String get contactsPermissionNeeded => 'إذن الوصول إلى جهات الاتصال مطلوب.';

  @override
  String get contactsPermissionHelp =>
      'افتح الإعدادات ← يلو فاست كول ← الأذونات ← جهات الاتصال ← سماح.';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get tryAgain => 'إعادة المحاولة';

  @override
  String contactsLastSyncFailed(String message) {
    return 'فشلت آخر مزامنة: $message';
  }

  @override
  String get syncGatePreparing => 'جارٍ التحضير…';

  @override
  String get syncGateAllowAccessTitle => 'اسمح بالوصول إلى جهات الاتصال';

  @override
  String get syncGateAllowAccessBody =>
      'يحتاج يلو فاست كول إلى جهات اتصالك للتعرف على المتصلين المجهولين واكتشاف الإزعاج. تبقى جهات اتصالك مشفّرة أثناء الإرسال.';

  @override
  String get syncGateAllowAccessButton => 'السماح بالوصول إلى جهات الاتصال';

  @override
  String get syncGateSyncingTitle => 'جارٍ مزامنة جهات اتصالك';

  @override
  String get syncGateSyncingBody =>
      'جارٍ الرفع إلى الخادم. يستغرق ذلك عادةً بضع ثوانٍ.';

  @override
  String get syncGateFailedTitle => 'فشلت المزامنة';

  @override
  String get syncGateAllSetTitle => 'تم بنجاح!';

  @override
  String syncGateAllSetBody(int count) {
    return 'تم رفع $count جهة اتصال. جارٍ المتابعة…';
  }

  @override
  String get syncGateReadyTitle => 'جاهز للمزامنة';

  @override
  String get syncGateReadyBody => 'اضغط للبدء';

  @override
  String get syncGateStart => 'بدء المزامنة';

  @override
  String get syncGateMustSync =>
      'لا يمكنك المتابعة حتى تتم مزامنة جهات الاتصال.';

  @override
  String get syncGatePermBlocked =>
      'تم رفض الإذن نهائياً. افتح الإعدادات لتفعيل جهات الاتصال.';

  @override
  String get historyTitle => 'المكالمات الأخيرة';

  @override
  String get historyRefresh => 'تحديث';

  @override
  String get historyCallTypeIncoming => 'واردة';

  @override
  String get historyCallTypeOutgoing => 'صادرة';

  @override
  String get historyCallTypeMissed => 'فائتة';

  @override
  String get historyCallTypeRejected => 'مرفوضة';

  @override
  String get historyCallTypeBlocked => 'محظورة';

  @override
  String get historyCallTypeVoicemail => 'بريد صوتي';

  @override
  String get historyCallTypeCall => 'مكالمة';

  @override
  String get historyEmptyTitle => 'لا توجد مكالمات حديثة';

  @override
  String get historyEmptyBody =>
      'اسمح بالوصول إلى الهاتف لعرض سجل مكالماتك والتعرّف على الأرقام المجهولة.';

  @override
  String get historyAllowPhone => 'السماح بالوصول إلى الهاتف';

  @override
  String get historyLoadFailed => 'تعذّر تحميل سجل المكالمات';

  @override
  String minAgo(int minutes) {
    return 'قبل $minutes د';
  }

  @override
  String get searchTitle => 'بحث';

  @override
  String get searchModeNumber => 'رقم';

  @override
  String get searchModeName => 'اسم';

  @override
  String get searchEnterNumber => 'أدخل الرقم للبحث.';

  @override
  String get searchPhoneField => 'رقم الهاتف';

  @override
  String get searchTypeName => 'اكتب اسماً';

  @override
  String get searchInvalidPhone => 'رقم الهاتف غير صحيح';

  @override
  String get searchEmptyNumberHint => 'اختر الدولة وأدخل الرقم للبحث عنه.';

  @override
  String get searchEmptyNameHint => 'اكتب اسماً ثم اضغط بحث.';

  @override
  String searchRegisteredUsers(int count) {
    return 'مستخدمون مسجّلون ($count)';
  }

  @override
  String searchEveryonesContacts(int count) {
    return 'من جهات اتصال الجميع ($count)';
  }

  @override
  String get searchUnnamedUser => 'مستخدم بدون اسم';

  @override
  String get searchUnknown => 'غير معروف';

  @override
  String searchUploads(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count رفعة',
      many: '$count رفعة',
      few: '$count رفعات',
      two: 'رفعتان',
      one: 'رفعة واحدة',
      zero: 'بدون رفع',
    );
    return '$_temp0';
  }

  @override
  String get searchAdAdded => 'تمت إضافة عملية بحث +1. إعادة المحاولة…';

  @override
  String get searchAdAddedLoading =>
      'تمت إضافة عملية بحث +1. جارٍ تحميل النتيجة…';

  @override
  String get searchAdFail => 'تعذّر إضافة المكافأة. حاول لاحقاً.';

  @override
  String get searchQuotaTitle => 'تم استنفاد حد البحث اليومي';

  @override
  String searchQuotaBody(String used, String limit) {
    return 'استخدمت $used/$limit عمليات بحث خلال الـ 24 ساعة الماضية.';
  }

  @override
  String searchQuotaReset(String when) {
    return 'البحث التالي متاح $when.';
  }

  @override
  String get searchWatchAdForReward => 'شاهد إعلاناً للحصول على +1 بحث';

  @override
  String get searchAdMaxUsed =>
      'لقد استخدمت الحد الأقصى من عمليات البحث الإعلانية لليوم.';

  @override
  String get searchShowNumber => 'إظهار الرقم';

  @override
  String get searchRelMoment => 'بعد لحظات';

  @override
  String searchRelMinutes(int minutes) {
    return 'خلال $minutes د';
  }

  @override
  String searchRelHoursMinutes(int hours, int minutes) {
    return 'خلال $hours س $minutes د';
  }

  @override
  String searchRelDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'خلال $days يوم',
      many: 'خلال $days يوماً',
      few: 'خلال $days أيام',
      two: 'خلال يومين',
      one: 'خلال يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String get callerInfoTitle => 'معلومات المتصل';

  @override
  String get callerInfoLoadFailed => 'تعذّر تحميل معلومات المتصل';

  @override
  String get callerInfoVerifiedUser => 'مستخدم موثّق على يلو فاست كول';

  @override
  String callerInfoSpamFlag(int count) {
    return 'تم الإبلاغ كإزعاج ($count)';
  }

  @override
  String get callerInfoRegistered => 'مستخدم مسجّل';

  @override
  String get callerInfoIdentified => 'متعرَّف عليه من المجتمع';

  @override
  String get callerInfoNotInDir => 'غير موجود في الدليل بعد';

  @override
  String get callerInfoAlsoSavedAs => 'محفوظ أيضاً باسم';

  @override
  String callerInfoMoreNotShown(int count) {
    return '+$count المزيد';
  }

  @override
  String get callerInfoRegisteredAccount => 'الحساب المسجّل';

  @override
  String get callerInfoLoginName => 'اسم الدخول';

  @override
  String get callerInfoEmail => 'البريد الإلكتروني';

  @override
  String get callerInfoMemberSince => 'عضو منذ';

  @override
  String get callerInfoAbout => 'حول هذا الرقم';

  @override
  String get callerInfoMostLikelyName => 'الاسم الأكثر احتمالاً';

  @override
  String get callerInfoCountry => 'الدولة';

  @override
  String get callerInfoSeenBy => 'شاهده';

  @override
  String get callerInfoNobodyYet => 'لا أحد بعد';

  @override
  String callerInfoUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مستخدم',
      many: '$count مستخدماً',
      few: '$count مستخدمين',
      two: 'مستخدمان',
      one: 'مستخدم واحد',
      zero: 'لا مستخدمين',
    );
    return '$_temp0';
  }

  @override
  String get callerInfoDifferentNames => 'أسماء مختلفة تم رفعها';

  @override
  String get callerInfoHowOthers => 'كيف حفظ الآخرون هذا الرقم';

  @override
  String callerInfoTopOf(int shown, int total) {
    return 'أعلى $shown من أصل $total أسماء مختلفة في الدليل';
  }

  @override
  String callerInfoNamesAcross(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count اسم مختلف في الدليل',
      many: '$count اسماً مختلفاً في الدليل',
      few: '$count أسماء مختلفة في الدليل',
      two: 'اسمان مختلفان في الدليل',
      one: 'اسم واحد مختلف في الدليل',
    );
    return '$_temp0';
  }

  @override
  String callerInfoPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count شخص',
      many: '$count شخصاً',
      few: '$count أشخاص',
      two: 'شخصان',
      one: 'شخص واحد',
    );
    return '$_temp0';
  }

  @override
  String callerInfoHiddenMore(int count) {
    return '+$count غير معروضين';
  }

  @override
  String get callerInfoCommunityReports => 'بلاغات المجتمع';

  @override
  String get callerInfoSpamReports => 'بلاغات الإزعاج';

  @override
  String get callerInfoStatus => 'الحالة';

  @override
  String get callerInfoFlagged => 'مُبلَّغ عنه كإزعاج';

  @override
  String get callerInfoNotFlagged => 'غير مُبلَّغ عنه';

  @override
  String get addPicture => 'إضافة صورة';

  @override
  String get changePicture => 'تغيير الصورة';

  @override
  String get manageBlocking => 'إدارة الحظر';

  @override
  String get manageBlockingSubtitle => 'قائمة الحظر وإعدادات الإزعاج والاحتيال';

  @override
  String get upgradeToPremium => 'الترقية إلى Premium';

  @override
  String get upgradeToPremiumSubtitle => 'بحث غير محدود وميزات كاملة';

  @override
  String get whoSearchedMe => 'من بحث عني';

  @override
  String get whoSearchedMeSubtitle => 'اطّلع على من بحث عن رقمك';

  @override
  String get premiumHeroTitle => 'يلو فاست بريميوم';

  @override
  String get premiumHeroSubtitle =>
      'افتح كامل قوة هوية المتصل.\nبدون إعلانات. بحث غير محدود.';

  @override
  String get premiumFeatureIdentify => 'تعرّف على أي رقم';

  @override
  String get premiumFeatureUnlimited => 'بحث غير محدود';

  @override
  String get premiumFeatureNoAds => 'بدون إعلانات';

  @override
  String get premiumFeatureSpamFilter => 'فلتر متقدّم للإزعاج';

  @override
  String get premiumFeatureBadges => 'شارات حصرية للبريميوم';

  @override
  String get premiumFeaturePriority => 'دعم بأولوية';

  @override
  String get premiumPlanMonthly => 'شهري';

  @override
  String get premiumPlanYearly => 'سنوي';

  @override
  String get premiumPlanLifetime => 'مدى الحياة';

  @override
  String get premiumPeriodMonth => '/ شهرياً';

  @override
  String get premiumPeriodYear => '/ سنوياً';

  @override
  String get premiumPeriodOneTime => 'دفعة واحدة';

  @override
  String get premiumBadgeBest => 'الأفضل';

  @override
  String get premiumUpgradeNow => 'الترقية الآن';

  @override
  String get premiumCancelAnytime =>
      'يمكنك الإلغاء في أي وقت. الاشتراكات تتجدّد تلقائياً.';

  @override
  String get premiumNotWired => 'الدفع غير مفعّل بعد';

  @override
  String get premiumUnlockHistory => 'افتح كامل السجل مع بريميوم';

  @override
  String get protectTitle => 'الحماية';

  @override
  String get protectSubtitle =>
      'حظر الإزعاج والاحتيال والمتصلين غير المرغوب فيهم تلقائياً.';

  @override
  String get protectShieldActive => 'أنت محمي';

  @override
  String get protectShieldInactive => 'الحماية متوقّفة';

  @override
  String protectShieldActiveBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم حظر $count مكالمة حتى الآن.',
      many: 'تم حظر $count مكالمة حتى الآن.',
      few: 'تم حظر $count مكالمات حتى الآن.',
      two: 'تم حظر مكالمتين حتى الآن.',
      one: 'تم حظر مكالمة واحدة حتى الآن.',
      zero: 'لم يتم حظر أي مكالمة بعد.',
    );
    return '$_temp0';
  }

  @override
  String get protectShieldInactiveBody => 'اضغط أدناه لتفعيل فرز المكالمات.';

  @override
  String get protectScreeningEnabledMsg => 'تم تفعيل فرز المكالمات.';

  @override
  String get protectScreeningNeededMsg =>
      'تحتاج إلى السماح بفرز المكالمات حتى يعمل الحظر.';

  @override
  String get protectSetDefaultBanner =>
      'فعّل فرز المكالمات حتى يستطيع التطبيق حظر المكالمات فعلياً.';

  @override
  String get protectCallerIdBanner =>
      'فعّل نافذة معرّف المتصل لإظهار الأسماء عند المكالمات الواردة.';

  @override
  String get protectCallerIdEnabledMsg => 'نافذة معرّف المتصل مفعّلة.';

  @override
  String get protectCallerIdNeededMsg =>
      'اسمح بـ \"العرض فوق التطبيقات الأخرى\" لرؤية أسماء المتصلين.';

  @override
  String get protectSettingsSection => 'إعدادات الحماية';

  @override
  String get protectBlockSpamTitle => 'حظر المكالمات المزعجة';

  @override
  String get protectBlockSpamBody => 'حظر الأرقام المزعجة المعروفة تلقائياً.';

  @override
  String get protectBlockScamTitle => 'حظر الاحتيال';

  @override
  String get protectBlockScamBody =>
      'إيقاف مكالمات الاحتيال قبل أن ترنّ هاتفك.';

  @override
  String get protectSilenceUnknownTitle => 'كتم الأرقام المجهولة';

  @override
  String get protectSilenceUnknownBody =>
      'إرسال المتصلين المجهولين مباشرة إلى البريد الصوتي.';

  @override
  String get protectIntlFilterTitle => 'فلتر المكالمات الدولية المزعجة';

  @override
  String get protectIntlFilterBody => 'حظر الأرقام الدولية المشبوهة.';

  @override
  String get protectBlockListSection => 'قائمة الحظر';

  @override
  String get protectAddNumber => 'إضافة رقم';

  @override
  String get protectBlockDialogTitle => 'حظر رقم';

  @override
  String get protectBlockDialogPhoneHint => '+966 555 123 4567';

  @override
  String get protectBlockDialogNameLabel => 'الاسم (اختياري)';

  @override
  String get protectBlockButton => 'حظر';

  @override
  String get protectAddedToBlockList => 'تمت إضافة الرقم إلى قائمة الحظر.';

  @override
  String get protectAlreadyBlocked => 'الرقم محظور بالفعل.';

  @override
  String get protectEmptyBlockListTitle => 'لا توجد أرقام محظورة بعد';

  @override
  String get protectEmptyBlockListBody =>
      'اضغط «إضافة رقم» لحظر رقم هاتف يدوياً.';

  @override
  String get protectBlockedSubtitle => 'محظور';

  @override
  String get protectUnblock => 'إلغاء الحظر';

  @override
  String get enableProtectionTitle => 'تفعيل الحماية';

  @override
  String get enableProtectionBody =>
      'اسمح ليلو فاست كول بحظر الإزعاج والاحتيال والمتصلين غير المرغوب فيهم تلقائياً.';

  @override
  String get enableProtectionShareLocation => 'مشاركة موقعي';

  @override
  String get enableProtectionShareLocationSub =>
      'يساعد في تحديد أنماط الإزعاج في منطقتك.';

  @override
  String get enableProtectionBulletSpamTitle => 'حظر مكالمات الإزعاج والاحتيال';

  @override
  String get enableProtectionBulletSpamBody =>
      'رفض الأرقام السيئة المعروفة قبل أن ترنّ هاتفك.';

  @override
  String get enableProtectionBulletSilenceTitle => 'كتم المتصلين المجهولين';

  @override
  String get enableProtectionBulletSilenceBody =>
      'إرسال الغرباء مباشرة إلى البريد الصوتي.';

  @override
  String get enableProtectionBulletIntlTitle => 'فلتر دولي';

  @override
  String get enableProtectionBulletIntlBody => 'حظر الأرقام الأجنبية المشبوهة.';

  @override
  String get enableProtectionFootnote =>
      'يمكنك تغيير هذا في أي وقت من الإعدادات.';

  @override
  String get enableProtectionLaterMsg =>
      'يمكنك تفعيل الحماية لاحقاً من الإعدادات أو من شاشة الحماية.';

  @override
  String get permissionsTitle => 'الأذونات';

  @override
  String get permissionsSubtitle =>
      'اضغط على كل إذن للسماح به. يمكنك تغيير ذلك لاحقاً من الإعدادات.';

  @override
  String get permContactsTitle => 'جهات الاتصال';

  @override
  String get permContactsDesc => 'للتعرّف على جهات اتصالك وحماية أرقامهم.';

  @override
  String get permLocationTitle => 'الموقع';

  @override
  String get permLocationDesc => 'لعرض معلومات محلية عن المتصلين القريبين منك.';

  @override
  String get permPhoneTitle => 'الهاتف';

  @override
  String get permPhoneDesc => 'لاكتشاف المكالمات الواردة وعرض معلومات المتصل.';

  @override
  String get permWhyTitle => 'لنُجهّز التطبيق لك';

  @override
  String get permWhySubtitle =>
      'يحتاج يلو فاست كول إلى بعض الأذونات للتعرّف على المتصلين وحظر الإزعاج. سيطلب منك هاتفك السماح بكلٍّ منها — فقط اضغط «سماح».';

  @override
  String get permWhyLocationHeading => 'لماذا نطلب موقعك';

  @override
  String get permLocationReason1 =>
      'اكتشاف أرقام الإزعاج والاحتيال النشطة في منطقتك';

  @override
  String get permLocationReason2 =>
      'إظهار المدينة أو المنطقة التي تأتي منها المكالمة المجهولة';

  @override
  String get permLocationReason3 =>
      'تحذيرك من أنماط الاحتيال المُبلّغ عنها بالقرب منك';

  @override
  String get permLocationReason4 => 'جعل التعرّف على المتصلين أكثر دقة في بلدك';

  @override
  String get permLocationPrivacyNote =>
      'لا يظهر موقعك الدقيق لأي مستخدم آخر، ويمكنك إيقافه في أي وقت من الإعدادات.';

  @override
  String get permAllowAll => 'السماح والمتابعة';

  @override
  String get permFooterNote => 'يمكنك تغيير كل ذلك لاحقاً من الإعدادات.';

  @override
  String get locReminderTitle => 'شارك موقعك';

  @override
  String get locReminderBody =>
      'يساعد في تحديد المكالمات المزعجة في منطقتك. يتم التحديث كل بضعة أيام.';

  @override
  String get locReminderNotNow => 'ليس الآن';

  @override
  String get locReminderTurnOn => 'تفعيل';

  @override
  String get callsTitle => 'المكالمات';

  @override
  String get callsSectionGeneral => 'عام';

  @override
  String get callsTroubleshootTitle => 'حلّ مشاكل المكالمات';

  @override
  String get callsTroubleshootSub => 'إصلاح مشاكل هوية المتصل والفرز';

  @override
  String get callsDisplayStyleTitle => 'نمط العرض';

  @override
  String get callsDisplayStyleSub =>
      'كيف تظهر معلومات المتصل عند المكالمات الواردة';

  @override
  String get callsIdentifyOtherAppsTitle => 'تعريف الأرقام في التطبيقات الأخرى';

  @override
  String get callsIdentifyOtherAppsSub =>
      'عرض معلومات المتصل في واتساب وماسنجر وغيرها';

  @override
  String get callsSectionHistory => 'سجل المكالمات';

  @override
  String get callsGroupCallsTitle => 'تجميع المكالمات في السجل';

  @override
  String get callsGroupCallsSub => 'دمج المكالمات المتكرّرة من نفس الرقم';

  @override
  String get callsShowFrequentTitle => 'عرض جهات الاتصال المتكرّرة';

  @override
  String get callsShowFrequentSub =>
      'إبراز أكثر جهات اتصالك تواصلاً في شاشة المكالمات';

  @override
  String get callsShowFromOtherAppsTitle => 'عرض مكالمات التطبيقات الأخرى';

  @override
  String get callsShowFromOtherAppsSub =>
      'تضمين واتساب وتيليجرام وما شابه في السجل';

  @override
  String get callsSectionNotifications => 'الإشعارات';

  @override
  String get callsAlertNotifTitle => 'إشعار تنبيه المكالمة';

  @override
  String get callsAlertNotifSub => 'إعلامك عند اتصال رقم مجهول';

  @override
  String get callsMissedNotifTitle => 'إشعار المكالمات الفائتة';

  @override
  String get callsMissedNotifSub => 'عرض إشعار لكل مكالمة فائتة';

  @override
  String get callsRemindMissedTitle => 'ذكّرني بالمكالمات الفائتة';

  @override
  String get callsRemindMissedSub => 'إرسال تذكير لاحق بعد كل مكالمة فائتة';

  @override
  String get callsDisplayStylePickerSub =>
      'اختر كيف تظهر معلومات المتصل عند الاتصال.';

  @override
  String get callsDisplayFullScreen => 'شاشة كاملة';

  @override
  String get callsDisplayFullScreenSub => 'يأخذ كامل الشاشة أثناء المكالمة';

  @override
  String get callsDisplayClassicPopup => 'نافذة كلاسيكية';

  @override
  String get callsDisplayClassicPopupSub => 'نافذة صغيرة عائمة فوق الشاشة';

  @override
  String callsDisplayStyleChanged(String style) {
    return 'نمط العرض: $style';
  }

  @override
  String get callsTroubleshootIntro =>
      'إذا لم تظهر هوية المتصل أو لم يتم التعرّف على المكالمات، جرّب هذه الخطوات:';

  @override
  String get callsTipDefault =>
      'اضبط يلو فاست كول كتطبيق افتراضي لهوية المتصل والإزعاج.';

  @override
  String get callsTipOverlay =>
      'اسمح للتطبيق بالرسم فوق التطبيقات الأخرى (التراكب).';

  @override
  String get callsTipNotifications =>
      'اسمح بالإشعارات حتى تعمل التنبيهات وتذكيرات المكالمات الفائتة.';

  @override
  String get callsTipBattery =>
      'أوقف تحسين البطارية حتى يستطيع التطبيق العمل في الخلفية.';

  @override
  String get callsTipPermissions =>
      'امنح أذونات جهات الاتصال والهاتف ليتمكّن التطبيق من قراءة الأرقام الواردة.';

  @override
  String get callsOpenAppSettings => 'فتح إعدادات التطبيق';

  @override
  String get profileEditTitle => 'تعديل الملف الشخصي';

  @override
  String get profileUpdatedMsg => 'تم تحديث الملف الشخصي';

  @override
  String get profileSaveFailedMsg => 'تعذّر حفظ الملف الشخصي';

  @override
  String get profileAddPicture => 'إضافة صورة شخصية';

  @override
  String get profileChangePicture => 'تغيير الصورة';

  @override
  String get profileFullName => 'الاسم الكامل';

  @override
  String get profileFullNameHelper => 'يمكنك تغيير اسمك مرة واحدة كل 7 أيام.';

  @override
  String profileFullNameLockedDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'مغلق لـ $days يوم إضافي. يمكنك تغيير اسمك مرة كل 7 أيام.',
      many: 'مغلق لـ $days يوماً إضافياً. يمكنك تغيير اسمك مرة كل 7 أيام.',
      few: 'مغلق لـ $days أيام إضافية. يمكنك تغيير اسمك مرة كل 7 أيام.',
      two: 'مغلق ليومين إضافيين. يمكنك تغيير اسمك مرة كل 7 أيام.',
      one: 'مغلق ليوم واحد إضافي. يمكنك تغيير اسمك مرة كل 7 أيام.',
    );
    return '$_temp0';
  }

  @override
  String profileFullNameLockedHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'مغلق لـ $hours ساعة إضافية.',
      many: 'مغلق لـ $hours ساعة إضافية.',
      few: 'مغلق لـ $hours ساعات إضافية.',
      two: 'مغلق لساعتين إضافيتين.',
      one: 'مغلق لساعة إضافية واحدة.',
    );
    return '$_temp0';
  }

  @override
  String profileFullNameLockedMinutes(int mins) {
    String _temp0 = intl.Intl.pluralLogic(
      mins,
      locale: localeName,
      other: 'مغلق لـ $mins دقيقة إضافية.',
      many: 'مغلق لـ $mins دقيقة إضافية.',
      few: 'مغلق لـ $mins دقائق إضافية.',
      two: 'مغلق لدقيقتين إضافيتين.',
      one: 'مغلق لدقيقة إضافية واحدة.',
    );
    return '$_temp0';
  }

  @override
  String get profilePhoneVerified => 'رقم الهاتف (موثّق)';

  @override
  String get profileGmailOptional => 'جيميل (اختياري)';

  @override
  String get profilePreviousNames => 'الأسماء السابقة';

  @override
  String get whoSearchedMeTitle => 'من بحث عني';

  @override
  String whoSearchedMePeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'بحث $count شخص عن رقمك',
      many: 'بحث $count شخصاً عن رقمك',
      few: 'بحث $count أشخاص عن رقمك',
      two: 'بحث شخصان عن رقمك',
      one: 'بحث شخص واحد عن رقمك',
      zero: 'لم يبحث عن رقمك أحد بعد',
    );
    return '$_temp0';
  }

  @override
  String get whoSearchedMeLast7Days =>
      'اطّلع على من بحث عن رقمك خلال آخر 7 أيام.';

  @override
  String get whoSearchedMeRecentSearches => 'عمليات البحث الأخيرة';
}
