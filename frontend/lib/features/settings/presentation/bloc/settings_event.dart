import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SettingsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SettingsLoadRequested extends SettingsEvent {}

class ThemeChanged extends SettingsEvent {
  final ThemeMode themeMode;

  ThemeChanged(this.themeMode);

  @override
  List<Object> get props => [themeMode];
}

class LocaleChanged extends SettingsEvent {
  final Locale locale;

  LocaleChanged(this.locale);

  @override
  List<Object> get props => [locale];
}