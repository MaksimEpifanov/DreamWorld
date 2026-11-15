import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/index.dart';
import '../../core/widgets/index.dart';
import '../../data/providers/auth_providers.dart';
import '../../data/services/auth_service.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
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
          .sendPasswordReset(email: _emailController.text.trim());
      if (mounted) setState(() => _sent = true);
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Не удалось отправить письмо. Попробуйте ещё раз.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Восстановление пароля'),
        leading: IconButton(
          tooltip: 'Назад ко входу',
          onPressed: () => context.go('/login'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
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
            child: _sent
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(Icons.mark_email_read_outlined, size: 48),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Если аккаунт с таким адресом существует, письмо со ссылкой для сброса уже отправлено. Проверьте «Входящие» и «Спам».',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body(),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('Вернуться ко входу'),
                      ),
                    ],
                  )
                : Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Укажите email аккаунта. Мы отправим ссылку для создания нового пароля.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const <String>[AutofillHints.email],
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
                        ),
                        if (_error != null) ...<Widget>[
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption(
                              color: AppColors.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        NeonButton(
                          onPressed: _loading ? null : _submit,
                          label: 'Отправить ссылку',
                          icon: Icons.mark_email_unread_outlined,
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
