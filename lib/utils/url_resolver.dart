import 'dart:io';
import 'package:flutter/foundation.dart';

class UrlResolver {
  static final Map<String, String> _cache = {};

  /// Tự động chuyển đổi `localhost` hoặc `127.0.0.1` sang `10.0.2.2` nếu chạy trên Android Emulator.
  /// Nếu chạy trên máy thật, giữ nguyên `localhost`/`127.0.0.1` (phục vụ cho `adb reverse`).
  static Future<String> resolve(String rawUrl, {int defaultPort = 5000}) async {
    if (_cache.containsKey(rawUrl)) {
      return _cache[rawUrl]!;
    }

    String envUrl = rawUrl;
    if (envUrl.endsWith('/')) {
      envUrl = envUrl.substring(0, envUrl.length - 1);
    }

    if (!kIsWeb &&
        Platform.isAndroid &&
        (envUrl.contains('localhost') || envUrl.contains('127.0.0.1'))) {
      try {
        final uri = Uri.parse(envUrl);
        final port = uri.hasPort ? uri.port : defaultPort;

        // Thử kết nối nhanh tới 10.0.2.2 (máy ảo Android). Dùng timeout rất ngắn (200ms) để không bị nghẽn trên máy thật.
        final socket = await Socket.connect(
          '10.0.2.2',
          port,
        ).timeout(const Duration(milliseconds: 200));
        socket.destroy();

        // Nếu thành công -> Đang dùng máy ảo (Emulator)
        final resolved = envUrl
            .replaceAll('localhost', '10.0.2.2')
            .replaceAll('127.0.0.1', '10.0.2.2');
        _cache[rawUrl] = resolved;
        return resolved;
      } catch (_) {
        // Nếu thất bại hoặc quá thời gian -> Đang dùng máy thật (sử dụng 127.0.0.1 để tránh lỗi phân giải IPv6 ::1 trên Android)
        final resolved = envUrl.replaceAll('localhost', '127.0.0.1');
        _cache[rawUrl] = resolved;
        return resolved;
      }
    } else {
      _cache[rawUrl] = envUrl;
      return envUrl;
    }
  }
}
