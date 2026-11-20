import 'package:flutter/material.dart';

/// Кнопка переключения видимости пароля в поле ввода.
class PasswordVisibilityButton extends StatelessWidget {
  const PasswordVisibilityButton({
    super.key,
    required this.obscure,
    required this.onToggle,
  });

  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: obscure ? 'Показать пароль' : 'Скрыть пароль',
      icon: Icon(
        obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      ),
      onPressed: onToggle,
    );
  }
}
