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
      try {
        await FcmSenderService.sendNotification(
          token: token.toString(),
          title: title,
          body: body,
          data: {'type': type, 'bookingId': bookingId, 'targetUserId': userId},
        );
      } catch (e) {
        if (e.toString().contains('UNREGISTERED') ||
            e.toString().contains('Requested entity was not found')) {
          await _firestore.collection('users').doc(userId).update({
            'fcmToken': FieldValue.delete(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
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

  Future<void> notifyBookingRejected({
    required String userId,
    required String bookingId,
    required String serviceTitle,
  }) async {
    await createNotification(
      userId: userId,
      bookingId: bookingId,
      serviceTitle: serviceTitle,
      type: 'booking_rejected',
      title: 'تم رفض الحجز ❌',
      body: 'تم رفض حجزك لخدمة $serviceTitle',
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

  Future<void> notifyWorkerStarted({
    required String userId,
    required String bookingId,
    required String serviceTitle,
  }) async {
    await createNotification(
      userId: userId,
      bookingId: bookingId,
      serviceTitle: serviceTitle,
      type: 'worker_started',
      title: 'بدأ الغسيل 🚘',
      body: 'بدأ العامل الآن بتنظيف سيارتك',
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

  Future<void> notifyAdminsNewBooking({
    required String serviceTitle,
    required String bookingId,
  }) async {
    final admins =
        await _firestore
            .collection('users')
            .where('role', isEqualTo: 'admin')
            .get();

    for (final admin in admins.docs) {
      await createNotification(
        userId: admin.id,
        bookingId: bookingId,
        serviceTitle: serviceTitle,
        type: 'admin_new_booking',
        title: 'طلب جديد 🚗',
        body: 'تم إنشاء حجز جديد لخدمة $serviceTitle',
      );
    }
  }

  Future<void> notifyWorkerNewOrder({
    required String workerId,
    required String serviceTitle,
    required String bookingId,
  }) async {
    await createNotification(
      userId: workerId,
      bookingId: bookingId,
      serviceTitle: serviceTitle,
      type: 'worker_order',
      title: 'طلب جديد لك 🚗',
      body: 'تم تعيين طلب جديد لخدمة $serviceTitle',
    );
  }

  Future<void> notifyPackageAlmostFinished({
    required String userId,
    required String bookingId,
    required String packageTitle,
    required int remainingWashes,
  }) async {
    await createNotification(
      userId: userId,
      bookingId: bookingId,
      serviceTitle: packageTitle,
      type: 'package_almost_finished',
      title: 'تنبيه الباقة ⚠️',
      body: 'باقي لك $remainingWashes غسلة في باقة $packageTitle',
    );
  }

  Future<void> notifyPackageFinished({
    required String userId,
    required String bookingId,
    required String packageTitle,
  }) async {
    await createNotification(
      userId: userId,
      bookingId: bookingId,
      serviceTitle: packageTitle,
      type: 'package_finished',
      title: 'انتهت الباقة 🚗',
      body: 'انتهت غسلات باقة $packageTitle',
    );
  }
}
