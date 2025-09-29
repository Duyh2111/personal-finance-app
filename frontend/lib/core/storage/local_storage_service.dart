import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static const String _themeModeKey = 'theme_mode';
  static const String _languageCodeKey = 'language_code';
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _biometricEnabledKey = 'biometric_enabled';

  Future<void> saveThemeMode(String themeMode) async {
    await _prefs.setString(_themeModeKey, themeMode);
  }

  String getThemeMode() {
    return _prefs.getString(_themeModeKey) ?? 'system';
  }

  Future<void> saveLanguageCode(String languageCode) async {
    await _prefs.setString(_languageCodeKey, languageCode);
  }

  String getLanguageCode() {
    return _prefs.getString(_languageCodeKey) ?? 'en';
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(_onboardingCompletedKey, completed);
  }

  bool getOnboardingCompleted() {
    return _prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setBool(_biometricEnabledKey, enabled);
  }

  bool getBiometricEnabled() {
    return _prefs.getBool(_biometricEnabledKey) ?? false;
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}