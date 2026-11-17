import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dreem_world/core/widgets/index.dart';

void main() {
  testWidgets('CompatibilityRing перестраивается при смене процента', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: CompatibilityRing(percent: 0.2)),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: CompatibilityRing(percent: 0.8)),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 900));

    expect(tester.takeException(), isNull);
    expect(find.byType(CompatibilityRing), findsOneWidget);
    expect(find.text('80%'), findsOneWidget);
  });
}
