import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  LanguageProvider({Locale? initialLocale}) : _locale = initialLocale;

  static const _prefsKey = 'app_locale'; // e.g. 'en', 'hi'

  Locale? _locale; // null means follow system
  Locale? get locale => _locale;

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
  ];

  Future<void> setLocale(Locale? locale) async {
    // null: system
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }
  }

  static Future<Locale?> loadInitialLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code == null) return null; // follow system
    return supportedLocales.firstWhere(
      (l) => l.languageCode == code,
      orElse: () => Locale(code),
    );
  }

  String labelFor(Locale? locale) {
    if (locale == null) return 'System';
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'hi':
        return 'Hindi';
      default:
        return locale.languageCode;
    }
  }
}
