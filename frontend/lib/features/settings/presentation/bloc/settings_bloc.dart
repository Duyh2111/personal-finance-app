import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferences _prefs;

  static const String _themeKey = 'theme_mode';
  static const String _localeKey = 'locale';

  SettingsBloc(this._prefs) : super(const SettingsState()) {
    on<SettingsLoadRequested>(_onLoadRequested);
    on<ThemeChanged>(_onThemeChanged);
    on<LocaleChanged>(_onLocaleChanged);

    add(SettingsLoadRequested());
  }

  Future<void> _onLoadRequested(
    SettingsLoadRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Load theme mode
      final themeIndex = _prefs.getInt(_themeKey) ?? ThemeMode.system.index;
      final themeMode = ThemeMode.values[themeIndex];

      // Load locale
      final localeString = _prefs.getString(_localeKey) ?? 'en';
      final locale = Locale(localeString, '');

      emit(state.copyWith(
        themeMode: themeMode,
        locale: locale,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onThemeChanged(
    ThemeChanged event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _prefs.setInt(_themeKey, event.themeMode.index);
      emit(state.copyWith(themeMode: event.themeMode));
    } catch (e) {
      // Handle error silently or emit error state
    }
  }

  Future<void> _onLocaleChanged(
    LocaleChanged event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _prefs.setString(_localeKey, event.locale.languageCode);
      emit(state.copyWith(locale: event.locale));
    } catch (e) {
      // Handle error silently or emit error state
    }
  }
}