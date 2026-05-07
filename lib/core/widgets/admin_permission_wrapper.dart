import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPermissionWrapper extends StatelessWidget {
  final Widget child;

  const AdminPermissionWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // لو المستخدم غير مسجل دخول
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('يجب تسجيل الدخول'),
        ),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(),
      builder: (context, snapshot) {
        // تحميل
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // إذا ما فيه بيانات
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(
              child: Text('لا يوجد صلاحية'),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final role = data['role'];

        // لو مش أدمن
        if (role != 'admin') {
          return const Scaffold(
            body: Center(
              child: Text('غير مصرح لك بالدخول'),
            ),
          );
        }

        // لو أدمن
        return child;
      },
    );
  }
} 