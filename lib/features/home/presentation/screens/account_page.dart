import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:carwash_go/core/theme/theme_notifier.dart';

import '../../../auth/presentation/screens/login_page.dart';
import 'edit_profile_page.dart';
import 'my_programs_page.dart';
import 'notifications_page.dart';
import 'payments_page.dart';
import 'rating_page.dart';
import 'saved_addresses_page.dart';
import 'support_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final user = FirebaseAuth.instance.currentUser;

  String name = "مستخدم";
  String phone = "";
  String email = "";
  String photoPath = "";

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    if (!mounted) return;

    if (doc.exists) {
      final data = doc.data();

      setState(() {
        name =
            data?['name'] ?? user!.displayName ?? "مستخدم";

        phone = data?['phone'] ?? "";

        email = data?['email'] ?? user!.email ?? "";

        photoPath = data?['photoPath'] ?? "";
      });
    }
  }

  Future<void> openEditProfile() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditProfilePage(),
      ),
    );

    if (updated == true) {
      loadUserData();
    }
  }

  Future<void> logout() async {
    await GoogleSignIn().signOut();

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  ImageProvider? profileImage() {
    if (photoPath.isNotEmpty &&
        File(photoPath).existsSync()) {
      return FileImage(File(photoPath));
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) {
        final isDark = themeMode == ThemeMode.dark;

        return Scaffold(
          backgroundColor:
              isDark ? Colors.black : const Color(0xFFF7F8FC),

          body: SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.fromLTRB(22, 28, 22, 26),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF5B8CFF),
                        Color(0xFF0D6BFF),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(34),
                      bottomRight: Radius.circular(34),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () =>
                                Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                            ),
                          ),

                          const Spacer(),

                          const Text(
                            "الحساب",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(width: 14),

                          CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white24,
                            backgroundImage: profileImage(),
                            child: profileImage() == null
                                ? const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 34,
                                  )
                                : null,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius:
                              BorderRadius.circular(22),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: openEditProfile,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(16),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      color: Color(0xFF0D6BFF),
                                      size: 18,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      "تعديل",
                                      style: TextStyle(
                                        color:
                                            Color(0xFF0D6BFF),
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    email,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15,
                                    ),
                                  ),

                                  if (phone.isNotEmpty) ...[
                                    const SizedBox(height: 6),

                                    Text(
                                      phone,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      children: [
                        itemCard(
                          title: "التنبيهات",
                          icon: Icons.notifications,
                          isDark: isDark,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const NotificationsPage(),
                              ),
                            );
                          },
                        ),

                        itemCard(
                          title: "المدفوعات",
                          icon: Icons.credit_card,
                          isDark: isDark,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const PaymentsPage(),
                              ),
                            );
                          },
                        ),

                        itemCard(
                          title: "العناوين المحفوظة",
                          icon: Icons.location_on,
                          isDark: isDark,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const SavedAddressesPage(),
                              ),
                            );
                          },
                        ),

                        itemCard(
                          title: "برامجي",
                          icon: Icons.verified_user,
                          isDark: isDark,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const MyProgramsPage(),
                              ),
                            );
                          },
                        ),

                        itemCard(
                          title: "التقييمات",
                          icon: Icons.star_rate_rounded,
                          isDark: isDark,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const RatingPage(),
                              ),
                            );
                          },
                        ),

                        itemCard(
                          title: "الدعم والمساعدة",
                          icon: Icons.help,
                          isDark: isDark,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const SupportPage(),
                              ),
                            );
                          },
                        ),

                        themeCard(isDark),

                        logoutCard(isDark),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget itemCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color:
              isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white12
                    : const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isDark
                    ? Colors.white
                    : const Color(0xFF1670FF),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Colors.white
                      : const Color(0xFF151B4A),
                ),
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: isDark ? Colors.white54 : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget themeCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color:
            isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white12
                  : const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              color: isDark
                  ? Colors.white
                  : const Color(0xFF1670FF),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              "الوضع الليلي",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? Colors.white
                    : const Color(0xFF151B4A),
              ),
            ),
          ),

          Switch(
            value: isDark,
            onChanged: (value) {
              saveTheme(value);
            },
          ),
        ],
      ),
    );
  }

  Widget logoutCard(bool isDark) {
    return GestureDetector(
      onTap: logout,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color:
              isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.logout_rounded,
              color: Colors.red,
            ),

            SizedBox(width: 12),

            Expanded(
              child: Text(
                "تسجيل الخروج",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}