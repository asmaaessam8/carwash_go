import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchAcceptedBookings() {
    return _firestore
        .collection('bookings')
        .where('status', isEqualTo: 'مقبول')
        .snapshots();
  }

  Future<void> markAsCompleted(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': 'مكتمل',
      'completedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}