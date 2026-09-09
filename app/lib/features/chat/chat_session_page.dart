import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_copy.dart';
import '../../data/conversation_repository.dart';
import '../../domain/agent_role.dart';
import '../../providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/glass_tokens.dart';
import '../../theme/radius_tokens.dart';
import '../../theme/spacing_tokens.dart';
import '../../widgets/atmosphere_background.dart';
import '../../widgets/glass/glass_app_bar.dart';
import '../../widgets/glass/glass_container.dart';
import 'chat_bubble.dart';
import 'chat_draft_store.dart';
import 'chat_typing_indicator.dart';
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
  int? _revealMessageId;
  DateTime? _lastSendAt;

  bool get _locked => !widget.role.isUnlocked;

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
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
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

  Future<void> _send() async {
    if (_locked || _sending) return;
    final privacy = await ref.read(privacyStoreProvider).isAccepted();
    if (!privacy) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppCopy.privacyRequiredToChat)),
      );
      return;
    }

    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (text.length > 2000) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppCopy.maxMessageLength)),
      );
      return;
    }

    final now = DateTime.now();
    if (_lastSendAt != null &&
        now.difference(_lastSendAt!) < const Duration(seconds: 1)) {
      return;
    }
    _lastSendAt = now;

    final conversationId = _conversationId;
    if (conversationId == null) return;

    setState(() {
      _sending = true;
      _awaitingReply = true;
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

      final graph = await ref.read(agentGraphProvider(widget.role).future);
      final turn = await graph.handle(
        conversationId: conversationId,
        userText: text,
      );
      final afterAssistant = await repo.listMessages(conversationId);
      if (mounted) {
        setState(() {
          _messages = afterAssistant;
          _revealMessageId = turn.assistantMessageId;
        });
        _scrollToEnd();
      }
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
          _awaitingReply = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = GlassAppBar.contentHeight +
        MediaQuery.paddingOf(context).top +
        SpacingTokens.sm;

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
      ),
      body: AtmosphereBackground(
        child: Column(
          children: [
            SizedBox(height: topInset),
            const LlmModelPickerBar(),
            if (_locked)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  SpacingTokens.pageMargin,
                  0,
                  SpacingTokens.pageMargin,
                  SpacingTokens.sm,
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
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.pageMargin,
                      ),
                      itemCount: _messages.length + (_awaitingReply ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_awaitingReply && index == _messages.length) {
                          return const ChatTypingIndicator();
                        }
                        final msg = _messages[index];
                        return ChatBubble(
                          message: msg,
                          animateReveal: msg.id == _revealMessageId,
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
              child: GlassContainer(
                fill: GlassFill.medium,
                borderRadius: RadiusTokens.borderPill,
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.lg,
                  vertical: SpacingTokens.sm,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('chat_input'),
                        controller: _controller,
                        enabled: !_locked && !_sending,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: _locked
                              ? '该角色暂未开放'
                              : '和${widget.role.displayName}说点什么…',
                          hintStyle:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                        ),
                        onChanged: (_) => _persistDraft(),
                      ),
                    ),
                    IconButton(
                      key: const Key('chat_send'),
                      onPressed: (_locked || _sending) ? null : _send,
                      icon: const Icon(Icons.send_rounded),
                      color: AppColors.primaryDeep,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
