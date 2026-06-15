/// Generates a short conversation title from the first user message.
class ConversationTitleHelper {
  ConversationTitleHelper._();

  static const _defaultTitle = 'New Chat';
  static const _maxLength = 25;

  static const _prefixes = [
    'how do i ',
    'how do you ',
    'how to ',
    'what is ',
    'what are ',
    'can you ',
    'please ',
    'help me ',
    'tell me ',
  ];

  static String generate(String message) {
    var text = message.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (text.isEmpty) return _defaultTitle;

    final lower = text.toLowerCase();
    for (final prefix in _prefixes) {
      if (lower.startsWith(prefix)) {
        text = text.substring(prefix.length).trim();
        break;
      }
    }

    text = text.replaceAll(RegExp(r'[?!.]+$'), '').trim();
    if (text.isEmpty) return _defaultTitle;

    text = text[0].toUpperCase() + text.substring(1);

    if (text.length > _maxLength) {
      text = '${text.substring(0, _maxLength - 3).trim()}...';
    }

    return text;
  }

  static bool shouldAutoTitle(String currentTitle) {
    return currentTitle.trim().isEmpty || currentTitle.trim() == _defaultTitle;
  }
}
