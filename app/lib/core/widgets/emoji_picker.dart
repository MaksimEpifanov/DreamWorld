import 'package:flutter/material.dart';

import '../theme/index.dart';

/// Категория эмодзи для панели выбора.
class EmojiCategory {
  const EmojiCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.emojis,
  });

  final String id;
  final String label;
  final IconData icon;
  final List<String> emojis;
}

/// Вставляет эмодзи в поле ввода в позицию курсора.
void insertEmoji(TextEditingController controller, String emoji) {
  final TextEditingValue value = controller.value;
  final TextSelection selection = value.selection;
  final bool hasSelection = selection.isValid;
  final int start = hasSelection ? selection.start : value.text.length;
  final int end = hasSelection ? selection.end : value.text.length;
  final String text = value.text.replaceRange(start, end, emoji);
  controller.value = TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: start + emoji.length),
  );
}

/// Наборы эмодзи, доступные в чатах.
const List<EmojiCategory> kEmojiCategories = <EmojiCategory>[
  EmojiCategory(
    id: 'smileys',
    label: 'Смайлы',
    icon: Icons.emoji_emotions_outlined,
    emojis: <String>[
      '😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣',
      '😊', '😇', '🙂', '🙃', '😉', '😌', '😍', '🥰',
      '😘', '😗', '😙', '😚', '😋', '😛', '😝', '😜',
      '🤪', '🤨', '🧐', '🤓', '😎', '🥳', '😏', '😒',
      '😞', '😔', '😟', '😕', '🙁', '😣', '😖', '😫',
      '😩', '🥺', '😢', '😭', '😤', '😠', '😡', '🤬',
      '🤯', '😳', '🥵', '🥶', '😱', '😨', '😰', '😥',
      '😓', '🤗', '🤔', '🤭', '🤫', '🤥', '😶', '😐',
      '😑', '😬', '🙄', '😯', '😦', '😧', '😮', '😲',
      '🥱', '😴', '🤤', '😪', '😵', '🤐', '🥴', '🤢',
      '🤮', '🤧', '😷', '🤒', '🤕', '🤠', '🤡', '👻',
    ],
  ),
  EmojiCategory(
    id: 'gestures',
    label: 'Жесты',
    icon: Icons.waving_hand_outlined,
    emojis: <String>[
      '👍', '👎', '👌', '✌️', '🤞', '🤟', '🤘', '🤙',
      '👈', '👉', '👆', '👇', '☝️', '✋', '🤚', '🖐️',
      '🖖', '👋', '🤝', '🙏', '💪', '🦾', '✍️', '🤳',
      '💅', '👏', '🙌', '👐', '🤲', '🫶', '🤜', '🤛',
      '✊', '👊', '🫰', '🫵', '🫱', '🫲', '🤌', '🤏',
    ],
  ),
  EmojiCategory(
    id: 'hearts',
    label: 'Сердца',
    icon: Icons.favorite_border_rounded,
    emojis: <String>[
      '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍',
      '🤎', '💔', '❤️‍🔥', '❤️‍🩹', '💕', '💞', '💓', '💗',
      '💖', '💘', '💝', '💟', '♥️', '💌', '💋', '💯',
    ],
  ),
  EmojiCategory(
    id: 'animals',
    label: 'Животные',
    icon: Icons.pets,
    emojis: <String>[
      '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼',
      '🐨', '🐯', '🦁', '🐮', '🐷', '🐸', '🐵', '🙈',
      '🙉', '🙊', '🐔', '🐧', '🐦', '🐤', '🦆', '🦅',
      '🦉', '🦇', '🐺', '🐗', '🐴', '🦄', '🐝', '🐛',
      '🦋', '🐌', '🐞', '🐜', '🐢', '🐍', '🦎', '🐙',
      '🦑', '🦀', '🐠', '🐟', '🐬', '🐳', '🐋', '🦈',
    ],
  ),
  EmojiCategory(
    id: 'food',
    label: 'Еда',
    icon: Icons.fastfood_rounded,
    emojis: <String>[
      '🍏', '🍎', '🍐', '🍊', '🍋', '🍌', '🍉', '🍇',
      '🍓', '🫐', '🍈', '🍒', '🍑', '🥭', '🍍', '🥥',
      '🥝', '🍅', '🥑', '🥦', '🥕', '🌽', '🌶️', '🥒',
      '🥬', '🍄', '🥜', '🍞', '🥐', '🥖', '🧀', '🥚',
      '🍳', '🥞', '🥓', '🍔', '🍟', '🍕', '🌭', '🥪',
      '🌮', '🌯', '🥗', '🍝', '🍜', '🍲', '🍣', '🍱',
      '🍤', '🍙', '🍚', '🍦', '🍰', '🎂', '🍮', '🍭',
      '🍬', '🍫', '🍩', '🍪', '☕', '🍵', '🧃', '🥤',
      '🍺', '🍻', '🥂', '🍷', '🥃', '🍸', '🍹', '🧉',
    ],
  ),
  EmojiCategory(
    id: 'activity',
    label: 'Активности',
    icon: Icons.sports_soccer_rounded,
    emojis: <String>[
      '⚽', '🏀', '🏈', '⚾', '🥎', '🎾', '🏐', '🏉',
      '🥏', '🎱', '🏓', '🏸', '🏒', '🏑', '🥍', '🏏',
      '🥅', '⛳', '🏹', '🎣', '🥊', '🥋', '🛹', '🛼',
      '🛷', '⛸️', '🥌', '🎿', '⛷️', '🏂', '🏋️', '🤸',
      '⛹️', '🤺', '🤾', '🏌️', '🏇', '🧘', '🏄', '🏊',
      '🚣', '🧗', '🚵', '🚴', '🏆', '🥇', '🥈', '🥉',
      '🏅', '🎖️', '🎫', '🎪', '🤹', '🎭', '🎨', '🎬',
      '🎤', '🎧', '🎼', '🎹', '🥁', '🎷', '🎺', '🎸',
      '🎻', '🎲', '🎯', '🎳', '🎮', '🧩',
    ],
  ),
  EmojiCategory(
    id: 'nature',
    label: 'Природа',
    icon: Icons.park_rounded,
    emojis: <String>[
      '🌟', '✨', '⚡', '🔥', '💥', '💫', '🌈', '☀️',
      '🌤️', '⛅', '🌦️', '🌧️', '⛈️', '🌩️', '🌨️', '❄️',
      '☃️', '⛄', '🌬️', '💨', '🌪️', '🌫️', '🌊', '💧',
      '💦', '☔', '🌙', '🌛', '🌜', '🌚', '🌝', '🌞',
      '🪐', '🌍', '🌎', '🌏', '🌋', '🗻', '🏔️', '⛰️',
      '🏕️', '🏖️', '🏜️', '🏝️', '🏞️', '🌵', '🌲', '🌳',
      '🌴', '🌱', '🌿', '☘️', '🍀', '🍁', '🍂', '🍃',
      '🌸', '🌼', '🌻', '🌺', '🌹', '🥀', '💐', '🌷',
    ],
  ),
  EmojiCategory(
    id: 'travel',
    label: 'Транспорт',
    icon: Icons.directions_car_rounded,
    emojis: <String>[
      '🚗', '🚕', '🚙', '🚌', '🚎', '🏎️', '🚓', '🚑',
      '🚒', '🚐', '🛻', '🚚', '🚛', '🚜', '🛵', '🏍️',
      '🛺', '🚲', '🛴', '🚨', '🚔', '🚍', '🚘', '🚖',
      '🚡', '🚠', '🚟', '🚃', '🚋', '🚞', '🚝', '🚄',
      '🚅', '🚈', '🚂', '🚆', '🚇', '🚊', '🚉', '✈️',
      '🛫', '🛬', '🛩️', '💺', '🛰️', '🚀', '🛸', '🚁',
      '🛶', '⛵', '🚤', '🛥️', '🛳️', '⛴️', '🚢', '⚓',
      '⛽', '🚧', '🚦', '🚥', '🗺️', '🗿', '🗽', '🗼',
      '🏰', '🏯', '🏟️', '🎡', '🎢', '🎠', '⛲', '⛱️',
    ],
  ),
];

/// Панель выбора эмодзи для поля ввода в чатах.
///
/// Сверху — переключатель категорий, ниже — сетка смайликов. Выбор эмодзи
/// отдаётся наружу через [onSelected].
class EmojiPicker extends StatefulWidget {
  const EmojiPicker({super.key, required this.onSelected, this.height = 244});

  final ValueChanged<String> onSelected;
  final double height;

  @override
  State<EmojiPicker> createState() => _EmojiPickerState();
}

class _EmojiPickerState extends State<EmojiPicker> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    final EmojiCategory category = kEmojiCategories[_index];

    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        border: Border(
          top: BorderSide(color: primary.withValues(alpha: 0.35)),
        ),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              itemCount: kEmojiCategories.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(width: AppSpacing.xs),
              itemBuilder: (BuildContext context, int index) {
                final EmojiCategory item = kEmojiCategories[index];
                final bool selected = index == _index;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _index = index),
                  child: Tooltip(
                    message: item.label,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? primary.withValues(alpha: 0.22)
                            : Colors.transparent,
                        borderRadius: AppRadius.pillAll,
                        border: Border.all(
                          color: primary.withValues(
                            alpha: selected ? 0.6 : 0.2,
                          ),
                        ),
                      ),
                      child: Icon(
                        item.icon,
                        size: 20,
                        color: selected ? primary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 46,
                mainAxisSpacing: AppSpacing.xs,
                crossAxisSpacing: AppSpacing.xs,
              ),
              itemCount: category.emojis.length,
              itemBuilder: (BuildContext context, int index) {
                final String emoji = category.emojis[index];
                return InkWell(
                  borderRadius: AppRadius.smAll,
                  onTap: () => widget.onSelected(emoji),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
