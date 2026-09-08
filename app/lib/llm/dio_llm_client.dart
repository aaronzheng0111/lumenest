import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'llm_types.dart';

/// Compile-time LLM config (`--dart-define`). Never hardcode keys in source.
class LlmConfig {
  const LlmConfig({
    required this.baseUrl,
    required this.apiKey,
    required this.model,
  });

  factory LlmConfig.fromEnvironment() {
    return const LlmConfig(
      baseUrl: String.fromEnvironment('LLM_BASE_URL', defaultValue: ''),
      apiKey: String.fromEnvironment('LLM_API_KEY', defaultValue: ''),
      model: String.fromEnvironment('LLM_MODEL', defaultValue: 'gpt-4o-mini'),
    );
  }

  final String baseUrl;
  final String apiKey;
  final String model;

  bool get hasKey => apiKey.trim().isNotEmpty;
  bool get hasBaseUrl => baseUrl.trim().isNotEmpty;
}

typedef LlmLogSink = void Function(String message);

/// OpenAI-compatible chat/completions client (module 06).
class DioLlmClient implements LlmClient {
  DioLlmClient({
    required this.config,
    Dio? dio,
    this.log,
    this.temperature = 0.7,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(seconds: 15),
                responseType: ResponseType.json,
              ),
            );

  final LlmConfig config;
  final Dio _dio;
  final LlmLogSink? log;
  final double temperature;

  /// Test hook: how many HTTP attempts were made (must stay 1 on failure).
  int requestCount = 0;

  @override
  Future<LlmResult> complete({
    required List<ChatMessageWire> messages,
    required String requestId,
  }) async {
    if (!config.hasKey || !config.hasBaseUrl) {
      _safeLog('llm missingKey requestId=$requestId');
      return const LlmResult(status: LlmStatus.missingKey);
    }

    final url = buildChatCompletionsUrl(config.baseUrl);
    final sw = Stopwatch()..start();
    requestCount++;

    try {
      final response = await _dio.post<dynamic>(
        url,
        data: {
          'model': config.model,
          'temperature': temperature,
          'messages': messages.map((m) => m.toJson()).toList(),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${config.apiKey}',
            'Content-Type': 'application/json',
            'x-request-id': requestId,
          },
        ),
      );
      sw.stop();
      final statusCode = response.statusCode ?? 0;
      _safeLog(
        'llm status=$statusCode latencyMs=${sw.elapsedMilliseconds} requestId=$requestId',
      );

      if (statusCode < 200 || statusCode >= 300) {
        return LlmResult(
          status: LlmStatus.httpError,
          httpStatus: statusCode,
          latencyMs: sw.elapsedMilliseconds,
        );
      }

      return _parseOk(response.data, sw.elapsedMilliseconds, statusCode);
    } on DioException catch (e) {
      sw.stop();
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        _safeLog(
          'llm timeout latencyMs=${sw.elapsedMilliseconds} requestId=$requestId',
        );
        return LlmResult(
          status: LlmStatus.timeout,
          latencyMs: sw.elapsedMilliseconds,
        );
      }
      final code = e.response?.statusCode;
      _safeLog(
        'llm httpError status=$code latencyMs=${sw.elapsedMilliseconds} requestId=$requestId',
      );
      return LlmResult(
        status: LlmStatus.httpError,
        httpStatus: code,
        latencyMs: sw.elapsedMilliseconds,
      );
    } catch (e) {
      sw.stop();
      _safeLog('llm parseError requestId=$requestId');
      return LlmResult(
        status: LlmStatus.parseError,
        latencyMs: sw.elapsedMilliseconds,
      );
    }
  }

  LlmResult _parseOk(dynamic data, int latencyMs, int statusCode) {
    try {
      final map = data is Map<String, dynamic>
          ? data
          : jsonDecode(jsonEncode(data)) as Map<String, dynamic>;
      final choices = map['choices'];
      if (choices is! List || choices.isEmpty) {
        return LlmResult(
          status: LlmStatus.parseError,
          httpStatus: statusCode,
          latencyMs: latencyMs,
        );
      }
      final first = choices.first;
      if (first is! Map) {
        return LlmResult(
          status: LlmStatus.parseError,
          httpStatus: statusCode,
          latencyMs: latencyMs,
        );
      }
      final message = first['message'];
      if (message is! Map || message['content'] is! String) {
        return LlmResult(
          status: LlmStatus.parseError,
          httpStatus: statusCode,
          latencyMs: latencyMs,
        );
      }
      final content = message['content'] as String;
      final usage = map['usage'];
      int? promptTokens;
      int? completionTokens;
      if (usage is Map) {
        promptTokens = usage['prompt_tokens'] as int?;
        completionTokens = usage['completion_tokens'] as int?;
      }
      return LlmResult(
        status: LlmStatus.ok,
        content: content,
        promptTokens: promptTokens,
        completionTokens: completionTokens,
        httpStatus: statusCode,
        latencyMs: latencyMs,
      );
    } catch (_) {
      return LlmResult(
        status: LlmStatus.parseError,
        httpStatus: statusCode,
        latencyMs: latencyMs,
      );
    }
  }

  void _safeLog(String message) {
    final sink = log ??
        (String m) {
          // Never log Authorization / message bodies.
          assert(!m.toLowerCase().contains('bearer'));
          assert(!m.toLowerCase().contains('api key'));
          debugPrint(m);
        };
    sink(message);
  }
}
