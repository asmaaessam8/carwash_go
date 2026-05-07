import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../home/data/repositories/notification_repository.dart';
import '../../data/repositories/worker_repository.dart';

class WorkerOrdersPage extends StatelessWidget {
  const WorkerOrdersPage({super.key});

  Future<void> _completeOrder(
    BuildContext context,
    WorkerRepository repo,
    String bookingId,
    Map<String, dynamic> data,
  ) async {
    await repo.markAsCompleted(bookingId);

    final userId = data['userId'];
    final serviceTitle = data['serviceTitle'] ?? 'خدمة';

    if (userId != null && userId.toString().isNotEmpty) {
      await NotificationRepository().notifyBookingCompleted(
        userId: userId,
        bookingId: bookingId,
        serviceTitle: serviceTitle,
      );
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تنفيذ الطلب بنجاح'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = WorkerRepository();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('طلبات العامل'),
        backgroundColor: const Color(0xFF1670FF),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: repo.fetchAcceptedBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد طلبات مقبولة حالياً',
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
                    const Text(
                      'طلب مقبول',
                      style: TextStyle(
                        color: Color(0xFF12C96F),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      serviceTitle,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF151B4A),
                      ),
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
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _completeOrder(
                            context,
                            repo,
                            doc.id,
                            data,
                          );
                        },
                        icon: const Icon(Icons.done_all_rounded),
                        label: const Text(
                          'تم التنفيذ',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF12C96F),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
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