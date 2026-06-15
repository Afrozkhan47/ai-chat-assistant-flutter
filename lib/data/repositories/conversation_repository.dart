import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/conversation_model.dart';
import '../models/message_model.dart';

class ConversationRepository {
  final Box<ConversationModel> _box;
  final _uuid = const Uuid();

  ConversationRepository(this._box);

  List<ConversationModel> getConversations() {
    final conversations = _box.values.toList();
    conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return conversations;
  }

  ConversationModel? getConversation(String id) {
    return _box.get(id);
  }

  Future<ConversationModel> createConversation({String title = 'New Chat'}) async {
    final now = DateTime.now();
    final conversation = ConversationModel(
      id: _uuid.v4(),
      title: title,
      messages: [],
      createdAt: now,
      updatedAt: now,
    );

    await _box.put(conversation.id, conversation);
    return conversation;
  }

  Future<void> deleteConversation(String id) async {
    await _box.delete(id);
  }

  Future<void> saveMessages(
    String conversationId,
    List<MessageModel> messages, {
    String? title,
  }) async {
    final conversation = _box.get(conversationId);
    if (conversation == null) return;

    await _box.put(
      conversationId,
      ConversationModel(
        id: conversation.id,
        title: title ?? conversation.title,
        messages: messages,
        createdAt: conversation.createdAt,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> updateTimestamps(String conversationId) async {
    final conversation = _box.get(conversationId);
    if (conversation == null) return;

    await _box.put(
      conversationId,
      ConversationModel(
        id: conversation.id,
        title: conversation.title,
        messages: conversation.messages,
        createdAt: conversation.createdAt,
        updatedAt: DateTime.now(),
      ),
    );
  }
}
