import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_filter_controller.dart';

class CategoriesWidget extends StatelessWidget {
  const CategoriesWidget({super.key});

  IconData _getIcon(String title) {
    if (title == 'الكل') {
      return Icons.grid_view_rounded;
    }

    if (title == 'غسيل خارجي') {
      return Icons.local_car_wash_rounded;
    }

    if (title == 'تنظيف داخلي') {
      return Icons.cleaning_services_rounded;
    }

    if (title == 'تلميع داخلي') {
      return Icons.auto_fix_high_rounded;
    }

    if (title == 'إضافات') {
      return Icons.add_box_rounded;
    }

    return Icons.category_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance
              .collection('categories')
              .orderBy('createdAt', descending: false)
              .snapshots(),

      builder: (context, snapshot) {
        final categories = <String>['الكل'];

        if (snapshot.hasData) {
          final firebaseCategories =
              snapshot.data!.docs
                  .map(
                    (doc) =>
                        doc.data()['name']?.toString() ?? '',
                  )
                  .where(
                    (name) => name.trim().isNotEmpty,
                  )
                  .toList();

          categories.addAll(firebaseCategories);
        }

        return Container(
          width: double.infinity,

          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 14,
          ),

          decoration: BoxDecoration(
            color:
                isDark
                    ? const Color(0xFF1C1C1E)
                    : Colors.white,

            borderRadius: BorderRadius.circular(24),

            border: Border.all(
              color:
                  isDark
                      ? Colors.white12
                      : const Color(0xFFE8EDFF),
            ),

            boxShadow:
                isDark
                    ? []
                    : [
                      BoxShadow(
                        color: const Color(
                          0xFF9DB5FF,
                        ).withOpacity(0.10),

                        blurRadius: 18,

                        offset: const Offset(0, 8),
                      ),
                    ],
          ),

          child: ValueListenableBuilder<String>(
            valueListenable:
                HomeFilterController.selectedCategory,

            builder: (
              context,
              selectedCategory,
              _,
            ) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,

                child: Row(
                  children:
                      categories.map((title) {
                        final isSelected =
                            selectedCategory == title;

                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),

                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(18),

                            onTap: () {
                              HomeFilterController
                                      .selectedCategory
                                      .value =
                                  title;
                            },

                            child: AnimatedContainer(
                              duration: const Duration(
                                milliseconds: 220,
                              ),

                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),

                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? const Color(
                                          0xFF1670FF,
                                        )
                                        : isDark
                                        ? const Color(
                                          0xFF2A2A2D,
                                        )
                                        : Colors.white,

                                borderRadius:
                                    BorderRadius.circular(
                                      18,
                                    ),

                                border: Border.all(
                                  color:
                                      isSelected
                                          ? const Color(
                                            0xFF1670FF,
                                          )
                                          : isDark
                                          ? Colors.white12
                                          : const Color(
                                            0xFFE1E6F5,
                                          ),
                                ),
                              ),

                              child: Row(
                                children: [
                                  Icon(
                                    _getIcon(title),

                                    color:
                                        isSelected
                                            ? Colors.white
                                            : isDark
                                            ? Colors.white
                                            : const Color(
                                              0xFF1670FF,
                                            ),

                                    size: 22,
                                  ),

                                  const SizedBox(
                                    width: 7,
                                  ),

                                  Text(
                                    title,

                                    style: TextStyle(
                                      fontSize: 13,

                                      fontWeight:
                                          FontWeight.w800,

                                      color:
                                          isSelected
                                              ? Colors.white
                                              : isDark
                                              ? Colors.white
                                              : const Color(
                                                0xFF18224B,
                                              ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}