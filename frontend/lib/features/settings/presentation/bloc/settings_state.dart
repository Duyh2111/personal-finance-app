import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final Locale locale;
  final bool isLoading;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('en', ''),
    this.isLoading = false,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? isLoading,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [themeMode, locale, isLoading];

  String get themeName {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  String get languageName {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'vi':
        return 'Vietnamese';
      default:
        return 'English';
    }
  }
}