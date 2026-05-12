import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  String _formatDate(dynamic createdAt) {
    if (createdAt is Timestamp) {
      final date = createdAt.toDate();
      return '${date.year}/${date.month}/${date.day}';
    }

    return '';
  }

  String _paymentName(String value) {
    switch (value) {
      case 'jeeb':
        return 'محفظ جيب';
      case 'floosak':
        return 'فلوسك';
      case 'kuraimi':
        return 'كريمي';
      default:
        return value;
    }
  }

  Color _statusColor(String status) {
    if (status == 'مكتمل') return Colors.green;
    if (status == 'ملغي') return Colors.red;
    return const Color(0xFF1670FF);
  }

  IconData _statusIcon(String status) {
    if (status == 'مكتمل') return Icons.check_circle_rounded;
    if (status == 'ملغي') return Icons.cancel_rounded;
    return Icons.access_time_filled_rounded;
  }

  IconData _receiptIcon(String status) {
    if (status == 'مكتمل') return Icons.receipt_long_rounded;
    if (status == 'ملغي') return Icons.receipt_long_outlined;
    return Icons.receipt_long_rounded;
  }

  String _statusText(String status) {
    if (status == 'مكتمل') return 'مكتمل';
    if (status == 'ملغي') return 'ملغي';
    if (status == 'مؤكد') return 'مقبول';
    return status;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text(
          'المدفوعات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1670FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: user == null
          ? const Center(
              child: Text('يجب تسجيل الدخول أولاً'),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "سجل المدفوعات",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF151B4A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('bookings')
                          .where('userId', isEqualTo: user.uid)
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'حدث خطأ أثناء تحميل البيانات',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black,
                              ),
                            ),
                          );
                        }

                        final docs = snapshot.data?.docs ?? [];

                        if (docs.isEmpty) {
                          return Center(
                            child: Text(
                              'لا توجد مدفوعات حالياً',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF5F677B),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data =
                                docs[index].data() as Map<String, dynamic>;

                            final title =
                                data['serviceTitle'] ?? 'طلب غسيل سيارة';

                            final price = data['totalPrice'] ?? 0;

                            final date = _formatDate(data['createdAt']);

                            final paymentMethod =
                                data['paymentMethodName'] ??
                                    _paymentName(data['paymentMethod'] ?? '');

                            final status = data['status'] ?? 'مؤكد';

                            return paymentItem(
                              isDark: isDark,
                              title: title,
                              price: '$price ريال',
                              date: date,
                              paymentMethod: paymentMethod,
                              status: status,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget paymentItem({
    required bool isDark,
    required String title,
    required String price,
    required String date,
    required String paymentMethod,
    required String status,
  }) {
    final statusColor = _statusColor(status);
    final statusIcon = _statusIcon(status);
    final receiptIcon = _receiptIcon(status);
    final shownStatus = _statusText(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE8EDFF),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: statusColor.withOpacity(0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              receiptIcon,
              color: statusColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF151B4A),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  paymentMethod.isEmpty ? date : '$date - $paymentMethod',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      statusIcon,
                      color: statusColor,
                      size: 18,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      shownStatus,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            price,
            style: TextStyle(
              color: statusColor,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}