import 'package:equatable/equatable.dart';

abstract class ConversationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadConversations extends ConversationEvent {}

class CreateConversation extends ConversationEvent {
  final String? title;

  CreateConversation({this.title});

  @override
  List<Object?> get props => [title];
}

class DeleteConversation extends ConversationEvent {
  final String id;

  DeleteConversation(this.id);

  @override
  List<Object?> get props => [id];
}
