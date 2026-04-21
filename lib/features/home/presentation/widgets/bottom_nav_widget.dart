import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomNavWidget extends StatefulWidget {
  const BottomNavWidget({super.key});

  @override
  State<BottomNavWidget> createState() => _BottomNavWidgetState();
}

class _BottomNavWidgetState extends State<BottomNavWidget> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6E7BAA).withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: GNav(
        selectedIndex: _selectedIndex,
        onTabChange: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        gap: 8,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        activeColor: Colors.white,
        color: const Color(0xFF8B95A7),
        tabBackgroundColor: const Color(0xFF1670FF),
        tabs: const [
          GButton(
            icon: Icons.home_rounded,
            text: 'الرئيسية',
          ),
          GButton(
            icon: Icons.calendar_month_rounded,
            text: 'حجوزاتي',
          ),
          GButton(
            icon: Icons.local_offer_rounded,
            text: 'الباقات',
          ),
          GButton(
            icon: Icons.person_rounded,
            text: 'الحساب',
          ),
        ],
      ),
    );
  }
}