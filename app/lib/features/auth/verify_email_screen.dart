import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/index.dart';
import '../../core/widgets/index.dart';
import '../../data/providers/auth_providers.dart';
import '../../data/services/auth_service.dart';
import '../onboarding/widgets/neon_logo_text.dart';

/// Экран ожидания подтверждения почты после регистрации или входа.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  static const int _resendCooldownSeconds = 45;

  Timer? _timer;
  int _cooldown = 0;
  bool _checking = false;
  bool _resending = false;
  String? _error;
  String? _info;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _cooldown = _resendCooldownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _cooldown--;
        if (_cooldown <= 0) timer.cancel();
      });
    });
  }

  Future<void> _confirm() async {
    setState(() {
      _checking = true;
      _error = null;
      _info = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).confirmEmailVerified();
      if (mounted) {
        setState(() => _info = 'Почта подтверждена. Открываем Dream World…');
      }
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Не удалось проверить подтверждение. Попробуйте ещё раз.',
        );
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _resend() async {
    setState(() {
      _resending = true;
      _error = null;
      _info = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).resendVerificationEmail();
      if (mounted) {
        setState(
          () => _info =
              'Письмо отправлено повторно. Проверьте «Входящие» и «Спам».',
        );
        _startCooldown();
      }
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Не удалось отправить письмо. Попробуйте позже.',
        );
      }
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  Future<void> _useAnotherAccount() async {
    await ref.read(authControllerProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String email =
        ref.watch(authControllerProvider).email ?? 'вашу почту';
    final bool canResend = _cooldown == 0 && !_resending && !_checking;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          _buildDecorativeCircles(scheme),
          SafeArea(
            child: ResponsiveContent(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                padding: AppSpacing.page,
                child: GlowContainer(
                  color: scheme.secondary,
                  glowRadius: 24,
                  glowOpacity: 0.3,
                  borderColor: scheme.secondary.withValues(alpha: 0.6),
                  background: scheme.surface,
                  borderRadius: AppRadius.lgAll,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.mark_email_unread_outlined,
                        size: 56,
                        color: scheme.secondary,
                      ).animate().fadeIn(duration: 400.ms),
                      const SizedBox(height: AppSpacing.md),
                      const NeonLogoText(fontSize: 28)
                          .animate()
                          .fadeIn(duration: 400.ms),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Подтвердите почту',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headline(),
                      ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Мы отправили письмо со ссылкой на $email. '
                        'Перейдите по ссылке, затем вернитесь сюда и нажмите '
                        '«Я подтвердил почту».',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body(),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Письма от нового отправителя иногда попадают в «Спам».',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (_error != null) ...<Widget>[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption(color: AppColors.error),
                        ),
                      ],
                      if (_info != null) ...<Widget>[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          _info!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption(color: scheme.secondary),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      NeonButton(
                        onPressed: _checking ? null : _confirm,
                        label: 'Я подтвердил почту',
                        icon: Icons.verified_outlined,
                        isLoading: _checking,
                        expanded: true,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextButton.icon(
                        onPressed: canResend ? _resend : null,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(
                          _cooldown > 0
                              ? 'Отправить ещё раз через $_cooldown с'
                              : 'Отправить письмо ещё раз',
                        ),
                      ),
                      TextButton(
                        onPressed: _checking || _resending
                            ? null
                            : _useAnotherAccount,
                        child: const Text('Войти под другим аккаунтом'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeCircles(ColorScheme scheme) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: -80,
          right: -60,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.tertiary.withValues(alpha: 0.1),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -40,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primary.withValues(alpha: 0.1),
            ),
          ),
        ),
      ],
    );
  }
}
