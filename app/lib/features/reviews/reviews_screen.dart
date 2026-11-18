import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/index.dart';
import '../../core/widgets/index.dart';
import '../../data/models/profile.dart';
import '../../data/models/review.dart';
import '../../data/providers/app_providers.dart';
import '../../data/providers/review_providers.dart';

/// Экран отзывов о сайте и приложении.
///
/// Любой вошедший пользователь может оставить свой отзыв и прочитать отзывы
/// других. Отзывы общие: в рабочей версии они хранятся в Firestore.
class ReviewsScreen extends ConsumerStatefulWidget {
  const ReviewsScreen({super.key});

  @override
  ConsumerState<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends ConsumerState<ReviewsScreen> {
  final TextEditingController _controller = TextEditingController();
  int _rating = 5;
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    final Profile? profile = ref.read(currentProfileProvider).valueOrNull;
    final String name = profile?.name.trim() ?? '';
    final Review review = Review(
      id: const Uuid().v4(),
      authorId: ref.read(currentUserIdProvider),
      authorName: name.isEmpty ? 'Гость' : name,
      text: text,
      rating: _rating,
      createdAt: DateTime.now().toIso8601String(),
    );
    setState(() => _sending = true);
    try {
      await ref.read(reviewRepositoryProvider).addReview(review);
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      _showMessage('Не удалось отправить отзыв. Попробуйте ещё раз.');
      return;
    }
    if (!mounted) return;
    setState(() {
      _sending = false;
      _rating = 5;
    });
    _controller.clear();
    FocusScope.of(context).unfocus();
    _showMessage('Спасибо за отзыв!');
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final List<Review> reviews =
        ref.watch(reviewsProvider).valueOrNull ?? const <Review>[];

    return Scaffold(
      appBar: NeonAppBar(
        title: 'Отзывы',
        leading: BackButton(onPressed: () => context.go('/main')),
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: <Widget>[
              Text(
                'Расскажите, что вы думаете о сайте и приложении DreamWorld.',
                style: AppTextStyles.body(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
              _ReviewComposer(
                controller: _controller,
                rating: _rating,
                sending: _sending,
                onRatingChanged: (int value) => setState(() => _rating = value),
                onSubmit: _submit,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.rate_review_outlined,
                    size: 20,
                    color: Color(0xFF71BFFF),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text('Отзывы участников', style: AppTextStyles.bodyBold()),
                  const Spacer(),
                  Text('${reviews.length}', style: AppTextStyles.caption()),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (reviews.isEmpty)
                const _EmptyReviews()
              else
                for (final Review review in reviews)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _ReviewTile(review: review),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewComposer extends StatelessWidget {
  const _ReviewComposer({
    required this.controller,
    required this.rating,
    required this.sending,
    required this.onRatingChanged,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final int rating;
  final bool sending;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Ваш отзыв', style: AppTextStyles.bodyBold()),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text('Оценка', style: AppTextStyles.caption()),
              _RatingSelector(value: rating, onChanged: onRatingChanged),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: controller,
            minLines: 3,
            maxLines: 5,
            maxLength: 600,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              labelText: 'Поделитесь впечатлением',
              hintText: 'Что понравилось, что можно улучшить...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          NeonButton(
            label: 'Отправить отзыв',
            icon: Icons.send_rounded,
            isLoading: sending,
            expanded: true,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

class _RatingSelector extends StatelessWidget {
  const _RatingSelector({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int star = 1; star <= 5; star++)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(star),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              child: Icon(
                star <= value ? Icons.star_rounded : Icons.star_border_rounded,
                size: 28,
                color: const Color(0xFFFFC53D),
              ),
            ),
          ),
      ],
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int star = 1; star <= 5; star++)
          Icon(
            star <= rating ? Icons.star_rounded : Icons.star_border_rounded,
            size: 14,
            color: const Color(0xFFFFC53D),
          ),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              AuraAvatar(size: 40, fallbackText: review.authorName),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      review.authorName.isEmpty ? 'Гость' : review.authorName,
                      style: AppTextStyles.bodyBold(),
                    ),
                    const SizedBox(height: 2),
                    _RatingStars(rating: review.rating),
                  ],
                ),
              ),
              Text(
                _dateLabel(review.createdAt),
                style: AppTextStyles.caption(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(review.text, style: AppTextStyles.body()),
        ],
      ),
    );
  }

  String _dateLabel(String iso) {
    final DateTime? date = DateTime.tryParse(iso);
    if (date == null) return '';
    final DateTime local = date.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(local.day)}.${two(local.month)}.${local.year}';
  }
}

class _EmptyReviews extends StatelessWidget {
  const _EmptyReviews();

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.rate_review_outlined,
            size: 40,
            color: Color(0xFF71BFFF),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Отзывов пока нет', style: AppTextStyles.bodyBold()),
          const SizedBox(height: 4),
          Text(
            'Станьте первым, кто поделится впечатлением о DreamWorld.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
