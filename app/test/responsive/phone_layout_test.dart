import 'dart:convert';
import 'dart:io';

import 'package:dreem_world/app.dart';
import 'package:dreem_world/data/models/app_user.dart';
import 'package:dreem_world/data/models/profile.dart';
import 'package:dreem_world/data/repositories/mock_profile_repository.dart';
import 'package:dreem_world/data/services/mock_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Аудит адаптивности: каждый маршрут на типичных размерах смартфонов.
void main() {
  setUpAll(() async {
    final File font = File('test/fonts/Roboto-Regular.ttf');
    if (!font.existsSync()) return;
    final FontLoader loader = FontLoader('Roboto')
      ..addFont(
        Future<ByteData>.value(ByteData.view(font.readAsBytesSync().buffer)),
      );
    await loader.load();
  });

  const Map<String, Size> phones = <String, Size>{
    'SE1': Size(320, 568),
    'android': Size(360, 640),
    'iphone14': Size(390, 844),
    'android landscape': Size(640, 360),
    'iphone14 landscape': Size(844, 390),
  };

  const List<String> routes = <String>[
    '/onboarding',
    '/login',
    '/register',
    '/profile-setup',
    '/main',
    '/main/planets',
    '/main/other-interests',
    '/main/planet/p_animals',
    '/main/planet/p_animals/map',
    '/main/planet/p_animals/news',
    '/discovery',
    '/chats',
    '/contacts',
    '/contacts/my-qr',
    '/contacts/scan',
    '/profile',
    '/notifications',
    '/settings',
    '/safety',
    '/minigames',
    '/minigames/quiz',
    '/minigames/match3',
    '/minigames/memory',
    '/match',
  ];

  phones.forEach((String phone, Size size) {
    for (final String route in routes) {
      testWidgets('$phone $route', (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        const AppUser user = AppUser(
          id: 'u1',
          email: 'user@example.com',
          name: 'Иван',
        );
        final Profile profile = Profile(
          id: 'u1',
          name: 'Иван',
          age: 25,
          city: 'Москва',
        );
        SharedPreferences.setMockInitialValues(<String, Object>{
          MockAuthService.currentSessionKey: jsonEncode(user.toJson()),
          MockProfileRepository.savedProfileKey: jsonEncode(profile.toJson()),
        });

        await tester.pumpWidget(const ProviderScope(child: DreemWorldApp()));
        await tester.pump(const Duration(milliseconds: 500));

        while (tester.takeException() != null) {}

        final MaterialApp app = tester.widget<MaterialApp>(
          find.byType(MaterialApp),
        );
        final GoRouter router = app.routerConfig! as GoRouter;

        router.go(route);

        final List<String> problems = <String>[];
        final void Function(FlutterErrorDetails)? previousOnError =
            FlutterError.onError;
        FlutterError.onError = (FlutterErrorDetails details) {
          problems.add(details.toString());
        };
        for (int i = 0; i < 15; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        FlutterError.onError = previousOnError;

        for (int i = 0; i < 3; i++) {
          await tester.pump(const Duration(milliseconds: 100));
          tester.takeException();
        }
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 500));
        tester.takeException();

        final List<String> brief = problems.map((String details) {
          final RegExp overflow = RegExp(r'RenderFlex overflowed by [^\n]+');
          final RegExpMatch? amount = overflow.firstMatch(details);
          final RegExp source = RegExp(
            r'(?:\n\s+)([A-Za-z]+):file:///[^\s]+\.dart:\d+',
          );
          final RegExpMatch? place = source.firstMatch(details);
          final String first = details.split('\n').first;
          return <String>[
            if (amount != null) amount.group(0)! else first,
            if (place != null) place.group(0)!.trim(),
          ].join(' | ');
        }).toList();

        expect(brief, isEmpty, reason: '$route:\n${brief.join('\n')}');
      });
    }
  });
}
