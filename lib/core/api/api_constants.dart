/// OpenAI-compatible API defaults and URL helpers.
class ApiConstants {
  ApiConstants._();

  static const String defaultBaseUrl = 'https://api.openai.com/v1';
  static const String defaultModel = 'gpt-4o-mini';
  static const String openAiChatCompletionsUrl =
      'https://api.openai.com/v1/chat/completions';

  /// Builds a safe chat/completions URL without double-appending the path.
  static String resolveChatCompletionsUrl(String baseUrl) {
    var url = baseUrl.trim();

    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    if (url.isEmpty) {
      return openAiChatCompletionsUrl;
    }

    if (url.endsWith('/chat/completions')) {
      return url;
    }

    if (url.endsWith('/v1')) {
      return '$url/chat/completions';
    }

    final uri = Uri.tryParse(url);
    if (uri != null &&
        uri.hasScheme &&
        uri.host.isNotEmpty &&
        (uri.path.isEmpty || uri.path == '/')) {
      return '$url/v1/chat/completions';
    }

    return '$url/chat/completions';
  }

  /// Removes accidental spaces/newlines pasted into API keys.
  static String cleanApiKey(String apiKey) {
    return apiKey.trim().replaceAll(RegExp(r'\s+'), '');
  }

  /// Stores base URL without the /chat/completions suffix.
  static String normalizeBaseUrl(String baseUrl) {
    var url = baseUrl.trim();

    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    if (url.endsWith('/chat/completions')) {
      url = url.substring(0, url.length - '/chat/completions'.length);
      while (url.endsWith('/')) {
        url = url.substring(0, url.length - 1);
      }
    }

    return url.isEmpty ? defaultBaseUrl : url;
  }
}
