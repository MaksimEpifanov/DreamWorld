import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/index.dart';
import '../../../core/widgets/index.dart';
import '../../../data/models/index.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/services/call_service.dart';
import '../../../data/services/mock_ai_service.dart';
import '../../../data/services/moderation_service.dart';
import '../../../data/services/translation_service.dart';
import '../safety/age_safety.dart';
import '../safety/widgets/report_sheet.dart';
import 'widgets/message_bubble.dart';

/// Экран диалога: градиентные пузыри, неоновое поле ввода,
/// перевод сообщений и подсказки тем от ИИ.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MockAiService _aiService = const MockAiService();
  final ModerationService _moderation = const MockModerationService();
  final Map<String, String> _translations = <String, String>{};
  String? _translatingMessageId;
  bool _showingTopics = false;
  List<String> _suggestedTopics = <String>[];

  String? _otherUserId;
  String _otherName = 'Собеседник';
  String? _ageRestriction;

  @override
  void initState() {
    super.initState();
    _loadChatContext();
  }

  Future<void> _loadChatContext() async {
    final String otherId = await _getOtherUserId();
    final Profile? other = await ref
        .read(profileRepositoryProvider)
        .getProfileById(otherId);
    final Profile? me = await ref
        .read(profileRepositoryProvider)
        .getCurrentProfile();
    if (!mounted) return;
    setState(() {
      _otherUserId = otherId;
      _otherName = other?.name ?? 'Собеседник';
      _ageRestriction = (me != null && other != null)
          ? AgeSafety.restrictionReason(myAge: me.age, otherAge: other.age)
          : null;
    });
    await ref.read(chatRepositoryProvider).markAsRead(widget.conversationId);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final String text = _textController.text.trim();
    if (text.isEmpty) {
      return;
    }

    if (_ageRestriction != null) {
      _showRestrictionDialog();
      return;
    }

    final ModerationVerdict verdict = _moderation.checkText(text);
    if (verdict.flagged) {
      await _showModerationWarning(verdict);
      return;
    }

    try {
      await ref
          .read(chatRepositoryProvider)
          .sendMessage(widget.conversationId, text);
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
    setState(() {
      _showingTopics = false;
      _suggestedTopics = <String>[];
    });
    _scrollToBottom();
  }

  void _showRestrictionDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: <Widget>[
            Icon(
              Icons.shield_moon_rounded,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            const Expanded(child: Text('Чат ограничен')),
          ],
        ),
        content: Text(
          _ageRestriction ?? '',
          style: AppTextStyles.body(color: AppColors.textSecondary),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
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
          'Отредактируйте сообщение. Повторные нарушения приведут к блокировке.',
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

  Future<void> _reportChat() async {
    await showReportSheet(
      context,
      ref,
      targetId: _otherUserId ?? widget.conversationId,
      targetName: _otherName,
      target: ReportTarget.user,
    );
  }

  Future<void> _translateMessage(Message message) async {
    if (_translatingMessageId == message.id) {
      return;
    }
    setState(() => _translatingMessageId = message.id);
    final TranslationService translationService = ref.read(
      translationServiceProvider,
    );
    final String translated = await translationService.translate(
      message.text,
      fromLang: '',
      toLang: translationService.defaultTargetLanguage,
    );
    if (mounted) {
      setState(() {
        _translations[message.id] = translated;
        _translatingMessageId = null;
      });
    }
  }

  Future<void> _suggestTopics() async {
    setState(() {
      _showingTopics = true;
      _suggestedTopics = <String>[];
    });
    final Profile? me = await ref
        .read(profileRepositoryProvider)
        .getCurrentProfile();
    final Profile? other = await ref
        .read(profileRepositoryProvider)
        .getProfileById(await _getOtherUserId());
    if (me != null && other != null) {
      final List<String> topics = await _aiService.suggestTopics(me, other);
      if (mounted) {
        setState(() => _suggestedTopics = topics);
      }
    } else if (mounted) {
      setState(() => _suggestedTopics = <String>[]);
    }
  }

  void _openOtherProfile() {
    final String? id = _otherUserId;
    if (id == null) return;
    context.push('/user/$id');
  }

  Future<String> _getOtherUserId() async {
    final Conversation? conversation = await ref
        .read(chatRepositoryProvider)
        .getConversationById(widget.conversationId);
    final String currentUserId = ref.read(currentUserIdProvider);
    if (conversation != null) {
      return conversation.otherParticipantId(currentUserId);
    }
    return currentUserId;
  }

  void _useTopic(String topic) {
    _textController.text = topic;
    setState(() {
      _showingTopics = false;
      _suggestedTopics = <String>[];
    });
    FocusScope.of(context).nextFocus();
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

  String get _callRoom => 'DreamWorld-${widget.conversationId}';

  String get _myName {
    final String name =
        ref.read(currentProfileProvider).valueOrNull?.name.trim() ?? '';
    return name.isEmpty ? 'Пользователь' : name;
  }

  Future<bool> _startCall({required bool video}) {
    return ref
        .read(callServiceProvider)
        .startCall(room: _callRoom, displayName: _myName, video: video);
  }

  void _openCallSheet() {
    final CallService service = ref.read(callServiceProvider);
    showCallSheet(
      context,
      title: _otherName,
      roomUrl: service.roomUrl(_callRoom),
      onStart: (bool video) => _startCall(video: video),
    );
  }
  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Message>> messagesAsync = ref.watch(
      messagesProvider(widget.conversationId),
    );
    final String currentUserId = ref.watch(currentUserIdProvider);

    // Пока диалог открыт, новые сообщения сразу считаются прочитанными.
    ref.listen<AsyncValue<List<Message>>>(
      messagesProvider(widget.conversationId),
      (AsyncValue<List<Message>>? previous, AsyncValue<List<Message>> next) {
        if (next.hasValue) {
          ref.read(chatRepositoryProvider).markAsRead(widget.conversationId);
        }
      },
    );

    return Scaffold(
      appBar: NeonAppBar(
        title: _otherName,
        titleWidget: _otherUserId == null
            ? null
            : Tooltip(
                message: 'Открыть профиль',
                child: InkWell(
                  borderRadius: AppRadius.pillAll,
                  onTap: _openOtherProfile,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xxs,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            _otherName,
                            style: AppTextStyles.headline(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 22,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
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
          IconButton(
            tooltip: 'Пожаловаться',
            icon: const Icon(Icons.flag_outlined),
            onPressed: _reportChat,
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: Column(
            children: <Widget>[
              Expanded(
                child: messagesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (Object error, StackTrace stackTrace) => const Center(
                    child: Text('Не удалось загрузить сообщения'),
                  ),
                  data: (List<Message> messages) {
                    _scrollToBottom();
                    if (messages.isEmpty) {
                      return const _EmptyChat();
                    }
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
                        final Message message = messages[index];
                        final bool isMine = message.senderId == currentUserId;
                        return _MessageRow(
                              message: message,
                              isMine: isMine,
                              translation: _translations[message.id],
                              isTranslating:
                                  _translatingMessageId == message.id,
                              onTranslate: () => _translateMessage(message),
                            )
                            .animate(key: ValueKey<String>(message.id))
                            .fadeIn(duration: 250.ms)
                            .slideY(begin: 0.12, end: 0, curve: Curves.easeOut);
                      },
                    );
                  },
                ),
              ),
              if (_showingTopics && _suggestedTopics.isNotEmpty)
                _TopicPanel(topics: _suggestedTopics, onSelect: _useTopic),
              if (_ageRestriction != null)
                _SafetyBanner(
                  text: _ageRestriction!,
                  onTap: _showRestrictionDialog,
                )
              else
                _InputBar(
                  controller: _textController,
                  onSend: _sendMessage,
                  onSuggest: _suggestTopics,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Баннер безопасности вместо поля ввода, когда личный чат ограничен.
class _SafetyBanner extends StatelessWidget {
  const _SafetyBanner({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(color: scheme.error.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.shield_moon_rounded, color: scheme.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Личный чат ограничен правилами безопасности',
              style: AppTextStyles.caption(color: AppColors.textSecondary),
            ),
          ),
          TextButton(onPressed: onTap, child: const Text('Почему?')),
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
                Icons.chat_bubble_outline_rounded,
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

class _MessageRow extends StatelessWidget {
  const _MessageRow({
    required this.message,
    required this.isMine,
    required this.translation,
    required this.isTranslating,
    required this.onTranslate,
  });

  final Message message;
  final bool isMine;
  final String? translation;
  final bool isTranslating;
  final VoidCallback onTranslate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        MessageBubble(message: message, isMine: isMine),
        if (!isMine) ...<Widget>[
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerLeft,
            child: _TranslateButton(
              isLoading: isTranslating,
              onTap: onTranslate,
            ),
          ),
          if (translation != null)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.xs,
                bottom: AppSpacing.xs,
              ),
              child: _TranslatedText(text: translation!),
            ),
        ],
      ],
    );
  }
}

class _TranslateButton extends StatelessWidget {
  const _TranslateButton({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = Theme.of(context).colorScheme.primary;
    return TextButton.icon(
      onPressed: isLoading ? null : onTap,
      icon: Icon(Icons.translate_rounded, size: 16, color: accent),
      label: Text(
        isLoading ? 'Перевод...' : 'Перевод',
        style: AppTextStyles.caption(color: accent),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _TranslatedText extends StatelessWidget {
  const _TranslatedText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: AppRadius.smAll,
        border: Border(left: BorderSide(color: primary, width: 2)),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption(color: AppColors.textSecondary),
      ),
    );
  }
}

class _TopicPanel extends StatelessWidget {
  const _TopicPanel({required this.topics, required this.onSelect});

  final List<String> topics;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        border: Border(top: BorderSide(color: primary.withValues(alpha: 0.35))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.lightbulb_rounded, size: 18, color: primary),
              const SizedBox(width: AppSpacing.xs),
              Text('Подсказки тем', style: AppTextStyles.title()),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              for (final String topic in topics)
                ActionChip(
                  label: Text(topic),
                  labelStyle: AppTextStyles.caption(
                    color: AppColors.textPrimary,
                  ),
                  backgroundColor: primary.withValues(alpha: 0.12),
                  side: BorderSide(color: primary.withValues(alpha: 0.4)),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.pillAll,
                  ),
                  onPressed: () => onSelect(topic),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Нижняя панель ввода: закруглённое поле, смайлики, подсказки и отправка.
class _InputBar extends StatefulWidget {
  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.onSuggest,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onSuggest;

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
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color primary = scheme.primary;

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
                      hintText: 'Введите сообщение...',
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
              _NeonIconButton(
                icon: Icons.emoji_emotions_outlined,
                tooltip: 'Смайлики',
                onTap: _toggleEmoji,
              ),
              const SizedBox(width: AppSpacing.sm),
              _NeonIconButton(
                icon: Icons.lightbulb_outline_rounded,
                tooltip: 'Подсказки тем',
                onTap: widget.onSuggest,
              ),
              const SizedBox(width: AppSpacing.sm),
              _NeonSendButton(onTap: _handleSend),
            ],
          ),
        ],
      ),
    );
  }
}

class _NeonIconButton extends StatelessWidget {
  const _NeonIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Tooltip(
      message: tooltip,
      child: GlowContainer(
        color: primary,
        glowRadius: 12,
        glowOpacity: 0.25,
        borderColor: primary.withValues(alpha: 0.4),
        background: AppColors.surfaceElevated,
        borderRadius: AppRadius.pillAll,
        child: IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: primary),
          iconSize: 22,
        ),
      ),
    );
  }
}

class _NeonSendButton extends StatelessWidget {
  const _NeonSendButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: GlowContainer(
        color: scheme.primary,
        glowRadius: 20,
        glowOpacity: 0.6,
        borderColor: scheme.primary,
        background: scheme.primary,
        borderRadius: AppRadius.pillAll,
        padding: const EdgeInsets.all(AppSpacing.sm + 2),
        child: Icon(Icons.send_rounded, color: scheme.onPrimary, size: 24),
      ),
    );
  }
}
