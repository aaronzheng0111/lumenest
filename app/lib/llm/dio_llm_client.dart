import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'llm_model_catalog.dart';
import 'llm_types.dart';

/// Compile-time LLM config (`--dart-define`) plus optional runtime model pick.
/// Never hardcode keys in source.
class LlmConfig {
  const LlmConfig({
    required this.baseUrl,
    required this.apiKey,
    required this.model,
    this.forceOffline = false,
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

  /// When true (e.g. 「本地演示」), skip remote calls even if a key is set.
  final bool forceOffline;

  bool get hasKey {
    final k = apiKey.trim();
    if (k.isEmpty) return false;
    // Common placeholder values from env/dev.json.example must not count as configured.
    const placeholders = {
      'REPLACE_ME',
      'your_api_key',
      'YOUR_API_KEY',
      'changeme',
    };
    return !placeholders.contains(k);
  }

  bool get hasBaseUrl => baseUrl.trim().isNotEmpty;

  LlmConfig copyWith({
    String? baseUrl,
    String? apiKey,
    String? model,
    bool? forceOffline,
  }) {
    return LlmConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      forceOffline: forceOffline ?? this.forceOffline,
    );
  }

  /// Applies a catalog selection. Runtime [apiModelId] overrides `LLM_MODEL`.
  /// [baseUrlHint] fills in only when env `LLM_BASE_URL` is empty.
  /// Remote picks without a real API key fall back to offline demo replies.
  LlmConfig withModelOption(LlmModelOption option) {
    if (option.offline || !hasKey) {
      return copyWith(forceOffline: true);
    }
    final hint = option.baseUrlHint?.trim() ?? '';
    final resolvedBase = hasBaseUrl
        ? baseUrl
        : (hint.isNotEmpty ? hint : baseUrl);
    final resolvedModel =
        option.apiModelId.trim().isNotEmpty ? option.apiModelId.trim() : model;
    return copyWith(
      baseUrl: resolvedBase,
      model: resolvedModel,
      forceOffline: false,
    );
  }
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
  bool get canCallRemote =>
      !config.forceOffline && config.hasKey && config.hasBaseUrl;

  Map<String, dynamic> _requestBody(
    List<ChatMessageWire> messages, {
    required bool stream,
  }) {
    return {
      'model': config.model,
      'temperature': temperature,
      'messages': messages.map((m) => m.toJson()).toList(),
      if (stream) 'stream': true,
    };
  }

  Options _authOptions(String requestId, {ResponseType? responseType}) {
    return Options(
      responseType: responseType,
      headers: {
        'Authorization': 'Bearer ${config.apiKey}',
        'Content-Type': 'application/json',
        'x-request-id': requestId,
        if (responseType == ResponseType.stream) 'Accept': 'text/event-stream',
      },
      // Streaming replies often exceed the 15s one-shot budget; idle between
      // SSE chunks still fails closed if the provider stalls.
      receiveTimeout: responseType == ResponseType.stream
          ? const Duration(seconds: 90)
          : null,
    );
  }

  @override
  Future<LlmResult> complete({
    required List<ChatMessageWire> messages,
    required String requestId,
  }) async {
    if (!canCallRemote) {
      _safeLog('llm missingKey requestId=$requestId');
      return const LlmResult(status: LlmStatus.missingKey);
    }

    final url = buildChatCompletionsUrl(config.baseUrl);
    final sw = Stopwatch()..start();
    requestCount++;

    try {
      final response = await _dio.post<dynamic>(
        url,
        data: _requestBody(messages, stream: false),
        options: _authOptions(requestId),
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
      return _mapDioException(e, sw.elapsedMilliseconds, requestId);
    } catch (e) {
      sw.stop();
      _safeLog('llm parseError requestId=$requestId');
      return LlmResult(
        status: LlmStatus.parseError,
        latencyMs: sw.elapsedMilliseconds,
      );
    }
  }

  @override
  Stream<LlmStreamEvent> streamComplete({
    required List<ChatMessageWire> messages,
    required String requestId,
  }) async* {
    if (!canCallRemote) {
      _safeLog('llm missingKey requestId=$requestId');
      yield const LlmStreamEnd(LlmResult(status: LlmStatus.missingKey));
      return;
    }

    final url = buildChatCompletionsUrl(config.baseUrl);
    final sw = Stopwatch()..start();
    requestCount++;

    try {
      final response = await _dio.post<ResponseBody>(
        url,
        data: _requestBody(messages, stream: true),
        options: _authOptions(requestId, responseType: ResponseType.stream),
      );
      final statusCode = response.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 300) {
        sw.stop();
        _safeLog(
          'llm status=$statusCode latencyMs=${sw.elapsedMilliseconds} requestId=$requestId',
        );
        yield LlmStreamEnd(
          LlmResult(
            status: LlmStatus.httpError,
            httpStatus: statusCode,
            latencyMs: sw.elapsedMilliseconds,
          ),
        );
        return;
      }

      final body = response.data;
      if (body == null) {
        sw.stop();
        yield LlmStreamEnd(
          LlmResult(
            status: LlmStatus.parseError,
            httpStatus: statusCode,
            latencyMs: sw.elapsedMilliseconds,
          ),
        );
        return;
      }

      final buffer = StringBuffer();
      await for (final delta in parseOpenAiSse(body.stream)) {
        buffer.write(delta.text);
        yield delta;
      }

      sw.stop();
      _safeLog(
        'llm status=$statusCode latencyMs=${sw.elapsedMilliseconds} requestId=$requestId stream=1',
      );
      if (buffer.isEmpty) {
        yield LlmStreamEnd(
          LlmResult(
            status: LlmStatus.parseError,
            httpStatus: statusCode,
            latencyMs: sw.elapsedMilliseconds,
          ),
        );
        return;
      }
      yield LlmStreamEnd(
        LlmResult(
          status: LlmStatus.ok,
          content: buffer.toString(),
          httpStatus: statusCode,
          latencyMs: sw.elapsedMilliseconds,
        ),
      );
    } on DioException catch (e) {
      sw.stop();
      yield LlmStreamEnd(_mapDioException(e, sw.elapsedMilliseconds, requestId));
    } catch (_) {
      sw.stop();
      _safeLog('llm parseError requestId=$requestId stream=1');
      yield LlmStreamEnd(
        LlmResult(
          status: LlmStatus.parseError,
          latencyMs: sw.elapsedMilliseconds,
        ),
      );
    }
  }

  LlmResult _mapDioException(DioException e, int latencyMs, String requestId) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      _safeLog('llm timeout latencyMs=$latencyMs requestId=$requestId');
      return LlmResult(status: LlmStatus.timeout, latencyMs: latencyMs);
    }
    final code = e.response?.statusCode;
    _safeLog('llm httpError status=$code latencyMs=$latencyMs requestId=$requestId');
    return LlmResult(
      status: LlmStatus.httpError,
      httpStatus: code,
      latencyMs: latencyMs,
    );
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

/// Parses OpenAI-compatible `text/event-stream` into text [LlmStreamDelta]s.
/// Stops on `data: [DONE]`. Ignores keep-alives and malformed lines.
Stream<LlmStreamDelta> parseOpenAiSse(Stream<List<int>> byteStream) async* {
  final lines = utf8.decoder.bind(byteStream).transform(const LineSplitter());
  await for (final line in lines) {
    if (line.isEmpty || line.startsWith(':')) continue;
    if (!line.startsWith('data:')) continue;
    final payload = line.substring(5).trim();
    if (payload.isEmpty) continue;
    if (payload == '[DONE]') return;

    dynamic decoded;
    try {
      decoded = jsonDecode(payload);
    } catch (_) {
      continue;
    }
    if (decoded is! Map) continue;
    final choices = decoded['choices'];
    if (choices is! List || choices.isEmpty) continue;
    final first = choices.first;
    if (first is! Map) continue;
    final delta = first['delta'];
    if (delta is! Map) continue;
    final content = delta['content'];
    if (content is String && content.isNotEmpty) {
      yield LlmStreamDelta(content);
    }
  }
}
