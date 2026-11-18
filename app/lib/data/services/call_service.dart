import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Звонки (аудио и видео).
abstract interface class CallService {
  /// Ссылка-приглашение в комнату [room].
  String roomUrl(String room);

  /// Открывает звонок в комнате [room].
  ///
  /// [video] = `false` — аудиозвонок. Возвращает `true`, если звонок открыт.
  Future<bool> startCall({
    required String room,
    required String displayName,
    bool video = true,
  });
}

/// Звонки через Jitsi Meet (`meet.jit.si`).
///
/// Бесплатно, без ключей и своего сервера. На веб звонок открывается в новой
/// вкладке, на Android/iOS — в браузере или приложении Jitsi. Встроенный экран
/// звонка (нативный SDK) — отдельный следующий шаг.
class JitsiCallService implements CallService {
  const JitsiCallService({this.serverUrl = defaultServerUrl});

  /// Публичный сервер Jitsi Meet.
  static const String defaultServerUrl = 'https://meet.jit.si';

  final String serverUrl;

  @override
  String roomUrl(String room) => '$serverUrl/$room';

  @override
  Future<bool> startCall({
    required String room,
    required String displayName,
    bool video = true,
  }) async {
    final Uri uri = Uri.parse(
      '$serverUrl/$room'
      '#userInfo.displayName=${Uri.encodeComponent('"$displayName"')}'
      '&config.startWithVideoMuted=${!video}',
    );
    if (kIsWeb) {
      return launchUrl(uri, webOnlyWindowName: '_blank');
    }
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
