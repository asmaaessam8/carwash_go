import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../home/data/repositories/notification_repository.dart';

class AdminBookingsPage extends StatelessWidget {
  const AdminBookingsPage({super.key});

  Future<void> _updateStatus(
    BuildContext context,
    String bookingId,
    String status,
    Map<String, dynamic> data,
  ) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final userId = data['userId'];
    final serviceTitle = data['serviceTitle'] ?? 'خدمة';

    if (userId != null && userId.toString().isNotEmpty) {
      if (status == 'مقبول') {
        await NotificationRepository().notifyBookingAccepted(
          userId: userId,
          bookingId: bookingId,
          serviceTitle: serviceTitle,
        );
      } else if (status == 'مرفوض') {
        await NotificationRepository().createNotification(
          userId: userId,
          bookingId: bookingId,
          serviceTitle: serviceTitle,
          type: 'booking_rejected',
          title: 'تم رفض الحجز ❌',
          body: 'تم رفض حجزك لخدمة $serviceTitle',
        );
      }
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم تحديث حالة الحجز إلى $status')),
    );
  }

  Color _statusColor(String status) {
    if (status == 'مقبول') return const Color(0xFF12C96F);
    if (status == 'مرفوض') return Colors.red;
    if (status == 'مكتمل') return Colors.green;
    if (status == 'ملغي') return Colors.red;
    return const Color(0xFF1670FF);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('إدارة الحجوزات'),
        backgroundColor: const Color(0xFF1670FF),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد حجوزات حالياً',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF5F677B),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(18),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              final serviceTitle = data['serviceTitle'] ?? 'خدمة';
              final userEmail = data['userEmail'] ?? 'غير معروف';
              final date = data['date'] ?? '';
              final time = data['time'] ?? '';
              final location = data['location'] ?? '';
              final carInfo = data['carInfo'] ?? '';
              final status = data['status'] ?? 'مؤكد';
              final totalPrice = data['totalPrice'] ?? 0;
              final addons = List<String>.from(data['addons'] ?? []);

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE8EDFF)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9DB5FF).withOpacity(0.10),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(status).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: _statusColor(status),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          serviceTitle,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF151B4A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _info('المستخدم', userEmail),
                    _info('التاريخ', date),
                    _info('الوقت', time),
                    _info('الموقع', location),
                    _info('السيارة', carInfo),
                    _info('الإجمالي', '$totalPrice ريال'),
                    if (addons.isNotEmpty)
                      _info('الإضافات', addons.join('، ')),
                    const SizedBox(height: 16),
                    if (status == 'مؤكد') ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _updateStatus(
                                  context,
                                  doc.id,
                                  'مقبول',
                                  data,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF12C96F),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('قبول'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _updateStatus(
                                  context,
                                  doc.id,
                                  'مرفوض',
                                  data,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('رفض'),
                            ),
                          ),
                        ],
                      ),
                    ] else if (status == 'مقبول') ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8FFF2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          'تم قبول الطلب، وسيظهر الآن في صفحة العامل',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF12A15D),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ] else if (status == 'مكتمل') ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8FFF2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          'تم تنفيذ الحجز بنجاح',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFECEC),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          status == 'مرفوض'
                              ? 'تم رفض هذا الطلب'
                              : 'هذا الطلب غير نشط',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF151B4A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF5F677B),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}