import 'package:equatable/equatable.dart';

import '../../../data/models/conversation_model.dart';

abstract class ConversationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ConversationInitial extends ConversationState {}

class ConversationLoading extends ConversationState {}

class ConversationLoaded extends ConversationState {
  final List<ConversationModel> conversations;

  ConversationLoaded(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

class ConversationError extends ConversationState {
  final String message;

  ConversationError(this.message);

  @override
  List<Object?> get props => [message];
}
