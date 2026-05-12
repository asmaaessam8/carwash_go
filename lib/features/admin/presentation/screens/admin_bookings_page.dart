import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../home/data/repositories/notification_repository.dart';

class AdminBookingsPage extends StatelessWidget {
  const AdminBookingsPage({super.key});

  Future<void> _openMap(BuildContext context, Map<String, dynamic> data) async {
    final mapUrl = data['locationMapUrl']?.toString() ?? '';
    final location = data['location']?.toString() ?? '';

    if (mapUrl.isEmpty && location.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('لا يوجد موقع لهذا الحجز')));
      return;
    }

    final url = Uri.parse(
      mapUrl.isNotEmpty
          ? mapUrl
          : 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}',
    );

    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);

    if (!opened) {
      await launchUrl(url, mode: LaunchMode.platformDefault);
    }
  }

  Future<String?> _getWorkerId() async {
    final workers =
        await FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'worker')
            .limit(1)
            .get();

    if (workers.docs.isEmpty) return null;

    return workers.docs.first.id;
  }

  Future<void> _acceptBooking(
    BuildContext context,
    String bookingId,
    Map<String, dynamic> data,
  ) async {
    final userId = data['userId']?.toString() ?? '';
    final serviceTitle = data['serviceTitle']?.toString() ?? 'خدمة';

    final workerId = await _getWorkerId();

    if (workerId == null) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('لا يوجد عامل متاح حالياً')));
      return;
    }

    await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
      'status': 'مقبول',
      'workerId': workerId,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (userId.isNotEmpty) {
      await NotificationRepository().notifyBookingAccepted(
        userId: userId,
        bookingId: bookingId,
        serviceTitle: serviceTitle,
      );
    }

    await NotificationRepository().notifyWorkerNewOrder(
      workerId: workerId,
      bookingId: bookingId,
      serviceTitle: serviceTitle,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم قبول الحجز وإرساله للعامل')),
    );
  }

  Future<void> _rejectBooking(
    BuildContext context,
    String bookingId,
    Map<String, dynamic> data,
  ) async {
    final userId = data['userId']?.toString() ?? '';
    final serviceTitle = data['serviceTitle']?.toString() ?? 'خدمة';

    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .update({'status': 'مرفوض', 'updatedAt': FieldValue.serverTimestamp()});

    if (userId.isNotEmpty) {
      await NotificationRepository().notifyBookingRejected(
        userId: userId,
        bookingId: bookingId,
        serviceTitle: serviceTitle,
      );
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم رفض الحجز')));
  }

  Color _statusColor(String status) {
    if (status == 'مؤكد') return const Color(0xFF1670FF);
    if (status == 'مقبول' || status == 'طلب مقبول') {
      return const Color(0xFF12C96F);
    }
    if (status == 'قيد الغسيل' || status == 'قيد التنفيذ') {
      return Colors.orange;
    }
    if (status == 'مرفوض') return Colors.red;
    if (status == 'مكتمل') return Colors.green;

    return Colors.grey;
  }

  Widget _statusBox(String status) {
    String text = 'تم تحديث حالة هذا الحجز';

    if (status == 'مقبول' || status == 'طلب مقبول') {
      text = 'تم قبول الطلب وإرساله للعامل';
    } else if (status == 'قيد الغسيل' || status == 'قيد التنفيذ') {
      text = 'العامل بدأ الغسيل الآن';
    } else if (status == 'مكتمل') {
      text = 'تم تنفيذ الحجز بنجاح';
    } else if (status == 'مرفوض') {
      text = 'تم رفض هذا الطلب';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _statusColor(status).withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _statusColor(status),
          fontWeight: FontWeight.w800,
        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // تم التعديل إلى أبيض
      appBar: AppBar(
        title: const Text('إدارة الحجوزات'),
        backgroundColor: const Color(0xFF1670FF),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream:
            FirebaseFirestore.instance
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

              final serviceTitle = data['serviceTitle']?.toString() ?? 'خدمة';
              final userEmail = data['userEmail']?.toString() ?? 'غير معروف';
              final date = data['date']?.toString() ?? '';
              final time = data['time']?.toString() ?? '';
              final location = data['location']?.toString() ?? '';
              final carInfo = data['carInfo']?.toString() ?? '';
              final status = data['status']?.toString() ?? 'مؤكد';
              final totalPrice = data['totalPrice'] ?? 0;
              final addons = List<String>.from(data['addons'] ?? []);

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE8EDFF)),
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
                        Expanded(
                          child: Text(
                            serviceTitle,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF151B4A),
                            ),
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
                    if (addons.isNotEmpty) _info('الإضافات', addons.join('، ')),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _openMap(context, data);
                        },
                        icon: const Icon(Icons.location_on_rounded),
                        label: const Text('عرض الموقع على الخريطة'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1670FF),
                          side: const BorderSide(color: Color(0xFF1670FF)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (status == 'مؤكد')
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                await _rejectBooking(context, doc.id, data);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('رفض'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                await _acceptBooking(context, doc.id, data);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF12C96F),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('قبول'),
                            ),
                          ),
                        ],
                      )
                    else
                      _statusBox(status),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}