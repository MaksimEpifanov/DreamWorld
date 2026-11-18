import 'package:flutter/material.dart';

import '../../../core/theme/index.dart';
import '../../../data/models/message.dart';

/// Пузырь сообщения.
///
/// Свои сообщения — неоновый градиент, чужие — полупрозрачная подложка.
/// Внутри пузыря отображаются текст и время (а для своих — статус доставки).
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
  });

  final Message message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color primary = scheme.primary;
    final Color secondary = scheme.secondary;

    final Color textColor = isMine ? scheme.onPrimary : AppColors.white;

    final BoxDecoration decoration = isMine
        ? BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[primary, secondary],
            ),
            borderRadius: _radiusFor(isMine),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: primary.withValues(alpha: 0.45),
                blurRadius: 18,
                spreadRadius: -2,
              ),
            ],
          )
        : BoxDecoration(
            color: primary.withValues(alpha: 0.18),
            borderRadius: _radiusFor(isMine),
            border: Border.all(color: primary.withValues(alpha: 0.45)),
          );

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        decoration: decoration,
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              message.displayText,
              style: AppTextStyles.body(color: textColor).copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
                shadows: isMine
                    ? null
                    : <Shadow>[
                        Shadow(
                          color: AppColors.black.withValues(alpha: 0.55),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  _formatTime(message.createdAt),
                  style: AppTextStyles.caption(
                    color: textColor.withValues(alpha: 0.85),
                  ),
                ),
                if (isMine) ...<Widget>[
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    _statusIcon(message.status),
                    size: 14,
                    color: textColor.withValues(alpha: 0.85),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  BorderRadius _radiusFor(bool mine) {
    const Radius round = Radius.circular(AppRadius.lg + 4);
    const Radius tail = Radius.circular(AppRadius.sm - 2);
    return BorderRadius.only(
      topLeft: round,
      topRight: round,
      bottomLeft: mine ? round : tail,
      bottomRight: mine ? tail : round,
    );
  }

  IconData _statusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.read:
        return Icons.done_all_rounded;
      case MessageStatus.delivered:
        return Icons.done_all_rounded;
      case MessageStatus.failed:
        return Icons.error_outline_rounded;
      case MessageStatus.sending:
        return Icons.access_time_rounded;
      case MessageStatus.sent:
        return Icons.done_rounded;
    }
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
