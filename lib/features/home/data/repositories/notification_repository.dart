import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/services/fcm_sender_service.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    String serviceTitle = '',
    String bookingId = '',
    String type = 'general',
  }) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'title': title,
      'body': body,
      'serviceTitle': serviceTitle,
      'bookingId': bookingId,
      'type': type,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data();

    final token = userData?['fcmToken'];

    if (token != null && token.toString().isNotEmpty) {
      await FcmSenderService.sendNotification(
        token: token,
        title: title,
        body: body,
        data: {
          'type': type,
          'bookingId': bookingId,
        },
      );
    }
  }

  Future<void> notifyNewBooking({
    required String userId,
    required String bookingId,
    required String serviceTitle,
  }) async {
    await createNotification(
      userId: userId,
      bookingId: bookingId,
      serviceTitle: serviceTitle,
      type: 'new_booking',
      title: 'حجز جديد 🚗',
      body: 'تم إنشاء حجز جديد لخدمة $serviceTitle',
    );
  }

  Future<void> notifyBookingAccepted({
    required String userId,
    required String bookingId,
    required String serviceTitle,
  }) async {
    await createNotification(
      userId: userId,
      bookingId: bookingId,
      serviceTitle: serviceTitle,
      type: 'booking_accepted',
      title: 'تم قبول الحجز ✅',
      body: 'تم قبول حجزك لخدمة $serviceTitle',
    );
  }

  Future<void> notifyWorkerOnWay({
    required String userId,
    required String bookingId,
    required String serviceTitle,
  }) async {
    await createNotification(
      userId: userId,
      bookingId: bookingId,
      serviceTitle: serviceTitle,
      type: 'worker_on_way',
      title: 'العامل في الطريق 🚘',
      body: 'العامل في الطريق لتنفيذ خدمة $serviceTitle',
    );
  }

  Future<void> notifyBookingCompleted({
    required String userId,
    required String bookingId,
    required String serviceTitle,
  }) async {
    await createNotification(
      userId: userId,
      bookingId: bookingId,
      serviceTitle: serviceTitle,
      type: 'booking_completed',
      title: 'تم إنهاء الغسيل 🎉',
      body: 'تم تنفيذ خدمة $serviceTitle بنجاح',
    );
  }

  Future<void> notifyTodayBooking({
    required String userId,
    required String bookingId,
    required String serviceTitle,
    required String time,
  }) async {
    await createNotification(
      userId: userId,
      bookingId: bookingId,
      serviceTitle: serviceTitle,
      type: 'today_booking',
      title: 'موعد الغسيل اليوم ⏰',
      body: 'لديك موعد اليوم لخدمة $serviceTitle الساعة $time',
    );
  }
}
