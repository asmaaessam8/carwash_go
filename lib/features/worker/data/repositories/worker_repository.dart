import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchWorkerBookings() {
    return _firestore
        .collection('bookings')
        .where(
          'status',
          whereIn: ['مقبول', 'طلب مقبول', 'قيد الغسيل', 'قيد التنفيذ'],
        )
        .snapshots();
  }

  Future<void> markAsInProgress(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': 'قيد الغسيل',
      'startedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markAsCompleted(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': 'مكتمل',
      'completedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
