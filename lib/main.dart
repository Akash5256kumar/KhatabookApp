import 'dart:async';
import 'dart:ui';

import 'package:apna_business_app/app/app.dart';
import 'package:apna_business_app/core/services/dev_notification_service.dart';
import 'package:apna_business_app/core/utils/logger.dart';
import 'package:apna_business_app/injection/injection_container.dart';
import 'package:flutter/material.dart';

/// Application entrypoint.
void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await configureDependencies();
      await DevNotificationService.instance.init();

      FlutterError.onError = (FlutterErrorDetails details) {
        logger.error(
          details.exception,
          message: 'Unhandled Flutter framework error',
          stackTrace: details.stack,
        );
      };

      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        logger.error(
          error,
          message: 'Unhandled platform error',
          stackTrace: stack,
        );
        return true;
      };

      runApp(const App());
    },
    (Object error, StackTrace stack) {
      logger.error(
        error,
        message: 'Unhandled async error',
        stackTrace: stack,
      );
    },
  );
}
