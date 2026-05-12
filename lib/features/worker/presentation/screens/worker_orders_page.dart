import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../home/data/repositories/notification_repository.dart';
import '../../data/repositories/worker_repository.dart';

class WorkerOrdersPage extends StatelessWidget {
  const WorkerOrdersPage({super.key});

  bool _isAccepted(String status) {
    return status.trim() == 'مقبول' || status.trim() == 'طلب مقبول';
  }

  bool _isInProgress(String status) {
    return status.trim() == 'قيد الغسيل' || status.trim() == 'قيد التنفيذ';
  }

  bool _isCompleted(String status) {
    return status.trim() == 'مكتمل';
  }

  Future<void> _openMap(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    final mapUrl = data['locationMapUrl']?.toString() ?? '';
    final location = data['location']?.toString() ?? '';

    if (mapUrl.isEmpty && location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد موقع لهذا الطلب')),
      );
      return;
    }

    final url = Uri.parse(
      mapUrl.isNotEmpty
          ? mapUrl
          : 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}',
    );

    final opened = await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );

    if (!opened) {
      await launchUrl(
        url,
        mode: LaunchMode.platformDefault,
      );
    }
  }

  Future<void> _startOrder(
    BuildContext context,
    WorkerRepository repo,
    String bookingId,
    Map<String, dynamic> data,
  ) async {
    await repo.markAsInProgress(bookingId);

    final userId = data['userId']?.toString() ?? '';
    final serviceTitle = data['serviceTitle']?.toString() ?? 'خدمة';

    if (userId.isNotEmpty) {
      await NotificationRepository().notifyWorkerStarted(
        userId: userId,
        bookingId: bookingId,
        serviceTitle: serviceTitle,
      );
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تحويل الطلب إلى قيد الغسيل')),
    );
  }

  Future<void> _completeOrder(
    BuildContext context,
    WorkerRepository repo,
    String bookingId,
    Map<String, dynamic> data,
  ) async {
    await repo.markAsCompleted(bookingId);

    final userId = data['userId']?.toString() ?? '';
    final serviceTitle = data['serviceTitle']?.toString() ?? 'خدمة';

    if (userId.isNotEmpty) {
      await NotificationRepository().notifyBookingCompleted(
        userId: userId,
        bookingId: bookingId,
        serviceTitle: serviceTitle,
      );
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إنهاء الغسيل بنجاح')),
    );
  }

  Widget _actionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
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
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF5F677B),
            ),
          ),
        ],
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
        stream: repo.fetchWorkerBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد طلبات حالياً',
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

              final status = (data['status'] ?? '').toString().trim();
              final serviceTitle = data['serviceTitle']?.toString() ?? 'خدمة';
              final userEmail = data['userEmail']?.toString() ?? 'غير معروف';
              final date = data['date']?.toString() ?? '';
              final time = data['time']?.toString() ?? '';
              final location = data['location']?.toString() ?? '';
              final carInfo = data['carInfo']?.toString() ?? '';
              final totalPrice = data['totalPrice'] ?? 0;
              final addons = List<String>.from(data['addons'] ?? []);

              final isAccepted = _isAccepted(status);
              final isInProgress = _isInProgress(status);
              final isCompleted = _isCompleted(status);

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
                    Text(
                      status.isEmpty ? 'غير محدد' : status,
                      style: TextStyle(
                        color: isCompleted
                            ? const Color(0xFF12C96F)
                            : const Color(0xFF1670FF),
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
                    if (isAccepted)
                      _actionButton(
                        text: 'قيد الغسيل',
                        icon: Icons.play_arrow_rounded,
                        color: const Color(0xFF1670FF),
                        onPressed: () async {
                          await _startOrder(context, repo, doc.id, data);
                        },
                      )
                    else if (isInProgress)
                      _actionButton(
                        text: 'تم الانتهاء',
                        icon: Icons.done_all_rounded,
                        color: const Color(0xFF12C96F),
                        onPressed: () async {
                          await _completeOrder(context, repo, doc.id, data);
                        },
                      )
                    else if (isCompleted)
                      const Text(
                        'تم إنهاء هذا الطلب',
                        style: TextStyle(
                          color: Color(0xFF12C96F),
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    else
                      const Text(
                        'هذا الطلب غير قابل للتنفيذ حالياً',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w800,
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
}