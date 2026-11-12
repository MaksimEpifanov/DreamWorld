import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/index.dart';
import '../../../core/widgets/index.dart';
import '../../wallet/wallet_controller.dart';
import 'quiz_data.dart';

/// Викторина: отвечайте на вопросы и получайте монеты.
///
/// Награда зависит от числа правильных ответов; действует дневной лимит
/// заработка в мини-играх (см. [WalletController.dailyGameLimit]).
class QuizGameScreen extends ConsumerStatefulWidget {
  const QuizGameScreen({super.key});

  @override
  ConsumerState<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends ConsumerState<QuizGameScreen> {
  static const int _total = 10;
  static const int _secondsPerQuestion = 20;

  late List<QuizQuestion> _questions;

  int _index = 0;
  int _correct = 0;
  int? _selected;
  Timer? _timer;
  int _secondsLeft = _secondsPerQuestion;
  bool _finished = false;
  int _credited = 0;
  bool _limitReached = false;

  @override
  void initState() {
    super.initState();
    final List<QuizQuestion> pool = List<QuizQuestion>.of(quizQuestions)
      ..shuffle(Random());
    _questions = pool.take(_total).toList(growable: false);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = _secondsPerQuestion;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
        _answer(-1);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _answer(int option) {
    if (_selected != null || _finished) return;
    _timer?.cancel();
    final bool ok = option >= 0 && _questions[_index].isCorrect(option);
    setState(() {
      _selected = option;
      if (ok) _correct++;
    });
    Future<void>.delayed(const Duration(milliseconds: 750), () {
      if (!mounted) return;
      if (_index + 1 >= _questions.length) {
        _finish();
      } else {
        setState(() {
          _index++;
          _selected = null;
        });
        _startTimer();
      }
    });
  }

  Future<void> _finish() async {
    final int reward = _correct * 5;
    final int credited = await ref
        .read(walletProvider.notifier)
        .rewardFromGame(reward);
    if (!mounted) return;
    setState(() {
      _finished = true;
      _credited = credited;
      _limitReached = credited < reward;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NeonAppBar(
        title: 'Викторина',
        leading: BackButton(onPressed: () => context.go('/minigames')),
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: Padding(
            padding: AppSpacing.page,
            child: _finished ? _buildResult(context) : _buildQuestion(context),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final QuizQuestion q = _questions[_index];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'Вопрос ${_index + 1} из ${_questions.length}',
                style: AppTextStyles.caption(),
              ),
              const Spacer(),
              Icon(Icons.timer_outlined, size: 16, color: scheme.secondary),
              const SizedBox(width: AppSpacing.xs),
              Text('$_secondsLeft с', style: AppTextStyles.caption()),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: AppRadius.pillAll,
            child: LinearProgressIndicator(
              value: _secondsLeft / _secondsPerQuestion,
              minHeight: 6,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GlassCard(child: Text(q.text, style: AppTextStyles.title())),
          const SizedBox(height: AppSpacing.lg),
          for (int i = 0; i < q.options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _OptionTile(
                text: q.options[i],
                state: _optionState(i, q),
                onTap: _selected == null ? () => _answer(i) : null,
              ),
            ),
        ],
      ),
    );
  }

  _OptionState _optionState(int i, QuizQuestion q) {
    if (_selected == null) return _OptionState.idle;
    if (q.isCorrect(i)) return _OptionState.correct;
    if (i == _selected) return _OptionState.wrong;
    return _OptionState.idle;
  }

  Widget _buildResult(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.emoji_events_rounded, size: 64, color: scheme.tertiary),
          const SizedBox(height: AppSpacing.md),
          Text('Игра окончена', style: AppTextStyles.headline()),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Правильных ответов: $_correct из ${_questions.length}',
            style: AppTextStyles.body(),
          ),
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            child: Column(
              children: <Widget>[
                Text('Начислено монет', style: AppTextStyles.caption()),
                const SizedBox(height: AppSpacing.xs),
                Text('+$_credited', style: AppTextStyles.display()),
                if (_limitReached) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Дневной лимит заработка достигнут',
                    style: AppTextStyles.caption(color: AppColors.warning),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          NeonButton(
            label: 'Играть снова',
            icon: Icons.replay_rounded,
            expanded: true,
            onPressed: () {
              setState(() {
                _finished = false;
                _index = 0;
                _correct = 0;
                _selected = null;
                _credited = 0;
                _limitReached = false;
                (List<QuizQuestion>.of(quizQuestions)..shuffle(Random()));
              });
              final List<QuizQuestion> pool = List<QuizQuestion>.of(
                quizQuestions,
              )..shuffle(Random());
              _questions = pool.take(_total).toList(growable: false);
              _startTimer();
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          NeonButton(
            label: 'К играм',
            variant: NeonButtonVariant.outlined,
            expanded: true,
            onPressed: () => context.go('/minigames'),
          ),
        ],
      ),
    );
  }
}

enum _OptionState { idle, correct, wrong }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String text;
  final _OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    Color border = AppColors.surfaceElevated;
    Color bg = AppColors.surface;
    IconData? icon;
    Color? iconColor;

    switch (state) {
      case _OptionState.correct:
        border = AppColors.success;
        bg = AppColors.success.withValues(alpha: 0.14);
        icon = Icons.check_circle_rounded;
        iconColor = AppColors.success;
      case _OptionState.wrong:
        border = AppColors.error;
        bg = AppColors.error.withValues(alpha: 0.14);
        icon = Icons.cancel_rounded;
        iconColor = AppColors.error;
      case _OptionState.idle:
        break;
    }

    return AnimatedPress(
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: border),
        ),
        child: Row(
          children: <Widget>[
            Expanded(child: Text(text, style: AppTextStyles.body())),
            if (icon != null)
              Icon(icon, color: iconColor, size: 20)
            else
              Icon(
                Icons.radio_button_unchecked_rounded,
                color: scheme.primary.withValues(alpha: 0.5),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
