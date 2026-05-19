import 'package:flutter/material.dart';

import 'package_booking_success_page.dart';
import '../../data/repositories/package_repository.dart';

class PackageBookingPage extends StatefulWidget {
  final String subscriptionId;
  final String packageTitle;
  final String packageDescription;

  const PackageBookingPage({
    super.key,
    required this.subscriptionId,
    required this.packageTitle,
    required this.packageDescription,
  });

  @override
  State<PackageBookingPage> createState() => _PackageBookingPageState();
}

class _PackageBookingPageState extends State<PackageBookingPage> {
  final PackageRepository repo = PackageRepository();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final locationController = TextEditingController();

  final carController = TextEditingController();

  final notesController = TextEditingController();

  bool isSaving = false;

  String get dateText {
    if (selectedDate == null) {
      return 'اختاري تاريخ الغسيل';
    }

    return '${selectedDate!.year}/${selectedDate!.month}/${selectedDate!.day}';
  }

  String get timeText {
    if (selectedTime == null) {
      return 'اختاري وقت الغسيل';
    }

    return selectedTime!.format(context);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رجاءً أكملي بيانات الموعد')),
      );

      return;
    }

    setState(() => isSaving = true);

    try {
      await repo.bookWashFromPackage(
        subscriptionId: widget.subscriptionId,
        packageTitle: widget.packageTitle,
        packageDescription: widget.packageDescription,
        date: dateText,
        time: timeText,
        location: locationController.text.trim(),
        carInfo: carController.text.trim(),
        notes: notesController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => PackageBookingSuccessPage(
                packageTitle: widget.packageTitle,
                date: dateText,
                time: timeText,
                location: locationController.text.trim(),
                carInfo: carController.text.trim(),
              ),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حجز موعد الغسيل من الباقة بنجاح')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
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
    return Scaffold(
      backgroundColor: Colors.white, // تم التعديل

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
                  'حجز موعد الباقة',

                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,

                    color: Color(0xFF1560D6),
                  ),
                ),

                const SizedBox(width: 12),

                Container(
                  width: 52,
                  height: 52,

                  decoration: BoxDecoration(
                    color: Colors.white, // تم التعديل

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
                crossAxisAlignment: CrossAxisAlignment.end,

                children: [
                  Text(
                    widget.packageTitle,

                    textAlign: TextAlign.right,

                    style: const TextStyle(
                      fontSize: 24,

                      fontWeight: FontWeight.w900,

                      color: Color(0xFF151B4A),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    widget.packageDescription,

                    textAlign: TextAlign.right,

                    style: const TextStyle(
                      fontSize: 15,

                      color: Color(0xFF5F677B),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'هذا الحجز سيتم خصمه من عدد الغسلات المتبقية في الباقة',

                    textAlign: TextAlign.right,

                    style: TextStyle(
                      fontSize: 14,

                      color: Color(0xFF1670FF),

                      fontWeight: FontWeight.w700,
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

            _sectionTitle('موقع الغسيل'),

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

            _sectionTitle('ملاحظات'),

            _inputField(
              controller: notesController,

              icon: Icons.note_alt_rounded,

              hint: 'أضف ملاحظاتك اختياري',

              maxLines: 2,
            ),

            const SizedBox(height: 24),

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
                  isSaving ? 'جاري حجز الموعد...' : 'تأكيد موعد الغسيل',

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

        fillColor: Colors.white, // أبيض

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
