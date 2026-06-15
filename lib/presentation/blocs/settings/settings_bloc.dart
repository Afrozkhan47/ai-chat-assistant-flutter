import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/settings_model.dart';
import '../../../data/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _repository;

  SettingsBloc(this._repository) : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<SaveSettings>(_onSaveSettings);
    on<ToggleDarkMode>(_onToggleDarkMode);
  }

  void _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) {
    try {
      final settings = _repository.loadSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onSaveSettings(
    SaveSettings event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _repository.saveSettings(event.settings);
      emit(SettingsLoaded(event.settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> _onToggleDarkMode(
    ToggleDarkMode event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final current = _currentSettings();
      final updated = SettingsModel(
        apiKey: current.apiKey,
        baseUrl: current.baseUrl,
        modelName: current.modelName,
        darkMode: !current.darkMode,
      );
      await _repository.saveSettings(updated);
      emit(SettingsLoaded(updated));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  SettingsModel _currentSettings() {
    if (state is SettingsLoaded) {
      return (state as SettingsLoaded).settings;
    }
    return _repository.loadSettings();
  }
}
