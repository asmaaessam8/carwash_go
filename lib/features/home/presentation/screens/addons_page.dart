import 'package:flutter/material.dart';
import 'booking_service_page.dart';

class AddonsPage extends StatefulWidget {
  const AddonsPage({super.key});

  @override
  State<AddonsPage> createState() => _AddonsPageState();
}

class _AddonsPageState extends State<AddonsPage> {
  final List<Map<String, dynamic>> addons = [
    {'title': 'تلميع كفرات', 'price': '25 ريال', 'selected': false},
    {'title': 'تلميع خارجي', 'price': '80 ريال', 'selected': false},
    {'title': 'تعطير داخلي', 'price': '15 ريال', 'selected': false},
    {'title': 'تنظيف مكائن', 'price': '120 ريال', 'selected': false},
    {'title': 'شمع حماية', 'price': '100 ريال', 'selected': false},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final selectedAddons = addons
        .where((item) => item['selected'] == true)
        .map((item) => '${item['title']} - ${item['price']}')
        .toList();

    return Scaffold(
      backgroundColor:
          isDark ? Colors.black : const Color(0xFFF7F8FC),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),

              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),

                    icon: Icon(
                      Icons.arrow_back_rounded,

                      color:
                          isDark
                              ? Colors.white
                              : const Color(0xFF1670FF),

                      size: 30,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    'الإضافات',

                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,

                      color:
                          isDark
                              ? Colors.white
                              : const Color(0xFF1560D6),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Container(
                    width: 54,
                    height: 54,

                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? const Color(0xFF1C1C1E)
                              : const Color(0xFFEAF2FF),

                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: Icon(
                      Icons.add_box_rounded,

                      color:
                          isDark
                              ? Colors.white
                              : const Color(0xFF1670FF),

                      size: 30,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18),

                itemCount: addons.length,

                itemBuilder: (context, index) {
                  final item = addons[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),

                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? const Color(0xFF1C1C1E)
                              : Colors.white,

                      borderRadius: BorderRadius.circular(22),

                      border: Border.all(
                        color:
                            isDark
                                ? Colors.white12
                                : const Color(0xFFE8EDFF),
                      ),
                    ),

                    child: Row(
                      children: [
                        Checkbox(
                          value: item['selected'],

                          activeColor:
                              const Color(0xFF1670FF),

                          checkColor: Colors.white,

                          onChanged: (value) {
                            setState(() {
                              item['selected'] =
                                  value ?? false;
                            });
                          },
                        ),

                        const Spacer(),

                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.end,

                          children: [
                            Text(
                              item['title'],

                              style: TextStyle(
                                fontSize: 18,

                                fontWeight:
                                    FontWeight.w800,

                                color:
                                    isDark
                                        ? Colors.white
                                        : const Color(
                                          0xFF151B4A,
                                        ),
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              item['price'],

                              style: const TextStyle(
                                fontSize: 15,

                                color: Color(
                                  0xFF1670FF,
                                ),

                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 12),

                        Container(
                          width: 48,
                          height: 48,

                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? Colors.white12
                                    : const Color(
                                      0xFFEAF2FF,
                                    ),

                            borderRadius:
                                BorderRadius.circular(16),
                          ),

                          child: Icon(
                            Icons.cleaning_services_rounded,

                            color:
                                isDark
                                    ? Colors.white
                                    : const Color(
                                      0xFF1670FF,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(18),

              child: SizedBox(
                width: double.infinity,
                height: 54,

                child: ElevatedButton(
                  onPressed: () {
                    if (selectedAddons.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'اختاري إضافة واحدة على الأقل',
                          ),
                        ),
                      );

                      return;
                    }

                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder:
                            (_) => BookingServicePage(
                              serviceTitle:
                                  'إضافات',

                              serviceDescription:
                                  'خدمات إضافية للسيارة',

                              serviceImage: '',

                              servicePrice: 0,

                              selectedAddons:
                                  selectedAddons,
                            ),
                      ),
                    );
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF0D6BFF),

                    foregroundColor: Colors.white,

                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),

                  child: const Text(
                    'متابعة الحجز',

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}