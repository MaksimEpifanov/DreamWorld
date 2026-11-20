import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/compact_scale.dart';
import 'animated_press.dart';
import 'glow_container.dart';

/// Варианты неоновой кнопки.
enum NeonButtonVariant { filled, outlined, ghost }

/// Неоновая кнопка с градиентом, свечением и плавным нажатием.
///
/// Нажатие обрабатывает [AnimatedPress] (внешний жест), а внутренняя
/// Material-кнопка отвечает только за визуальное состояние — так тап
/// срабатывает ровно один раз.
class NeonButton extends StatelessWidget {
  const NeonButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.variant = NeonButtonVariant.filled,
    this.color,
    this.isLoading = false,
    this.expanded = false,
    this.compact = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final NeonButtonVariant variant;
  final Color? color;
  final bool isLoading;

  /// Растягивает кнопку на всю доступную ширину.
  final bool expanded;

  /// Уплотнённая кнопка для внутреннего экрана планеты.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color accent = color ?? scheme.primary;
    final Color gradientEnd = color != null
        ? Color.lerp(accent, Colors.black, 0.22)!
        : Color.lerp(accent, scheme.secondary, 0.45)!;
    final bool enabled = onPressed != null && !isLoading;
    final Color contentColor = variant == NeonButtonVariant.filled
        ? scheme.onPrimary
        : accent;
    final Color muted = contentColor.withValues(alpha: 0.5);
    final EdgeInsetsGeometry buttonPadding = compact
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    final Size buttonMinimumSize = compact
        ? const Size(0, 26)
        : const Size(0, 44);
    final TextStyle? buttonTextStyle =
        compact ? CompactText.bodyBold() : null;

    final Widget button = switch (variant) {
      NeonButtonVariant.filled => FilledButton(
        onPressed: null,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: contentColor,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: enabled ? contentColor : muted,
          shadowColor: Colors.transparent,
          padding: buttonPadding,
          minimumSize: buttonMinimumSize,
          textStyle: buttonTextStyle,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        ),
        child: _content(enabled ? contentColor : muted),
      ),
      NeonButtonVariant.outlined => OutlinedButton(
        onPressed: null,
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          disabledForegroundColor: enabled
              ? accent
              : accent.withValues(alpha: 0.5),
          side: BorderSide(color: accent.withValues(alpha: 0.9)),
          padding: buttonPadding,
          minimumSize: buttonMinimumSize,
          textStyle: buttonTextStyle,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        ),
        child: _content(enabled ? accent : accent.withValues(alpha: 0.5)),
      ),
      NeonButtonVariant.ghost => TextButton(
        onPressed: null,
        style: TextButton.styleFrom(
          foregroundColor: accent,
          disabledForegroundColor: enabled
              ? accent
              : accent.withValues(alpha: 0.5),
          padding: buttonPadding,
          minimumSize: buttonMinimumSize,
          textStyle: buttonTextStyle,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        ),
        child: _content(enabled ? accent : accent.withValues(alpha: 0.5)),
      ),
    };

    final Widget decorated = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.mdAll,
        gradient: variant == NeonButtonVariant.filled
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[accent, gradientEnd],
              )
            : null,
        border: variant == NeonButtonVariant.filled
            ? Border.all(color: Colors.white.withValues(alpha: 0.25))
            : null,
      ),
      child: button,
    );

    final Widget result = GlowContainer(
      color: accent,
      glowRadius: enabled ? (compact ? 8 : 18) : 0,
      glowOpacity: enabled ? (compact ? 0.3 : 0.42) : 0,
      borderRadius: AppRadius.mdAll,
      child: decorated,
    );

    final Widget pressed = enabled
        ? AnimatedPress(onPressed: onPressed, child: result)
        : result;

    if (expanded) return SizedBox(width: double.infinity, child: pressed);
    return pressed;
  }

  Widget _content(Color contentColor) {
    if (isLoading) {
      return SizedBox(
        width: compact ? 12 : 20,
        height: compact ? 12 : 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: contentColor),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: compact ? 12 : 20),
          SizedBox(width: compact ? CompactSpace.xs : CompactSpace.md),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }
    return Text(
      label,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }
}
