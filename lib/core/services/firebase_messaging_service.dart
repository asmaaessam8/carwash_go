import 'dart:html' as html;

import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await _messaging.requestPermission();

    if (html.Notification.permission != 'granted') {
      await html.Notification.requestPermission();
    }

    final token = await _messaging.getToken(
      vapidKey: 'BMSTGmqKa1wvMKkId6bGKtR5RGRgKvLy0IlIm-NrGIpTG2uiL7RXpXlJP1FinO73AaAQ3rDgwioFbtt8USy6RBU',
    );

    print('FCM TOKEN: $token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? 'تنبيه جديد';
      final body = message.notification?.body ?? '';

      print('Foreground message received');
      print('Notification Title: $title');
      print('Notification Body: $body');

      if (html.Notification.permission == 'granted') {
        html.Notification(
          title,
          body: body,
          icon: 'icons/Icon-192.png',
        );
      }
    });
  }
}