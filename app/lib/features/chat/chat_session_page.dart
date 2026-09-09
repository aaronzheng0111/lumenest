import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../agent/offline_default_reply.dart';
import '../../agent/tool_acl.dart';
import '../../agent/tools/get_current_time_tool.dart';
import '../../agent/xiaonuan_graph.dart';
import '../../app_copy.dart';
import '../../chat/chat_suggestions_catalog.dart';
import '../../data/conversation_repository.dart';
import '../../domain/agent_role.dart';
import '../../providers.dart';
import '../../theme/glass_tokens.dart';
import '../../theme/spacing_tokens.dart';
import '../../widgets/atmosphere_background.dart';
import '../../widgets/glass/glass_app_bar.dart';
import '../../widgets/glass/glass_container.dart';
import 'chat_bubble.dart';
import 'chat_composer.dart';
import 'chat_draft_store.dart';
import 'chat_pending_tools.dart';
import 'chat_tool_status.dart';
import 'llm_model_picker.dart';

class ChatSessionPage extends ConsumerStatefulWidget {
  const ChatSessionPage({super.key, required this.role});

  final AgentRole role;

  @override
  ConsumerState<ChatSessionPage> createState() => _ChatSessionPageState();
}

class _ChatSessionPageState extends ConsumerState<ChatSessionPage> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  int? _conversationId;
  List<ChatMessage> _messages = [];
  bool _loading = true;
  bool _sending = false;
  bool _awaitingReply = false;
  List<AgentTool> _pendingTools = const [];
  int? _revealMessageId;
  DateTime? _lastSendAt;
  String? _streamingText;
  AgentRole? _streamingSpeaker;

  bool get _locked => !widget.role.isUnlocked;

  /// Show chips in every chat window, including locked roles (fill-on-tap OK).
  bool get _showSuggestions =>
      !_loading &&
      !_sending &&
      (_locked || (_messages.isEmpty && _conversationId != null));

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _persistDraft();
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    if (_locked) {
      setState(() => _loading = false);
      return;
    }
    try {
      final repo = ref.read(conversationRepositoryProvider);
      final id = await repo.getOrCreateSolo(role: widget.role);
      final msgs = await repo.listMessages(id);
      final draft = await _loadDraft(id);
      if (!mounted) return;
      setState(() {
        _conversationId = id;
        _messages = msgs;
        if (draft != null && draft.isNotEmpty) {
          _controller.text = draft;
        }
        _loading = false;
      });
      _scrollToEnd();
    } catch (e, st) {
      debugPrint('chat bootstrap failed: $e\n$st');
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnack(AppCopy.chatSessionNotReady);
    }
  }

  Future<String?> _loadDraft(int conversationId) =>
      ChatDraftStore.load(conversationId);

  Future<void> _persistDraft() async {
    final id = _conversationId;
    if (id == null) return;
    await ChatDraftStore.save(id, _controller.text);
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _showSnack(String message) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    final bottom = SpacingTokens.xxl * 2 +
        SpacingTokens.xl +
        MediaQuery.paddingOf(context).bottom;
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(
          SpacingTokens.pageMargin,
          0,
          SpacingTokens.pageMargin,
          bottom,
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _applySuggestion(String prompt) async {
    _controller.text = prompt;
    _controller.selection = TextSelection.collapsed(offset: prompt.length);
    if (_locked) return;
    await _send();
  }

  Future<void> _send() async {
    if (_locked || _sending) return;
    final privacy = await ref.read(privacyStoreProvider).isAccepted();
    if (!privacy) {
      _showSnack(AppCopy.privacyRequiredToChat);
      return;
    }

    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (text.length > 2000) {
      _showSnack(AppCopy.maxMessageLength);
      return;
    }

    final now = DateTime.now();
    if (_lastSendAt != null &&
        now.difference(_lastSendAt!) < const Duration(seconds: 1)) {
      return;
    }
    _lastSendAt = now;

    final conversationId = _conversationId;
    if (conversationId == null) {
      _showSnack(AppCopy.chatSessionNotReady);
      return;
    }

    final pendingTools = predictPendingTools(
      userText: text,
      speaker: widget.role,
    );

    setState(() {
      _sending = true;
      _awaitingReply = true;
      _pendingTools = pendingTools;
      _streamingText = null;
      _streamingSpeaker = null;
    });
    _controller.clear();
    await _persistDraft();

    try {
      final repo = ref.read(conversationRepositoryProvider);
      await repo.insertUserMessage(
        conversationId: conversationId,
        content: text,
      );
      final afterUser = await repo.listMessages(conversationId);
      if (mounted) {
        setState(() => _messages = afterUser);
        _scrollToEnd();
      }

      GraphTurnResult turn;
      try {
        final graph = await _loadSoloGraph();
        turn = await graph.handle(
          conversationId: conversationId,
          userText: text,
          onPartial: (speaker, partial) {
            if (!mounted) return;
            setState(() {
              _awaitingReply = false;
              _pendingTools = const [];
              _streamingSpeaker = speaker;
              _streamingText = partial;
            });
            _scrollToEnd();
          },
        );
      } catch (e, st) {
        debugPrint('chat graph failed, using offline fallback: $e\n$st');
        final fallback = OfflineDefaultReply.build(
          speaker: widget.role,
          userText: text,
          currentTime: GetCurrentTimeTool.shouldInvoke(text)
              ? GetCurrentTimeTool.invoke()
              : null,
        );
        final id = await repo.insertAssistantMessage(
          conversationId: conversationId,
          content: fallback,
          speaker: widget.role,
        );
        turn = GraphTurnResult(
          assistantContent: fallback,
          blockedBySafety: false,
          llmCalls: 0,
          assistantMessageId: id,
          usedOfflineDefault: true,
          toolsUsed: pendingTools,
        );
      }

      final afterAssistant = await repo.listMessages(conversationId);
      if (mounted) {
        setState(() {
          _messages = afterAssistant;
          _streamingText = null;
          _streamingSpeaker = null;
          _awaitingReply = false;
          // Fake typewriter only for offline/safety one-shot replies.
          _revealMessageId = (turn.usedOfflineDefault || turn.blockedBySafety)
              ? turn.assistantMessageId
              : null;
        });
        _scrollToEnd();
      }
    } catch (e, st) {
      debugPrint('chat send failed: $e\n$st');
      _showSnack('${AppCopy.chatSendFailed}（$e）');
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
          _awaitingReply = false;
          _pendingTools = const [];
          _streamingText = null;
          _streamingSpeaker = null;
        });
      }
    }
  }

  Future<XiaonuanGraph> _loadSoloGraph() async {
    final provider = agentGraphProvider(widget.role);
    try {
      return await ref.read(provider.future);
    } catch (e, st) {
      debugPrint('agentGraphProvider failed, retrying once: $e\n$st');
      ref.invalidate(provider);
      return ref.read(provider.future);
    }
  }

  Future<void> _clearThisChat() async {
    final id = _conversationId;
    if (id == null || _locked) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppCopy.clearThisChat),
        content: const Text(AppCopy.clearThisChatConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppCopy.privacyClose),
          ),
          TextButton(
            key: const Key('confirm_clear_this_chat'),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppCopy.clearThisChat),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await ref.read(conversationRepositoryProvider).clearMessages(id);
    await ChatDraftStore.save(id, '');
    _controller.clear();
    if (!mounted) return;
    setState(() {
      _messages = [];
      _revealMessageId = null;
    });
    ref.invalidate(conversationListProvider);
    _showSnack(AppCopy.clearChatHistoryDone);
  }

  Future<void> _deleteMessage(ChatMessage message) async {
    await ref.read(conversationRepositoryProvider).deleteMessage(message.id);
    final id = _conversationId;
    if (id == null || !mounted) return;
    final msgs = await ref.read(conversationRepositoryProvider).listMessages(id);
    if (!mounted) return;
    setState(() {
      _messages = msgs;
      if (_revealMessageId == message.id) _revealMessageId = null;
    });
    ref.invalidate(conversationListProvider);
    _showSnack(AppCopy.messageDeleted);
  }

  @override
  Widget build(BuildContext context) {
    final topInset = GlassAppBar.contentHeight +
        MediaQuery.paddingOf(context).top +
        SpacingTokens.sm;
    final suggestions = ref.watch(
      chatSuggestionsForProvider((
        scene: ChatSuggestionScene.solo,
        role: widget.role,
      )),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: GlassAppBar.forContext(
        context,
        title: Text(widget.role.displayName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          if (!_locked)
            IconButton(
              key: const Key('chat_clear'),
              tooltip: AppCopy.clearThisChat,
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: _sending ? null : _clearThisChat,
            ),
        ],
      ),
      body: AtmosphereBackground(
        child: Column(
          children: [
            if (_locked)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  SpacingTokens.pageMargin,
                  topInset,
                  SpacingTokens.pageMargin,
                  0,
                ),
                child: GlassContainer(
                  fill: GlassFill.roseSoft,
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: Text(
                    AppCopy.roleLockedBanner,
                    key: const Key('locked_banner'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              )
            else
              SizedBox(height: topInset),
            if (!_locked) const LlmModelPickerBar(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.pageMargin,
                      ),
                      itemCount: _messages.length +
                          (_awaitingReply || _streamingText != null ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) {
                          final streaming = _streamingText;
                          if (streaming != null) {
                            final speaker = _streamingSpeaker ?? widget.role;
                            return ChatBubble(
                              key: const Key('streaming_bubble'),
                              message: ChatMessage(
                                id: -1,
                                conversationId: _conversationId ?? 0,
                                role: 'assistant',
                                content: streaming,
                                createdAt: DateTime.now(),
                                speakerRole: speaker.wireId,
                              ),
                              showActions: false,
                            );
                          }
                          return ChatAwaitingReply(tools: _pendingTools);
                        }
                        final msg = _messages[index];
                        return ChatBubble(
                          message: msg,
                          animateReveal: msg.id == _revealMessageId,
                          onDeleted: () => _deleteMessage(msg),
                        );
                      },
                    ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                SpacingTokens.pageMargin,
                0,
                SpacingTokens.pageMargin,
                SpacingTokens.lg + MediaQuery.paddingOf(context).bottom,
              ),
              child: ChatComposer(
                controller: _controller,
                enabled: !_locked && !_sending,
                hintText: _locked
                    ? AppCopy.roleLockedHint
                    : AppCopy.soloChatHint(widget.role.displayName),
                onSend: _send,
                onChanged: (_) => _persistDraft(),
                enableMentions: !_locked,
                showSuggestions: _showSuggestions && suggestions.isNotEmpty,
                suggestedPrompts: suggestions,
                onSuggestionSelected: _applySuggestion,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
