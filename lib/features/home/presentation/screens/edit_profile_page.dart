import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final user = FirebaseAuth.instance.currentUser;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  File? selectedImage;
  String photoPath = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    final data = doc.data();

    nameController.text =
        data?['name'] ?? user!.displayName ?? '';

    emailController.text =
        data?['email'] ?? user!.email ?? '';

    phoneController.text = data?['phone'] ?? '';

    photoPath = data?['photoPath'] ?? '';

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) return;

    setState(() {
      selectedImage = File(image.path);
      photoPath = image.path;
    });
  }

  Future<void> _saveChanges() async {
    if (user == null) return;

    try {
      setState(() {
        isLoading = true;
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set(
        {
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
          'photoPath': photoPath,
        },
        SetOptions(merge: true),
      );

      await user!.updateDisplayName(
        nameController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ التعديلات بنجاح'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء حفظ التعديلات'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? Colors.black : const Color(0xFFF7F8FC),

      appBar: AppBar(
        title: const Text('تعديل الحساب'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1670FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 58,
                backgroundColor: const Color(0xFFEAF2FF),
                backgroundImage: selectedImage != null
                    ? FileImage(selectedImage!)
                    : photoPath.isNotEmpty &&
                            File(photoPath).existsSync()
                        ? FileImage(File(photoPath))
                        : null,
                child: selectedImage == null &&
                        (photoPath.isEmpty ||
                            !File(photoPath).existsSync())
                    ? const Icon(
                        Icons.camera_alt,
                        size: 38,
                        color: Color(0xFF1670FF),
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 24),

            _inputField(
              controller: nameController,
              hint: 'الاسم',
              icon: Icons.person,
              isDark: isDark,
            ),

            const SizedBox(height: 16),

            _inputField(
              controller: emailController,
              hint: 'البريد الإلكتروني',
              icon: Icons.email,
              isDark: isDark,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            _inputField(
              controller: phoneController,
              hint: 'رقم الهاتف',
              icon: Icons.phone,
              isDark: isDark,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 26),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1670FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'حفظ التعديلات',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
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

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor:
            isDark ? const Color(0xFF1C1C1E) : Colors.white,
        hintStyle: TextStyle(
          color: isDark ? Colors.white54 : Colors.grey,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }
}