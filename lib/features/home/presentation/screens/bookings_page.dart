import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'booking_service_page.dart';

String getPaymentName(String value) {
  switch (value) {
    case 'jeeb':
      return 'محفظ جيب';
    case 'floosak':
      return 'فلوسك';
    case 'kuraimi':
      return 'كريمي';
    case 'الدفع عند الوصول':
      return 'الدفع عند الوصول';
    case 'الدفع ببطاقة مدى':
      return 'الدفع ببطاقة مدى';
    case 'Apple Pay':
      return 'Apple Pay';
    default:
      return value;
  }
}

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  String selectedTab = 'القادمة';

  Stream<QuerySnapshot<Map<String, dynamic>>> _bookingsStream() {
    final user = FirebaseAuth.instance.currentUser;

    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: user?.uid)
        .orderBy('createdAt', descending: true);

    if (selectedTab == 'القادمة') {
      query = query.where('status', isEqualTo: 'مؤكد');
    } else if (selectedTab == 'المكتملة') {
      query = query.where('status', isEqualTo: 'مكتمل');
    } else if (selectedTab == 'الملغية') {
      query = query.where('status', isEqualTo: 'ملغي');
    }

    return query.snapshots();
  }

  Future<void> _cancelBooking(String bookingId) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .update({'status': 'ملغي'});

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إلغاء الحجز')),
    );
  }

  Future<void> _updateBookingTime(String bookingId) async {
    final newDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );

    if (newDate == null) return;

    final newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (newTime == null) return;

    final dateText = '${newDate.year}/${newDate.month}/${newDate.day}';
    final timeText = newTime.format(context);

    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .update({
      'date': dateText,
      'time': timeText,
      'status': 'مؤكد',
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تعديل الموعد بنجاح')),
    );
  }

  void _rebook(Map<String, dynamic> data) {
    final servicePrice = data['servicePrice'] is int
        ? data['servicePrice'] as int
        : int.tryParse(data['servicePrice'].toString()) ?? 0;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingServicePage(
          serviceTitle: data['serviceTitle'] ?? 'خدمة',
          serviceDescription: data['serviceDescription'] ?? 'خدمة غسيل سيارات',
          serviceImage: data['serviceImage'] ?? '',
          servicePrice: servicePrice,
          selectedAddons: List<String>.from(data['addons'] ?? []),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark ? Colors.white : const Color(0xFF1670FF),
                        size: 30,
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'حجوزاتي',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color:
                                isDark ? Colors.white : const Color(0xFF1560D6),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'تابعي مواعيد غسيل سيارتك بسهولة',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF5F677B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1C1C1E)
                            : const Color(0xFFEAF2FF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.calendar_month_rounded,
                        color: isDark ? Colors.white : const Color(0xFF1976FF),
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? Colors.white12 : const Color(0xFFE2E8F6),
                    ),
                  ),
                  child: Row(
                    children: [
                      _tabItem('الكل'),
                      _tabItem('القادمة'),
                      _tabItem('المكتملة'),
                      _tabItem('الملغية'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              if (user == null)
                Expanded(
                  child: Center(
                    child: Text(
                      'يجب تسجيل الدخول لعرض الحجوزات',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _bookingsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'حدث خطأ أثناء تحميل الحجوزات',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        );
                      }

                      final docs = snapshot.data?.docs ?? [];

                      if (docs.isEmpty) {
                        return Center(
                          child: Text(
                            'لا توجد حجوزات حالياً',
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

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data();

                          return _BookingCard(
                            bookingId: doc.id,
                            data: data,
                            onCancel: () => _cancelBooking(doc.id),
                            onEdit: () => _updateBookingTime(doc.id),
                            onRebook: () => _rebook(data),
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabItem(String text) {
    final selected = selectedTab == text;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedTab = text;
          });
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF1670FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final String bookingId;
  final Map<String, dynamic> data;
  final VoidCallback onCancel;
  final VoidCallback onEdit;
  final VoidCallback onRebook;

  const _BookingCard({
    required this.bookingId,
    required this.data,
    required this.onCancel,
    required this.onEdit,
    required this.onRebook,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final serviceTitle = data['serviceTitle'] ?? 'خدمة غسيل';
    final serviceDescription = data['serviceDescription'] ?? 'خدمة غسيل سيارات';
    final date = data['date'] ?? '';
    final time = data['time'] ?? '';
    final location = data['location'] ?? '';
    final carInfo = data['carInfo'] ?? '';

    final paymentMethod =
        data['paymentMethodName'] ?? getPaymentName(data['paymentMethod'] ?? 'غير محدد');

    final totalPrice = data['totalPrice'] ?? 0;
    final deliveryPrice = data['deliveryPrice'] ?? 0;
    final addressDistance = data['addressDistance'];

    final status = data['status'] ?? 'مؤكد';
    final addons = List<String>.from(data['addons'] ?? []);

    final isCancelled = status == 'ملغي';
    final isCompleted = status == 'مكتمل';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE8EDFF),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF9DB5FF).withOpacity(0.14),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: isCancelled
                      ? Colors.red.withOpacity(0.15)
                      : isCompleted
                          ? Colors.green.withOpacity(0.15)
                          : isDark
                              ? Colors.white12
                              : const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isCancelled
                        ? Colors.red.shade200
                        : isCompleted
                            ? Colors.green.shade200
                            : isDark
                                ? Colors.white24
                                : const Color(0xFFB8D3FF),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isCancelled ? Icons.close_rounded : Icons.check_rounded,
                      color: isCancelled
                          ? Colors.red
                          : isCompleted
                              ? Colors.green
                              : isDark
                                  ? Colors.white
                                  : const Color(0xFF1670FF),
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: TextStyle(
                        color: isCancelled
                            ? Colors.red
                            : isCompleted
                                ? Colors.green
                                : isDark
                                    ? Colors.white
                                    : const Color(0xFF1670FF),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'رقم الحجز',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : const Color(0xFF5F677B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#${bookingId.substring(0, 6).toUpperCase()}',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.white : const Color(0xFF1670FF),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            serviceTitle,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF151B4A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            serviceDescription,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white70 : const Color(0xFF5F677B),
            ),
          ),

          const SizedBox(height: 18),
          Divider(color: isDark ? Colors.white12 : const Color(0xFFE7EAF4)),

          _InfoRow(
            icon: Icons.calendar_month_rounded,
            title: 'التاريخ والوقت',
            value: '$date\n$time',
          ),
          _InfoRow(
            icon: Icons.location_on_rounded,
            title: 'الموقع',
            value: location,
          ),

          if (addressDistance != null)
            _InfoRow(
              icon: Icons.route_rounded,
              title: 'المسافة ورسوم الوصول',
              value:
                  '${addressDistance.toStringAsFixed(2)} كم\n$deliveryPrice ريال',
              valueColor: const Color(0xFF1670FF),
            ),

          _InfoRow(
            icon: Icons.directions_car_rounded,
            title: 'السيارة',
            value: carInfo,
          ),
          _InfoRow(
            icon: Icons.account_balance_wallet_rounded,
            title: 'الدفع',
            value: '$paymentMethod\n$totalPrice ريال',
            valueColor: const Color(0xFF12C96F),
          ),

          if (addons.isNotEmpty)
            _InfoRow(
              icon: Icons.add_box_rounded,
              title: 'الإضافات',
              value: addons.join('\n'),
            ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111111) : const Color(0xFFF4F8FF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? Colors.white12 : const Color(0xFFD6E5FF),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  color: isDark ? Colors.white : const Color(0xFF1670FF),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isCancelled
                        ? 'تم إلغاء هذا الحجز'
                        : isCompleted
                            ? 'تم تنفيذ هذا الحجز بنجاح'
                            : 'تم تأكيد الحجز\nالعامل في الطريق حسب الموعد',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF5F677B),
                      height: 1.5,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'المبلغ الإجمالي',
                      style: TextStyle(
                        color:
                            isDark ? Colors.white70 : const Color(0xFF1670FF),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalPrice ريال',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1670FF),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          if (!isCompleted && !isCancelled) ...[
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    text: 'تعديل الموعد',
                    icon: Icons.edit_rounded,
                    isPrimary: false,
                    onPressed: onEdit,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],

          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  text: 'إعادة الحجز',
                  icon: Icons.refresh_rounded,
                  isPrimary: false,
                  onPressed: onRebook,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  text: 'إلغاء الحجز',
                  icon: Icons.close_rounded,
                  isPrimary: true,
                  onPressed: isCancelled || isCompleted ? null : onCancel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color:
                      valueColor ?? (isDark ? Colors.white : const Color(0xFF151B4A)),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : const Color(0xFF151B4A),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? Colors.white12 : const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isDark ? Colors.white : const Color(0xFF1670FF),
              ),
            ),
          ],
        ),
        Divider(
          height: 28,
          color: isDark ? Colors.white12 : const Color(0xFFE7EAF4),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.text,
    required this.icon,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 46,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isPrimary
              ? const Color(0xFF1670FF)
              : isDark
                  ? const Color(0xFF1C1C1E)
                  : Colors.white,
          foregroundColor: isPrimary
              ? Colors.white
              : isDark
                  ? Colors.white
                  : const Color(0xFF1670FF),
          disabledBackgroundColor:
              isDark ? Colors.white12 : const Color(0xFFE8ECF5),
          disabledForegroundColor:
              isDark ? Colors.white38 : const Color(0xFF9AA3B8),
          side: BorderSide(
            color: isDark ? Colors.white24 : const Color(0xFF1670FF),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}