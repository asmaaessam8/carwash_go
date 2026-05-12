import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<ThemeMode> themeNotifier =
    ValueNotifier<ThemeMode>(ThemeMode.light);

Future<void> loadSavedTheme() async {
  final prefs = await SharedPreferences.getInstance();

  final isDark =
      prefs.getBool('isDarkMode') ?? false;

  themeNotifier.value =
      isDark ? ThemeMode.dark : ThemeMode.light;
}

Future<void> saveTheme(bool isDark) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setBool(
    'isDarkMode',
    isDark,
  );

  themeNotifier.value =
      isDark ? ThemeMode.dark : ThemeMode.light;
}