// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Yellow Fast Call';

  @override
  String get appVersion => 'Yellow Fast Call v1.1.0';

  @override
  String get appTagline => 'Know who is calling';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingSlide1Title => 'Know who is calling';

  @override
  String get onboardingSlide1Subtitle =>
      'Identify unknown numbers in real time and never wonder who is on the other end.';

  @override
  String get onboardingSlide2Title => 'Block spam and scams';

  @override
  String get onboardingSlide2Subtitle =>
      'Automatic protection against telemarketers, scams and robocalls — before your phone rings.';

  @override
  String get onboardingSlide3Title => 'Your privacy, protected';

  @override
  String get onboardingSlide3Subtitle =>
      'Your data is encrypted end-to-end. You stay in control — delete or hide your number anytime.';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get continueAction => 'Continue';

  @override
  String get done => 'Done';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get search => 'Search';

  @override
  String get unknown => 'Unknown';

  @override
  String get loading => 'Loading…';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get failed => 'Failed';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get justNow => 'Just now';

  @override
  String get phoneTitle => 'Enter your phone number';

  @override
  String get phoneSubtitle =>
      'We will send you a verification code by SMS or WhatsApp.';

  @override
  String get phoneFieldLabel => 'Phone number';

  @override
  String get phoneFieldHint => '750 123 4567';

  @override
  String get phoneInvalid => 'Invalid phone number';

  @override
  String get channelSms => 'SMS';

  @override
  String get channelWhatsapp => 'WhatsApp';

  @override
  String get sendCode => 'Send code';

  @override
  String get termsAndPrivacyAgree =>
      'By continuing you agree to the Terms & Privacy Policy.';

  @override
  String get otpTitle => 'Verification code';

  @override
  String otpSentVia(String channel) {
    return 'We sent a 6-digit code via $channel to ';
  }

  @override
  String get otpDevMode => 'Dev mode — your code:';

  @override
  String get otpUse => 'Use';

  @override
  String otpResendIn(int seconds) {
    return 'Resend code in ${seconds}s';
  }

  @override
  String get otpResend => 'Resend code';

  @override
  String get otpVerify => 'Verify';

  @override
  String get otpCodeSentAgain => 'Code sent again';

  @override
  String get otpWrongCode => 'Wrong code';

  @override
  String get nameTitle => 'What is your name?';

  @override
  String get nameSubtitle =>
      'This is the name people will see when you call them.';

  @override
  String get nameFieldLabel => 'Full name';

  @override
  String get nameValidationShort => 'Enter your name';

  @override
  String get nameValidationLong => 'Name is too long';

  @override
  String get finish => 'Finish';

  @override
  String get gmailTitle => 'Link your Gmail';

  @override
  String get gmailSubtitle =>
      'Optional. Linking your Google account helps you recover your account and improves caller suggestions.';

  @override
  String get gmailContinueWith => 'Continue with Google';

  @override
  String get gmailSkip => 'Skip for now';

  @override
  String gmailSignInFailed(String error) {
    return 'Google sign-in failed: $error';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navProtect => 'Protect';

  @override
  String get navPremium => 'Premium';

  @override
  String get homeHello => 'Hello,';

  @override
  String get homeHelloFallbackName => 'there';

  @override
  String get homeSettingsTooltip => 'Settings';

  @override
  String homeSearchesLeft(int remaining, int limit) {
    return '$remaining of $limit searches left';
  }

  @override
  String get homeSearchHint => 'Search any phone number or name…';

  @override
  String get homeQuickActions => 'Quick actions';

  @override
  String get homeActionContacts => 'Contacts';

  @override
  String get homeActionContactsSubtitle => 'On this device';

  @override
  String get homeActionHistory => 'History';

  @override
  String get homeActionHistorySubtitle => 'Recent calls';

  @override
  String get homeActionBlock => 'Block';

  @override
  String get homeActionBlockSubtitle => 'Manage list';

  @override
  String get homeActionPremium => 'Premium';

  @override
  String get homeActionPremiumSubtitle => 'Go ad-free';

  @override
  String get homeRecentCalls => 'Recent calls';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homeRecentEmptyTitle => 'No recent calls yet';

  @override
  String get homeRecentEmptyBody =>
      'Allow phone access on the History screen to see your call log here.';

  @override
  String get homeRecentLoadFailedTitle => 'Could not load call history';

  @override
  String get homeRecentLoadFailedBody =>
      'Pull down on the History screen to try again.';

  @override
  String get homeWatchAdPlusOne => 'Watch ad +1';

  @override
  String get homeWatchAdSuccess => '+1 search added — you can search now.';

  @override
  String get homeWatchAdFail => 'Could not add bonus.';

  @override
  String get homeStatSpamBlocked => 'Spam blocked';

  @override
  String get homeStatIdentified => 'Identified';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sectionGeneral => 'General';

  @override
  String get sectionCallsAndCallerId => 'Calls & Caller ID';

  @override
  String get sectionBlockAndSpam => 'Block & Spam';

  @override
  String get sectionSupport => 'Support';

  @override
  String get sectionAccount => 'Account';

  @override
  String get yourName => 'Your name';

  @override
  String get tileEditProfile => 'Edit profile';

  @override
  String get tileCalls => 'Calls';

  @override
  String get tileTheme => 'Theme';

  @override
  String get tileLanguage => 'Language';

  @override
  String get tileNotifications => 'Notifications';

  @override
  String get shareLocation => 'Share my location';

  @override
  String get shareLocationSubtitle =>
      'Send your location to help identify regional spam.';

  @override
  String get shareLocationDialogTitle => 'Share your location?';

  @override
  String get shareLocationDialogBody =>
      'Yellow Fast Call uses your location to identify spam numbers active in your area. You can turn this off any time.';

  @override
  String get shareLocationNotNow => 'Not now';

  @override
  String get shareLocationAllow => 'Allow';

  @override
  String get locationGetting => 'Getting your location…';

  @override
  String locationSaved(String lat, String lng) {
    return 'Location saved: $lat, $lng';
  }

  @override
  String get locationBlockedTitle => 'Location permission blocked';

  @override
  String get locationBlockedBody =>
      'You previously denied location access. To allow it now, open the app permissions page and tap Location → Allow.';

  @override
  String get openPermissions => 'Open permissions';

  @override
  String get callerIdOverlay => 'Caller ID overlay';

  @override
  String get callerIdOverlaySubtitle =>
      'Show caller info during incoming calls';

  @override
  String get afterCallScreen => 'After-call screen';

  @override
  String get afterCallScreenSubtitle => 'Show caller details when a call ends';

  @override
  String get showAlternateNumbers => 'Show alternate numbers';

  @override
  String get showAlternateNumbersSubtitle =>
      'Display other numbers linked to a contact';

  @override
  String get defaultCallScreener => 'Default call screener';

  @override
  String get setAsDefaultCallScreener => 'Set as default call screener';

  @override
  String get callScreenerActive => 'Active';

  @override
  String get callScreenerOff => 'Off';

  @override
  String get callScreenerSetSuccess =>
      'Yellow Fast Call is now your default call screener.';

  @override
  String get callScreenerSetFailure =>
      'Could not set as default. Try from system settings.';

  @override
  String get blockSpam => 'Block spam';

  @override
  String get blockSpamSubtitle => 'Reject calls reported as spam';

  @override
  String get blockScam => 'Block scam';

  @override
  String get blockScamSubtitle => 'Reject calls flagged as scam or fraud';

  @override
  String get silenceUnknown => 'Silence unknown callers';

  @override
  String get silenceUnknownSubtitle => 'Send unknown numbers to voicemail';

  @override
  String get intlSpamFilter => 'International spam filter';

  @override
  String get intlSpamFilterSubtitle => 'Block suspicious foreign numbers';

  @override
  String get manageBlockList => 'Manage block list';

  @override
  String get helpCenter => 'Help center';

  @override
  String get termsOfService => 'Terms of service';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountTitle => 'Delete account?';

  @override
  String get deleteAccountBody =>
      'Your account will be deleted and you will be signed out on this device. This action cannot be undone.';

  @override
  String get accountDeleted => 'Account deleted.';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String get languageDialogTitle => 'Language';

  @override
  String languageSetTo(String language) {
    return 'Language set to $language.';
  }

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get notificationsSheetSubtitle =>
      'Show alerts for blocked calls, spam reports and app updates.';

  @override
  String get enableNotifications => 'Enable notifications';

  @override
  String get openSystemSettings => 'Open system settings';

  @override
  String get notificationsOn => 'On';

  @override
  String get notificationsOff => 'Off';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get takeAPhoto => 'Take a photo';

  @override
  String get profilePictureUpdated => 'Profile picture updated';

  @override
  String couldNotSetPicture(String error) {
    return 'Could not set picture: $error';
  }

  @override
  String get contactsTitle => 'My contacts';

  @override
  String get contactsSyncNow => 'Sync now';

  @override
  String contactsSyncFailed(String error) {
    return 'Sync failed: $error';
  }

  @override
  String contactsUploadedCount(int count) {
    return 'Uploaded $count contacts';
  }

  @override
  String get contactsSearchHint => 'Search name or number…';

  @override
  String get contactsEmpty => 'No contacts on this device.';

  @override
  String contactsNoMatches(String query) {
    return 'No matches for \"$query\".';
  }

  @override
  String contactsLastUpload(int count, String time) {
    return 'Last upload: $count contacts at $time';
  }

  @override
  String get contactsNotUploaded =>
      'Not uploaded yet — tap the cloud icon to sync.';

  @override
  String get contactsNoPhone => '— no phone —';

  @override
  String get contactsNoName => '(no name)';

  @override
  String get contactsPermissionNeeded => 'Contacts permission is needed.';

  @override
  String get contactsPermissionHelp =>
      'Open settings → Yellow Fast Call → Permissions → Contacts → Allow.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get tryAgain => 'Try again';

  @override
  String contactsLastSyncFailed(String message) {
    return 'Last sync failed: $message';
  }

  @override
  String get syncGatePreparing => 'Preparing…';

  @override
  String get syncGateAllowAccessTitle => 'Allow contacts access';

  @override
  String get syncGateAllowAccessBody =>
      'Yellow Fast Call needs your contacts to identify unknown callers and detect spam. Your contacts stay encrypted in transit.';

  @override
  String get syncGateAllowAccessButton => 'Allow contacts access';

  @override
  String get syncGateSyncingTitle => 'Syncing your contacts';

  @override
  String get syncGateSyncingBody =>
      'Uploading to the server. This usually takes a few seconds.';

  @override
  String get syncGateFailedTitle => 'Sync failed';

  @override
  String get syncGateAllSetTitle => 'All set!';

  @override
  String syncGateAllSetBody(int count) {
    return 'Uploaded $count contacts. Continuing…';
  }

  @override
  String get syncGateReadyTitle => 'Ready to sync';

  @override
  String get syncGateReadyBody => 'Tap to start';

  @override
  String get syncGateStart => 'Start sync';

  @override
  String get syncGateMustSync =>
      'You can\'t continue until contacts are synced.';

  @override
  String get syncGatePermBlocked =>
      'Permission permanently denied. Open settings to enable Contacts.';

  @override
  String get historyTitle => 'Recent calls';

  @override
  String get historyRefresh => 'Refresh';

  @override
  String get historyCallTypeIncoming => 'Incoming';

  @override
  String get historyCallTypeOutgoing => 'Outgoing';

  @override
  String get historyCallTypeMissed => 'Missed';

  @override
  String get historyCallTypeRejected => 'Rejected';

  @override
  String get historyCallTypeBlocked => 'Blocked';

  @override
  String get historyCallTypeVoicemail => 'Voicemail';

  @override
  String get historyCallTypeCall => 'Call';

  @override
  String get historyEmptyTitle => 'No recent calls';

  @override
  String get historyEmptyBody =>
      'Allow phone access to see your call history and identify unknown numbers.';

  @override
  String get historyAllowPhone => 'Allow phone access';

  @override
  String get historyLoadFailed => 'Could not load call history';

  @override
  String minAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String get searchTitle => 'Search';

  @override
  String get searchModeNumber => 'Number';

  @override
  String get searchModeName => 'Name';

  @override
  String get searchEnterNumber => 'Enter the number to search.';

  @override
  String get searchPhoneField => 'Phone number';

  @override
  String get searchTypeName => 'Type a name';

  @override
  String get searchInvalidPhone => 'Invalid phone number';

  @override
  String get searchEmptyNumberHint =>
      'Pick a country and enter the number to look it up.';

  @override
  String get searchEmptyNameHint => 'Type a name, then Search.';

  @override
  String searchRegisteredUsers(int count) {
    return 'Registered users ($count)';
  }

  @override
  String searchEveryonesContacts(int count) {
    return 'From everyone\'s contacts ($count)';
  }

  @override
  String get searchUnnamedUser => 'Unnamed user';

  @override
  String get searchUnknown => 'Unknown';

  @override
  String searchUploads(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uploads',
      one: '1 upload',
    );
    return '$_temp0';
  }

  @override
  String get searchAdAdded => '+1 search added. Retrying…';

  @override
  String get searchAdAddedLoading => '+1 search added. Loading result…';

  @override
  String get searchAdFail => 'Could not add bonus. Try again later.';

  @override
  String get searchQuotaTitle => 'Daily search limit reached';

  @override
  String searchQuotaBody(String used, String limit) {
    return 'You used $used/$limit searches in the last 24 hours.';
  }

  @override
  String searchQuotaReset(String when) {
    return 'Next search available $when.';
  }

  @override
  String get searchWatchAdForReward => 'Watch ad for +1 search';

  @override
  String get searchAdMaxUsed =>
      'You\'ve already used the maximum number of ad-bonus searches for today.';

  @override
  String get searchShowNumber => 'Show number';

  @override
  String get searchRelMoment => 'in a moment';

  @override
  String searchRelMinutes(int minutes) {
    return 'in $minutes min';
  }

  @override
  String searchRelHoursMinutes(int hours, int minutes) {
    return 'in ${hours}h ${minutes}m';
  }

  @override
  String searchRelDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'in $days days',
      one: 'in 1 day',
    );
    return '$_temp0';
  }

  @override
  String get callerInfoTitle => 'Caller info';

  @override
  String get callerInfoLoadFailed => 'Could not load caller info';

  @override
  String get callerInfoVerifiedUser => 'Verified Yellow Fast Call user';

  @override
  String callerInfoSpamFlag(int count) {
    return 'Reported as spam ($count)';
  }

  @override
  String get callerInfoRegistered => 'Registered user';

  @override
  String get callerInfoIdentified => 'Identified by community';

  @override
  String get callerInfoNotInDir => 'Not in directory yet';

  @override
  String get callerInfoAlsoSavedAs => 'Also saved as';

  @override
  String callerInfoMoreNotShown(int count) {
    return '+$count more';
  }

  @override
  String get callerInfoRegisteredAccount => 'Registered account';

  @override
  String get callerInfoLoginName => 'Login name';

  @override
  String get callerInfoEmail => 'Email';

  @override
  String get callerInfoMemberSince => 'Member since';

  @override
  String get callerInfoAbout => 'About this number';

  @override
  String get callerInfoMostLikelyName => 'Most likely name';

  @override
  String get callerInfoCountry => 'Country';

  @override
  String get callerInfoSeenBy => 'Seen by';

  @override
  String get callerInfoNobodyYet => 'Nobody yet';

  @override
  String callerInfoUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count users',
      one: '1 user',
    );
    return '$_temp0';
  }

  @override
  String get callerInfoDifferentNames => 'Different names uploaded';

  @override
  String get callerInfoHowOthers => 'How others saved this number';

  @override
  String callerInfoTopOf(int shown, int total) {
    return 'Top $shown of $total different names across the directory';
  }

  @override
  String callerInfoNamesAcross(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count different names across the directory',
      one: '1 different name across the directory',
    );
    return '$_temp0';
  }

  @override
  String callerInfoPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String callerInfoHiddenMore(int count) {
    return '+$count more not shown';
  }

  @override
  String get callerInfoCommunityReports => 'Community reports';

  @override
  String get callerInfoSpamReports => 'Spam reports';

  @override
  String get callerInfoStatus => 'Status';

  @override
  String get callerInfoFlagged => 'Flagged as spam';

  @override
  String get callerInfoNotFlagged => 'Not flagged';

  @override
  String get addPicture => 'Add picture';

  @override
  String get changePicture => 'Change picture';

  @override
  String get manageBlocking => 'Manage blocking';

  @override
  String get manageBlockingSubtitle => 'Block list, spam & scam settings';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get upgradeToPremiumSubtitle => 'Unlimited searches & full features';

  @override
  String get whoSearchedMe => 'Who searched me';

  @override
  String get whoSearchedMeSubtitle => 'See people who looked up your number';

  @override
  String get premiumHeroTitle => 'Yellow Fast Premium';

  @override
  String get premiumHeroSubtitle =>
      'Unlock the full caller ID power.\nNo ads. Unlimited searches.';

  @override
  String get premiumFeatureIdentify => 'Identify any number';

  @override
  String get premiumFeatureUnlimited => 'Unlimited searches';

  @override
  String get premiumFeatureNoAds => 'No ads';

  @override
  String get premiumFeatureSpamFilter => 'Advanced spam filter';

  @override
  String get premiumFeatureBadges => 'Premium-only badges';

  @override
  String get premiumFeaturePriority => 'Priority support';

  @override
  String get premiumPlanMonthly => 'Monthly';

  @override
  String get premiumPlanYearly => 'Yearly';

  @override
  String get premiumPlanLifetime => 'Lifetime';

  @override
  String get premiumPeriodMonth => '/ month';

  @override
  String get premiumPeriodYear => '/ year';

  @override
  String get premiumPeriodOneTime => 'one-time';

  @override
  String get premiumBadgeBest => 'BEST';

  @override
  String get premiumUpgradeNow => 'Upgrade now';

  @override
  String get premiumCancelAnytime =>
      'Cancel anytime. Subscriptions auto-renew.';

  @override
  String get premiumNotWired => 'Payments not wired yet';

  @override
  String get premiumUnlockHistory => 'Unlock full history with Premium';

  @override
  String get protectTitle => 'Protect';

  @override
  String get protectSubtitle =>
      'Block spam, scams and unwanted callers automatically.';

  @override
  String get protectShieldActive => 'You are protected';

  @override
  String get protectShieldInactive => 'Protection is off';

  @override
  String protectShieldActiveBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count calls blocked so far.',
      one: '1 call blocked so far.',
      zero: 'No calls blocked yet.',
    );
    return '$_temp0';
  }

  @override
  String get protectShieldInactiveBody => 'Tap below to enable call screening.';

  @override
  String get protectScreeningEnabledMsg => 'Call screening enabled.';

  @override
  String get protectScreeningNeededMsg =>
      'You need to allow call screening for blocking to work.';

  @override
  String get protectSetDefaultBanner =>
      'Enable call screening so the app can actually block calls.';

  @override
  String get protectCallerIdBanner =>
      'Turn on the Caller ID popup so names show on incoming calls.';

  @override
  String get protectCallerIdEnabledMsg => 'Caller ID popup is on.';

  @override
  String get protectCallerIdNeededMsg =>
      'Allow \"Display over other apps\" to see caller names.';

  @override
  String get protectSettingsSection => 'Protection settings';

  @override
  String get protectBlockSpamTitle => 'Block spam calls';

  @override
  String get protectBlockSpamBody => 'Automatically block known spam numbers.';

  @override
  String get protectBlockScamTitle => 'Block scams';

  @override
  String get protectBlockScamBody => 'Stop scam calls before they ring you.';

  @override
  String get protectSilenceUnknownTitle => 'Silence unknown numbers';

  @override
  String get protectSilenceUnknownBody =>
      'Send unknown callers straight to voicemail.';

  @override
  String get protectIntlFilterTitle => 'International spam filter';

  @override
  String get protectIntlFilterBody => 'Block suspicious international numbers.';

  @override
  String get protectBlockListSection => 'Block list';

  @override
  String get protectAddNumber => 'Add number';

  @override
  String get protectBlockDialogTitle => 'Block a number';

  @override
  String get protectBlockDialogPhoneHint => '+1 555 123 4567';

  @override
  String get protectBlockDialogNameLabel => 'Name (optional)';

  @override
  String get protectBlockButton => 'Block';

  @override
  String get protectAddedToBlockList => 'Number added to block list.';

  @override
  String get protectAlreadyBlocked => 'Number is already blocked.';

  @override
  String get protectEmptyBlockListTitle => 'No numbers blocked yet';

  @override
  String get protectEmptyBlockListBody =>
      'Tap \"Add number\" to block a phone number manually.';

  @override
  String get protectBlockedSubtitle => 'Blocked';

  @override
  String get protectUnblock => 'Unblock';

  @override
  String get enableProtectionTitle => 'Enable Protection';

  @override
  String get enableProtectionBody =>
      'Let Yellow Fast Call block spam, scams and unwanted callers automatically.';

  @override
  String get enableProtectionShareLocation => 'Share my location';

  @override
  String get enableProtectionShareLocationSub =>
      'Helps identify regional spam patterns.';

  @override
  String get enableProtectionBulletSpamTitle => 'Block spam & scam calls';

  @override
  String get enableProtectionBulletSpamBody =>
      'Reject known bad numbers before they ring.';

  @override
  String get enableProtectionBulletSilenceTitle => 'Silence unknown callers';

  @override
  String get enableProtectionBulletSilenceBody =>
      'Send strangers straight to voicemail.';

  @override
  String get enableProtectionBulletIntlTitle => 'International filter';

  @override
  String get enableProtectionBulletIntlBody =>
      'Block suspicious foreign numbers.';

  @override
  String get enableProtectionFootnote =>
      'You can change this anytime in Settings.';

  @override
  String get enableProtectionLaterMsg =>
      'You can enable protection later from Settings or Protect.';

  @override
  String get permissionsTitle => 'Permissions';

  @override
  String get permissionsSubtitle =>
      'Tap each permission to allow. You can change these later in settings.';

  @override
  String get permContactsTitle => 'Contacts';

  @override
  String get permContactsDesc =>
      'Identify your contacts and protect their numbers.';

  @override
  String get permLocationTitle => 'Location';

  @override
  String get permLocationDesc =>
      'Show local information about callers near you.';

  @override
  String get permPhoneTitle => 'Phone';

  @override
  String get permPhoneDesc =>
      'Detect incoming calls so we can show caller info.';

  @override
  String get permWhyTitle => 'Let\'s get you set up';

  @override
  String get permWhySubtitle =>
      'Yellow Fast Call needs a few permissions to identify callers and block spam. Your phone will ask you to allow each one — just tap Allow.';

  @override
  String get permWhyLocationHeading => 'Why we ask for your location';

  @override
  String get permLocationReason1 =>
      'Spot spam and scam numbers active in your area';

  @override
  String get permLocationReason2 =>
      'Show the city or region an unknown call comes from';

  @override
  String get permLocationReason3 =>
      'Warn you about fraud patterns reported nearby';

  @override
  String get permLocationReason4 =>
      'Make caller identification more accurate in your country';

  @override
  String get permLocationPrivacyNote =>
      'Your precise location is never shown to other users, and you can turn it off anytime in Settings.';

  @override
  String get permAllowAll => 'Allow & continue';

  @override
  String get permFooterNote => 'You can change all of these later in Settings.';

  @override
  String get locReminderTitle => 'Share your location';

  @override
  String get locReminderBody =>
      'Helps identify spam in your area. Updated every few days.';

  @override
  String get locReminderNotNow => 'Not now';

  @override
  String get locReminderTurnOn => 'Turn on';

  @override
  String get callsTitle => 'Calls';

  @override
  String get callsSectionGeneral => 'General';

  @override
  String get callsTroubleshootTitle => 'Troubleshoot calling';

  @override
  String get callsTroubleshootSub => 'Fix problems with caller ID & screening';

  @override
  String get callsDisplayStyleTitle => 'Display style';

  @override
  String get callsDisplayStyleSub =>
      'How caller info appears on incoming calls';

  @override
  String get callsIdentifyOtherAppsTitle => 'Identify numbers on other apps';

  @override
  String get callsIdentifyOtherAppsSub =>
      'Show caller info in WhatsApp, Messenger and more';

  @override
  String get callsSectionHistory => 'Call history';

  @override
  String get callsGroupCallsTitle => 'Group calls in call history';

  @override
  String get callsGroupCallsSub =>
      'Combine repeated calls from the same number';

  @override
  String get callsShowFrequentTitle => 'Show frequently called contacts';

  @override
  String get callsShowFrequentSub =>
      'Surface your top contacts on the call screen';

  @override
  String get callsShowFromOtherAppsTitle => 'Show calls from other apps';

  @override
  String get callsShowFromOtherAppsSub =>
      'Include WhatsApp, Telegram and similar in history';

  @override
  String get callsSectionNotifications => 'Notifications';

  @override
  String get callsAlertNotifTitle => 'Call alert notification';

  @override
  String get callsAlertNotifSub => 'Get notified when an unknown number calls';

  @override
  String get callsMissedNotifTitle => 'Missed call notification';

  @override
  String get callsMissedNotifSub => 'Show a notification for every missed call';

  @override
  String get callsRemindMissedTitle => 'Remind me of missed calls';

  @override
  String get callsRemindMissedSub =>
      'Send a follow-up reminder after a missed call';

  @override
  String get callsDisplayStylePickerSub =>
      'Pick how the caller info appears when someone calls.';

  @override
  String get callsDisplayFullScreen => 'Full screen';

  @override
  String get callsDisplayFullScreenSub =>
      'Takes the whole screen during a call';

  @override
  String get callsDisplayClassicPopup => 'Classic popup';

  @override
  String get callsDisplayClassicPopupSub =>
      'A small floating popup on top of your screen';

  @override
  String callsDisplayStyleChanged(String style) {
    return 'Display style: $style';
  }

  @override
  String get callsTroubleshootIntro =>
      'If caller ID is not showing or calls are not being identified, try these steps:';

  @override
  String get callsTipDefault =>
      'Set Yellow Fast Call as your default caller ID & spam app.';

  @override
  String get callsTipOverlay =>
      'Allow the app to draw over other apps (overlay).';

  @override
  String get callsTipNotifications =>
      'Allow notifications so alerts and missed call reminders work.';

  @override
  String get callsTipBattery =>
      'Disable battery optimization so the app can run in the background.';

  @override
  String get callsTipPermissions =>
      'Grant Contacts and Phone permissions so the app can read incoming numbers.';

  @override
  String get callsOpenAppSettings => 'Open app settings';

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get profileUpdatedMsg => 'Profile updated';

  @override
  String get profileSaveFailedMsg => 'Could not save profile';

  @override
  String get profileAddPicture => 'Add profile picture';

  @override
  String get profileChangePicture => 'Change picture';

  @override
  String get profileFullName => 'Full name';

  @override
  String get profileFullNameHelper =>
      'You can change your name once every 7 days.';

  @override
  String profileFullNameLockedDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other:
          'Locked for $days more days. You can change your name once every 7 days.',
      one: 'Locked for 1 more day. You can change your name once every 7 days.',
    );
    return '$_temp0';
  }

  @override
  String profileFullNameLockedHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'Locked for $hours more hours.',
      one: 'Locked for 1 more hour.',
    );
    return '$_temp0';
  }

  @override
  String profileFullNameLockedMinutes(int mins) {
    String _temp0 = intl.Intl.pluralLogic(
      mins,
      locale: localeName,
      other: 'Locked for $mins more minutes.',
      one: 'Locked for 1 more minute.',
    );
    return '$_temp0';
  }

  @override
  String get profilePhoneVerified => 'Phone number (verified)';

  @override
  String get profileGmailOptional => 'Gmail (optional)';

  @override
  String get profilePreviousNames => 'Previous names';

  @override
  String get whoSearchedMeTitle => 'Who searched me';

  @override
  String whoSearchedMePeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people searched your number',
      one: '1 person searched your number',
    );
    return '$_temp0';
  }

  @override
  String get whoSearchedMeLast7Days =>
      'See who looked you up in the last 7 days.';

  @override
  String get whoSearchedMeRecentSearches => 'Recent searches';
}
