import 'package:flutter/material.dart';

import '../widgets/bottom_nav_widget.dart';
import '../widgets/categories_widget.dart';
import '../widgets/home_header.dart';
import '../widgets/package_carousel.dart';
import '../widgets/product_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            children: const [
              HomeHeader(),
              SizedBox(height: 20),
              PackageCarousel(),
              SizedBox(height: 18),
              CategoriesWidget(),
              SizedBox(height: 18),
              ProductCardsSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavWidget(),
    );
  }
}