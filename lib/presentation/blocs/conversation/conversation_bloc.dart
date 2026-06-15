import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/conversation_repository.dart';
import 'conversation_event.dart';
import 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final ConversationRepository _repository;

  ConversationBloc(this._repository) : super(ConversationInitial()) {
    on<LoadConversations>(_onLoadConversations);
    on<CreateConversation>(_onCreateConversation);
    on<DeleteConversation>(_onDeleteConversation);
  }

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<ConversationState> emit,
  ) async {
    emit(ConversationLoading());
    try {
      final conversations = _repository.getConversations();
      emit(ConversationLoaded(conversations));
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }

  Future<void> _onCreateConversation(
    CreateConversation event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      final trimmed = event.title?.trim();
      final title = (trimmed == null || trimmed.isEmpty)
          ? 'New Chat'
          : trimmed;
      await _repository.createConversation(title: title);
      add(LoadConversations());
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }

  Future<void> _onDeleteConversation(
    DeleteConversation event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      await _repository.deleteConversation(event.id);
      add(LoadConversations());
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }
}
