import 'package:equatable/equatable.dart';

import '../../../data/models/message_model.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {
  final List<MessageModel> messages;

  ChatLoading(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatLoaded extends ChatState {
  final List<MessageModel> messages;

  ChatLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatError extends ChatState {
  final List<MessageModel> messages;
  final String message;

  ChatError({required this.messages, required this.message});

  @override
  List<Object?> get props => [messages, message];
}
