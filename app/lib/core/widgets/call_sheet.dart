import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/index.dart';
import 'neon_button.dart';

/// Показывает лист запуска звонка.
///
/// Позволяет начать аудио- или видеозвонок и скопировать ссылку-приглашение.
/// [onStart] возвращает `true`, если звонок удалось открыть.
Future<void> showCallSheet(
  BuildContext context, {
  required String title,
  required String roomUrl,
  required Future<bool> Function(bool video) onStart,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext context) => _CallSheet(
      title: title,
      roomUrl: roomUrl,
      onStart: onStart,
    ),
  );
}

class _CallSheet extends StatefulWidget {
  const _CallSheet({
    required this.title,
    required this.roomUrl,
    required this.onStart,
  });

  final String title;
  final String roomUrl;
  final Future<bool> Function(bool video) onStart;

  @override
  State<_CallSheet> createState() => _CallSheetState();
}

class _CallSheetState extends State<_CallSheet> {
  bool _starting = false;

  Future<void> _start(bool video) async {
    if (_starting) return;
    setState(() => _starting = true);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final NavigatorState navigator = Navigator.of(context);
    final bool opened = await widget.onStart(video);
    if (!mounted) return;
    navigator.pop();
    if (!opened) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Не удалось открыть звонок. Попробуйте ещё раз.'),
        ),
      );
    }
  }

  Future<void> _copyLink() async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final NavigatorState navigator = Navigator.of(context);
    await Clipboard.setData(ClipboardData(text: widget.roomUrl));
    if (!mounted) return;
    navigator.pop();
    messenger.showSnackBar(
      const SnackBar(content: Text('Ссылка-приглашение скопирована')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
        border: Border(top: BorderSide(color: primary.withValues(alpha: 0.4))),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.5),
                  borderRadius: AppRadius.pillAll,
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Icon(Icons.videocam_rounded, color: primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Позвонить: ${widget.title}',
                    style: AppTextStyles.title(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Звонок откроется в Jitsi Meet — бесплатно и без регистрации. '
              'Ссылку-приглашение можно отправить собеседнику.',
              style: AppTextStyles.caption(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: NeonButton(
                    label: 'Аудиозвонок',
                    icon: Icons.call_rounded,
                    expanded: true,
                    isLoading: _starting,
                    onPressed: _starting ? null : () => _start(false),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: NeonButton(
                    label: 'Видеозвонок',
                    icon: Icons.videocam_rounded,
                    variant: NeonButtonVariant.outlined,
                    expanded: true,
                    isLoading: _starting,
                    onPressed: _starting ? null : () => _start(true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            NeonButton(
              label: 'Скопировать ссылку',
              icon: Icons.link_rounded,
              variant: NeonButtonVariant.ghost,
              expanded: true,
              onPressed: _copyLink,
            ),
          ],
        ),
      ),
    );
  }
}
