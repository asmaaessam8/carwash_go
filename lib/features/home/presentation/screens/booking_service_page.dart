import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/repositories/notification_repository.dart';
import 'booking_success_page.dart';

class BookingServicePage extends StatefulWidget {
  final String serviceTitle;
  final String serviceDescription;
  final String serviceImage;
  final int servicePrice;
  final List<String> selectedAddons;

  const BookingServicePage({
    super.key,
    required this.serviceTitle,
    required this.serviceDescription,
    required this.serviceImage,
    required this.servicePrice,
    this.selectedAddons = const [],
  });

  @override
  State<BookingServicePage> createState() => _BookingServicePageState();
}

class _BookingServicePageState extends State<BookingServicePage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final locationController = TextEditingController();
  final carController = TextEditingController();
  final notesController = TextEditingController();

  late List<String> selectedAddons;

  String selectedPayment = 'cash_on_delivery';
  bool isSaving = false;

  final List<Map<String, dynamic>> addons = const [
    {'title': 'تلميع كفرات', 'price': 25},
    {'title': 'تلميع خارجي', 'price': 80},
    {'title': 'تعطير داخلي', 'price': 15},
    {'title': 'تنظيف مكائن', 'price': 120},
    {'title': 'شمع حماية', 'price': 100},
  ];

  @override
  void initState() {
    super.initState();
    selectedAddons = List.from(widget.selectedAddons);
  }

  int get servicePrice => widget.servicePrice;

  int get addonsTotal {
    int total = 0;

    for (final selected in selectedAddons) {
      for (final addon in addons) {
        final text = '${addon['title']} - ${addon['price']} ريال';
        if (selected == text) {
          total += addon['price'] as int;
        }
      }
    }

    return total;
  }

  int get totalPrice => servicePrice + addonsTotal;

  String get dateText {
    if (selectedDate == null) return 'اختاري تاريخ الحجز';
    return '${selectedDate!.year}/${selectedDate!.month}/${selectedDate!.day}';
  }

  String get timeText {
    if (selectedTime == null) return 'اختاري وقت الحجز';
    return selectedTime!.format(context);
  }

  String get locationMapUrl {
    final location = Uri.encodeComponent(locationController.text.trim());
    return 'https://www.google.com/maps/search/?api=1&query=$location';
  }

  String getPaymentName(String value) {
    switch (value) {
      case 'cash_on_delivery':
        return 'الدفع عند الوصول';
      case 'jeeb':
        return 'محفظة جيب';
      case 'floosak':
        return 'فلوسك';
      case 'kuraimi':
        return 'كريمي';
      default:
        return value;
    }
  }

  String getPaymentAccountTitle(String value) {
    switch (value) {
      case 'cash_on_delivery':
        return 'الدفع عند الوصول';
      case 'jeeb':
        return 'رقم نقطة جيب';
      case 'floosak':
        return 'رقم نقطة فلوسك';
      case 'kuraimi':
        return 'رقم نقطة كريمي';
      default:
        return 'رقم الدفع';
    }
  }

  String getPaymentAccountNumber(String value) {
    switch (value) {
      case 'jeeb':
        return '7 356854';
      case 'floosak':
        return '0134567';
      case 'kuraimi':
        return '1755370';
      default:
        return '';
    }
  }

  String get selectedPaymentName => getPaymentName(selectedPayment);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Widget _buildServiceImage() {
    if (widget.serviceImage.trim().isEmpty) {
      return Icon(
        Icons.local_car_wash_rounded,
        size: 100,
        color: isDark ? Colors.white : const Color(0xFF1670FF),
      );
    }

    try {
      return Image.memory(
        base64Decode(widget.serviceImage),
        height: 160,
        fit: BoxFit.contain,
      );
    } catch (_) {
      return Icon(
        Icons.local_car_wash_rounded,
        size: 100,
        color: isDark ? Colors.white : const Color(0xFF1670FF),
      );
    }
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  Future<void> pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() => selectedTime = time);
    }
  }

  Future<void> confirmBooking() async {
    if (selectedDate == null ||
        selectedTime == null ||
        locationController.text.trim().isEmpty ||
        carController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('رجاءً أكملي بيانات الحجز')));
      return;
    }

    if (widget.serviceTitle == 'إضافات' && selectedAddons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختاري إضافة واحدة على الأقل')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يجب تسجيل الدخول أولاً')));
      return;
    }

    setState(() => isSaving = true);

    try {
      final bookingRef = await FirebaseFirestore.instance
          .collection('bookings')
          .add({
            'userId': user.uid,
            'userEmail': user.email,
            'serviceTitle': widget.serviceTitle,
            'serviceDescription': widget.serviceDescription,
            'date': dateText,
            'time': timeText,
            'location': locationController.text.trim(),
            'locationQuery': locationController.text.trim(),
            'locationMapUrl': locationMapUrl,
            'carInfo': carController.text.trim(),
            'notes': notesController.text.trim(),
            'addons': selectedAddons,
            'paymentMethod': selectedPayment,
            'paymentMethodName': selectedPaymentName,
            'paymentAccountTitle': getPaymentAccountTitle(selectedPayment),
            'paymentAccountNumber': getPaymentAccountNumber(selectedPayment),
            'paymentStatus':
                selectedPayment == 'cash_on_delivery'
                    ? 'الدفع عند الوصول'
                    : 'بانتظار التحويل',
            'servicePrice': servicePrice,
            'addonsTotal': addonsTotal,
            'totalPrice': totalPrice,
            'status': 'مؤكد',
            'createdAt': FieldValue.serverTimestamp(),
          });

      await NotificationRepository().notifyNewBooking(
        userId: user.uid,
        bookingId: bookingRef.id,
        serviceTitle: widget.serviceTitle,
      );

      await NotificationRepository().notifyAdminsNewBooking(
        serviceTitle: widget.serviceTitle,
        bookingId: bookingRef.id,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (_) => BookingSuccessPage(
                serviceTitle: widget.serviceTitle,
                date: dateText,
                time: timeText,
                location: locationController.text.trim(),
                carInfo: carController.text.trim(),
                addons: selectedAddons,
                paymentMethod: selectedPaymentName,
                totalPrice: totalPrice,
              ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء حفظ الحجز: $e')));
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  void showAddonsSheet() {
    final tempSelected = List<String>.from(selectedAddons);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final modalIsDark = Theme.of(context).brightness == Brightness.dark;

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                decoration: BoxDecoration(
                  color: modalIsDark ? const Color(0xFF121212) : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color:
                            modalIsDark
                                ? Colors.white24
                                : const Color(0xFFD8DDEA),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'اختيار الإضافات',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color:
                            modalIsDark
                                ? Colors.white
                                : const Color(0xFF151B4A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...addons.map((addon) {
                      final text = '${addon['title']} - ${addon['price']} ريال';
                      final isSelected = tempSelected.contains(text);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? modalIsDark
                                      ? Colors.white12
                                      : Colors.white
                                  : modalIsDark
                                  ? const Color(0xFF1C1C1E)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color:
                                isSelected
                                    ? const Color(0xFF1670FF)
                                    : modalIsDark
                                    ? Colors.white12
                                    : const Color(0xFFE1E6F5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isSelected,
                              activeColor: const Color(0xFF1670FF),
                              onChanged: (value) {
                                setModalState(() {
                                  if (value == true) {
                                    tempSelected.add(text);
                                  } else {
                                    tempSelected.remove(text);
                                  }
                                });
                              },
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  addon['title'].toString(),
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color:
                                        modalIsDark
                                            ? Colors.white
                                            : const Color(0xFF151B4A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${addon['price']} ريال',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1670FF),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color:
                                    modalIsDark ? Colors.white12 : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.cleaning_services_rounded,
                                color:
                                    modalIsDark
                                        ? Colors.white
                                        : const Color(0xFF1670FF),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedAddons = tempSelected;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D6BFF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'حفظ الإضافات',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    locationController.dispose();
    carController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnlyAddons = widget.serviceTitle == 'إضافات';

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Row(
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
                Text(
                  'حجز الخدمة',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1560D6),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? const Color(0xFF1C1C1E)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: isDark ? Colors.white : const Color(0xFF1670FF),
                    size: 30,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: _cardDecoration(),
              child: Column(
                children: [
                  _buildServiceImage(),
                  const SizedBox(height: 14),
                  Text(
                    widget.serviceTitle,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF151B4A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.serviceDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : const Color(0xFF5F677B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _sectionTitle('التاريخ والوقت'),
            _selectField(
              icon: Icons.calendar_month_rounded,
              text: dateText,
              onTap: pickDate,
            ),
            _selectField(
              icon: Icons.access_time_rounded,
              text: timeText,
              onTap: pickTime,
            ),
            const SizedBox(height: 18),
            _sectionTitle('موقع الخدمة'),
            _inputField(
              controller: locationController,
              icon: Icons.location_on_rounded,
              hint: 'مثال: حي النهضة، صنعاء',
            ),
            const SizedBox(height: 18),
            _sectionTitle('معلومات السيارة'),
            _inputField(
              controller: carController,
              icon: Icons.directions_car_rounded,
              hint: 'مثال: تويوتا كامري 2023 - ABC 123',
            ),
            const SizedBox(height: 18),
            _sectionTitle(isOnlyAddons ? 'الإضافات' : 'إضافات اختيارية'),
            InkWell(
              onTap: showAddonsSheet,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(15),
                decoration: _cardDecoration(),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: isDark ? Colors.white54 : const Color(0xFF9AA8C7),
                      size: 18,
                    ),
                    const Spacer(),
                    Expanded(
                      flex: 7,
                      child: Text(
                        selectedAddons.isEmpty
                            ? 'اختياري: اضغطي لاختيار الإضافات'
                            : selectedAddons.join('، '),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color:
                              selectedAddons.isEmpty
                                  ? isDark
                                      ? Colors.white54
                                      : const Color(0xFF8B95A7)
                                  : isDark
                                  ? Colors.white
                                  : const Color(0xFF151B4A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.add_box_rounded,
                      color: isDark ? Colors.white : const Color(0xFF1670FF),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            _sectionTitle('طريقة الدفع'),
            _paymentOption(
              title: 'الدفع عند الوصول',
              value: 'cash_on_delivery',
              imagePath: '',
              icon: Icons.payments_rounded,
            ),
            _paymentOption(
              title: 'محفظة جيب',
              value: 'jeeb',
              imagePath: 'assets/images/jeeb.jpeg',
            ),
            _paymentOption(
              title: 'فلوسك',
              value: 'floosak',
              imagePath: 'assets/images/floosak.jpeg',
            ),
            _paymentOption(
              title: 'كريمي',
              value: 'kuraimi',
              imagePath: 'assets/images/kuraimi.jpeg',
            ),
            _paymentAccountBox(),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _priceRow('سعر الخدمة', servicePrice),
                  if (addonsTotal > 0) _priceRow('الإضافات', addonsTotal),
                  Divider(
                    height: 22,
                    color: isDark ? Colors.white12 : const Color(0xFFE1E6F5),
                  ),
                  Row(
                    children: [
                      Text(
                        '$totalPrice ريال',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1670FF),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'الإجمالي',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color:
                              isDark ? Colors.white : const Color(0xFF151B4A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _sectionTitle('ملاحظات'),
            _inputField(
              controller: notesController,
              icon: Icons.note_alt_rounded,
              hint: 'أضف ملاحظاتك اختياري',
              maxLines: 2,
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: isSaving ? null : confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D6BFF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  isSaving ? 'جاري حفظ الحجز...' : 'تأكيد الحجز',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentAccountBox() {
    if (selectedPayment == 'cash_on_delivery') {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFE8FFF2),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF12C96F).withOpacity(0.35)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF12C96F),
              size: 30,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'سيتم الدفع للعامل عند وصوله وتنفيذ الخدمة.',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF151B4A),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final title = getPaymentAccountTitle(selectedPayment);
    final number = getPaymentAccountNumber(selectedPayment);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF1670FF).withOpacity(0.25),
          width: 1.3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF151B4A),
            ),
          ),
          const SizedBox(height: 12),
          SelectableText(
            number,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1670FF),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'حوّل المبلغ إلى الرقم أعلاه، ثم اضغط تأكيد الحجز.',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF5F677B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentOption({
    required String title,
    required String value,
    required String imagePath,
    IconData? icon,
  }) {
    final isSelected = selectedPayment == value;

    return InkWell(
      onTap: () {
        setState(() {
          selectedPayment = value;
        });
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 62,
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? isDark
                      ? Colors.white12
                      : Colors.white
                  : isDark
                  ? const Color(0xFF1C1C1E)
                  : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                isSelected
                    ? const Color(0xFF1670FF)
                    : isDark
                    ? Colors.white12
                    : const Color(0xFFE1E6F5),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color:
                  isSelected
                      ? const Color(0xFF1670FF)
                      : isDark
                      ? Colors.white54
                      : const Color(0xFF9AA8C7),
              size: 25,
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF151B4A),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 62,
              height: 36,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  imagePath.isEmpty
                      ? Icon(
                        icon ?? Icons.payments_rounded,
                        color: const Color(0xFF1670FF),
                      )
                      : Image.asset(imagePath, fit: BoxFit.contain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String title, int price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$price ريال',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF151B4A),
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white70 : const Color(0xFF5F677B),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: isDark ? Colors.white12 : const Color(0xFFE1E6F5),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white : const Color(0xFF1560D6),
        ),
      ),
    );
  }

  Widget _selectField({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(15),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isDark ? Colors.white54 : const Color(0xFF9AA8C7),
            ),
            const Spacer(),
            Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white : const Color(0xFF151B4A),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 10),
            Icon(icon, color: isDark ? Colors.white : const Color(0xFF1670FF)),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF151B4A),
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark ? Colors.white54 : const Color(0xFF9AA8C7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          suffixIcon: Icon(icon, color: const Color(0xFF1670FF), size: 22),
          filled: true,
          fillColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isDark ? Colors.white12 : const Color(0xFFE1E6F5),
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF1670FF), width: 1.5),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}