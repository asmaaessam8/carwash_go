import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RatingPage extends StatefulWidget {
  const RatingPage({super.key});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  final commentController = TextEditingController();

  double rating = 5;
  bool isLoading = false;

  Future<String> _getUserName(User user) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      final data = userDoc.data();

      final name = data?['name']?.toString();

      if (name != null && name.isNotEmpty) {
        return name;
      }

      if (user.displayName != null && user.displayName!.isNotEmpty) {
        return user.displayName!;
      }

      return 'مستخدم';
    } catch (_) {
      return user.displayName ?? 'مستخدم';
    }
  }

  Future<void> submitRating() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يجب تسجيل الدخول أولاً')));
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final userName = await _getUserName(user);

      await FirebaseFirestore.instance.collection('ratings').add({
        'userId': user.uid,
        'userName': userName,
        'userEmail': user.email ?? '',
        'rating': rating,
        'comment': commentController.text.trim(),
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إرسال التقييم بنجاح')));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إرسال التقييم: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget buildStar(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          rating = index.toDouble();
        });
      },
      child: Icon(
        Icons.star,
        size: 40,
        color: index <= rating ? Colors.amber : Colors.grey.shade400,
      ),
    );
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1670FF),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('تقييم الخدمة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.star_rate_rounded,
                color: Color(0xFF1670FF),
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'كيف كانت الخدمة؟',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF151B4A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'قيم تجربتك وساعدنا نحسن خدماتنا',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildStar(1),
                buildStar(2),
                buildStar(3),
                buildStar(4),
                buildStar(5),
              ],
            ),
            const SizedBox(height: 35),
            TextField(
              controller: commentController,
              maxLines: 5,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'اكتب تعليقك هنا...',
                filled: true,
                fillColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: isLoading ? null : submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1670FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child:
                    isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'إرسال التقييم',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
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
