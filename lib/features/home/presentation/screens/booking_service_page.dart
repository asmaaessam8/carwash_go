import 'dart:convert';
import '../../data/repositories/notification_repository.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  String selectedPayment = 'الدفع عند الوصول';
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

  Widget _buildServiceImage() {
    if (widget.serviceImage.trim().isEmpty) {
      return const Icon(
        Icons.local_car_wash_rounded,
        size: 100,
        color: Color(0xFF1670FF),
      );
    }

    try {
      return Image.memory(
        base64Decode(widget.serviceImage),
        height: 160,
        fit: BoxFit.contain,
      );
    } catch (_) {
      return const Icon(
        Icons.local_car_wash_rounded,
        size: 100,
        color: Color(0xFF1670FF),
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

    final savedServiceTitle = widget.serviceTitle;
    final savedDescription = widget.serviceDescription;
    final savedDate = dateText;
    final savedTime = timeText;
    final savedLocation = locationController.text.trim();
    final savedCarInfo = carController.text.trim();
    final savedNotes = notesController.text.trim();
    final savedAddons = List<String>.from(selectedAddons);
    final savedPaymentMethod = selectedPayment;
    final savedServicePrice = servicePrice;
    final savedAddonsTotal = addonsTotal;
    final savedTotalPrice = totalPrice;

    setState(() => isSaving = true);

    try {
    final bookingRef =
    await FirebaseFirestore.instance.collection('bookings').add({
  'userId': user.uid,
  'userEmail': user.email,
  'serviceTitle': savedServiceTitle,
  'serviceDescription': savedDescription,
  'date': savedDate,
  'time': savedTime,
  'location': savedLocation,
  'carInfo': savedCarInfo,
  'notes': savedNotes,
  'addons': savedAddons,
  'paymentMethod': savedPaymentMethod,
  'servicePrice': savedServicePrice,
  'addonsTotal': savedAddonsTotal,
  'totalPrice': savedTotalPrice,
  'status': 'مؤكد',
  'createdAt': FieldValue.serverTimestamp(),
});

await NotificationRepository().notifyNewBooking(
  userId: user.uid,
  bookingId: bookingRef.id,
  serviceTitle: savedServiceTitle,
);

      
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (_) => BookingSuccessPage(
                serviceTitle: savedServiceTitle,
                date: savedDate,
                time: savedTime,
                location: savedLocation,
                carInfo: savedCarInfo,
                addons: savedAddons,
                paymentMethod: savedPaymentMethod,
                totalPrice: savedTotalPrice,
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
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8DDEA),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'اختيار الإضافات',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF151B4A),
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
                                  ? const Color(0xFFEAF2FF)
                                  : const Color(0xFFF7F8FC),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color:
                                isSelected
                                    ? const Color(0xFF1670FF)
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
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF151B4A),
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
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.cleaning_services_rounded,
                                color: Color(0xFF1670FF),
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
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFF1670FF),
                    size: 30,
                  ),
                ),
                const Spacer(),
                const Text(
                  'حجز الخدمة',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1560D6),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: Color(0xFF1670FF),
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
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF151B4A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.serviceDescription,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF5F677B),
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
              hint: 'مثال: حي الياسمين، الرياض',
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
                    const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF9AA8C7),
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
                                  ? const Color(0xFF8B95A7)
                                  : const Color(0xFF151B4A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.add_box_rounded, color: Color(0xFF1670FF)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            _sectionTitle('طريقة الدفع'),
            _paymentOption('الدفع عند الوصول', Icons.payments_rounded),
            _paymentOption('الدفع ببطاقة مدى', Icons.credit_card_rounded),
            _paymentOption('Apple Pay', Icons.phone_iphone_rounded),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _priceRow('سعر الخدمة', servicePrice),
                  if (addonsTotal > 0) _priceRow('الإضافات', addonsTotal),
                  const Divider(height: 22),
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
                      const Text(
                        'الإجمالي',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF151B4A),
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

  Widget _paymentOption(String title, IconData icon) {
    final isSelected = selectedPayment == title;

    return InkWell(
      onTap: () {
        setState(() {
          selectedPayment = title;
        });
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEAF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF1670FF) : const Color(0xFFE1E6F5),
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
                      : const Color(0xFF9AA8C7),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF151B4A),
              ),
            ),
            const SizedBox(width: 10),
            Icon(icon, color: const Color(0xFF1670FF)),
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
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF151B4A),
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF5F677B),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE1E6F5)),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF9DB5FF).withOpacity(0.08),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1560D6),
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
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF9AA8C7),
            ),
            const Spacer(),
            Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF151B4A),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 10),
            Icon(icon, color: const Color(0xFF1670FF)),
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
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: Icon(icon, color: const Color(0xFF1670FF)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE1E6F5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE1E6F5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF1670FF), width: 1.3),
        ),
      ),
    );
  }
}
