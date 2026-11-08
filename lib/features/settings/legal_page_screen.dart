import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/responsive.dart';
import '../../l10n/generated/app_localizations.dart';

enum LegalPageKind { termsOfService, privacyPolicy, help }

class LegalPageScreen extends StatelessWidget {
  final LegalPageKind kind;
  const LegalPageScreen({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final title = switch (kind) {
      LegalPageKind.termsOfService => l.termsOfService,
      LegalPageKind.privacyPolicy => l.privacyPolicy,
      LegalPageKind.help => l.helpCenter,
    };
    final body = switch (kind) {
      LegalPageKind.termsOfService =>
        isArabic ? LegalContent.termsOfServiceAr : LegalContent.termsOfService,
      LegalPageKind.privacyPolicy =>
        isArabic ? LegalContent.privacyPolicyAr : LegalContent.privacyPolicy,
      LegalPageKind.help =>
        isArabic ? LegalContent.helpAr : LegalContent.help,
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ResponsiveBox(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.pagePadding,
              vertical: context.hp(2),
            ),
            child: Text(
              body,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.55,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LegalContent {
  static const termsOfService = '''Yellow Fast Call — Terms of Service

Last updated: 2026-05-13

1. Acceptance of terms
By installing or using Yellow Fast Call ("the App"), you agree to these Terms of Service. If you do not agree, do not use the App.

2. Service description
The App provides caller identification, spam detection, and call blocking features. Spam classification is based on community reports and our own analysis. We do not guarantee that every spam call will be blocked or that every flagged number is actually spam.

3. Your account
You provide a phone number, your name, and optionally a Gmail address. You are responsible for keeping your device secure. You may not impersonate other people or submit false reports.

4. Contacts and call data
Where you grant permission, the App reads your contacts and call log to provide caller identification and protection features. We use this data only to power features of the App.

5. Acceptable use
You agree not to:
- Use the App for harassment, stalking or any illegal purpose
- Reverse engineer, decompile, or attempt to extract source code
- Use automated tools to abuse our backend

6. Ads
The App may show ads. Advertisers may collect limited data to personalize ads, subject to your consent under applicable law.

7. Liability
The App is provided "as is" with no warranty. We are not liable for missed calls, mis-classified callers, or damages resulting from use of the App, to the maximum extent allowed by law.

8. Changes
We may update these terms. Continued use after changes means you accept the updated terms.''';

  static const privacyPolicy = '''Yellow Fast Call — Privacy Policy

Last updated: 2026-05-13

1. What we collect
- Phone number you sign in with
- Your name, profile picture (if you provide one), and email if you sign in with Google
- Contacts (only with your explicit permission, used to power caller ID lookups)
- Call log entries (only with your permission, used to mark spam and show recent calls)
- Anonymous usage data and crash reports

2. How we use it
- Identify unknown callers
- Detect and block spam / scam callers
- Improve the App and fix bugs
- Show personalized or non-personalized ads (depending on your consent)

3. What we don't do
- We do not sell your personal data
- We do not share your contacts with other users without your action
- We do not record or transcribe your calls

4. Ads
We use Google AdMob. AdMob may collect device identifiers and ad-interaction data subject to its own privacy policy and your consent.

5. Permissions
Contacts, phone, call log, microphone (if applicable), and notifications are requested only when needed. You can revoke them at any time in Android Settings.

6. Your rights
You can delete your account at any time from Settings → Delete account. Deletion removes your profile and unlinks your data from your phone number on our side.

7. Children
The App is not directed at children under 13. We do not knowingly collect data from children.''';

  static const help = '''Need help?

Common questions

Q: Calls are still ringing even with blocking on.
A: Make sure Yellow Fast Call is set as your call-screening app. Open Protect → tap the yellow banner → choose "Set as default".

Q: My phone is Android 9 or older.
A: Real call blocking requires Android 10 or newer because of how Android's call screening works.

Q: I added a number to the block list but they still got through.
A: Some phone networks deliver calls through paths that bypass screening. We block the call as soon as Android asks us, but not every carrier honors this 100% of the time.

Q: Why do I see ads?
A: Ads help keep the app free. You can remove them by upgrading to Premium.

Q: How do I delete my account?
A: Settings → Delete account. This wipes your profile and the data on your device.''';

  static const termsOfServiceAr = '''يلو فاست كول — شروط الخدمة

آخر تحديث: 2026-05-13

1. قبول الشروط
بتثبيت تطبيق يلو فاست كول («التطبيق») أو استخدامه، فإنك توافق على شروط الخدمة هذه. إذا لم توافق، لا تستخدم التطبيق.

2. وصف الخدمة
يوفّر التطبيق ميزات هوية المتصل واكتشاف الإزعاج وحظر المكالمات. يعتمد تصنيف الإزعاج على بلاغات المجتمع وتحليلنا الخاص. لا نضمن حظر كل مكالمة مزعجة أو أن كل رقم مُبلَّغ عنه هو فعلياً مزعج.

3. حسابك
أنت تقدّم رقم هاتف واسماً، وبشكل اختياري عنوان جيميل. أنت مسؤول عن الحفاظ على أمان جهازك. لا يجوز انتحال شخصية الآخرين أو تقديم بلاغات كاذبة.

4. جهات الاتصال وبيانات المكالمات
حيث تمنح الإذن، يقرأ التطبيق جهات اتصالك وسجل مكالماتك لتقديم ميزات هوية المتصل والحماية. نستخدم هذه البيانات فقط لتشغيل ميزات التطبيق.

5. الاستخدام المقبول
أنت توافق على عدم:
- استخدام التطبيق للمضايقة أو الملاحقة أو أي غرض غير قانوني
- إجراء هندسة عكسية أو فكّ ترجمة أو محاولة استخراج الكود المصدري
- استخدام أدوات آلية لإساءة استخدام الخادم لدينا

6. الإعلانات
قد يعرض التطبيق إعلانات. قد يجمع المعلنون بيانات محدودة لتخصيص الإعلانات، وفقاً لموافقتك بموجب القانون المعمول به.

7. المسؤولية
يُقدَّم التطبيق «كما هو» بدون أي ضمان. لسنا مسؤولين عن المكالمات الفائتة أو المتصلين المُصنَّفين بشكل خاطئ أو الأضرار الناتجة عن استخدام التطبيق، إلى أقصى حد يسمح به القانون.

8. التغييرات
قد نقوم بتحديث هذه الشروط. الاستمرار في الاستخدام بعد التغييرات يعني قبولك للشروط المحدّثة.''';

  static const privacyPolicyAr = '''يلو فاست كول — سياسة الخصوصية

آخر تحديث: 2026-05-13

1. ما الذي نجمعه
- رقم الهاتف الذي تسجّل به الدخول
- اسمك وصورتك الشخصية (إن قدّمتها) والبريد الإلكتروني إذا سجّلت الدخول بحساب جوجل
- جهات الاتصال (فقط بإذن صريح منك، تُستخدم لتشغيل عمليات البحث عن هوية المتصل)
- إدخالات سجل المكالمات (فقط بإذنك، تُستخدم لتمييز الإزعاج وعرض المكالمات الأخيرة)
- بيانات استخدام مجهولة وتقارير الأعطال

2. كيف نستخدمها
- التعرّف على المتصلين المجهولين
- اكتشاف وحظر المتصلين المزعجين والاحتياليين
- تحسين التطبيق وإصلاح الأخطاء
- عرض إعلانات مخصّصة أو غير مخصّصة (حسب موافقتك)

3. ما الذي لا نفعله
- لا نبيع بياناتك الشخصية
- لا نشارك جهات اتصالك مع مستخدمين آخرين دون فعلٍ منك
- لا نسجّل مكالماتك ولا نقوم بتفريغها نصياً

4. الإعلانات
نستخدم Google AdMob. قد يجمع AdMob معرّفات الجهاز وبيانات التفاعل مع الإعلانات وفقاً لسياسة الخصوصية الخاصة به وموافقتك.

5. الأذونات
يتم طلب جهات الاتصال والهاتف وسجل المكالمات والميكروفون (إن وُجد) والإشعارات فقط عند الحاجة. يمكنك إلغاؤها في أي وقت من إعدادات الأندرويد.

6. حقوقك
يمكنك حذف حسابك في أي وقت من الإعدادات ← حذف الحساب. الحذف يزيل ملفك الشخصي ويفصل بياناتك عن رقم هاتفك على جانبنا.

7. الأطفال
التطبيق غير موجَّه للأطفال دون سن الثالثة عشرة. لا نجمع عمداً بيانات من الأطفال.''';

  static const helpAr = '''هل تحتاج إلى مساعدة؟

أسئلة شائعة

س: المكالمات لا تزال ترن رغم تفعيل الحظر.
ج: تأكّد من أن يلو فاست كول هو تطبيق فرز المكالمات لديك. افتح «الحماية» ← اضغط على الشريط الأصفر ← اختر «تعيين كافتراضي».

س: هاتفي يعمل بأندرويد 9 أو أقدم.
ج: الحظر الفعلي للمكالمات يتطلّب أندرويد 10 أو أحدث بسبب طريقة عمل فرز المكالمات في أندرويد.

س: أضفت رقماً إلى قائمة الحظر لكنه ما زال يصل إليّ.
ج: بعض شبكات الهاتف توصل المكالمات عبر مسارات تتجاوز الفرز. نحظر المكالمة بمجرّد أن يطلب أندرويد ذلك، لكن ليس كل المشغّلين يحترمون ذلك بنسبة 100%.

س: لماذا أرى إعلانات؟
ج: الإعلانات تساعد في إبقاء التطبيق مجانياً. يمكنك إزالتها بالترقية إلى بريميوم.

س: كيف أحذف حسابي؟
ج: الإعدادات ← حذف الحساب. هذا يمسح ملفك الشخصي والبيانات الموجودة على جهازك.''';
}
