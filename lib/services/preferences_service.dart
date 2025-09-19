import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _offlinePreferenceKey = 'offline_preference';
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  
  static PreferencesService? _instance;
  static SharedPreferences? _prefs;
  
  PreferencesService._();
  
  static Future<PreferencesService> getInstance() async {
    _instance ??= PreferencesService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }
  
  // Offline preference methods
  Future<bool> getOfflinePreference() async {
    return _prefs?.getBool(_offlinePreferenceKey) ?? false;
  }
  
  Future<void> setOfflinePreference(bool value) async {
    await _prefs?.setBool(_offlinePreferenceKey, value);
  }
  
  // Onboarding methods
  Future<bool> hasSeenOnboarding() async {
    return _prefs?.getBool(_hasSeenOnboardingKey) ?? false;
  }
  
  Future<void> setHasSeenOnboarding(bool value) async {
    await _prefs?.setBool(_hasSeenOnboardingKey, value);
  }
  
  // Clear all preferences (for logout)
  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}