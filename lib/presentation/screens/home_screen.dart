import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/service_locator.dart';
import '../../data/models/conversation_model.dart';
import '../../data/repositories/chat_repository.dart';
import '../blocs/chat/chat_bloc.dart';
import '../blocs/chat/chat_event.dart';
import '../blocs/conversation/conversation_bloc.dart';
import '../blocs/conversation/conversation_event.dart';
import '../blocs/conversation/conversation_state.dart';
import '../widgets/create_conversation_dialog.dart';
import '../widgets/empty_state_view.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _createConversation(BuildContext context) async {
    final title = await showCreateConversationDialog(context);
    if (title == null || !context.mounted) return;

    context.read<ConversationBloc>().add(CreateConversation(title: title));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ConversationBloc, ConversationState>(
        builder: (context, state) {
          if (state is ConversationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ConversationError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error: ${state.message}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (state is ConversationLoaded) {
            if (state.conversations.isEmpty) {
              return EmptyStateView(
                icon: Icons.chat_bubble_outline,
                title: 'No conversations yet',
                subtitle: 'Tap the + button below to start your first chat.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
              itemCount: state.conversations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _ConversationCard(
                  conversation: state.conversations[index],
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createConversation(context),
        icon: const Icon(Icons.add),
        label: const Text('New Chat'),
      ),
    );
  }
}

class _ConversationCard extends StatelessWidget {
  final ConversationModel conversation;

  const _ConversationCard({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final date =
        DateFormat('MMM d, yyyy • h:mm a').format(conversation.updatedAt);
    final preview = conversation.messages.isEmpty
        ? 'No messages yet'
        : conversation.messages.last.content;

    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openChat(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Icons.chat_outlined,
                  size: 20,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preview,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.65),
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      date,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Delete',
                icon: Icon(
                  Icons.delete_outline,
                  color: colorScheme.error.withValues(alpha: 0.8),
                ),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ChatBloc(
            repository: getIt<ChatRepository>(),
            conversationId: conversation.id,
          )..add(LoadMessages()),
          child: ChatScreen(
            conversationId: conversation.id,
            initialTitle: conversation.title,
          ),
        ),
      ),
    ).then((_) {
      if (context.mounted) {
        context.read<ConversationBloc>().add(LoadConversations());
      }
    });
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete conversation?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      context.read<ConversationBloc>().add(
            DeleteConversation(conversation.id),
          );
    }
  }
}
