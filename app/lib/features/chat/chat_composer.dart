import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/agent_role.dart';
import '../../theme/app_colors.dart';
import '../../theme/glass_tokens.dart';
import '../../theme/radius_tokens.dart';
import '../../theme/spacing_tokens.dart';
import '../../widgets/glass/glass_container.dart';
import 'chat_mention_picker.dart';
import 'chat_mention_query.dart';
import 'chat_mention_roles.dart';
import 'chat_suggested_prompts.dart';

/// Shared chat input: optional suggestions, @mention picker, glass composer.
class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.enabled,
    required this.hintText,
    required this.onSend,
    this.onChanged,
    this.enableMentions = true,
    this.mentionRoles,
    this.showSuggestions = false,
    this.suggestedPrompts = const [],
    this.onSuggestionSelected,
    this.textInputAction = TextInputAction.send,
  });

  final TextEditingController controller;
  final bool enabled;
  final String hintText;
  final VoidCallback onSend;
  final ValueChanged<String>? onChanged;
  final bool enableMentions;

  /// Defaults to [ChatMentionRoles.all] ([AgentRole] values).
  final List<AgentRole>? mentionRoles;
  final bool showSuggestions;

  /// From [ChatSuggestionsCatalog]; do not hardcode in page widgets.
  final List<String> suggestedPrompts;
  final ValueChanged<String>? onSuggestionSelected;
  final TextInputAction textInputAction;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final _focusNode = FocusNode();
  ChatMentionQuery? _activeMention;
  List<AgentRole> _filteredRoles = const [];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncMention);
    _focusNode.addListener(_syncMention);
  }

  @override
  void didUpdateWidget(covariant ChatComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_syncMention);
      widget.controller.addListener(_syncMention);
      _syncMention();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncMention);
    _focusNode.dispose();
    super.dispose();
  }

  void _syncMention() {
    if (!widget.enableMentions || !widget.enabled) {
      if (_activeMention != null || _filteredRoles.isNotEmpty) {
        setState(() {
          _activeMention = null;
          _filteredRoles = const [];
        });
      }
      return;
    }
    final text = widget.controller.text;
    final cursor = widget.controller.selection.baseOffset;
    final effectiveCursor = cursor < 0 ? text.length : cursor;
    final roles = widget.mentionRoles ?? ChatMentionRoles.all;
    final query = findActiveMention(text, effectiveCursor);
    final filtered = query == null
        ? const <AgentRole>[]
        : filterMentionRoles(
            roles,
            query.query,
            (r) => r.displayName,
          );
    final sameQuery = query?.atIndex == _activeMention?.atIndex &&
        query?.query == _activeMention?.query;
    if (sameQuery && listEquals(filtered, _filteredRoles)) return;
    setState(() {
      _activeMention = query;
      _filteredRoles = filtered;
    });
  }

  void _insertMention(AgentRole role) {
    final query = _activeMention;
    if (query == null) return;
    final text = widget.controller.text;
    final cursor = widget.controller.selection.baseOffset;
    final end = cursor < 0 ? text.length : cursor;
    final mention = '@${role.displayName} ';
    final next = text.replaceRange(query.atIndex, end, mention);
    final newCursor = query.atIndex + mention.length;
    widget.controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: newCursor),
    );
    widget.onChanged?.call(next);
    setState(() {
      _activeMention = null;
      _filteredRoles = const [];
    });
    _focusNode.requestFocus();
  }

  void _onChanged(String value) {
    widget.onChanged?.call(value);
    _syncMention();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (_activeMention == null || _filteredRoles.isEmpty) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      setState(() {
        _activeMention = null;
        _filteredRoles = const [];
      });
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final showPicker =
        widget.enableMentions && _activeMention != null && _filteredRoles.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showSuggestions &&
            widget.onSuggestionSelected != null &&
            widget.suggestedPrompts.isNotEmpty)
          ChatSuggestedPrompts(
            prompts: widget.suggestedPrompts,
            onSelected: widget.onSuggestionSelected!,
          ),
        if (showPicker)
          ChatMentionPicker(
            roles: _filteredRoles,
            onSelected: _insertMention,
          ),
        GlassContainer(
          fill: GlassFill.medium,
          borderRadius: RadiusTokens.borderPill,
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.lg,
            vertical: SpacingTokens.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Focus(
                  onKeyEvent: _onKey,
                  child: TextField(
                    key: const Key('chat_input'),
                    controller: widget.controller,
                    focusNode: _focusNode,
                    enabled: widget.enabled,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: widget.textInputAction,
                    onSubmitted: (_) {
                      if (widget.enabled) widget.onSend();
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: widget.hintText,
                      hintStyle:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                    ),
                    onChanged: _onChanged,
                  ),
                ),
              ),
              IconButton(
                key: const Key('chat_send'),
                onPressed: widget.enabled ? widget.onSend : null,
                icon: const Icon(Icons.send_rounded),
                color: AppColors.primaryDeep,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
