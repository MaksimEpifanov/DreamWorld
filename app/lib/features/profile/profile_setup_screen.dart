import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/planet_interest_details.dart';
import '../../core/theme/index.dart';
import '../../core/utils/image_utils.dart';
import '../../core/widgets/index.dart';
import '../../data/models/index.dart';
import '../../data/providers/app_providers.dart';
import 'widgets/photo_picker.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
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
    'Рыбалка',
    'Автомобили',
    'Животные',
    'Садоводство',
    'Эзотерика',
    'Финансы',
    'Волонтёрство',
    'Психология',
    'Саморазвитие',
    'Хобби и коллекционирование',
    'Космос',
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

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  /// Подставляет данные уже существующей анкеты (например, имя из аккаунта),
  /// чтобы пользователю не пришлось вводить всё заново.
  Future<void> _loadExisting() async {
    final Profile? profile = await ref
        .read(profileRepositoryProvider)
        .getCurrentProfile();
    if (!mounted || profile == null) return;
    setState(() {
      if (profile.name.trim().isNotEmpty && _nameController.text.isEmpty) {
        _nameController.text = profile.name;
      }
      if (profile.age > 0 && _ageController.text.isEmpty) {
        _ageController.text = profile.age.toString();
      }
      if ((profile.city ?? '').isNotEmpty && _cityController.text.isEmpty) {
        _cityController.text = profile.city!;
      }
      if ((profile.bio ?? '').isNotEmpty && _bioController.text.isEmpty) {
        _bioController.text = profile.bio!;
      }
      _photoDataUri ??= profile.photoUrl;
      _relationshipGoal = profile.relationshipGoal;
      _selectedGoals.addAll(profile.goals);
      _selectedValues.addAll(profile.values);
      for (final Interest interest in profile.interests) {
        if (interest.name.isNotEmpty) {
          _selectedInterests.add(interest.name);
        }
      }
      _selectedDetailedInterests.addAll(profile.detailedInterests);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  /// Отказ от заполнения анкеты: запоминаем локально, чтобы не спрашивать снова.
  Future<void> _skip() async {
    final String uid = ref.read(currentUserIdProvider);
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(profileSetupDismissedKey(uid), true);
    } catch (_) {
      // Локальное хранилище недоступно — просто продолжаем.
    }
    ref.invalidate(hasSavedProfileProvider);
    if (mounted) context.go('/main');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);

    final profileRepo = ref.read(profileRepositoryProvider);
    final currentUserId = ref.read(currentUserIdProvider);
    final Profile? existing = await profileRepo.getCurrentProfile();

    final Profile newProfile =
        (existing ?? Profile(id: currentUserId, name: '', age: 18)).copyWith(
          id: currentUserId,
          name: _nameController.text.trim(),
          age: int.tryParse(_ageController.text.trim()) ?? 18,
          city: _cityController.text.trim(),
          country: 'Россия',
          bio: _bioController.text.trim(),
          photoUrl: remoteImageUrlOrNull(existing?.photoUrl),
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
                return Interest(
                  id: s.replaceAll(RegExp(r'\s+'), '_').toLowerCase(),
                  name: s,
                  category: InterestCategory.other,
                );
            }
          }).toList(),
          goals: _selectedGoals.toList(),
          values: _selectedValues.toList(),
          languages: const <String>['ru'],
          relationshipGoal: _relationshipGoal,
          detailedInterests: _selectedDetailedInterests.toList(),
        );

    try {
      await profileRepo.saveProfile(newProfile);
      if (_photoDataUri != null) {
        await saveMainProfilePhoto(ref, _photoDataUri!);
      }
      ref.invalidate(currentProfileProvider);
      ref.invalidate(hasSavedProfileProvider);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Не удалось сохранить профиль. Проверьте интернет и попробуйте ещё раз.',
            ),
          ),
        );
      return;
    }

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(profileSetupDismissedKey(currentUserId));
    } catch (_) {
      // Локальное хранилище недоступно — не критично.
    }

    ref.invalidate(hasSavedProfileProvider);
    if (mounted) {
      context.go('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание профиля'),
        actions: <Widget>[
          TextButton(
            onPressed: _isSaving ? null : _skip,
            child: const Text('Пропустить'),
          ),
        ],
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
                  const SizedBox(height: AppSpacing.sm),
                  PhotoPicker(
                    photoDataUri: _photoDataUri,
                    onPicked: (String uri) {
                      setState(() => _photoDataUri = uri);
                    },
                    height: 220,
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
                  _DetailedInterestsSelector(
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
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
        ),
      ),
      // Кнопка сохранения закреплена внизу экрана: при низком окне браузера
      // она больше не «уезжает» за пределы видимой области длинной формы.
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: AppSpacing.page,
          child: Align(
            heightFactor: 1,
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: ResponsiveContent.kResponsiveMaxWidth,
              ),
              child: NeonButton(
                onPressed: _isSaving ? null : _save,
                label: _isSaving
                    ? 'Сохранение...'
                    : 'Сохранить и продолжить',
                isLoading: _isSaving,
                expanded: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailedInterestsSelector extends StatefulWidget {
  const _DetailedInterestsSelector({
    required this.selected,
    required this.onChanged,
  });

  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  @override
  State<_DetailedInterestsSelector> createState() =>
      _DetailedInterestsSelectorState();
}

class _DetailedInterestsSelectorState
    extends State<_DetailedInterestsSelector> {
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
