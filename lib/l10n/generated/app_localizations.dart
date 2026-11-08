import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Yellow Fast Call'**
  String get appName;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Yellow Fast Call v1.1.0'**
  String get appVersion;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Know who is calling'**
  String get appTagline;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Know who is calling'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Identify unknown numbers in real time and never wonder who is on the other end.'**
  String get onboardingSlide1Subtitle;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Block spam and scams'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatic protection against telemarketers, scams and robocalls — before your phone rings.'**
  String get onboardingSlide2Subtitle;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Your privacy, protected'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your data is encrypted end-to-end. You stay in control — delete or hide your number anytime.'**
  String get onboardingSlide3Subtitle;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @phoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get phoneTitle;

  /// No description provided for @phoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We will send you a verification code by SMS or WhatsApp.'**
  String get phoneSubtitle;

  /// No description provided for @phoneFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneFieldLabel;

  /// No description provided for @phoneFieldHint.
  ///
  /// In en, this message translates to:
  /// **'750 123 4567'**
  String get phoneFieldHint;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get phoneInvalid;

  /// No description provided for @channelSms.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get channelSms;

  /// No description provided for @channelWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get channelWhatsapp;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @termsAndPrivacyAgree.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to the Terms & Privacy Policy.'**
  String get termsAndPrivacyAgree;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get otpTitle;

  /// No description provided for @otpSentVia.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code via {channel} to '**
  String otpSentVia(String channel);

  /// No description provided for @otpDevMode.
  ///
  /// In en, this message translates to:
  /// **'Dev mode — your code:'**
  String get otpDevMode;

  /// No description provided for @otpUse.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get otpUse;

  /// No description provided for @otpResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds}s'**
  String otpResendIn(int seconds);

  /// No description provided for @otpResend.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get otpResend;

  /// No description provided for @otpVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get otpVerify;

  /// No description provided for @otpCodeSentAgain.
  ///
  /// In en, this message translates to:
  /// **'Code sent again'**
  String get otpCodeSentAgain;

  /// No description provided for @otpWrongCode.
  ///
  /// In en, this message translates to:
  /// **'Wrong code'**
  String get otpWrongCode;

  /// No description provided for @nameTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your name?'**
  String get nameTitle;

  /// No description provided for @nameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This is the name people will see when you call them.'**
  String get nameSubtitle;

  /// No description provided for @nameFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get nameFieldLabel;

  /// No description provided for @nameValidationShort.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get nameValidationShort;

  /// No description provided for @nameValidationLong.
  ///
  /// In en, this message translates to:
  /// **'Name is too long'**
  String get nameValidationLong;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @gmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Link your Gmail'**
  String get gmailTitle;

  /// No description provided for @gmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional. Linking your Google account helps you recover your account and improves caller suggestions.'**
  String get gmailSubtitle;

  /// No description provided for @gmailContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get gmailContinueWith;

  /// No description provided for @gmailSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get gmailSkip;

  /// No description provided for @gmailSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed: {error}'**
  String gmailSignInFailed(String error);

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navProtect.
  ///
  /// In en, this message translates to:
  /// **'Protect'**
  String get navProtect;

  /// No description provided for @navPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get navPremium;

  /// No description provided for @homeHello.
  ///
  /// In en, this message translates to:
  /// **'Hello,'**
  String get homeHello;

  /// No description provided for @homeHelloFallbackName.
  ///
  /// In en, this message translates to:
  /// **'there'**
  String get homeHelloFallbackName;

  /// No description provided for @homeSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettingsTooltip;

  /// No description provided for @homeSearchesLeft.
  ///
  /// In en, this message translates to:
  /// **'{remaining} of {limit} searches left'**
  String homeSearchesLeft(int remaining, int limit);

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search any phone number or name…'**
  String get homeSearchHint;

  /// No description provided for @homeQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get homeQuickActions;

  /// No description provided for @homeActionContacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get homeActionContacts;

  /// No description provided for @homeActionContactsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'On this device'**
  String get homeActionContactsSubtitle;

  /// No description provided for @homeActionHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get homeActionHistory;

  /// No description provided for @homeActionHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recent calls'**
  String get homeActionHistorySubtitle;

  /// No description provided for @homeActionBlock.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get homeActionBlock;

  /// No description provided for @homeActionBlockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage list'**
  String get homeActionBlockSubtitle;

  /// No description provided for @homeActionPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get homeActionPremium;

  /// No description provided for @homeActionPremiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Go ad-free'**
  String get homeActionPremiumSubtitle;

  /// No description provided for @homeRecentCalls.
  ///
  /// In en, this message translates to:
  /// **'Recent calls'**
  String get homeRecentCalls;

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// No description provided for @homeRecentEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No recent calls yet'**
  String get homeRecentEmptyTitle;

  /// No description provided for @homeRecentEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Allow phone access on the History screen to see your call log here.'**
  String get homeRecentEmptyBody;

  /// No description provided for @homeRecentLoadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load call history'**
  String get homeRecentLoadFailedTitle;

  /// No description provided for @homeRecentLoadFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Pull down on the History screen to try again.'**
  String get homeRecentLoadFailedBody;

  /// No description provided for @homeWatchAdPlusOne.
  ///
  /// In en, this message translates to:
  /// **'Watch ad +1'**
  String get homeWatchAdPlusOne;

  /// No description provided for @homeWatchAdSuccess.
  ///
  /// In en, this message translates to:
  /// **'+1 search added — you can search now.'**
  String get homeWatchAdSuccess;

  /// No description provided for @homeWatchAdFail.
  ///
  /// In en, this message translates to:
  /// **'Could not add bonus.'**
  String get homeWatchAdFail;

  /// No description provided for @homeStatSpamBlocked.
  ///
  /// In en, this message translates to:
  /// **'Spam blocked'**
  String get homeStatSpamBlocked;

  /// No description provided for @homeStatIdentified.
  ///
  /// In en, this message translates to:
  /// **'Identified'**
  String get homeStatIdentified;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @sectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get sectionGeneral;

  /// No description provided for @sectionCallsAndCallerId.
  ///
  /// In en, this message translates to:
  /// **'Calls & Caller ID'**
  String get sectionCallsAndCallerId;

  /// No description provided for @sectionBlockAndSpam.
  ///
  /// In en, this message translates to:
  /// **'Block & Spam'**
  String get sectionBlockAndSpam;

  /// No description provided for @sectionSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get sectionSupport;

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get sectionAccount;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @tileEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get tileEditProfile;

  /// No description provided for @tileCalls.
  ///
  /// In en, this message translates to:
  /// **'Calls'**
  String get tileCalls;

  /// No description provided for @tileTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get tileTheme;

  /// No description provided for @tileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get tileLanguage;

  /// No description provided for @tileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get tileNotifications;

  /// No description provided for @shareLocation.
  ///
  /// In en, this message translates to:
  /// **'Share my location'**
  String get shareLocation;

  /// No description provided for @shareLocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send your location to help identify regional spam.'**
  String get shareLocationSubtitle;

  /// No description provided for @shareLocationDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Share your location?'**
  String get shareLocationDialogTitle;

  /// No description provided for @shareLocationDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Yellow Fast Call uses your location to identify spam numbers active in your area. You can turn this off any time.'**
  String get shareLocationDialogBody;

  /// No description provided for @shareLocationNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get shareLocationNotNow;

  /// No description provided for @shareLocationAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get shareLocationAllow;

  /// No description provided for @locationGetting.
  ///
  /// In en, this message translates to:
  /// **'Getting your location…'**
  String get locationGetting;

  /// No description provided for @locationSaved.
  ///
  /// In en, this message translates to:
  /// **'Location saved: {lat}, {lng}'**
  String locationSaved(String lat, String lng);

  /// No description provided for @locationBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Location permission blocked'**
  String get locationBlockedTitle;

  /// No description provided for @locationBlockedBody.
  ///
  /// In en, this message translates to:
  /// **'You previously denied location access. To allow it now, open the app permissions page and tap Location → Allow.'**
  String get locationBlockedBody;

  /// No description provided for @openPermissions.
  ///
  /// In en, this message translates to:
  /// **'Open permissions'**
  String get openPermissions;

  /// No description provided for @callerIdOverlay.
  ///
  /// In en, this message translates to:
  /// **'Caller ID overlay'**
  String get callerIdOverlay;

  /// No description provided for @callerIdOverlaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show caller info during incoming calls'**
  String get callerIdOverlaySubtitle;

  /// No description provided for @afterCallScreen.
  ///
  /// In en, this message translates to:
  /// **'After-call screen'**
  String get afterCallScreen;

  /// No description provided for @afterCallScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show caller details when a call ends'**
  String get afterCallScreenSubtitle;

  /// No description provided for @showAlternateNumbers.
  ///
  /// In en, this message translates to:
  /// **'Show alternate numbers'**
  String get showAlternateNumbers;

  /// No description provided for @showAlternateNumbersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Display other numbers linked to a contact'**
  String get showAlternateNumbersSubtitle;

  /// No description provided for @defaultCallScreener.
  ///
  /// In en, this message translates to:
  /// **'Default call screener'**
  String get defaultCallScreener;

  /// No description provided for @setAsDefaultCallScreener.
  ///
  /// In en, this message translates to:
  /// **'Set as default call screener'**
  String get setAsDefaultCallScreener;

  /// No description provided for @callScreenerActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get callScreenerActive;

  /// No description provided for @callScreenerOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get callScreenerOff;

  /// No description provided for @callScreenerSetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Yellow Fast Call is now your default call screener.'**
  String get callScreenerSetSuccess;

  /// No description provided for @callScreenerSetFailure.
  ///
  /// In en, this message translates to:
  /// **'Could not set as default. Try from system settings.'**
  String get callScreenerSetFailure;

  /// No description provided for @blockSpam.
  ///
  /// In en, this message translates to:
  /// **'Block spam'**
  String get blockSpam;

  /// No description provided for @blockSpamSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reject calls reported as spam'**
  String get blockSpamSubtitle;

  /// No description provided for @blockScam.
  ///
  /// In en, this message translates to:
  /// **'Block scam'**
  String get blockScam;

  /// No description provided for @blockScamSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reject calls flagged as scam or fraud'**
  String get blockScamSubtitle;

  /// No description provided for @silenceUnknown.
  ///
  /// In en, this message translates to:
  /// **'Silence unknown callers'**
  String get silenceUnknown;

  /// No description provided for @silenceUnknownSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send unknown numbers to voicemail'**
  String get silenceUnknownSubtitle;

  /// No description provided for @intlSpamFilter.
  ///
  /// In en, this message translates to:
  /// **'International spam filter'**
  String get intlSpamFilter;

  /// No description provided for @intlSpamFilterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Block suspicious foreign numbers'**
  String get intlSpamFilterSubtitle;

  /// No description provided for @manageBlockList.
  ///
  /// In en, this message translates to:
  /// **'Manage block list'**
  String get manageBlockList;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help center'**
  String get helpCenter;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Your account will be deleted and you will be signed out on this device. This action cannot be undone.'**
  String get deleteAccountBody;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted.'**
  String get accountDeleted;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @languageDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageDialogTitle;

  /// No description provided for @languageSetTo.
  ///
  /// In en, this message translates to:
  /// **'Language set to {language}.'**
  String languageSetTo(String language);

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @notificationsSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show alerts for blocked calls, spam reports and app updates.'**
  String get notificationsSheetSubtitle;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get enableNotifications;

  /// No description provided for @openSystemSettings.
  ///
  /// In en, this message translates to:
  /// **'Open system settings'**
  String get openSystemSettings;

  /// No description provided for @notificationsOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get notificationsOn;

  /// No description provided for @notificationsOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get notificationsOff;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @takeAPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takeAPhoto;

  /// No description provided for @profilePictureUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated'**
  String get profilePictureUpdated;

  /// No description provided for @couldNotSetPicture.
  ///
  /// In en, this message translates to:
  /// **'Could not set picture: {error}'**
  String couldNotSetPicture(String error);

  /// No description provided for @contactsTitle.
  ///
  /// In en, this message translates to:
  /// **'My contacts'**
  String get contactsTitle;

  /// No description provided for @contactsSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get contactsSyncNow;

  /// No description provided for @contactsSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed: {error}'**
  String contactsSyncFailed(String error);

  /// No description provided for @contactsUploadedCount.
  ///
  /// In en, this message translates to:
  /// **'Uploaded {count} contacts'**
  String contactsUploadedCount(int count);

  /// No description provided for @contactsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search name or number…'**
  String get contactsSearchHint;

  /// No description provided for @contactsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No contacts on this device.'**
  String get contactsEmpty;

  /// No description provided for @contactsNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches for \"{query}\".'**
  String contactsNoMatches(String query);

  /// No description provided for @contactsLastUpload.
  ///
  /// In en, this message translates to:
  /// **'Last upload: {count} contacts at {time}'**
  String contactsLastUpload(int count, String time);

  /// No description provided for @contactsNotUploaded.
  ///
  /// In en, this message translates to:
  /// **'Not uploaded yet — tap the cloud icon to sync.'**
  String get contactsNotUploaded;

  /// No description provided for @contactsNoPhone.
  ///
  /// In en, this message translates to:
  /// **'— no phone —'**
  String get contactsNoPhone;

  /// No description provided for @contactsNoName.
  ///
  /// In en, this message translates to:
  /// **'(no name)'**
  String get contactsNoName;

  /// No description provided for @contactsPermissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Contacts permission is needed.'**
  String get contactsPermissionNeeded;

  /// No description provided for @contactsPermissionHelp.
  ///
  /// In en, this message translates to:
  /// **'Open settings → Yellow Fast Call → Permissions → Contacts → Allow.'**
  String get contactsPermissionHelp;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @contactsLastSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Last sync failed: {message}'**
  String contactsLastSyncFailed(String message);

  /// No description provided for @syncGatePreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing…'**
  String get syncGatePreparing;

  /// No description provided for @syncGateAllowAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow contacts access'**
  String get syncGateAllowAccessTitle;

  /// No description provided for @syncGateAllowAccessBody.
  ///
  /// In en, this message translates to:
  /// **'Yellow Fast Call needs your contacts to identify unknown callers and detect spam. Your contacts stay encrypted in transit.'**
  String get syncGateAllowAccessBody;

  /// No description provided for @syncGateAllowAccessButton.
  ///
  /// In en, this message translates to:
  /// **'Allow contacts access'**
  String get syncGateAllowAccessButton;

  /// No description provided for @syncGateSyncingTitle.
  ///
  /// In en, this message translates to:
  /// **'Syncing your contacts'**
  String get syncGateSyncingTitle;

  /// No description provided for @syncGateSyncingBody.
  ///
  /// In en, this message translates to:
  /// **'Uploading to the server. This usually takes a few seconds.'**
  String get syncGateSyncingBody;

  /// No description provided for @syncGateFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncGateFailedTitle;

  /// No description provided for @syncGateAllSetTitle.
  ///
  /// In en, this message translates to:
  /// **'All set!'**
  String get syncGateAllSetTitle;

  /// No description provided for @syncGateAllSetBody.
  ///
  /// In en, this message translates to:
  /// **'Uploaded {count} contacts. Continuing…'**
  String syncGateAllSetBody(int count);

  /// No description provided for @syncGateReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to sync'**
  String get syncGateReadyTitle;

  /// No description provided for @syncGateReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap to start'**
  String get syncGateReadyBody;

  /// No description provided for @syncGateStart.
  ///
  /// In en, this message translates to:
  /// **'Start sync'**
  String get syncGateStart;

  /// No description provided for @syncGateMustSync.
  ///
  /// In en, this message translates to:
  /// **'You can\'t continue until contacts are synced.'**
  String get syncGateMustSync;

  /// No description provided for @syncGatePermBlocked.
  ///
  /// In en, this message translates to:
  /// **'Permission permanently denied. Open settings to enable Contacts.'**
  String get syncGatePermBlocked;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent calls'**
  String get historyTitle;

  /// No description provided for @historyRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get historyRefresh;

  /// No description provided for @historyCallTypeIncoming.
  ///
  /// In en, this message translates to:
  /// **'Incoming'**
  String get historyCallTypeIncoming;

  /// No description provided for @historyCallTypeOutgoing.
  ///
  /// In en, this message translates to:
  /// **'Outgoing'**
  String get historyCallTypeOutgoing;

  /// No description provided for @historyCallTypeMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get historyCallTypeMissed;

  /// No description provided for @historyCallTypeRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get historyCallTypeRejected;

  /// No description provided for @historyCallTypeBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get historyCallTypeBlocked;

  /// No description provided for @historyCallTypeVoicemail.
  ///
  /// In en, this message translates to:
  /// **'Voicemail'**
  String get historyCallTypeVoicemail;

  /// No description provided for @historyCallTypeCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get historyCallTypeCall;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No recent calls'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Allow phone access to see your call history and identify unknown numbers.'**
  String get historyEmptyBody;

  /// No description provided for @historyAllowPhone.
  ///
  /// In en, this message translates to:
  /// **'Allow phone access'**
  String get historyAllowPhone;

  /// No description provided for @historyLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load call history'**
  String get historyLoadFailed;

  /// No description provided for @minAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String minAgo(int minutes);

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchModeNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get searchModeNumber;

  /// No description provided for @searchModeName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get searchModeName;

  /// No description provided for @searchEnterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter the number to search.'**
  String get searchEnterNumber;

  /// No description provided for @searchPhoneField.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get searchPhoneField;

  /// No description provided for @searchTypeName.
  ///
  /// In en, this message translates to:
  /// **'Type a name'**
  String get searchTypeName;

  /// No description provided for @searchInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get searchInvalidPhone;

  /// No description provided for @searchEmptyNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Pick a country and enter the number to look it up.'**
  String get searchEmptyNumberHint;

  /// No description provided for @searchEmptyNameHint.
  ///
  /// In en, this message translates to:
  /// **'Type a name, then Search.'**
  String get searchEmptyNameHint;

  /// No description provided for @searchRegisteredUsers.
  ///
  /// In en, this message translates to:
  /// **'Registered users ({count})'**
  String searchRegisteredUsers(int count);

  /// No description provided for @searchEveryonesContacts.
  ///
  /// In en, this message translates to:
  /// **'From everyone\'s contacts ({count})'**
  String searchEveryonesContacts(int count);

  /// No description provided for @searchUnnamedUser.
  ///
  /// In en, this message translates to:
  /// **'Unnamed user'**
  String get searchUnnamedUser;

  /// No description provided for @searchUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get searchUnknown;

  /// No description provided for @searchUploads.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 upload} other{{count} uploads}}'**
  String searchUploads(int count);

  /// No description provided for @searchAdAdded.
  ///
  /// In en, this message translates to:
  /// **'+1 search added. Retrying…'**
  String get searchAdAdded;

  /// No description provided for @searchAdAddedLoading.
  ///
  /// In en, this message translates to:
  /// **'+1 search added. Loading result…'**
  String get searchAdAddedLoading;

  /// No description provided for @searchAdFail.
  ///
  /// In en, this message translates to:
  /// **'Could not add bonus. Try again later.'**
  String get searchAdFail;

  /// No description provided for @searchQuotaTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily search limit reached'**
  String get searchQuotaTitle;

  /// No description provided for @searchQuotaBody.
  ///
  /// In en, this message translates to:
  /// **'You used {used}/{limit} searches in the last 24 hours.'**
  String searchQuotaBody(String used, String limit);

  /// No description provided for @searchQuotaReset.
  ///
  /// In en, this message translates to:
  /// **'Next search available {when}.'**
  String searchQuotaReset(String when);

  /// No description provided for @searchWatchAdForReward.
  ///
  /// In en, this message translates to:
  /// **'Watch ad for +1 search'**
  String get searchWatchAdForReward;

  /// No description provided for @searchAdMaxUsed.
  ///
  /// In en, this message translates to:
  /// **'You\'ve already used the maximum number of ad-bonus searches for today.'**
  String get searchAdMaxUsed;

  /// No description provided for @searchShowNumber.
  ///
  /// In en, this message translates to:
  /// **'Show number'**
  String get searchShowNumber;

  /// No description provided for @searchRelMoment.
  ///
  /// In en, this message translates to:
  /// **'in a moment'**
  String get searchRelMoment;

  /// No description provided for @searchRelMinutes.
  ///
  /// In en, this message translates to:
  /// **'in {minutes} min'**
  String searchRelMinutes(int minutes);

  /// No description provided for @searchRelHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'in {hours}h {minutes}m'**
  String searchRelHoursMinutes(int hours, int minutes);

  /// No description provided for @searchRelDays.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{in 1 day} other{in {days} days}}'**
  String searchRelDays(int days);

  /// No description provided for @callerInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Caller info'**
  String get callerInfoTitle;

  /// No description provided for @callerInfoLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load caller info'**
  String get callerInfoLoadFailed;

  /// No description provided for @callerInfoVerifiedUser.
  ///
  /// In en, this message translates to:
  /// **'Verified Yellow Fast Call user'**
  String get callerInfoVerifiedUser;

  /// No description provided for @callerInfoSpamFlag.
  ///
  /// In en, this message translates to:
  /// **'Reported as spam ({count})'**
  String callerInfoSpamFlag(int count);

  /// No description provided for @callerInfoRegistered.
  ///
  /// In en, this message translates to:
  /// **'Registered user'**
  String get callerInfoRegistered;

  /// No description provided for @callerInfoIdentified.
  ///
  /// In en, this message translates to:
  /// **'Identified by community'**
  String get callerInfoIdentified;

  /// No description provided for @callerInfoNotInDir.
  ///
  /// In en, this message translates to:
  /// **'Not in directory yet'**
  String get callerInfoNotInDir;

  /// No description provided for @callerInfoAlsoSavedAs.
  ///
  /// In en, this message translates to:
  /// **'Also saved as'**
  String get callerInfoAlsoSavedAs;

  /// No description provided for @callerInfoMoreNotShown.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String callerInfoMoreNotShown(int count);

  /// No description provided for @callerInfoRegisteredAccount.
  ///
  /// In en, this message translates to:
  /// **'Registered account'**
  String get callerInfoRegisteredAccount;

  /// No description provided for @callerInfoLoginName.
  ///
  /// In en, this message translates to:
  /// **'Login name'**
  String get callerInfoLoginName;

  /// No description provided for @callerInfoEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get callerInfoEmail;

  /// No description provided for @callerInfoMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get callerInfoMemberSince;

  /// No description provided for @callerInfoAbout.
  ///
  /// In en, this message translates to:
  /// **'About this number'**
  String get callerInfoAbout;

  /// No description provided for @callerInfoMostLikelyName.
  ///
  /// In en, this message translates to:
  /// **'Most likely name'**
  String get callerInfoMostLikelyName;

  /// No description provided for @callerInfoCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get callerInfoCountry;

  /// No description provided for @callerInfoSeenBy.
  ///
  /// In en, this message translates to:
  /// **'Seen by'**
  String get callerInfoSeenBy;

  /// No description provided for @callerInfoNobodyYet.
  ///
  /// In en, this message translates to:
  /// **'Nobody yet'**
  String get callerInfoNobodyYet;

  /// No description provided for @callerInfoUsersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 user} other{{count} users}}'**
  String callerInfoUsersCount(int count);

  /// No description provided for @callerInfoDifferentNames.
  ///
  /// In en, this message translates to:
  /// **'Different names uploaded'**
  String get callerInfoDifferentNames;

  /// No description provided for @callerInfoHowOthers.
  ///
  /// In en, this message translates to:
  /// **'How others saved this number'**
  String get callerInfoHowOthers;

  /// No description provided for @callerInfoTopOf.
  ///
  /// In en, this message translates to:
  /// **'Top {shown} of {total} different names across the directory'**
  String callerInfoTopOf(int shown, int total);

  /// No description provided for @callerInfoNamesAcross.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 different name across the directory} other{{count} different names across the directory}}'**
  String callerInfoNamesAcross(int count);

  /// No description provided for @callerInfoPeopleCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person} other{{count} people}}'**
  String callerInfoPeopleCount(int count);

  /// No description provided for @callerInfoHiddenMore.
  ///
  /// In en, this message translates to:
  /// **'+{count} more not shown'**
  String callerInfoHiddenMore(int count);

  /// No description provided for @callerInfoCommunityReports.
  ///
  /// In en, this message translates to:
  /// **'Community reports'**
  String get callerInfoCommunityReports;

  /// No description provided for @callerInfoSpamReports.
  ///
  /// In en, this message translates to:
  /// **'Spam reports'**
  String get callerInfoSpamReports;

  /// No description provided for @callerInfoStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get callerInfoStatus;

  /// No description provided for @callerInfoFlagged.
  ///
  /// In en, this message translates to:
  /// **'Flagged as spam'**
  String get callerInfoFlagged;

  /// No description provided for @callerInfoNotFlagged.
  ///
  /// In en, this message translates to:
  /// **'Not flagged'**
  String get callerInfoNotFlagged;

  /// No description provided for @addPicture.
  ///
  /// In en, this message translates to:
  /// **'Add picture'**
  String get addPicture;

  /// No description provided for @changePicture.
  ///
  /// In en, this message translates to:
  /// **'Change picture'**
  String get changePicture;

  /// No description provided for @manageBlocking.
  ///
  /// In en, this message translates to:
  /// **'Manage blocking'**
  String get manageBlocking;

  /// No description provided for @manageBlockingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Block list, spam & scam settings'**
  String get manageBlockingSubtitle;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @upgradeToPremiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited searches & full features'**
  String get upgradeToPremiumSubtitle;

  /// No description provided for @whoSearchedMe.
  ///
  /// In en, this message translates to:
  /// **'Who searched me'**
  String get whoSearchedMe;

  /// No description provided for @whoSearchedMeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See people who looked up your number'**
  String get whoSearchedMeSubtitle;

  /// No description provided for @premiumHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Yellow Fast Premium'**
  String get premiumHeroTitle;

  /// No description provided for @premiumHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock the full caller ID power.\nNo ads. Unlimited searches.'**
  String get premiumHeroSubtitle;

  /// No description provided for @premiumFeatureIdentify.
  ///
  /// In en, this message translates to:
  /// **'Identify any number'**
  String get premiumFeatureIdentify;

  /// No description provided for @premiumFeatureUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited searches'**
  String get premiumFeatureUnlimited;

  /// No description provided for @premiumFeatureNoAds.
  ///
  /// In en, this message translates to:
  /// **'No ads'**
  String get premiumFeatureNoAds;

  /// No description provided for @premiumFeatureSpamFilter.
  ///
  /// In en, this message translates to:
  /// **'Advanced spam filter'**
  String get premiumFeatureSpamFilter;

  /// No description provided for @premiumFeatureBadges.
  ///
  /// In en, this message translates to:
  /// **'Premium-only badges'**
  String get premiumFeatureBadges;

  /// No description provided for @premiumFeaturePriority.
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get premiumFeaturePriority;

  /// No description provided for @premiumPlanMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get premiumPlanMonthly;

  /// No description provided for @premiumPlanYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get premiumPlanYearly;

  /// No description provided for @premiumPlanLifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get premiumPlanLifetime;

  /// No description provided for @premiumPeriodMonth.
  ///
  /// In en, this message translates to:
  /// **'/ month'**
  String get premiumPeriodMonth;

  /// No description provided for @premiumPeriodYear.
  ///
  /// In en, this message translates to:
  /// **'/ year'**
  String get premiumPeriodYear;

  /// No description provided for @premiumPeriodOneTime.
  ///
  /// In en, this message translates to:
  /// **'one-time'**
  String get premiumPeriodOneTime;

  /// No description provided for @premiumBadgeBest.
  ///
  /// In en, this message translates to:
  /// **'BEST'**
  String get premiumBadgeBest;

  /// No description provided for @premiumUpgradeNow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade now'**
  String get premiumUpgradeNow;

  /// No description provided for @premiumCancelAnytime.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime. Subscriptions auto-renew.'**
  String get premiumCancelAnytime;

  /// No description provided for @premiumNotWired.
  ///
  /// In en, this message translates to:
  /// **'Payments not wired yet'**
  String get premiumNotWired;

  /// No description provided for @premiumUnlockHistory.
  ///
  /// In en, this message translates to:
  /// **'Unlock full history with Premium'**
  String get premiumUnlockHistory;

  /// No description provided for @protectTitle.
  ///
  /// In en, this message translates to:
  /// **'Protect'**
  String get protectTitle;

  /// No description provided for @protectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Block spam, scams and unwanted callers automatically.'**
  String get protectSubtitle;

  /// No description provided for @protectShieldActive.
  ///
  /// In en, this message translates to:
  /// **'You are protected'**
  String get protectShieldActive;

  /// No description provided for @protectShieldInactive.
  ///
  /// In en, this message translates to:
  /// **'Protection is off'**
  String get protectShieldInactive;

  /// No description provided for @protectShieldActiveBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No calls blocked yet.} =1{1 call blocked so far.} other{{count} calls blocked so far.}}'**
  String protectShieldActiveBody(int count);

  /// No description provided for @protectShieldInactiveBody.
  ///
  /// In en, this message translates to:
  /// **'Tap below to enable call screening.'**
  String get protectShieldInactiveBody;

  /// No description provided for @protectScreeningEnabledMsg.
  ///
  /// In en, this message translates to:
  /// **'Call screening enabled.'**
  String get protectScreeningEnabledMsg;

  /// No description provided for @protectScreeningNeededMsg.
  ///
  /// In en, this message translates to:
  /// **'You need to allow call screening for blocking to work.'**
  String get protectScreeningNeededMsg;

  /// No description provided for @protectSetDefaultBanner.
  ///
  /// In en, this message translates to:
  /// **'Enable call screening so the app can actually block calls.'**
  String get protectSetDefaultBanner;

  /// No description provided for @protectCallerIdBanner.
  ///
  /// In en, this message translates to:
  /// **'Turn on the Caller ID popup so names show on incoming calls.'**
  String get protectCallerIdBanner;

  /// No description provided for @protectCallerIdEnabledMsg.
  ///
  /// In en, this message translates to:
  /// **'Caller ID popup is on.'**
  String get protectCallerIdEnabledMsg;

  /// No description provided for @protectCallerIdNeededMsg.
  ///
  /// In en, this message translates to:
  /// **'Allow \"Display over other apps\" to see caller names.'**
  String get protectCallerIdNeededMsg;

  /// No description provided for @protectSettingsSection.
  ///
  /// In en, this message translates to:
  /// **'Protection settings'**
  String get protectSettingsSection;

  /// No description provided for @protectBlockSpamTitle.
  ///
  /// In en, this message translates to:
  /// **'Block spam calls'**
  String get protectBlockSpamTitle;

  /// No description provided for @protectBlockSpamBody.
  ///
  /// In en, this message translates to:
  /// **'Automatically block known spam numbers.'**
  String get protectBlockSpamBody;

  /// No description provided for @protectBlockScamTitle.
  ///
  /// In en, this message translates to:
  /// **'Block scams'**
  String get protectBlockScamTitle;

  /// No description provided for @protectBlockScamBody.
  ///
  /// In en, this message translates to:
  /// **'Stop scam calls before they ring you.'**
  String get protectBlockScamBody;

  /// No description provided for @protectSilenceUnknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Silence unknown numbers'**
  String get protectSilenceUnknownTitle;

  /// No description provided for @protectSilenceUnknownBody.
  ///
  /// In en, this message translates to:
  /// **'Send unknown callers straight to voicemail.'**
  String get protectSilenceUnknownBody;

  /// No description provided for @protectIntlFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'International spam filter'**
  String get protectIntlFilterTitle;

  /// No description provided for @protectIntlFilterBody.
  ///
  /// In en, this message translates to:
  /// **'Block suspicious international numbers.'**
  String get protectIntlFilterBody;

  /// No description provided for @protectBlockListSection.
  ///
  /// In en, this message translates to:
  /// **'Block list'**
  String get protectBlockListSection;

  /// No description provided for @protectAddNumber.
  ///
  /// In en, this message translates to:
  /// **'Add number'**
  String get protectAddNumber;

  /// No description provided for @protectBlockDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Block a number'**
  String get protectBlockDialogTitle;

  /// No description provided for @protectBlockDialogPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+1 555 123 4567'**
  String get protectBlockDialogPhoneHint;

  /// No description provided for @protectBlockDialogNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get protectBlockDialogNameLabel;

  /// No description provided for @protectBlockButton.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get protectBlockButton;

  /// No description provided for @protectAddedToBlockList.
  ///
  /// In en, this message translates to:
  /// **'Number added to block list.'**
  String get protectAddedToBlockList;

  /// No description provided for @protectAlreadyBlocked.
  ///
  /// In en, this message translates to:
  /// **'Number is already blocked.'**
  String get protectAlreadyBlocked;

  /// No description provided for @protectEmptyBlockListTitle.
  ///
  /// In en, this message translates to:
  /// **'No numbers blocked yet'**
  String get protectEmptyBlockListTitle;

  /// No description provided for @protectEmptyBlockListBody.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Add number\" to block a phone number manually.'**
  String get protectEmptyBlockListBody;

  /// No description provided for @protectBlockedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get protectBlockedSubtitle;

  /// No description provided for @protectUnblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get protectUnblock;

  /// No description provided for @enableProtectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Protection'**
  String get enableProtectionTitle;

  /// No description provided for @enableProtectionBody.
  ///
  /// In en, this message translates to:
  /// **'Let Yellow Fast Call block spam, scams and unwanted callers automatically.'**
  String get enableProtectionBody;

  /// No description provided for @enableProtectionShareLocation.
  ///
  /// In en, this message translates to:
  /// **'Share my location'**
  String get enableProtectionShareLocation;

  /// No description provided for @enableProtectionShareLocationSub.
  ///
  /// In en, this message translates to:
  /// **'Helps identify regional spam patterns.'**
  String get enableProtectionShareLocationSub;

  /// No description provided for @enableProtectionBulletSpamTitle.
  ///
  /// In en, this message translates to:
  /// **'Block spam & scam calls'**
  String get enableProtectionBulletSpamTitle;

  /// No description provided for @enableProtectionBulletSpamBody.
  ///
  /// In en, this message translates to:
  /// **'Reject known bad numbers before they ring.'**
  String get enableProtectionBulletSpamBody;

  /// No description provided for @enableProtectionBulletSilenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Silence unknown callers'**
  String get enableProtectionBulletSilenceTitle;

  /// No description provided for @enableProtectionBulletSilenceBody.
  ///
  /// In en, this message translates to:
  /// **'Send strangers straight to voicemail.'**
  String get enableProtectionBulletSilenceBody;

  /// No description provided for @enableProtectionBulletIntlTitle.
  ///
  /// In en, this message translates to:
  /// **'International filter'**
  String get enableProtectionBulletIntlTitle;

  /// No description provided for @enableProtectionBulletIntlBody.
  ///
  /// In en, this message translates to:
  /// **'Block suspicious foreign numbers.'**
  String get enableProtectionBulletIntlBody;

  /// No description provided for @enableProtectionFootnote.
  ///
  /// In en, this message translates to:
  /// **'You can change this anytime in Settings.'**
  String get enableProtectionFootnote;

  /// No description provided for @enableProtectionLaterMsg.
  ///
  /// In en, this message translates to:
  /// **'You can enable protection later from Settings or Protect.'**
  String get enableProtectionLaterMsg;

  /// No description provided for @permissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissionsTitle;

  /// No description provided for @permissionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap each permission to allow. You can change these later in settings.'**
  String get permissionsSubtitle;

  /// No description provided for @permContactsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get permContactsTitle;

  /// No description provided for @permContactsDesc.
  ///
  /// In en, this message translates to:
  /// **'Identify your contacts and protect their numbers.'**
  String get permContactsDesc;

  /// No description provided for @permLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get permLocationTitle;

  /// No description provided for @permLocationDesc.
  ///
  /// In en, this message translates to:
  /// **'Show local information about callers near you.'**
  String get permLocationDesc;

  /// No description provided for @permPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get permPhoneTitle;

  /// No description provided for @permPhoneDesc.
  ///
  /// In en, this message translates to:
  /// **'Detect incoming calls so we can show caller info.'**
  String get permPhoneDesc;

  /// No description provided for @permWhyTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get you set up'**
  String get permWhyTitle;

  /// No description provided for @permWhySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Yellow Fast Call needs a few permissions to identify callers and block spam. Your phone will ask you to allow each one — just tap Allow.'**
  String get permWhySubtitle;

  /// No description provided for @permWhyLocationHeading.
  ///
  /// In en, this message translates to:
  /// **'Why we ask for your location'**
  String get permWhyLocationHeading;

  /// No description provided for @permLocationReason1.
  ///
  /// In en, this message translates to:
  /// **'Spot spam and scam numbers active in your area'**
  String get permLocationReason1;

  /// No description provided for @permLocationReason2.
  ///
  /// In en, this message translates to:
  /// **'Show the city or region an unknown call comes from'**
  String get permLocationReason2;

  /// No description provided for @permLocationReason3.
  ///
  /// In en, this message translates to:
  /// **'Warn you about fraud patterns reported nearby'**
  String get permLocationReason3;

  /// No description provided for @permLocationReason4.
  ///
  /// In en, this message translates to:
  /// **'Make caller identification more accurate in your country'**
  String get permLocationReason4;

  /// No description provided for @permLocationPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Your precise location is never shown to other users, and you can turn it off anytime in Settings.'**
  String get permLocationPrivacyNote;

  /// No description provided for @permAllowAll.
  ///
  /// In en, this message translates to:
  /// **'Allow & continue'**
  String get permAllowAll;

  /// No description provided for @permFooterNote.
  ///
  /// In en, this message translates to:
  /// **'You can change all of these later in Settings.'**
  String get permFooterNote;

  /// No description provided for @locReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Share your location'**
  String get locReminderTitle;

  /// No description provided for @locReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Helps identify spam in your area. Updated every few days.'**
  String get locReminderBody;

  /// No description provided for @locReminderNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get locReminderNotNow;

  /// No description provided for @locReminderTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get locReminderTurnOn;

  /// No description provided for @callsTitle.
  ///
  /// In en, this message translates to:
  /// **'Calls'**
  String get callsTitle;

  /// No description provided for @callsSectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get callsSectionGeneral;

  /// No description provided for @callsTroubleshootTitle.
  ///
  /// In en, this message translates to:
  /// **'Troubleshoot calling'**
  String get callsTroubleshootTitle;

  /// No description provided for @callsTroubleshootSub.
  ///
  /// In en, this message translates to:
  /// **'Fix problems with caller ID & screening'**
  String get callsTroubleshootSub;

  /// No description provided for @callsDisplayStyleTitle.
  ///
  /// In en, this message translates to:
  /// **'Display style'**
  String get callsDisplayStyleTitle;

  /// No description provided for @callsDisplayStyleSub.
  ///
  /// In en, this message translates to:
  /// **'How caller info appears on incoming calls'**
  String get callsDisplayStyleSub;

  /// No description provided for @callsIdentifyOtherAppsTitle.
  ///
  /// In en, this message translates to:
  /// **'Identify numbers on other apps'**
  String get callsIdentifyOtherAppsTitle;

  /// No description provided for @callsIdentifyOtherAppsSub.
  ///
  /// In en, this message translates to:
  /// **'Show caller info in WhatsApp, Messenger and more'**
  String get callsIdentifyOtherAppsSub;

  /// No description provided for @callsSectionHistory.
  ///
  /// In en, this message translates to:
  /// **'Call history'**
  String get callsSectionHistory;

  /// No description provided for @callsGroupCallsTitle.
  ///
  /// In en, this message translates to:
  /// **'Group calls in call history'**
  String get callsGroupCallsTitle;

  /// No description provided for @callsGroupCallsSub.
  ///
  /// In en, this message translates to:
  /// **'Combine repeated calls from the same number'**
  String get callsGroupCallsSub;

  /// No description provided for @callsShowFrequentTitle.
  ///
  /// In en, this message translates to:
  /// **'Show frequently called contacts'**
  String get callsShowFrequentTitle;

  /// No description provided for @callsShowFrequentSub.
  ///
  /// In en, this message translates to:
  /// **'Surface your top contacts on the call screen'**
  String get callsShowFrequentSub;

  /// No description provided for @callsShowFromOtherAppsTitle.
  ///
  /// In en, this message translates to:
  /// **'Show calls from other apps'**
  String get callsShowFromOtherAppsTitle;

  /// No description provided for @callsShowFromOtherAppsSub.
  ///
  /// In en, this message translates to:
  /// **'Include WhatsApp, Telegram and similar in history'**
  String get callsShowFromOtherAppsSub;

  /// No description provided for @callsSectionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get callsSectionNotifications;

  /// No description provided for @callsAlertNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Call alert notification'**
  String get callsAlertNotifTitle;

  /// No description provided for @callsAlertNotifSub.
  ///
  /// In en, this message translates to:
  /// **'Get notified when an unknown number calls'**
  String get callsAlertNotifSub;

  /// No description provided for @callsMissedNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Missed call notification'**
  String get callsMissedNotifTitle;

  /// No description provided for @callsMissedNotifSub.
  ///
  /// In en, this message translates to:
  /// **'Show a notification for every missed call'**
  String get callsMissedNotifSub;

  /// No description provided for @callsRemindMissedTitle.
  ///
  /// In en, this message translates to:
  /// **'Remind me of missed calls'**
  String get callsRemindMissedTitle;

  /// No description provided for @callsRemindMissedSub.
  ///
  /// In en, this message translates to:
  /// **'Send a follow-up reminder after a missed call'**
  String get callsRemindMissedSub;

  /// No description provided for @callsDisplayStylePickerSub.
  ///
  /// In en, this message translates to:
  /// **'Pick how the caller info appears when someone calls.'**
  String get callsDisplayStylePickerSub;

  /// No description provided for @callsDisplayFullScreen.
  ///
  /// In en, this message translates to:
  /// **'Full screen'**
  String get callsDisplayFullScreen;

  /// No description provided for @callsDisplayFullScreenSub.
  ///
  /// In en, this message translates to:
  /// **'Takes the whole screen during a call'**
  String get callsDisplayFullScreenSub;

  /// No description provided for @callsDisplayClassicPopup.
  ///
  /// In en, this message translates to:
  /// **'Classic popup'**
  String get callsDisplayClassicPopup;

  /// No description provided for @callsDisplayClassicPopupSub.
  ///
  /// In en, this message translates to:
  /// **'A small floating popup on top of your screen'**
  String get callsDisplayClassicPopupSub;

  /// No description provided for @callsDisplayStyleChanged.
  ///
  /// In en, this message translates to:
  /// **'Display style: {style}'**
  String callsDisplayStyleChanged(String style);

  /// No description provided for @callsTroubleshootIntro.
  ///
  /// In en, this message translates to:
  /// **'If caller ID is not showing or calls are not being identified, try these steps:'**
  String get callsTroubleshootIntro;

  /// No description provided for @callsTipDefault.
  ///
  /// In en, this message translates to:
  /// **'Set Yellow Fast Call as your default caller ID & spam app.'**
  String get callsTipDefault;

  /// No description provided for @callsTipOverlay.
  ///
  /// In en, this message translates to:
  /// **'Allow the app to draw over other apps (overlay).'**
  String get callsTipOverlay;

  /// No description provided for @callsTipNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications so alerts and missed call reminders work.'**
  String get callsTipNotifications;

  /// No description provided for @callsTipBattery.
  ///
  /// In en, this message translates to:
  /// **'Disable battery optimization so the app can run in the background.'**
  String get callsTipBattery;

  /// No description provided for @callsTipPermissions.
  ///
  /// In en, this message translates to:
  /// **'Grant Contacts and Phone permissions so the app can read incoming numbers.'**
  String get callsTipPermissions;

  /// No description provided for @callsOpenAppSettings.
  ///
  /// In en, this message translates to:
  /// **'Open app settings'**
  String get callsOpenAppSettings;

  /// No description provided for @profileEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditTitle;

  /// No description provided for @profileUpdatedMsg.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdatedMsg;

  /// No description provided for @profileSaveFailedMsg.
  ///
  /// In en, this message translates to:
  /// **'Could not save profile'**
  String get profileSaveFailedMsg;

  /// No description provided for @profileAddPicture.
  ///
  /// In en, this message translates to:
  /// **'Add profile picture'**
  String get profileAddPicture;

  /// No description provided for @profileChangePicture.
  ///
  /// In en, this message translates to:
  /// **'Change picture'**
  String get profileChangePicture;

  /// No description provided for @profileFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get profileFullName;

  /// No description provided for @profileFullNameHelper.
  ///
  /// In en, this message translates to:
  /// **'You can change your name once every 7 days.'**
  String get profileFullNameHelper;

  /// No description provided for @profileFullNameLockedDays.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Locked for 1 more day. You can change your name once every 7 days.} other{Locked for {days} more days. You can change your name once every 7 days.}}'**
  String profileFullNameLockedDays(int days);

  /// No description provided for @profileFullNameLockedHours.
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, =1{Locked for 1 more hour.} other{Locked for {hours} more hours.}}'**
  String profileFullNameLockedHours(int hours);

  /// No description provided for @profileFullNameLockedMinutes.
  ///
  /// In en, this message translates to:
  /// **'{mins, plural, =1{Locked for 1 more minute.} other{Locked for {mins} more minutes.}}'**
  String profileFullNameLockedMinutes(int mins);

  /// No description provided for @profilePhoneVerified.
  ///
  /// In en, this message translates to:
  /// **'Phone number (verified)'**
  String get profilePhoneVerified;

  /// No description provided for @profileGmailOptional.
  ///
  /// In en, this message translates to:
  /// **'Gmail (optional)'**
  String get profileGmailOptional;

  /// No description provided for @profilePreviousNames.
  ///
  /// In en, this message translates to:
  /// **'Previous names'**
  String get profilePreviousNames;

  /// No description provided for @whoSearchedMeTitle.
  ///
  /// In en, this message translates to:
  /// **'Who searched me'**
  String get whoSearchedMeTitle;

  /// No description provided for @whoSearchedMePeopleCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person searched your number} other{{count} people searched your number}}'**
  String whoSearchedMePeopleCount(int count);

  /// No description provided for @whoSearchedMeLast7Days.
  ///
  /// In en, this message translates to:
  /// **'See who looked you up in the last 7 days.'**
  String get whoSearchedMeLast7Days;

  /// No description provided for @whoSearchedMeRecentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get whoSearchedMeRecentSearches;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
