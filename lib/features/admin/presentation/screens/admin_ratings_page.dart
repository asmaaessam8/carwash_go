import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminRatingsPage extends StatelessWidget {
  const AdminRatingsPage({super.key});

  Widget buildStars(double rating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? Icons.star_rounded : Icons.star_border_rounded,
          color: Colors.amber,
          size: 24,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1670FF),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('تقييمات المستخدمين'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ratings')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد تقييمات حالياً',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          final ratings = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ratings.length,
            itemBuilder: (context, index) {
              final data = ratings[index].data() as Map<String, dynamic>;

              final userName = data['userName']?.toString() ?? 'مستخدم';
              final userEmail = data['userEmail']?.toString() ?? '';
              final comment = data['comment']?.toString() ?? '';
              final rating = (data['rating'] ?? 0).toDouble();

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF151B4A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),
                    buildStars(rating),
                    const SizedBox(height: 12),
                    Text(
                      comment.isEmpty ? 'لا يوجد تعليق' : comment,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Color(0xFF151B4A),
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
}