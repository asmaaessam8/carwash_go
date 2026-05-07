import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/booking_service_page.dart';
import '../screens/addons_page.dart';
import 'home_filter_controller.dart';

class ProductCardsSection extends StatelessWidget {
  const ProductCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: HomeFilterController.selectedCategory,
      builder: (context, selectedCategory, _) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('products')
              .orderBy('createdAt', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.only(top: 30),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const _EmptyProductsCard();
            }

            final products = snapshot.data!.docs.where((doc) {
              final data = doc.data();

              if (selectedCategory == 'الكل') return true;

              return data['category'] == selectedCategory;
            }).toList();

            if (products.isEmpty) {
              return const _EmptyProductsCard(
                text: 'لا توجد خدمات في هذا التصنيف',
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) {
                final data = products[index].data();

                final title = data['title']?.toString() ?? '';
                final description = data['description']?.toString() ?? '';
                final imageBase64 = data['imageBase64']?.toString() ?? '';
                final price = data['price'] is int
                    ? data['price'] as int
                    : int.tryParse(data['price'].toString()) ?? 0;

                return ProductCard(
                  title: title,
                  description: description,
                  imageBase64: imageBase64,
                  servicePrice: price,
                  showButton: title != 'إضافات',
                );
              },
            );
          },
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageBase64;
  final int servicePrice;
  final bool showButton;

  const ProductCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageBase64,
    required this.servicePrice,
    required this.showButton,
  });

  void _openPage(BuildContext context) {
    if (title == 'إضافات') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AddonsPage(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookingServicePage(
            serviceTitle: title,
            serviceDescription: description,
            serviceImage: imageBase64,
            servicePrice: servicePrice,
          ),
        ),
      );
    }
  }

  Widget _buildImage() {
    if (imageBase64.trim().isEmpty) {
      return const Icon(
        Icons.local_car_wash_rounded,
        size: 78,
        color: Color(0xFF1670FF),
      );
    }

    try {
      return Image.memory(
        base64Decode(imageBase64),
        height: 110,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.local_car_wash_rounded,
            size: 78,
            color: Color(0xFF1670FF),
          );
        },
      );
    } catch (_) {
      return const Icon(
        Icons.local_car_wash_rounded,
        size: 78,
        color: Color(0xFF1670FF),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openPage(context),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 220,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE8EDFF)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9DB5FF).withOpacity(0.10),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              title,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: Color(0xFF18224B),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: _buildImage(),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: () => _openPage(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: showButton
                        ? const Color(0xFFF59A2E)
                        : const Color(0xFFEAF2FF),
                    foregroundColor:
                        showButton ? Colors.white : const Color(0xFF1670FF),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(
                    showButton ? 'احجز الآن' : 'اختيار الإضافات',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
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

class _EmptyProductsCard extends StatelessWidget {
  final String text;

  const _EmptyProductsCard({
    this.text = 'لا توجد خدمات متاحة حالياً',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EDFF)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 50,
            color: Color(0xFF1670FF),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF5F677B),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}