import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'local_notification_service.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _messaging.getToken();

    debugPrint('FCM TOKEN: $token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final title =
          message.notification?.title ??
          message.data['title'] ??
          'تنبيه جديد';

      final body =
          message.notification?.body ??
          message.data['body'] ??
          '';

      if (title.toString().trim().isEmpty &&
          body.toString().trim().isEmpty) {
        return;
      }

      await LocalNotificationService.showNotification(
        title: title.toString(),
        body: body.toString(),
      );
    });
  }
}