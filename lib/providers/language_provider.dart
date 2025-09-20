import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en', '');
  
  Locale get currentLocale => _currentLocale;
  
  LanguageProvider() {
    _loadSavedLanguage();
  }
  
  void _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    _currentLocale = Locale(languageCode, '');
    notifyListeners();
  }
  
  void changeLanguage(String languageCode) async {
    if (_currentLocale.languageCode != languageCode) {
      _currentLocale = Locale(languageCode, '');
      
      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', languageCode);
      
      notifyListeners();
    }
  }
  
  bool get isEnglish => _currentLocale.languageCode == 'en';
  bool get isMyanmar => _currentLocale.languageCode == 'my';
}