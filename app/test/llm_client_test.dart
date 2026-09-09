import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/llm/dio_llm_client.dart';
import 'package:ai_mom_baby/llm/llm_model_catalog.dart';
import 'package:ai_mom_baby/llm/llm_types.dart';

void main() {
  test('URL rules: base with /v1', () {
    expect(
      buildChatCompletionsUrl('https://api.openai.com/v1/'),
      'https://api.openai.com/v1/chat/completions',
    );
  });

  test('URL rules: base without /v1', () {
    expect(
      buildChatCompletionsUrl('https://proxy.example.com'),
      'https://proxy.example.com/v1/chat/completions',
    );
  });

  test('missingKey when api key empty', () async {
    final client = DioLlmClient(
      config: const LlmConfig(baseUrl: 'https://example.com/v1', apiKey: '', model: 'gpt-4o-mini'),
    );
    final result = await client.complete(
      messages: const [ChatMessageWire(role: 'user', content: 'hi')],
      requestId: 'req-1',
    );
    expect(result.status, LlmStatus.missingKey);
    expect(client.requestCount, 0);
  });

  test('REPLACE_ME placeholder is treated as missing key', () {
    const config = LlmConfig(
      baseUrl: 'https://example.com/v1',
      apiKey: 'REPLACE_ME',
      model: 'gpt-4o-mini',
    );
    expect(config.hasKey, isFalse);
    expect(
      DioLlmClient(config: config).canCallRemote,
      isFalse,
    );
  });

  test('remote catalog pick without key forces offline', () {
    const env = LlmConfig(
      baseUrl: '',
      apiKey: '',
      model: 'gpt-4o-mini',
    );
    final applied = env.withModelOption(
      const LlmModelOption(
        id: 'deepseek-chat',
        displayName: 'DeepSeek',
        provider: 'deepseek',
        apiModelId: 'deepseek-chat',
        baseUrlHint: 'https://api.deepseek.com',
        enabled: true,
        offline: false,
      ),
    );
    expect(applied.forceOffline, isTrue);
    expect(DioLlmClient(config: applied).canCallRemote, isFalse);
  });

  test('200 parses choices[0].message.content', () async {
    final adapter = _ScriptedAdapter([
      _ScriptedResponse(
        statusCode: 200,
        body: {
          'choices': [
            {
              'message': {'role': 'assistant', 'content': '多喝水休息'},
            }
          ],
          'usage': {'prompt_tokens': 10, 'completion_tokens': 5},
        },
      ),
    ]);
    final dio = Dio()..httpClientAdapter = adapter;
    final logs = <String>[];
    final client = DioLlmClient(
      config: const LlmConfig(
        baseUrl: 'https://example.com/v1',
        apiKey: 'test-key',
        model: 'gpt-4o-mini',
      ),
      dio: dio,
      log: logs.add,
    );
    final result = await client.complete(
      messages: const [ChatMessageWire(role: 'user', content: '今天有点累')],
      requestId: 'req-ok',
    );
    expect(result.status, LlmStatus.ok);
    expect(result.content, '多喝水休息');
    expect(result.promptTokens, 10);
    expect(client.requestCount, 1);
    expect(logs.single.contains('Bearer'), isFalse);
    expect(logs.single.toLowerCase().contains('api key'), isFalse);
    expect(logs.single.contains('今天有点累'), isFalse);
  });

  test('200 missing choices is parseError; no retry', () async {
    final adapter = _ScriptedAdapter([
      _ScriptedResponse(statusCode: 200, body: {'choices': []}),
    ]);
    final client = DioLlmClient(
      config: const LlmConfig(
        baseUrl: 'https://example.com/v1',
        apiKey: 'test-key',
        model: 'gpt-4o-mini',
      ),
      dio: Dio()..httpClientAdapter = adapter,
    );
    final result = await client.complete(
      messages: const [ChatMessageWire(role: 'user', content: 'x')],
      requestId: 'req-parse',
    );
    expect(result.status, LlmStatus.parseError);
    expect(client.requestCount, 1);
    expect(adapter.calls, 1);
  });

  test('500 is httpError; no retry', () async {
    final adapter = _ScriptedAdapter([
      _ScriptedResponse(statusCode: 500, body: {'error': 'x'}),
    ]);
    final client = DioLlmClient(
      config: const LlmConfig(
        baseUrl: 'https://example.com/v1',
        apiKey: 'test-key',
        model: 'gpt-4o-mini',
      ),
      dio: Dio()..httpClientAdapter = adapter,
    );
    final result = await client.complete(
      messages: const [ChatMessageWire(role: 'user', content: 'x')],
      requestId: 'req-500',
    );
    expect(result.status, LlmStatus.httpError);
    expect(result.httpStatus, 500);
    expect(adapter.calls, 1);
  });

  test('hang times out once', () async {
    final adapter = _ScriptedAdapter([
      _ScriptedResponse.timeout(),
    ]);
    final client = DioLlmClient(
      config: const LlmConfig(
        baseUrl: 'https://example.com/v1',
        apiKey: 'test-key',
        model: 'gpt-4o-mini',
      ),
      dio: Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      )..httpClientAdapter = adapter,
    );
    final result = await client.complete(
      messages: const [ChatMessageWire(role: 'user', content: 'x')],
      requestId: 'req-timeout',
    );
    expect(result.status, LlmStatus.timeout);
    expect(client.requestCount, 1);
    expect(adapter.calls, 1);
  });

  test('request fixture shape keys', () {
    final fixture = jsonDecode(
      File('../sdd/06-llm-api-client/fixtures/chat_completions_request.json')
          .readAsStringSync(),
    ) as Map<String, dynamic>;
    expect(fixture['model'], isA<String>());
    expect(fixture['temperature'], 0.7);
    expect(fixture['messages'], isA<List>());
  });

  test('parseOpenAiSse yields deltas and stops on [DONE]', () async {
    final bytes = utf8.encode(
      'data: {"choices":[{"delta":{"content":"你"}}]}\n'
      'data: {"choices":[{"delta":{"content":"好"}}]}\n'
      'data: [DONE]\n'
      'data: {"choices":[{"delta":{"content":"忽略"}}]}\n',
    );
    final deltas = await parseOpenAiSse(Stream.value(bytes))
        .map((e) => e.text)
        .toList();
    expect(deltas, ['你', '好']);
  });

  test('streamComplete posts stream:true and yields tokens', () async {
    final sse = utf8.encode(
      'data: {"choices":[{"delta":{"content":"多"}}]}\n'
      'data: {"choices":[{"delta":{"content":"喝水"}}]}\n'
      'data: [DONE]\n',
    );
    final adapter = _ScriptedAdapter([
      _ScriptedResponse(
        statusCode: 200,
        body: const {},
        sseBytes: sse,
      ),
    ]);
    final client = DioLlmClient(
      config: const LlmConfig(
        baseUrl: 'https://example.com/v1',
        apiKey: 'test-key',
        model: 'gpt-4o-mini',
      ),
      dio: Dio()..httpClientAdapter = adapter,
    );
    final partials = <String>[];
    final result = await collectLlmStream(
      client.streamComplete(
        messages: const [ChatMessageWire(role: 'user', content: '累')],
        requestId: 'req-stream',
      ),
      onPartial: partials.add,
    );
    expect(adapter.lastBody?['stream'], isTrue);
    expect(result.status, LlmStatus.ok);
    expect(result.content, '多喝水');
    expect(partials, ['多', '多喝水']);
    expect(client.requestCount, 1);
  });
}

class _ScriptedResponse {
  _ScriptedResponse({
    required this.statusCode,
    required this.body,
    this.timeout = false,
    this.sseBytes,
  });

  factory _ScriptedResponse.timeout() =>
      _ScriptedResponse(statusCode: 0, body: const {}, timeout: true);

  final int statusCode;
  final Map<String, dynamic> body;
  final bool timeout;
  final List<int>? sseBytes;
}

class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.responses);

  final List<_ScriptedResponse> responses;
  int calls = 0;
  Map<String, dynamic>? lastBody;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    final scripted = responses[calls - 1];
    expect(options.headers.containsKey('Authorization'), isTrue);
    expect(options.headers['x-request-id'], isNotNull);
    final data = options.data;
    if (data is Map<String, dynamic>) {
      lastBody = data;
    } else if (data is Map) {
      lastBody = Map<String, dynamic>.from(data);
    }
    if (scripted.timeout) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.receiveTimeout,
      );
    }
    if (scripted.sseBytes != null) {
      return ResponseBody.fromBytes(
        scripted.sseBytes!,
        scripted.statusCode,
        headers: {
          Headers.contentTypeHeader: ['text/event-stream'],
        },
      );
    }
    final bytes = utf8.encode(jsonEncode(scripted.body));
    return ResponseBody.fromString(
      utf8.decode(bytes),
      scripted.statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
