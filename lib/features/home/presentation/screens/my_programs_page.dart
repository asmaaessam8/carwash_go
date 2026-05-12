import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package_booking_page.dart';

class MyProgramsPage extends StatelessWidget {
  const MyProgramsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final isDark =
        Theme.of(context).brightness ==
        Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark
              ? Colors.black
              : const Color(0xFFF7F8FC),

      appBar: AppBar(
        title: const Text('برامجي'),

        backgroundColor: const Color(0xFF1670FF),

        foregroundColor: Colors.white,

        elevation: 0,
      ),

      body:
          user == null
              ? Center(
                child: Text(
                  'يجب تسجيل الدخول',

                  style: TextStyle(
                    color:
                        isDark
                            ? Colors.white
                            : Colors.black,

                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
              : StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>
              >(
                stream:
                    FirebaseFirestore.instance
                        .collection('subscriptions')
                        .where(
                          'userId',
                          isEqualTo: user.uid,
                        )
                        .snapshots(),

                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(),
                    );
                  }

                  final docs =
                      snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        'لا توجد باقات مشتركة حالياً',

                        style: TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.w700,

                          color:
                              isDark
                                  ? Colors.white70
                                  : const Color(
                                    0xFF5F677B,
                                  ),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(18),

                    itemCount: docs.length,

                    separatorBuilder:
                        (_, __) =>
                            const SizedBox(height: 14),

                    itemBuilder: (context, index) {
                      final doc = docs[index];

                      final data = doc.data();

                      final title =
                          data['packageTitle'] ??
                          'باقة';

                      final description =
                          data['packageDescription'] ??
                          '';

                      final remaining =
                          data['remainingWashes'] ?? 0;

                      final total =
                          data['totalWashes'] ?? 0;

                      final price =
                          data['price'] ?? 0;

                      final status =
                          data['status'] ?? 'active';

                      return Container(
                        padding:
                            const EdgeInsets.all(18),

                        decoration: BoxDecoration(
                          color:
                              isDark
                                  ? const Color(
                                    0xFF1C1C1E,
                                  )
                                  : Colors.white,

                          borderRadius:
                              BorderRadius.circular(
                                24,
                              ),

                          border: Border.all(
                            color:
                                isDark
                                    ? Colors
                                        .white12
                                    : const Color(
                                      0xFFE8EDFF,
                                    ),
                          ),

                          boxShadow:
                              isDark
                                  ? []
                                  : [
                                    BoxShadow(
                                      color:
                                          const Color(
                                            0xFF9DB5FF,
                                          ).withOpacity(
                                            0.12,
                                          ),

                                      blurRadius: 18,

                                      offset:
                                          const Offset(
                                            0,
                                            7,
                                          ),
                                    ),
                                  ],
                        ),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.end,

                          children: [
                            Row(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        horizontal:
                                            12,
                                        vertical: 7,
                                      ),

                                  decoration: BoxDecoration(
                                    color:
                                        status ==
                                                'active'
                                            ? const Color(
                                              0xFFE8FFF2,
                                            )
                                            : const Color(
                                              0xFFFFECEC,
                                            ),

                                    borderRadius:
                                        BorderRadius.circular(
                                          14,
                                        ),
                                  ),

                                  child: Text(
                                    status ==
                                            'active'
                                        ? 'نشطة'
                                        : 'منتهية',

                                    style: TextStyle(
                                      color:
                                          status ==
                                                  'active'
                                              ? const Color(
                                                0xFF12C96F,
                                              )
                                              : Colors
                                                  .red,

                                      fontWeight:
                                          FontWeight
                                              .w900,
                                    ),
                                  ),
                                ),

                                const Spacer(),

                                Text(
                                  title,

                                  textAlign:
                                      TextAlign.right,

                                  style: TextStyle(
                                    fontSize: 22,

                                    fontWeight:
                                        FontWeight
                                            .w900,

                                    color:
                                        isDark
                                            ? Colors
                                                .white
                                            : const Color(
                                              0xFF151B4A,
                                            ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            Text(
                              description,

                              textAlign:
                                  TextAlign.right,

                              style: TextStyle(
                                fontSize: 14,

                                color:
                                    isDark
                                        ? Colors
                                            .white70
                                        : const Color(
                                          0xFF5F677B,
                                        ),

                                height: 1.5,
                              ),
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            _row(
                              context,
                              'عدد الغسلات',
                              '$total',
                            ),

                            _row(
                              context,
                              'المتبقي',
                              '$remaining غسلة',
                            ),

                            _row(
                              context,
                              'السعر',
                              '$price ريال',
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            SizedBox(
                              width: double.infinity,

                              height: 48,

                              child: ElevatedButton.icon(
                                onPressed:
                                    remaining <= 0 ||
                                            status !=
                                                'active'
                                        ? null
                                        : () {
                                          Navigator.push(
                                            context,

                                            MaterialPageRoute(
                                              builder:
                                                  (_) =>
                                                      PackageBookingPage(
                                                        subscriptionId:
                                                            doc.id,

                                                        packageTitle:
                                                            title,

                                                        packageDescription:
                                                            description,
                                                      ),
                                            ),
                                          );
                                        },

                                icon: const Icon(
                                  Icons
                                      .calendar_month_rounded,
                                ),

                                label: Text(
                                  remaining <= 0
                                      ? 'لا توجد غسلات متبقية'
                                      : 'احجز موعد غسيل',

                                  style:
                                      const TextStyle(
                                        fontSize:
                                            16,

                                        fontWeight:
                                            FontWeight
                                                .w800,
                                      ),
                                ),

                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(
                                        0xFF0D6BFF,
                                      ),

                                  foregroundColor:
                                      Colors.white,

                                  disabledBackgroundColor:
                                      isDark
                                          ? Colors
                                              .white12
                                          : const Color(
                                            0xFFE1E6F5,
                                          ),

                                  disabledForegroundColor:
                                      isDark
                                          ? Colors
                                              .white54
                                          : const Color(
                                            0xFF8B95A7,
                                          ),

                                  elevation: 0,

                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                          14,
                                        ),
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

  Widget _row(
    BuildContext context,
    String title,
    String value,
  ) {
    final isDark =
        Theme.of(context).brightness ==
        Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),

      child: Row(
        children: [
          Text(
            value,

            style: TextStyle(
              fontSize: 15,

              fontWeight: FontWeight.w800,

              color:
                  isDark
                      ? Colors.white
                      : const Color(0xFF151B4A),
            ),
          ),

          const Spacer(),

          Text(
            title,

            style: TextStyle(
              fontSize: 15,

              color:
                  isDark
                      ? Colors.white70
                      : const Color(0xFF5F677B),

              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}