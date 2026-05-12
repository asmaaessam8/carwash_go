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
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,

      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: isDark ? Colors.black : Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                HomeHeader(),

                SizedBox(height: 20),

                PackageCarousel(),

                SizedBox(height: 20),

                CategoriesWidget(),

                SizedBox(height: 20),

                ProductCardsSection(),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: const BottomNavWidget(),
    );
  }
}