import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

    return await _firestore.collection('subscriptions').add({
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
      'expiresAt': Timestamp.fromDate(
        DateTime.now().add(Duration(days: days)),
      ),
    });
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

  final subscriptionRef =
      _firestore.collection('subscriptions').doc(subscriptionId);

  await _firestore.runTransaction((transaction) async {
    final subscriptionDoc = await transaction.get(subscriptionRef);

    if (!subscriptionDoc.exists) {
      throw Exception('الاشتراك غير موجود');
    }

    final data = subscriptionDoc.data()!;
    final remainingWashes = data['remainingWashes'] ?? 0;

    if (remainingWashes <= 0) {
      throw Exception('لا توجد غسلات متبقية في هذه الباقة');
    }

    final bookingRef = _firestore.collection('bookings').doc();

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
      'carInfo': carInfo,
      'notes': notes,
      'addons': [],
      'paymentMethod': 'من الباقة',
      'servicePrice': 0,
      'addonsTotal': 0,
      'totalPrice': 0,
      'status': 'مؤكد',
      'createdAt': FieldValue.serverTimestamp(),
    });

    transaction.update(subscriptionRef, {
      'remainingWashes': remainingWashes - 1,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  });
}}