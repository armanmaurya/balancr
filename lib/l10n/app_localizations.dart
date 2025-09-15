import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations);

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<String> _supported = ['en', 'hi'];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Balancr',
      'settingsTitle': 'Settings',
      'profileTitle': 'Profile',
      'preferencesTitle': 'Preferences',
      'aboutTitle': 'About',
      'version': 'Version',
      'darkMode': 'Dark mode',
      'enabled': 'Enabled',
      'disabled': 'Disabled',
      'language': 'Language',
      'currency': 'Currency',
      'termsOfService': 'Terms of Service',
      'privacyPolicy': 'Privacy Policy',
      'signOut': 'Sign Out',
      'signOutConfirmTitle': 'Sign Out',
      'signOutConfirmMessage': 'Are you sure you want to sign out?',
      'cancel': 'Cancel',
      'system': 'System',
      'chooseLanguage': 'Choose language',
      'english': 'English',
      'hindi': 'Hindi',
      'signedIn': 'Signed in',
      'userFallbackName': 'User',
      'loginWelcome': 'Welcome to Balancr',
      'loginSubtitle': 'Sign in to continue and manage your finances',
      'continueWithGoogle': 'Continue with Google',
      'signingIn': 'Signing in...',
      'termsPrefix': 'By continuing, you agree to our ',
      'and': ' and ',
      'termsSuffixPeriod': '.',
    },
    'hi': {
      'appTitle': 'Balancr',
      'settingsTitle': 'सेटिंग्स',
      'profileTitle': 'प्रोफ़ाइल',
      'preferencesTitle': 'प्राथमिकताएँ',
      'aboutTitle': 'जानकारी',
      'version': 'संस्करण',
      'darkMode': 'डार्क मोड',
      'enabled': 'सक्रिय',
      'disabled': 'निष्क्रिय',
      'language': 'भाषा',
      'currency': 'मुद्रा',
      'termsOfService': 'सेवा की शर्तें',
      'privacyPolicy': 'गोपनीयता नीति',
      'signOut': 'साइन आउट',
      'signOutConfirmTitle': 'साइन आउट',
      'signOutConfirmMessage': 'क्या आप वाकई साइन आउट करना चाहते हैं?',
      'cancel': 'रद्द करें',
      'system': 'सिस्टम',
      'chooseLanguage': 'भाषा चुनें',
      'english': 'अंग्रेज़ी',
      'hindi': 'हिंदी',
      'signedIn': 'साइन इन किया',
      'userFallbackName': 'उपयोगकर्ता',
      'loginWelcome': 'Balancr में आपका स्वागत है',
      'loginSubtitle': 'जारी रखने और अपने वित्त प्रबंधित करने के लिए साइन इन करें',
      'continueWithGoogle': 'Google के साथ जारी रखें',
      'signingIn': 'साइन इन हो रहा है...',
      'termsPrefix': 'जारी रखते हुए, आप हमारी ',
      'and': ' और ',
      'termsSuffixPeriod': '.',
    },
  };

  String _t(String key) =>
      _localizedValues[locale.languageCode]?[key] ?? _localizedValues['en']![key] ?? key;

  // Getters
  String get appTitle => _t('appTitle');
  String get settingsTitle => _t('settingsTitle');
  String get profileTitle => _t('profileTitle');
  String get preferencesTitle => _t('preferencesTitle');
  String get aboutTitle => _t('aboutTitle');
  String get version => _t('version');
  String get darkMode => _t('darkMode');
  String get enabled => _t('enabled');
  String get disabled => _t('disabled');
  String get language => _t('language');
  String get currency => _t('currency');
  String get termsOfService => _t('termsOfService');
  String get privacyPolicy => _t('privacyPolicy');
  String get signOut => _t('signOut');
  String get signOutConfirmTitle => _t('signOutConfirmTitle');
  String get signOutConfirmMessage => _t('signOutConfirmMessage');
  String get cancel => _t('cancel');
  String get system => _t('system');
  String get chooseLanguage => _t('chooseLanguage');
  String get english => _t('english');
  String get hindi => _t('hindi');
  String get signedIn => _t('signedIn');
  String get userFallbackName => _t('userFallbackName');
  String get loginWelcome => _t('loginWelcome');
  String get loginSubtitle => _t('loginSubtitle');
  String get continueWithGoogle => _t('continueWithGoogle');
  String get signingIn => _t('signingIn');
  String get termsPrefix => _t('termsPrefix');
  String get and => _t('and');
  String get termsSuffixPeriod => _t('termsSuffixPeriod');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations._supported.contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => SynchronousFuture<AppLocalizations>(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
