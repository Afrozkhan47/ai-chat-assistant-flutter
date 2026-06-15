import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/api/api_service.dart';
import '../data/models/conversation_model.dart';
import '../data/models/message_model.dart';
import '../data/models/settings_model.dart';
import '../data/repositories/chat_repository.dart';
import '../data/repositories/conversation_repository.dart';
import '../data/repositories/settings_repository.dart';
import 'constants/hive_constants.dart';

final getIt = GetIt.instance;

/// Initializes Hive, registers adapters, opens boxes, and wires GetIt.
Future<void> setupLocator() async {
  await Hive.initFlutter();

  // MessageModel must be registered before ConversationModel (nested list).
  Hive.registerAdapter(MessageModelAdapter());
  Hive.registerAdapter(ConversationModelAdapter());
  Hive.registerAdapter(SettingsModelAdapter());

  final conversationBox = await Hive.openBox<ConversationModel>(
    HiveConstants.conversationsBox,
  );
  final settingsBox = await Hive.openBox<SettingsModel>(
    HiveConstants.settingsBox,
  );

  getIt.registerSingleton<Box<ConversationModel>>(conversationBox);
  getIt.registerSingleton<Box<SettingsModel>>(settingsBox);

  getIt.registerLazySingleton<ConversationRepository>(
    () => ConversationRepository(getIt<Box<ConversationModel>>()),
  );
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepository(getIt<Box<SettingsModel>>()),
  );
  getIt.registerLazySingleton<ApiService>(() => ApiService());
  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepository(
      getIt<ApiService>(),
      getIt<ConversationRepository>(),
      getIt<SettingsRepository>(),
    ),
  );
}
