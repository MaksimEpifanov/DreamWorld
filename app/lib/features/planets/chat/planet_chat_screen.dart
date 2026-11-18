import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/index.dart';
import '../../../core/widgets/index.dart';
import '../../../data/models/planet.dart';
import '../../../data/models/planet_chat_message.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/providers/planet_providers.dart';
import '../../../data/services/call_service.dart';
import '../../../data/services/moderation_service.dart';
import '../../chat/widgets/message_bubble.dart';

/// Общий чат сообщества планеты.
///
/// Все вошедшие видят сообщения друг друга в реальном времени и могут писать
/// сами. В рабочей версии сообщения хранятся в Firestore, в мок-режиме — в
/// памяти.
class PlanetChatScreen extends ConsumerStatefulWidget {
  const PlanetChatScreen({super.key, required this.planetId});

  final String planetId;

  @override
  ConsumerState<PlanetChatScreen> createState() => _PlanetChatScreenState();
}

class _PlanetChatScreenState extends ConsumerState<PlanetChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ModerationService _moderation = const MockModerationService();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String get _senderName {
    final String name =
        ref.read(currentProfileProvider).valueOrNull?.name.trim() ?? '';
    return name.isEmpty ? 'Пользователь' : name;
  }

  String get _callRoom => 'DreamWorld-planet-${widget.planetId}';

  Future<bool> _startCall({required bool video}) {
    return ref
        .read(callServiceProvider)
        .startCall(room: _callRoom, displayName: _senderName, video: video);
  }

  void _openCallSheet() {
    final CallService service = ref.read(callServiceProvider);
    final String name =
        ref.read(planetByIdProvider(widget.planetId))?.displayName ?? 'планета';
    showCallSheet(
      context,
      title: name,
      roomUrl: service.roomUrl(_callRoom),
      onStart: (bool video) => _startCall(video: video),
    );
  }

  Future<void> _send() async {
    final String text = _textController.text.trim();
    if (text.isEmpty) return;

    final ModerationVerdict verdict = _moderation.checkText(text);
    if (verdict.flagged) {
      await _showModerationWarning(verdict);
      return;
    }

    final Planet? planet = ref.read(planetByIdProvider(widget.planetId));
    if (planet == null) return;
    try {
      await ref
          .read(planetChatRepositoryProvider)
          .sendMessage(planet, text, senderName: _senderName);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('Сообщение не отправлено. Проверьте интернет.'),
          ),
        );
      return;
    }
    _textController.clear();
    _scrollToBottom();
  }

  Future<void> _showModerationWarning(ModerationVerdict verdict) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: <Widget>[
            Icon(
              Icons.report_gmailerrorred_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: AppSpacing.sm),
            const Expanded(child: Text('Сообщение заблокировано')),
          ],
        ),
        content: Text(
          'ИИ-фильтр обнаружил возможное нарушение правил.\n\n'
          '${verdict.message}\n\n'
          'Отредактируйте сообщение.',
          style: AppTextStyles.body(color: AppColors.textSecondary),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Исправить'),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Planet? planet = ref.watch(planetByIdProvider(widget.planetId));
    final AsyncValue<List<PlanetChatMessage>> messagesAsync = ref.watch(
      planetChatMessagesProvider(widget.planetId),
    );
    final String currentUserId = ref.watch(currentUserIdProvider);

    ref.listen<AsyncValue<List<PlanetChatMessage>>>(
      planetChatMessagesProvider(widget.planetId),
      (AsyncValue<List<PlanetChatMessage>>? previous,
       AsyncValue<List<PlanetChatMessage>> next) {
        if (next.hasValue) _scrollToBottom();
      },
    );

    return Scaffold(
      appBar: NeonAppBar(
        title: 'Чат · ${planet?.displayName ?? 'планета'}',
        leading: BackButton(
          onPressed: () =>
              context.go('/main/planet/${widget.planetId}'),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Аудиозвонок',
            icon: const Icon(Icons.call_outlined),
            onPressed: _openCallSheet,
          ),
          IconButton(
            tooltip: 'Видеозвонок',
            icon: const Icon(Icons.videocam_outlined),
            onPressed: _openCallSheet,
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: Column(
            children: <Widget>[
              _CommunityBanner(planet: planet),
              Expanded(
                child: messagesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (Object error, StackTrace stackTrace) => const Center(
                    child: Text('Не удалось загрузить сообщения'),
                  ),
                  data: (List<PlanetChatMessage> messages) {
                    if (messages.isEmpty) return const _EmptyChat();
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.sm,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (BuildContext context, int index) {
                        final PlanetChatMessage message = messages[index];
                        final bool isMine = message.senderId == currentUserId;
                        return _PlanetMessageRow(
                              message: message,
                              isMine: isMine,
                            )
                            .animate(key: ValueKey<String>(message.id))
                            .fadeIn(duration: 250.ms)
                            .slideY(
                              begin: 0.12,
                              end: 0,
                              curve: Curves.easeOut,
                            );
                      },
                    );
                  },
                ),
              ),
              _InputBar(controller: _textController, onSend: _send),
            ],
          ),
        ),
      ),
    );
  }
}

/// Шапка чата: поясняет, что это общий чат планеты.
class _CommunityBanner extends StatelessWidget {
  const _CommunityBanner({required this.planet});

  final Planet? planet;

  @override
  Widget build(BuildContext context) {
    final Color accent = planet?.accent ?? Theme.of(context).colorScheme.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.7),
        border: Border(
          bottom: BorderSide(color: accent.withValues(alpha: 0.35)),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.groups_rounded, size: 18, color: accent),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Общий чат. Сообщения видят все участники планеты.',
              style: AppTextStyles.caption(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Center(
      child: Padding(
        padding: AppSpacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GlowContainer(
              color: primary,
              glowRadius: 22,
              glowOpacity: 0.45,
              borderColor: primary,
              background: AppColors.surface,
              borderRadius: AppRadius.pillAll,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Icon(
                Icons.forum_outlined,
                size: 40,
                color: primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Пока нет сообщений. Напишите первое!',
              style: AppTextStyles.title(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanetMessageRow extends StatelessWidget {
  const _PlanetMessageRow({required this.message, required this.isMine});

  final PlanetChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (!isMine)
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            child: Text(
              message.senderName.isEmpty ? 'Участник' : message.senderName,
              style: AppTextStyles.caption(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        MessageBubble(message: message.toMessage(), isMine: isMine),
      ],
    );
  }
}

/// Нижняя панель ввода сообщения в общий чат.
class _InputBar extends StatefulWidget {
  const _InputBar({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  State<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<_InputBar> {
  bool _showEmoji = false;

  void _toggleEmoji() => setState(() => _showEmoji = !_showEmoji);

  void _insertEmoji(String emoji) => insertEmoji(widget.controller, emoji);

  void _handleSend() {
    setState(() => _showEmoji = false);
    widget.onSend();
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        border: Border(top: BorderSide(color: primary.withValues(alpha: 0.3))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (_showEmoji) EmojiPicker(onSelected: _insertEmoji),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: AppRadius.pillAll,
                    border: Border.all(
                      color: primary.withValues(alpha: 0.35),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  child: TextField(
                    controller: widget.controller,
                    style: AppTextStyles.body(),
                    cursorColor: primary,
                    decoration: InputDecoration(
                      hintText: 'Написать в чат сообщества...',
                      border: InputBorder.none,
                      isDense: true,
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      hintStyle: AppTextStyles.body(
                        color: AppColors.textMuted,
                      ),
                    ),
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: kIsWeb ? TextInputAction.send : null,
                    onEditingComplete: () {},
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _EmojiButton(onTap: _toggleEmoji),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _handleSend,
                child: GlowContainer(
                  color: primary,
                  glowRadius: 20,
                  glowOpacity: 0.6,
                  borderColor: primary,
                  background: primary,
                  borderRadius: AppRadius.pillAll,
                  padding: const EdgeInsets.all(AppSpacing.sm + 2),
                  child: Icon(
                    Icons.send_rounded,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmojiButton extends StatelessWidget {
  const _EmojiButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Tooltip(
      message: 'Смайлики',
      child: GlowContainer(
        color: primary,
        glowRadius: 12,
        glowOpacity: 0.25,
        borderColor: primary.withValues(alpha: 0.4),
        background: AppColors.surfaceElevated,
        borderRadius: AppRadius.pillAll,
        child: IconButton(
          onPressed: onTap,
          icon: Icon(Icons.emoji_emotions_outlined, color: primary),
          iconSize: 22,
        ),
      ),
    );
  }
}
