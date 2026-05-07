import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';

class FcmSenderService {
  static const String _projectId = 'carwash-go-a8adc';

  static Future<void> sendNotification({
    required String token,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
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
          'token': token,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': data ?? {},
        },
      }),
    );

    client.close();

    if (response.statusCode != 200) {
      throw Exception('FCM Send Error: ${response.body}');
    }
  }
}