import 'package:uuid/uuid.dart';

import '../../core/utils/conversation_title_helper.dart';
import '../../core/api/api_service.dart';
import '../models/message_model.dart';
import 'conversation_repository.dart';
import 'settings_repository.dart';

class ChatRepository {
  final ApiService _apiService;
  final ConversationRepository _conversationRepository;
  final SettingsRepository _settingsRepository;
  final _uuid = const Uuid();

  ChatRepository(
    this._apiService,
    this._conversationRepository,
    this._settingsRepository,
  );

  List<MessageModel> loadMessages(String conversationId) {
    final conversation = _conversationRepository.getConversation(conversationId);
    return conversation?.messages ?? [];
  }

  Future<List<MessageModel>> sendMessage(
    String conversationId,
    String text,
  ) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw Exception('Message cannot be empty.');
    }

    final conversation = _conversationRepository.getConversation(conversationId);
    if (conversation == null) {
      throw Exception('Conversation not found.');
    }

    final settings = _settingsRepository.loadSettings();

    if (settings.apiKey.isEmpty) {
      throw Exception('Please add your API key in Settings and tap Save.');
    }

    final now = DateTime.now();

    final userMessage = MessageModel(
      id: _uuid.v4(),
      content: trimmed,
      isUser: true,
      timestamp: now,
    );

    final updatedMessages = [...conversation.messages, userMessage];
    final isFirstUserMessage = conversation.messages.isEmpty;
    final autoTitle = isFirstUserMessage &&
            ConversationTitleHelper.shouldAutoTitle(conversation.title)
        ? ConversationTitleHelper.generate(trimmed)
        : null;

    await _conversationRepository.saveMessages(
      conversationId,
      updatedMessages,
      title: autoTitle,
    );

    final apiMessages = updatedMessages
        .map(
          (message) => {
            'role': message.isUser ? 'user' : 'assistant',
            'content': message.content,
          },
        )
        .toList();

    final aiContent = await _apiService.sendChatCompletion(
      apiKey: settings.apiKey,
      baseUrl: settings.baseUrl,
      modelName: settings.modelName,
      messages: apiMessages,
    );

    final aiMessage = MessageModel(
      id: _uuid.v4(),
      content: aiContent,
      isUser: false,
      timestamp: DateTime.now(),
    );

    final finalMessages = [...updatedMessages, aiMessage];
    await _conversationRepository.saveMessages(conversationId, finalMessages);

    return finalMessages;
  }
}
