import 'package:hive/hive.dart';

import 'message_model.dart';

part 'conversation_model.g.dart';

@HiveType(typeId: 1)
class ConversationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final List<MessageModel> messages;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime updatedAt;

  ConversationModel({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });
}
