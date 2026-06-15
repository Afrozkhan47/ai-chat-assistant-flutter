import 'package:hive/hive.dart';

part 'message_model.g.dart';

@HiveType(typeId: 0)
class MessageModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final bool isUser;

  @HiveField(3)
  final DateTime timestamp;

  MessageModel({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}
