import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'bookings_page.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  String _formatDate(dynamic value) {
    if (value == null) return '';

    DateTime? date;

    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    }

    if (date == null) return '';

    return '${date.year}/${date.month}/${date.day} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _markAsRead(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? Colors.black : Colors.white,

      appBar: AppBar(
        title: const Text('التنبيهات'),

        backgroundColor: const Color(0xFF1670FF),

        foregroundColor: Colors.white,

        elevation: 0,
      ),

      body:
          user == null
              ? Center(
                child: Text(
                  'يجب تسجيل الدخول لعرض التنبيهات',

                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,

                    color:
                        isDark
                            ? Colors.white
                            : const Color(0xFF151B4A),
                  ),
                ),
              )
              : StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>
              >(
                stream:
                    FirebaseFirestore.instance
                        .collection('notifications')
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

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'حدث خطأ أثناء تحميل التنبيهات',

                        style: TextStyle(
                          color:
                              isDark
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                    );
                  }

                  final docs =
                      snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        'لا توجد تنبيهات حالياً',

                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.w700,

                          color:
                              isDark
                                  ? Colors.white70
                                  : const Color(
                                    0xFF151B4A,
                                  ),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),

                    itemCount: docs.length,

                    separatorBuilder:
                        (_, __) =>
                            const SizedBox(height: 16),

                    itemBuilder: (context, index) {
                      final doc = docs[index];

                      final data = doc.data();

                      final title =
                          data['title']
                              ?.toString() ??
                          'تنبيه جديد';

                      final body =
                          data['body']
                              ?.toString() ??
                          '';

                      final serviceTitle =
                          data['serviceTitle']
                              ?.toString() ??
                          '';

                      final isRead =
                          data['isRead'] == true;

                      final createdAt =
                          _formatDate(
                            data['createdAt'],
                          );

                      return InkWell(
                        onTap: () async {
                          if (!isRead) {
                            await _markAsRead(
                              doc.id,
                            );
                          }

                          if (!context.mounted) {
                            return;
                          }

                          Navigator.push(
                            context,

                            MaterialPageRoute(
                              builder:
                                  (_) =>
                                      const BookingsPage(),
                            ),
                          );
                        },

                        borderRadius:
                            BorderRadius.circular(24),

                        child: Container(
                          padding:
                              const EdgeInsets.all(16),

                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? const Color(
                                      0xFF1C1C1E,
                                    )
                                    : isRead
                                    ? Colors.white
                                    : const Color(
                                      0xFFEAF2FF,
                                    ),

                            borderRadius:
                                BorderRadius.circular(
                                  24,
                                ),

                            border: Border.all(
                              color:
                                  isDark
                                      ? Colors
                                          .white12
                                      : isRead
                                      ? const Color(
                                        0xFFE1E6F5,
                                      )
                                      : const Color(
                                        0xFF1670FF,
                                      ),
                            ),
                          ),

                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                              Container(
                                width: 58,
                                height: 58,

                                decoration: BoxDecoration(
                                  color:
                                      isDark
                                          ? Colors
                                              .white12
                                          : const Color(
                                            0xFFEAF2FF,
                                          ),

                                  borderRadius:
                                      BorderRadius.circular(
                                        18,
                                      ),
                                ),

                                child: Icon(
                                  isRead
                                      ? Icons
                                          .notifications_none_rounded
                                      : Icons
                                          .notifications_active_rounded,

                                  color:
                                      isDark
                                          ? Colors
                                              .white
                                          : const Color(
                                            0xFF1670FF,
                                          ),

                                  size: 30,
                                ),
                              ),

                              const SizedBox(
                                width: 14,
                              ),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .end,

                                  children: [
                                    if (!isRead)
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                              horizontal:
                                                  12,
                                              vertical:
                                                  5,
                                            ),

                                        decoration: BoxDecoration(
                                          color:
                                              const Color(
                                                0xFF1670FF,
                                              ),

                                          borderRadius:
                                              BorderRadius.circular(
                                                20,
                                              ),
                                        ),

                                        child: const Text(
                                          'جديد',

                                          style: TextStyle(
                                            color:
                                                Colors
                                                    .white,

                                            fontSize:
                                                12,

                                            fontWeight:
                                                FontWeight
                                                    .w700,
                                          ),
                                        ),
                                      ),

                                    if (!isRead)
                                      const SizedBox(
                                        height: 10,
                                      ),

                                    Text(
                                      title,

                                      textAlign:
                                          TextAlign
                                              .right,

                                      style: TextStyle(
                                        fontSize: 18,

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

                                    const SizedBox(
                                      height: 8,
                                    ),

                                    Text(
                                      body,

                                      textAlign:
                                          TextAlign
                                              .right,

                                      style: TextStyle(
                                        fontSize: 15,

                                        color:
                                            isDark
                                                ? Colors
                                                    .white70
                                                : const Color(
                                                  0xFF5F677B,
                                                ),
                                      ),
                                    ),

                                    if (serviceTitle
                                        .isNotEmpty) ...[
                                      const SizedBox(
                                        height: 10,
                                      ),

                                      Align(
                                        alignment:
                                            Alignment
                                                .centerRight,

                                        child: Text(
                                          serviceTitle,

                                          style: const TextStyle(
                                            fontSize:
                                                16,

                                            color: Color(
                                              0xFF1670FF,
                                            ),

                                            fontWeight:
                                                FontWeight
                                                    .w800,
                                          ),
                                        ),
                                      ),
                                    ],

                                    if (createdAt
                                        .isNotEmpty) ...[
                                      const SizedBox(
                                        height: 10,
                                      ),

                                      Text(
                                        createdAt,

                                        style: TextStyle(
                                          fontSize: 14,

                                          color:
                                              isDark
                                                  ? Colors
                                                      .white54
                                                  : Colors
                                                      .grey,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}