import 'package:dreem_world/data/services/call_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JitsiCallService', () {
    test('roomUrl собирает ссылку на комнату', () {
      const JitsiCallService service = JitsiCallService();

      expect(
        service.roomUrl('DreamWorld-c_anna'),
        'https://meet.jit.si/DreamWorld-c_anna',
      );
    });

    test('поддерживает собственный сервер', () {
      const JitsiCallService service = JitsiCallService(
        serverUrl: 'https://meet.example.org',
      );

      expect(service.roomUrl('room1'), 'https://meet.example.org/room1');
    });
  });
}
