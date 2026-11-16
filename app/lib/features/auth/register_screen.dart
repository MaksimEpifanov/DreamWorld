import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/index.dart';
import '../../core/utils/email_domains.dart';
import '../../core/widgets/index.dart';
import '../../data/providers/auth_providers.dart';
import '../../data/services/auth_service.dart';
import '../onboarding/widgets/neon_logo_text.dart';

/// Экран регистрации нового аккаунта.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref
          .read(authControllerProvider.notifier)
          .register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
          );
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _error = e.message);
        _showError(e.message);
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Не удалось создать аккаунт. Попробуйте ещё раз.',
        );
        _showError('Не удалось создать аккаунт. Попробуйте ещё раз.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const NeonLogoText(fontSize: 32)
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .scale(
                              begin: const Offset(0.9, 0.9),
                              end: const Offset(1, 1),
                              duration: 400.ms,
                              curve: Curves.easeOutBack,
                            ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Создать аккаунт',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headline(),
                        ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Сначала аккаунт, потом анкета',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body(
                            color: AppColors.textSecondary,
                          ),
                        ).animate(delay: 150.ms).fadeIn(duration: 400.ms),
                        const SizedBox(height: AppSpacing.lg),
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          autofillHints: const <String>[AutofillHints.name],
                          decoration: const InputDecoration(
                            labelText: 'Имя',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                          validator: (String? value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Введите имя';
                            }
                            return null;
                          },
                        ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const <String>[AutofillHints.email],
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.mail_outline_rounded),
                          ),
                          validator: (String? value) {
                            final String email = value?.trim() ?? '';
                            if (email.isEmpty) return 'Введите email';
                            if (!RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$')
                                .hasMatch(email)) {
                              return 'Некорректный email';
                            }
                            return null;
                          },
                        ).animate(delay: 250.ms).fadeIn(duration: 400.ms),
                        if (isMailRuEmail(_emailController.text)) ...<Widget>[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Mail.ru часто блокирует письма подтверждения. '
                            'Надёжнее указать адрес Gmail.',
                            style: AppTextStyles.caption(
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          autofillHints: const <String>[
                            AutofillHints.newPassword,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Пароль',
                            prefixIcon: Icon(Icons.lock_outline_rounded),
                            helperText: 'Минимум 6 символов',
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Введите пароль';
                            }
                            if (value.length < 6) {
                              return 'Пароль должен быть не короче 6 символов';
                            }
                            return null;
                          },
                        ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _confirmController,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: const InputDecoration(
                            labelText: 'Повторите пароль',
                            prefixIcon: Icon(Icons.lock_reset_rounded),
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Введите пароль ещё раз';
                            }
                            if (value != _passwordController.text) {
                              return 'Пароли не совпадают';
                            }
                            return null;
                          },
                        ).animate(delay: 350.ms).fadeIn(duration: 400.ms),
                        if (_error != null) ...<Widget>[
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            _error!,
                            style: AppTextStyles.caption(
                              color: AppColors.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        NeonButton(
                          onPressed: _isLoading ? null : _submit,
                          label: 'Создать аккаунт',
                          icon: Icons.person_add_alt_1_rounded,
                          isLoading: _isLoading,
                          expanded: true,
                        ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
                        const SizedBox(height: AppSpacing.md),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () => context.go('/login'),
                          child: const Text('Уже есть аккаунт? Войти'),
                        ).animate(delay: 450.ms).fadeIn(duration: 400.ms),
                      ],
                    ),
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
