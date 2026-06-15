import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/message_model.dart';
import '../../../data/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;
  final String conversationId;
  final _uuid = const Uuid();

  ChatBloc({
    required ChatRepository repository,
    required this.conversationId,
  })  : _repository = repository,
        super(ChatInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
  }

  void _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) {
    try {
      final messages = _repository.loadMessages(conversationId);
      emit(ChatLoaded(messages));
    } catch (e) {
      emit(ChatError(messages: const [], message: e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoading) return;

    final currentMessages = _currentMessages();
    final userMessage = MessageModel(
      id: _uuid.v4(),
      content: event.text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    emit(ChatLoading([...currentMessages, userMessage]));

    try {
      final messages = await _repository.sendMessage(
        conversationId,
        event.text,
      );
      emit(ChatLoaded(messages));
    } catch (e) {
      emit(
        ChatError(
          messages: [...currentMessages, userMessage],
          message: e.toString(),
        ),
      );
    }
  }

  List<MessageModel> _currentMessages() {
    final state = this.state;
    if (state is ChatLoaded) return state.messages;
    if (state is ChatLoading) return state.messages;
    if (state is ChatError) return state.messages;
    return [];
  }
}
