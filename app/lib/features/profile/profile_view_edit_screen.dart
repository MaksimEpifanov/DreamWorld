import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/planet_interest_details.dart';
import '../../core/theme/index.dart';
import '../../core/utils/image_utils.dart';
import '../../core/widgets/index.dart';
import '../../data/models/index.dart';
import '../../data/providers/app_providers.dart';
import '../../data/providers/auth_providers.dart';
import '../../data/services/user_code.dart';
import 'widgets/photo_picker.dart';

class ProfileViewEditScreen extends ConsumerStatefulWidget {
  const ProfileViewEditScreen({super.key});

  @override
  ConsumerState<ProfileViewEditScreen> createState() =>
      _ProfileViewEditScreenState();
}

class _ProfileViewEditScreenState extends ConsumerState<ProfileViewEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  final List<String> _interestOptions = const <String>[
    'Путешествия',
    'Музыка',
    'Спорт',
    'Чтение',
    'Фильмы',
    'Искусство',
    'Технологии',
    'Еда',
    'Природа',
    'Игры',
  ];

  final Set<String> _selectedInterests = <String>{};
  final Set<String> _selectedDetailedInterests = <String>{};
  RelationshipGoal _relationshipGoal = RelationshipGoal.friendship;
  final Set<String> _selectedValues = <String>{};
  final List<String> _valueOptions = const <String>[
    'Честность',
    'Уважение',
    'Доверие',
    'Поддержка',
    'Юмор',
    'Амбициозность',
  ];
  final List<String> _goalOptions = const <String>[
    'Общение',
    'Дружба',
    'Отношения',
    'Семья',
  ];
  final Set<String> _selectedGoals = <String>{};

  String? _photoDataUri;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profileRepo = ref.read(profileRepositoryProvider);
    final profile = await profileRepo.getCurrentProfile();
    if (mounted && profile != null) {
      _nameController.text = profile.name;
      _ageController.text = profile.age.toString();
      _cityController.text = profile.city ?? '';
      _bioController.text = profile.bio ?? '';
      _photoDataUri = profile.photoUrl;
      _relationshipGoal = profile.relationshipGoal;
      _selectedGoals.clear();
      _selectedGoals.addAll(profile.goals);
      _selectedValues.clear();
      _selectedValues.addAll(profile.values);
      _selectedInterests.clear();
      for (final interest in profile.interests) {
        if (interest.name.isNotEmpty) {
          _selectedInterests.add(interest.name);
        }
      }
      _selectedDetailedInterests
        ..clear()
        ..addAll(profile.detailedInterests);
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);

    final profileRepo = ref.read(profileRepositoryProvider);
    final currentUserId = ref.read(currentUserIdProvider);
    final GoRouter router = GoRouter.of(context);

    final Profile updatedProfile = Profile(
      id: currentUserId,
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? 18,
      city: _cityController.text.trim(),
      country: 'Россия',
      bio: _bioController.text.trim(),
      photoUrl: _photoDataUri,
      interests: _selectedInterests.map((s) {
        switch (s) {
          case 'Путешествия':
            return InterestCatalog.travel;
          case 'Музыка':
            return InterestCatalog.music;
          case 'Спорт':
            return InterestCatalog.sport;
          case 'Чтение':
            return InterestCatalog.books;
          case 'Фильмы':
            return InterestCatalog.cinema;
          case 'Искусство':
            return InterestCatalog.art;
          case 'Технологии':
            return InterestCatalog.tech;
          case 'Еда':
            return InterestCatalog.food;
          case 'Природа':
            return InterestCatalog.nature;
          case 'Игры':
            return InterestCatalog.games;
          default:
            return Interest(id: s, name: s, category: InterestCategory.other);
        }
      }).toList(),
      goals: _selectedGoals.toList(),
      values: _selectedValues.toList(),
      languages: const <String>['ru'],
      relationshipGoal: _relationshipGoal,
      detailedInterests: _selectedDetailedInterests.toList(),
    );

    try {
      await profileRepo.saveProfile(updatedProfile);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(const SnackBar(content: Text('Изменения сохранены')));

    if (router.canPop()) {
      router.pop();
    } else {
      router.go('/main');
    }
  }

  Future<void> _subscribe() async {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Подписка Dreem+'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Открывает все планеты, видеозвонки и безлимит сообщений. '
              'Первые 7 дней бесплатно.',
              style: AppTextStyles.body(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Оплата пока не подключена.', style: AppTextStyles.caption()),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Позже'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: scheme.primary),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Оформить'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isPremium = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пробный период Dreem+ активирован (демо)'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        leading: BackButton(onPressed: () => context.go('/main')),
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: AppSpacing.page,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _ProfileHeader(
                    photoDataUri: _photoDataUri,
                    name: _nameController.text.trim(),
                    age: _ageController.text.trim(),
                    city: _cityController.text.trim(),
                    interests: _selectedInterests.toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (ref
                      .watch(authControllerProvider)
                      .pendingEmailVerification) ...<Widget>[
                    _UnverifiedEmailCard(
                      email: ref.watch(authControllerProvider).email,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  _UserIdCard(userId: ref.watch(currentUserIdProvider)),
                  const SizedBox(height: AppSpacing.lg),
                  _SubscriptionCard(
                    isPremium: _isPremium,
                    onSubscribe: () => _subscribe(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  NeonButton(
                    label: 'Изменить фото',
                    icon: Icons.add_a_photo_outlined,
                    variant: NeonButtonVariant.outlined,
                    expanded: true,
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.xlAll,
                        ),
                        builder: (BuildContext context) => Padding(
                          padding: AppSpacing.page,
                          child: PhotoPicker(
                            photoDataUri: _photoDataUri,
                            height: 220,
                            onPicked: (String dataUri) {
                              setState(() => _photoDataUri = dataUri);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  NeonCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Основные данные', style: AppTextStyles.title()),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Имя'),
                          onChanged: (_) => setState(() {}),
                          validator: (String? value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Введите имя';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _ageController,
                          decoration: const InputDecoration(
                            labelText: 'Возраст',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          validator: (String? value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Введите возраст';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(labelText: 'Город'),
                          onChanged: (_) => setState(() {}),
                          validator: (String? value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Введите город';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  NeonCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Интересы', style: AppTextStyles.title()),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Выбери основные направления',
                          style: AppTextStyles.caption(
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _interestOptions.map((String interest) {
                            final bool selected = _selectedInterests.contains(
                              interest,
                            );
                            return FilterChip(
                              label: Text(interest),
                              selected: selected,
                              onSelected: (bool value) {
                                setState(() {
                                  if (value) {
                                    _selectedInterests.add(interest);
                                  } else {
                                    _selectedInterests.remove(interest);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _DetailedInterestsEditor(
                    selected: _selectedDetailedInterests,
                    onChanged: (Set<String> value) {
                      setState(() {
                        _selectedDetailedInterests
                          ..clear()
                          ..addAll(value);
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  NeonCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Цель отношений', style: AppTextStyles.title()),
                        const SizedBox(height: AppSpacing.sm),
                        SegmentedButton<RelationshipGoal>(
                          segments: const <ButtonSegment<RelationshipGoal>>[
                            ButtonSegment<RelationshipGoal>(
                              value: RelationshipGoal.friendship,
                              label: Text('Дружба'),
                            ),
                            ButtonSegment<RelationshipGoal>(
                              value: RelationshipGoal.chat,
                              label: Text('Чат'),
                            ),
                            ButtonSegment<RelationshipGoal>(
                              value: RelationshipGoal.dating,
                              label: Text('Свидания'),
                            ),
                            ButtonSegment<RelationshipGoal>(
                              value: RelationshipGoal.serious,
                              label: Text('Серьезные'),
                            ),
                          ],
                          selected: <RelationshipGoal>{_relationshipGoal},
                          onSelectionChanged:
                              (Set<RelationshipGoal> newSelection) {
                                setState(() {
                                  _relationshipGoal = newSelection.first;
                                });
                              },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  NeonCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Ценности', style: AppTextStyles.title()),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _valueOptions.map((String value) {
                            final bool selected = _selectedValues.contains(
                              value,
                            );
                            return FilterChip(
                              label: Text(value),
                              selected: selected,
                              onSelected: (bool valueChip) {
                                setState(() {
                                  if (valueChip) {
                                    _selectedValues.add(value);
                                  } else {
                                    _selectedValues.remove(value);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  NeonCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Цели', style: AppTextStyles.title()),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _goalOptions.map((String goal) {
                            final bool selected = _selectedGoals.contains(goal);
                            return FilterChip(
                              label: Text(goal),
                              selected: selected,
                              onSelected: (bool value) {
                                setState(() {
                                  if (value) {
                                    _selectedGoals.add(goal);
                                  } else {
                                    _selectedGoals.remove(goal);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  NeonCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('О себе', style: AppTextStyles.title()),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _bioController,
                          decoration: const InputDecoration(
                            labelText: 'Коротко о себе',
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  NeonButton(
                    onPressed: _isSaving ? null : _save,
                    label: _isSaving ? 'Сохранение...' : 'Сохранить',
                    isLoading: _isSaving,
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

/// Напоминание подтвердить почту, если вход был без письма.
class _UnverifiedEmailCard extends StatelessWidget {
  const _UnverifiedEmailCard({this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return NeonCard(
      child: Row(
        children: <Widget>[
          Icon(Icons.mark_email_unread_outlined, color: scheme.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Почта не подтверждена', style: AppTextStyles.bodyBold()),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  email == null || email!.isEmpty
                      ? 'Подтвердите почту, чтобы защитить аккаунт.'
                      : 'Подтвердите $email, чтобы защитить аккаунт.',
                  style: AppTextStyles.caption(),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.go('/verify-email'),
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );
  }
}

/// Карточка публичного ID: по нему пользователя находят в поиске.
class _UserIdCard extends StatelessWidget {
  const _UserIdCard({required this.userId});

  final String userId;

  Future<void> _copy(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(const SnackBar(content: Text('Ваш ID скопирован')));
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String code = UserCode.fromUserId(userId);

    return NeonCard(
      child: Row(
        children: <Widget>[
          Icon(Icons.badge_outlined, color: scheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Ваш ID', style: AppTextStyles.caption()),
                Text(
                  code,
                  style: AppTextStyles.bodyBold(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Скопировать ID',
            icon: const Icon(Icons.copy_rounded, size: 20),
            onPressed: () => _copy(context, code),
          ),
        ],
      ),
    );
  }
}

/// Карточка подписки Dreem+ (демо-режим, реальная оплата не подключена).
class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.isPremium, required this.onSubscribe});

  final bool isPremium;
  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return GlowContainer(
      color: scheme.primary,
      glowRadius: 20,
      glowOpacity: 0.35,
      borderColor: scheme.primary.withValues(alpha: 0.6),
      background: AppColors.surface,
      borderRadius: AppRadius.lgAll,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.workspace_premium_rounded, color: scheme.secondary),
              const SizedBox(width: AppSpacing.sm),
              Text('Dreem+', style: AppTextStyles.title()),
              const Spacer(),
              Chip(
                label: Text(isPremium ? 'Активна' : 'Бесплатно'),
                side: BorderSide(color: scheme.primary.withValues(alpha: 0.5)),
                backgroundColor: scheme.primary.withValues(alpha: 0.12),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isPremium
                ? 'Спасибо! Все планеты, видеозвонки и безлимит сообщений открыты.'
                : 'Откройте все планеты, видеозвонки и безлимит сообщений.',
            style: AppTextStyles.body(color: AppColors.textSecondary),
          ),
          if (!isPremium) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            NeonButton(
              label: 'Оформить подписку',
              icon: Icons.workspace_premium_rounded,
              expanded: true,
              onPressed: onSubscribe,
            ),
          ],
        ],
      ),
    );
  }
}

/// Шапка профиля: крупный аватар со свечением, имя, возраст, город и чипы интересов.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.photoDataUri,
    required this.name,
    required this.age,
    required this.city,
    required this.interests,
  });

  final String? photoDataUri;
  final String name;
  final String age;
  final String city;
  final List<String> interests;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Uint8List? bytes = decodeDataUri(photoDataUri);
    final String displayName = name.isEmpty ? 'Без имени' : name;
    final String title = age.isEmpty ? displayName : '$displayName, $age';

    return Column(
      children: <Widget>[
        GlowContainer(
          color: scheme.primary,
          glowRadius: 32,
          glowOpacity: 0.55,
          borderColor: scheme.primary.withValues(alpha: 0.7),
          background: AppColors.surface,
          borderRadius: BorderRadius.circular(72),
          padding: const EdgeInsets.all(4),
          child: ClipOval(
            child: SizedBox(
              width: 136,
              height: 136,
              child: bytes != null
                  ? Image.memory(
                      bytes,
                      fit: BoxFit.cover,
                      width: 136,
                      height: 136,
                    )
                  : Icon(Icons.person, size: 72, color: scheme.primary),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(title, style: AppTextStyles.headline()),
        if (city.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: scheme.secondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(city, style: AppTextStyles.caption()),
            ],
          ),
        ],
        if (interests.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: interests
                .map(
                  (String interest) => Chip(
                    label: Text(interest),
                    side: BorderSide(
                      color: scheme.primary.withValues(alpha: 0.5),
                    ),
                    backgroundColor: scheme.primary.withValues(alpha: 0.12),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _DetailedInterestsEditor extends StatefulWidget {
  const _DetailedInterestsEditor({
    required this.selected,
    required this.onChanged,
  });

  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  @override
  State<_DetailedInterestsEditor> createState() =>
      _DetailedInterestsEditorState();
}

class _DetailedInterestsEditorState extends State<_DetailedInterestsEditor> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final int count = widget.selected.length;

    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Более детально', style: AppTextStyles.title()),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      count == 0
                          ? 'Отметь, чем именно ты увлекаешься'
                          : 'Выбрано: ',
                      style: AppTextStyles.caption(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                icon: Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                ),
              ),
            ],
          ),
          if (_expanded) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            for (final MapEntry<PlanetScene, List<PlanetInterestGroup>> entry
                in planetInterestDetailsByScene.entries) ...<Widget>[
              Text(_sceneTitle(entry.key), style: AppTextStyles.bodyBold()),
              const SizedBox(height: AppSpacing.sm),
              for (final PlanetInterestGroup group in entry.value) ...<Widget>[
                Text(
                  group.title,
                  style: AppTextStyles.caption(color: scheme.primary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: group.items.map((String item) {
                    final bool selected = widget.selected.contains(item);
                    return FilterChip(
                      label: Text(item),
                      selected: selected,
                      onSelected: (bool value) {
                        final Set<String> next = Set<String>.from(
                          widget.selected,
                        );
                        if (value) {
                          next.add(item);
                        } else {
                          next.remove(item);
                        }
                        widget.onChanged(next);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          ],
        ],
      ),
    );
  }

  String _sceneTitle(PlanetScene scene) {
    switch (scene) {
      case PlanetScene.fishing:
        return '🎣 Рыбалка';
      case PlanetScene.travel:
        return '✈️ Путешествия';
      case PlanetScene.cinema:
        return '🎬 Фильмы и сериалы';
      case PlanetScene.books:
        return '📚 Книги';
      case PlanetScene.music:
        return '🎵 Музыка';
      case PlanetScene.sports:
        return '🏃 Спорт';
      case PlanetScene.reading:
        return '📖 Чтение';
      case PlanetScene.art:
        return '🎨 Искусство';
      case PlanetScene.technology:
        return '💻 Технологии';
      case PlanetScene.food:
        return '🍳 Еда и кулинария';
      case PlanetScene.nature:
        return '🌲 Природа';
      case PlanetScene.gaming:
        return '🎮 Игры';
      case PlanetScene.cars:
        return '🚗 Автомобили';
      case PlanetScene.animals:
        return '🐾 Животные';
      case PlanetScene.gardening:
        return '🌿 Садоводство и растения';
      case PlanetScene.esoteric:
        return '🔮 Эзотерика';
      case PlanetScene.finance:
        return '💰 Финансы';
      case PlanetScene.volunteering:
        return '🤝 Волонтёрство';
      case PlanetScene.psychology:
        return '🧠 Психология';
      case PlanetScene.other:
        return '🎭 Другое';
      case PlanetScene.selfDevelopment:
        return '🚀 Саморазвитие';
      case PlanetScene.collecting:
        return '🏺 Хобби и коллекционирование';
      case PlanetScene.space:
        return '🚀 Космос';
    }
  }
}
