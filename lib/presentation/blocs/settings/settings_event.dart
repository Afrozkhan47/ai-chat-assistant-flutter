import 'package:equatable/equatable.dart';

import '../../../data/models/settings_model.dart';

abstract class SettingsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class SaveSettings extends SettingsEvent {
  final SettingsModel settings;

  SaveSettings(this.settings);

  @override
  List<Object?> get props => [settings];
}

class ToggleDarkMode extends SettingsEvent {}
