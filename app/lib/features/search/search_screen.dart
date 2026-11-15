import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/index.dart';
import '../../core/widgets/index.dart';
import '../../data/models/index.dart';
import '../../data/providers/app_providers.dart';
import '../../data/services/user_code.dart';
import '../contacts/contacts_controller.dart';

/// Поиск людей по публичному ID.
///
/// У каждого пользователя есть постоянный код вида `DW-7K4M-2QXV`.
/// По нему человека можно найти и на сайте, и в APK.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _query = value);
    });
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    setState(() => _query = '');
  }

  Future<void> _copyCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(const SnackBar(content: Text('Ваш ID скопирован')));
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String userId = ref.watch(currentUserIdProvider);
    final String userCode = UserCode.fromUserId(userId);
    final bool ready = UserCode.isComplete(_query);
    final AsyncValue<List<Profile>> results = ready
        ? ref.watch(profileSearchProvider(_query))
        : const AsyncData<List<Profile>>(<Profile>[]);

    return Scaffold(
      appBar: NeonAppBar(
        title: 'Поиск по ID',
        leading: BackButton(onPressed: () => context.go('/main')),
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: ListView(
            padding: AppSpacing.page,
            children: <Widget>[
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.badge_outlined,
                          size: 34,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Ваш ID', style: AppTextStyles.title()),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                'Поделитесь им — по нему вас найдут в поиске.',
                                style: AppTextStyles.caption(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.md,
                        right: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.1),
                        borderRadius: AppRadius.pillAll,
                        border: Border.all(
                          color: scheme.primary.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              userCode,
                              style: AppTextStyles.bodyBold(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Скопировать ID',
                            icon: const Icon(Icons.copy_rounded, size: 20),
                            onPressed: () => _copyCode(userCode),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 360.ms).slideY(begin: 0.08),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _controller,
                onChanged: _onChanged,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: 'ID пользователя',
                  hintText: 'DW-XXXX-XXXX',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Очистить',
                          icon: const Icon(Icons.close_rounded),
                          onPressed: _clear,
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (!ready)
                const _SearchHint(
                  icon: Icons.pin_outlined,
                  text:
                      'Введите ID полностью — 8 символов после DW-.\n'
                      'Например: DW-7K4M-2QXV.',
                )
              else
                results.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (Object error, StackTrace stackTrace) =>
                      const _SearchHint(
                        icon: Icons.error_outline_rounded,
                        text: 'Не удалось выполнить поиск. Попробуйте ещё раз.',
                      ),
                  data: (List<Profile> profiles) {
                    if (profiles.isEmpty) {
                      return const _SearchHint(
                        icon: Icons.person_search_outlined,
                        text:
                            'Пользователь с таким ID не найден.\n'
                            'Проверьте код и попробуйте снова.',
                      );
                    }
                    return Column(
                      children: <Widget>[
                        for (int i = 0; i < profiles.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _SearchResultCard(
                              profile: profiles[i],
                              index: i,
                              isSelf: profiles[i].id == userId,
                            ),
                          ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultCard extends ConsumerWidget {
  const _SearchResultCard({
    required this.profile,
    required this.index,
    required this.isSelf,
  });

  final Profile profile;
  final int index;
  final bool isSelf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool inContacts = ref.watch(contactsProvider).contains(profile.id);
    final String? city = profile.city;

    return GlassCard(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: <Widget>[
              AuraAvatar(
                photoUrl: profile.photoUrl,
                size: 52,
                fallbackText: profile.name,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(profile.name, style: AppTextStyles.bodyBold()),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      city == null || city.isEmpty
                          ? UserCode.fromUserId(profile.id)
                          : '$city • ${UserCode.fromUserId(profile.id)}',
                      style: AppTextStyles.caption(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSelf)
                Chip(
                  label: const Text('Это вы'),
                  side: BorderSide(
                    color: scheme.primary.withValues(alpha: 0.5),
                  ),
                  backgroundColor: scheme.primary.withValues(alpha: 0.12),
                )
              else if (inContacts)
                IconButton(
                  tooltip: 'Уже в контактах',
                  icon: Icon(
                    Icons.check_circle_outline,
                    color: scheme.secondary,
                  ),
                  onPressed: null,
                )
              else
                IconButton(
                  tooltip: 'Добавить в контакты',
                  icon: Icon(
                    Icons.person_add_alt_1_rounded,
                    color: scheme.primary,
                  ),
                  onPressed: () {
                    ref.read(contactsProvider.notifier).add(profile.id);
                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            '${profile.name} добавлен(а) в контакты',
                          ),
                        ),
                      );
                  },
                ),
            ],
          ),
        )
        .animate(delay: (index * 50).ms)
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
  }
}

class _SearchHint extends StatelessWidget {
  const _SearchHint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 56, color: scheme.primary.withValues(alpha: 0.6)),
          const SizedBox(height: AppSpacing.md),
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
