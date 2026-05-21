import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Shows local notifications during development (debug builds only).
///
/// In release builds every public method is a no-op so this service is
/// completely safe to call unconditionally.
class DevNotificationService {
  DevNotificationService._();

  static final DevNotificationService instance = DevNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'dev_otp_channel';
  static const _channelName = 'Dev OTP';

  /// Call once from main() before runApp().
  Future<void> init() async {
    if (!kDebugMode) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    // Android 13+ — request POST_NOTIFICATIONS at runtime.
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Shows a notification with the debug OTP.
  ///
  /// Silent no-op in release builds.
  Future<void> showOtp({
    required String otp,
    required String phone,
  }) async {
    if (!kDebugMode) return;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'OTP codes for local development',
      importance: Importance.max,
      priority: Priority.high,
      // Makes the OTP easy to copy from the notification shade.
      styleInformation: BigTextStyleInformation(''),
      ticker: 'OTP received',
    );

    const notifDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentSound: false,
      ),
    );

    await _plugin.show(
      0, // fixed ID — replaces any previous OTP notification
      '🔐 OTP for $phone',
      'Your OTP is:  $otp  (tap to copy)',
      notifDetails,
    );
  }
}
