import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_constants.dart';
import 'api_exception.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 60);

  Future<String> sendChatCompletion({
    required String apiKey,
    required String baseUrl,
    required String modelName,
    required List<Map<String, String>> messages,
  }) async {
    final cleanKey = ApiConstants.cleanApiKey(apiKey);
    if (cleanKey.isEmpty) {
      throw ApiException('Please add your API key in Settings.');
    }

    final url = ApiConstants.resolveChatCompletionsUrl(baseUrl);
    final model = modelName.trim().isEmpty
        ? ApiConstants.defaultModel
        : modelName.trim();

    final headers = {
      'Authorization': 'Bearer $cleanKey',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'model': model,
      'messages': messages,
    });

    if (kDebugMode) {
      debugPrint('OpenAI request URL: $url');
      debugPrint('OpenAI model: $model');
    }

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: body,
          )
          .timeout(_timeout);

      if (kDebugMode) {
        debugPrint('OpenAI status: ${response.statusCode}');
        debugPrint('OpenAI body: ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        if (data is! Map<String, dynamic>) {
          throw ApiException('Unexpected response format from API.');
        }

        final content = data['choices']?[0]?['message']?['content'];
        if (content == null || content.toString().trim().isEmpty) {
          throw ApiException('The AI returned an empty response.');
        }

        return content.toString().trim();
      }

      throw ApiException(
        _parseErrorMessage(response.statusCode, response.body),
      );
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('Request timed out. Please try again.');
    } on FormatException {
      throw ApiException('Invalid response from API. Please try again.');
    } catch (error) {
      if (kDebugMode) {
        debugPrint('OpenAI request error: $error');
      }
      throw ApiException('Network error. Check your internet connection.');
    }
  }

  String _parseErrorMessage(int statusCode, String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        final error = decoded['error'];
        if (error is Map && error['message'] != null) {
          return error['message'].toString();
        }
        if (decoded['message'] != null) {
          return decoded['message'].toString();
        }
      }
    } catch (_) {
      if (body.trim().isNotEmpty) {
        return 'API error ($statusCode): ${body.trim()}';
      }
    }

    switch (statusCode) {
      case 401:
      case 403:
        return 'Authentication failed ($statusCode). Check your API key in Settings.';
      case 404:
        return 'API endpoint not found ($statusCode). Check Base URL in Settings.';
      case 429:
        return 'Rate limit exceeded. Please wait and try again.';
      default:
        return 'Request failed ($statusCode). Please try again.';
    }
  }
}
