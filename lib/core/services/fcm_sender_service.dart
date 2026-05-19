import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';

class FcmSenderService {
  static const String _projectId = 'carwash-go-a8adc';

  static Future<void> sendNotification({
    required String token,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    if (token.trim().isEmpty) {
      debugPrint('FCM TOKEN EMPTY');
      return;
    }

    final serviceAccountJson = await rootBundle.loadString(
      'assets/keys/service_account.json',
    );

    final credentials = ServiceAccountCredentials.fromJson(
      jsonDecode(serviceAccountJson),
    );

    final scopes = [
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    final client = await clientViaServiceAccount(credentials, scopes);

    final url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send',
    );

    final response = await client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'message': {
          'token': token.trim(),
          'notification': {
            'title': title,
            'body': body,
          },
          'data': data ?? {},
          'android': {
            'priority': 'high',
            'notification': {
              'sound': 'default',
              'channel_id': 'carwash_high_channel_4',
            },
          },
        },
      }),
    );

    debugPrint('FCM RESPONSE CODE: ${response.statusCode}');
    debugPrint('FCM RESPONSE BODY: ${response.body}');

    client.close();

    if (response.statusCode != 200) {
      throw Exception('FCM Send Error: ${response.body}');
    }
  }
}