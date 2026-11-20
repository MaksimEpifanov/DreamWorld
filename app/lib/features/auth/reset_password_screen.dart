import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/index.dart';
import '../../core/widgets/index.dart';
import '../../data/providers/auth_providers.dart';
import '../../data/services/auth_service.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .updatePassword(password: _passwordController.text);
      if (mounted) context.go('/main');
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Не удалось изменить пароль. Запросите новую ссылку.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новый пароль')),
      body: ResponsiveContent(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          padding: AppSpacing.page,
          child: GlowContainer(
            color: Theme.of(context).colorScheme.primary,
            glowRadius: 20,
            glowOpacity: 0.2,
            background: Theme.of(context).colorScheme.surface,
            borderRadius: AppRadius.lgAll,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Придумайте новый пароль для аккаунта.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    autofillHints: const <String>[AutofillHints.newPassword],
                    decoration: InputDecoration(
                      labelText: 'Новый пароль',
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                      suffixIcon: PasswordVisibilityButton(
                        obscure: _obscurePassword,
                        onToggle: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    validator: (String? value) {
                      if (value == null || value.length < 6) {
                        return 'Пароль должен быть не короче 6 символов';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _confirmController,
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'Повторите пароль',
                      prefixIcon: Icon(Icons.lock_reset_rounded),
                      suffixIcon: PasswordVisibilityButton(
                        obscure: _obscureConfirm,
                        onToggle: () => setState(
                          () => _obscureConfirm = !_obscureConfirm,
                        ),
                      ),
                    ),
                    validator: (String? value) {
                      if (value != _passwordController.text) {
                        return 'Пароли не совпадают';
                      }
                      return null;
                    },
                  ),
                  if (_error != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption(color: AppColors.error),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  NeonButton(
                    onPressed: _loading ? null : _submit,
                    label: 'Сохранить пароль',
                    icon: Icons.check_rounded,
                    isLoading: _loading,
                    expanded: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthCallbackScreen extends ConsumerStatefulWidget {
  const AuthCallbackScreen({super.key});

  @override
  ConsumerState<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends ConsumerState<AuthCallbackScreen> {
  bool _checking = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  Future<void> _check() async {
    final AuthState auth = ref.read(authControllerProvider);
    if (!auth.isAwaitingEmailVerification) {
      if (mounted) setState(() => _checking = false);
      return;
    }
    try {
      await ref.read(authControllerProvider.notifier).confirmEmailVerified();
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthState auth = ref.watch(authControllerProvider);
    final bool signedIn = auth.isAuthenticated;
    return Scaffold(
      body: ResponsiveContent(
        alignment: Alignment.center,
        child: Padding(
          padding: AppSpacing.page,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                signedIn ? Icons.mark_email_read_outlined : Icons.mail_outline,
                size: 52,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                signedIn ? 'Email подтверждён. Аккаунт активирован.' : 'Подтверждаем email. Если это занимает долго, вернитесь ко входу и войдите с паролем.',
                textAlign: TextAlign.center,
                style: AppTextStyles.headline(),
              ),
              if (_error != null) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption(color: AppColors.error),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              if (_checking)
                const CircularProgressIndicator()
              else
                NeonButton(
                  onPressed: () => context.go(signedIn ? '/main' : '/login'),
                  label: signedIn ? 'Открыть DreamWorld' : 'Ко входу',
                  icon: Icons.arrow_forward_rounded,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
