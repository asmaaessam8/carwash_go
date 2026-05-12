import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'notification_repository.dart';

class PackageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int priceToInt(String price) {
    return int.tryParse(
          price
              .replaceAll('ريال', '')
              .replaceAll(',', '')
              .trim()
              .split('.')
              .first,
        ) ??
        0;
  }

  int washesCount(String title) {
    if (title.contains('12')) return 12;
    if (title.contains('6')) return 6;
    return 0;
  }

  int validDays(String title) {
    if (title.contains('12')) return 90;
    if (title.contains('6')) return 45;
    return 30;
  }

  Future<DocumentReference<Map<String, dynamic>>> subscribePackage({
    required String title,
    required String description,
    required String price,
    required String image,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }

    final totalWashes = washesCount(title);
    final days = validDays(title);

    final subscriptionRef = await _firestore.collection('subscriptions').add({
      'userId': user.uid,
      'userEmail': user.email,
      'packageTitle': title,
      'packageDescription': description,
      'packageImage': image,
      'price': priceToInt(price),
      'totalWashes': totalWashes,
      'remainingWashes': totalWashes,
      'validDays': days,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(DateTime.now().add(Duration(days: days))),
    });

    await NotificationRepository().notifyNewBooking(
      userId: user.uid,
      bookingId: subscriptionRef.id,
      serviceTitle: title,
    );

    await NotificationRepository().notifyAdminsNewBooking(
      serviceTitle: title,
      bookingId: subscriptionRef.id,
    );

    return subscriptionRef;
  }

  Future<void> bookWashFromPackage({
    required String subscriptionId,
    required String packageTitle,
    required String packageDescription,
    required String date,
    required String time,
    required String location,
    required String carInfo,
    required String notes,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }

    final subscriptionRef = _firestore
        .collection('subscriptions')
        .doc(subscriptionId);

    final bookingRef = _firestore.collection('bookings').doc();

    int remainingAfterBooking = 0;

    await _firestore.runTransaction((transaction) async {
      final subscriptionDoc = await transaction.get(subscriptionRef);

      if (!subscriptionDoc.exists) {
        throw Exception('الاشتراك غير موجود');
      }

      final data = subscriptionDoc.data()!;
      final remainingWashes = data['remainingWashes'] ?? 0;
      final status = data['status'] ?? 'active';

      if (status != 'active') {
        throw Exception('هذه الباقة منتهية');
      }

      if (remainingWashes <= 0) {
        throw Exception('لا توجد غسلات متبقية في هذه الباقة');
      }

      remainingAfterBooking = remainingWashes - 1;

      transaction.set(bookingRef, {
        'userId': user.uid,
        'userEmail': user.email,
        'type': 'packageBooking',
        'subscriptionId': subscriptionId,
        'serviceTitle': packageTitle,
        'serviceDescription': packageDescription,
        'date': date,
        'time': time,
        'location': location,
        'locationQuery': location,
        'locationMapUrl':
            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}',
        'carInfo': carInfo,
        'notes': notes,
        'addons': [],
        'paymentMethod': 'من الباقة',
        'paymentMethodName': 'من الباقة',
        'servicePrice': 0,
        'addonsTotal': 0,
        'totalPrice': 0,
        'status': 'مؤكد',
        'createdAt': FieldValue.serverTimestamp(),
      });

      transaction.update(subscriptionRef, {
        'remainingWashes': remainingAfterBooking,
        'status': remainingAfterBooking == 0 ? 'finished' : 'active',
        'updatedAt': FieldValue.serverTimestamp(),
        if (remainingAfterBooking == 0)
          'finishedAt': FieldValue.serverTimestamp(),
      });
    });

    await NotificationRepository().notifyNewBooking(
      userId: user.uid,
      bookingId: bookingRef.id,
      serviceTitle: packageTitle,
    );

    await NotificationRepository().notifyAdminsNewBooking(
      serviceTitle: packageTitle,
      bookingId: bookingRef.id,
    );

    if (remainingAfterBooking == 1) {
      await NotificationRepository().notifyPackageAlmostFinished(
        userId: user.uid,
        bookingId: bookingRef.id,
        packageTitle: packageTitle,
        remainingWashes: remainingAfterBooking,
      );
    }

    if (remainingAfterBooking == 0) {
      await NotificationRepository().notifyPackageFinished(
        userId: user.uid,
        bookingId: bookingRef.id,
        packageTitle: packageTitle,
      );
    }
  }
}
