import 'dart:io';

import 'package:flutter/foundation.dart';

/// Custom HTTP overrides to allow self-signed certificates in debug mode.
///
/// In production builds, this falls back to the default behavior.
class AppHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    if (kDebugMode) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    }
    return client;
  }
}
