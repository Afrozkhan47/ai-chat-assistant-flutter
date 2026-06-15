import 'package:hive/hive.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 2)
class SettingsModel extends HiveObject {
  @HiveField(0)
  final String apiKey;

  @HiveField(1)
  final String baseUrl;

  @HiveField(2)
  final String modelName;

  @HiveField(3)
  final bool darkMode;

  SettingsModel({
    this.apiKey = '',
    this.baseUrl = 'https://api.openai.com/v1',
    this.modelName = 'gpt-4o-mini',
    this.darkMode = false,
  });
}
