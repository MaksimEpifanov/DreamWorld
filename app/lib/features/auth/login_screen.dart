import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/index.dart';
import '../../core/widgets/index.dart';
import '../../data/providers/auth_providers.dart';
import '../../data/services/auth_service.dart';
import '../onboarding/widgets/neon_logo_text.dart';

/// Экран входа в аккаунт.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _error = e.message);
        _showError(e.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Не удалось войти. Попробуйте ещё раз.');
        _showError('Не удалось войти. Попробуйте ещё раз.');
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
                  color: scheme.primary,
                  glowRadius: 24,
                  glowOpacity: 0.3,
                  borderColor: scheme.primary.withValues(alpha: 0.6),
                  background: scheme.surface,
                  borderRadius: AppRadius.lgAll,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const NeonLogoText(fontSize: 36)
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .scale(
                              begin: const Offset(0.9, 0.9),
                              end: const Offset(1, 1),
                              duration: 400.ms,
                              curve: Curves.easeOutBack,
                            ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Вход в аккаунт',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headline(),
                        ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _isLoading
                                ? null
                                : () => context.go('/forgot-password'),
                            child: const Text('Забыли пароль?'),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const <String>[AutofillHints.email],
                          textInputAction: TextInputAction.next,
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
                        ).animate(delay: 150.ms).fadeIn(duration: 400.ms),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          autofillHints: const <String>[AutofillHints.password],
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            labelText: 'Пароль',
                            prefixIcon: Icon(Icons.lock_outline_rounded),
                            suffixIcon: PasswordVisibilityButton(
                              obscure: _obscurePassword,
                              onToggle: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Введите пароль';
                            }
                            return null;
                          },
                        ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
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
                          label: 'Войти',
                          icon: Icons.login_rounded,
                          isLoading: _isLoading,
                          expanded: true,
                        ).animate(delay: 250.ms).fadeIn(duration: 400.ms),
                        const SizedBox(height: AppSpacing.md),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () => context.go('/register'),
                          child: const Text('Нет аккаунта? Зарегистрироваться'),
                        ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
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
          top: -60,
          left: -40,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primary.withValues(alpha: 0.1),
            ),
          ),
        ),
        Positioned(
          bottom: -80,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.secondary.withValues(alpha: 0.1),
            ),
          ),
        ),
      ],
    );
  }
}
