import 'package:hive/hive.dart';

import '../../core/api/api_constants.dart';
import '../../core/constants/hive_constants.dart';
import '../models/settings_model.dart';

class SettingsRepository {
  final Box<SettingsModel> _box;

  SettingsRepository(this._box);

  SettingsModel loadSettings() {
    final stored = _box.get(HiveConstants.settingsKey);
    if (stored == null) {
      return SettingsModel();
    }

    return _normalize(stored);
  }

  Future<void> saveSettings(SettingsModel settings) async {
    await _box.put(HiveConstants.settingsKey, _normalize(settings));
  }

  SettingsModel _normalize(SettingsModel settings) {
    final modelName = settings.modelName.trim();
    return SettingsModel(
      apiKey: ApiConstants.cleanApiKey(settings.apiKey),
      baseUrl: ApiConstants.normalizeBaseUrl(settings.baseUrl),
      modelName:
          modelName.isEmpty ? ApiConstants.defaultModel : modelName,
      darkMode: settings.darkMode,
    );
  }
}
