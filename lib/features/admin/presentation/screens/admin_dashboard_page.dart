import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'admin_bookings_page.dart';
import 'admin_categories_page.dart';
import 'admin_products_page.dart';
import 'admin_users_page.dart';
import 'admin_ratings_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('لوحة تحكم الأدمن'),
        backgroundColor: const Color(0xFF1670FF),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream:
                FirebaseFirestore.instance
                    .collection('bookings')
                    .where('status', isEqualTo: 'مؤكد')
                    .snapshots(),
            builder: (context, snapshot) {
              final count = snapshot.data?.docs.length ?? 0;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_rounded),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminBookingsPage(),
                        ),
                      );
                    },
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'مرحباً بك في لوحة التحكم',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF151B4A),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'يمكنك إدارة الخدمات، المستخدمين، والحجوزات من هنا',
              style: TextStyle(fontSize: 14, color: Color(0xFF5F677B)),
            ),
          ),
          const SizedBox(height: 22),

          _AdminCard(
            title: 'إدارة الخدمات',
            subtitle: 'إضافة وتعديل وحذف خدمات غسيل السيارات',
            icon: Icons.local_car_wash_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminProductsPage()),
              );
            },
          ),

          const SizedBox(height: 16),

          _AdminCard(
            title: 'إدارة التصنيفات',
            subtitle: 'إضافة وتعديل وحذف تصنيفات الخدمات',
            icon: Icons.category_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminCategoriesPage()),
              );
            },
          ),

          const SizedBox(height: 16),

          _AdminCard(
            title: 'إدارة الحجوزات',
            subtitle: 'عرض طلبات الحجز وقبولها أو رفضها',
            icon: Icons.calendar_month_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminBookingsPage()),
              );
            },
          ),

          const SizedBox(height: 16),

          _AdminCard(
            title: 'إدارة المستخدمين',
            subtitle: 'عرض حسابات المستخدمين وإضافة أو حذف مستخدم',
            icon: Icons.people_alt_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminUsersPage()),
              );
            },
          ),

          const SizedBox(height: 16),

          _AdminCard(
            title: 'تقييمات المستخدمين',
            subtitle: 'عرض تقييمات وتعليقات المستخدمين على الخدمة',
            icon: Icons.star_rate_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminRatingsPage()),
              );
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _AdminCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE8EDFF)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9DB5FF).withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF9AA8C7),
              size: 18,
            ),
            const Spacer(),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF151B4A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5F677B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: const Color(0xFF1670FF), size: 30),
            ),
          ],
        ),
      ),
    );
  }
}
