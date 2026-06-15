import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/service_locator.dart';
import '../../data/models/message_model.dart';
import '../../data/repositories/conversation_repository.dart';
import '../blocs/chat/chat_bloc.dart';
import '../blocs/chat/chat_event.dart';
import '../blocs/chat/chat_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String initialTitle;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.initialTitle,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late String _title;

  @override
  void initState() {
    super.initState();
    _title = widget.initialTitle;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _refreshTitle() {
    final conversation =
        getIt<ConversationRepository>().getConversation(widget.conversationId);
    if (conversation != null && conversation.title != _title) {
      setState(() => _title = conversation.title);
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    context.read<ChatBloc>().add(SendMessage(text));
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            _title,
            key: ValueKey(_title),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatLoaded || state is ChatError) {
                  _refreshTitle();
                }
                _scrollToBottom();
              },
              builder: (context, state) {
                if (state is ChatInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<MessageModel> messages = const [];

                if (state is ChatLoading) {
                  messages = state.messages;
                } else if (state is ChatLoaded) {
                  messages = state.messages;
                } else if (state is ChatError) {
                  messages = state.messages;
                }

                final isLoading = state is ChatLoading;
                final errorMessage =
                    state is ChatError ? state.message : null;

                if (messages.isEmpty && !isLoading) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.waving_hand_outlined,
                            size: 40,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.7),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Say hello to start chatting',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: errorMessage == null
                          ? const SizedBox.shrink()
                          : MaterialBanner(
                              key: ValueKey(errorMessage),
                              content: Text(errorMessage),
                              leading: const Icon(Icons.error_outline),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    context
                                        .read<ChatBloc>()
                                        .add(LoadMessages());
                                  },
                                  child: const Text('Dismiss'),
                                ),
                              ],
                            ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: messages.length + (isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (isLoading && index == messages.length) {
                            return const TypingIndicator();
                          }

                          return MessageBubble(
                            key: ValueKey(messages[index].id),
                            message: messages[index],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          _MessageInput(
            controller: _messageController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _MessageInput({
    required this.controller,
    required this.onSend,
  });

  @override
  State<_MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<_MessageInput> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ChatBloc>().state is ChatLoading;
    final colorScheme = Theme.of(context).colorScheme;
    final canSend = _hasText && !isLoading;

    return SafeArea(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                enabled: !isLoading,
                maxLines: 5,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) {
                  if (canSend) widget.onSend();
                },
              ),
            ),
            const SizedBox(width: 8),
            AnimatedScale(
              scale: canSend ? 1 : 0.85,
              duration: const Duration(milliseconds: 180),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: canSend
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: canSend ? widget.onSend : null,
                  icon: Icon(
                    Icons.send_rounded,
                    color: canSend
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
