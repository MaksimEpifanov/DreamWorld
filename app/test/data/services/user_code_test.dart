import 'package:dreem_world/data/services/user_code.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserCode', () {
    test('код постоянный и имеет формат DW-XXXX-XXXX', () {
      final String code = UserCode.fromUserId('abc123');

      expect(UserCode.fromUserId('abc123'), code);
      expect(code.startsWith(UserCode.prefix), isTrue);
      expect(
        RegExp(r'^DW-[2-9A-HJ-NP-Z]{4}-[2-9A-HJ-NP-Z]{4}$').hasMatch(code),
        isTrue,
      );
      expect(UserCode.isComplete(code), isTrue);
    });

    test('распознаёт код, введённый с пробелами и в нижнем регистре', () {
      final String code = UserCode.fromUserId('p_anna');
      final String sloppy = code.toLowerCase().replaceAll('-', ' ');

      expect(UserCode.normalize(sloppy), UserCode.normalize(code));
      expect(UserCode.matches('p_anna', sloppy), isTrue);
      expect(UserCode.matches('p_anna', 'DW-0000-0000'), isFalse);
    });

    test('разные пользователи получают разные коды', () {
      final List<String> ids = <String>[
        'me',
        'p_anna',
        'p_leo',
        'p_sofia',
        'p_mia',
        'p_dmitri',
        'u1',
        'u2',
      ];
      final Set<String> codes = ids.map(UserCode.fromUserId).toSet();

      expect(codes, hasLength(ids.length));
    });

    test('неполный код не считается готовым к поиску', () {
      expect(UserCode.isComplete(''), isFalse);
      expect(UserCode.isComplete('DW-7K4'), isFalse);
      expect(UserCode.normalize('dw-7k4m-2qxv').length, UserCode.length);
    });
  });
}
