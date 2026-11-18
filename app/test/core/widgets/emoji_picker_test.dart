import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dreem_world/core/theme/index.dart';
import 'package:dreem_world/core/widgets/emoji_picker.dart';

void main() {
  group('insertEmoji', () {
    test('добавляет эмодзи в конец, когда курсор не задан', () {
      final TextEditingController controller = TextEditingController(
        text: 'Привет',
      );
      addTearDown(controller.dispose);

      insertEmoji(controller, '😀');

      expect(controller.text, 'Привет😀');
      expect(controller.selection.baseOffset, 'Привет😀'.length);
    });

    test('вставляет эмодзи в позицию курсора', () {
      final TextEditingController controller = TextEditingController(
        text: 'Привет мир',
      );
      addTearDown(controller.dispose);
      controller.selection = const TextSelection.collapsed(offset: 6);

      insertEmoji(controller, '🔥');

      expect(controller.text, 'Привет🔥 мир');
    });

    test('заменяет выделенный текст эмодзи', () {
      final TextEditingController controller = TextEditingController(
        text: 'Привет мир',
      );
      addTearDown(controller.dispose);
      controller.selection = const TextSelection(
        baseOffset: 7,
        extentOffset: 10,
      );

      insertEmoji(controller, '🙂');

      expect(controller.text, 'Привет 🙂');
    });
  });

  testWidgets('EmojiPicker показывает категории и отдаёт выбранный эмодзи', (
    WidgetTester tester,
  ) async {
    String? picked;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.of(AppThemeName.neonViolet),
        home: Scaffold(
          body: EmojiPicker(onSelected: (String emoji) => picked = emoji),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(Duration.zero);

    expect(find.byType(GridView), findsOneWidget);
    expect(find.text('😀'), findsOneWidget);

    await tester.tap(find.text('😀'));
    expect(picked, '😀');

    await tester.tap(find.byIcon(Icons.pets));
    await tester.pump();

    expect(find.text('🐶'), findsOneWidget);
    expect(find.text('😀'), findsNothing);
  });
}
