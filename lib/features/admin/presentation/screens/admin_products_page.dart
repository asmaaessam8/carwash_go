import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/repositories/admin_repository.dart';

class AdminProductsPage extends StatelessWidget {
  const AdminProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = AdminRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الخدمات'),
        backgroundColor: const Color(0xFF1670FF),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1670FF),
        onPressed: () {
          _showProductDialog(context, repo);
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: repo.fetchAdminProducts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('لا توجد خدمات'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data();
              final id = docs[i].id;

              return Card(
                child: ListTile(
                  leading: _imagePreview(data['imageBase64']),
                  title: Text(data['title'] ?? ''),
                  subtitle: Text(
                    '${data['price'] ?? 0} ريال - ${data['category'] ?? 'بدون تصنيف'}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showProductDialog(
                            context,
                            repo,
                            productId: id,
                            oldData: data,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteDialog(context, repo, id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _imagePreview(dynamic imageBase64) {
    if (imageBase64 == null || imageBase64.toString().trim().isEmpty) {
      return const Icon(Icons.local_car_wash_rounded, color: Color(0xFF1670FF));
    }

    try {
      return Image.memory(
        base64Decode(imageBase64.toString()),
        width: 55,
        height: 55,
        fit: BoxFit.cover,
      );
    } catch (_) {
      return const Icon(Icons.local_car_wash_rounded, color: Color(0xFF1670FF));
    }
  }

  Future<List<String>> _getCategories(AdminRepository repo) async {
    final snapshot = await repo.fetchCategories().first;

    return snapshot.docs
        .map((doc) => doc.data()['name']?.toString() ?? '')
        .where((name) => name.trim().isNotEmpty)
        .toList();
  }

  void _showProductDialog(
    BuildContext context,
    AdminRepository repo, {
    String? productId,
    Map<String, dynamic>? oldData,
  }) async {
    final isEdit = productId != null;

    final titleController = TextEditingController(text: oldData?['title'] ?? '');
    final descriptionController =
        TextEditingController(text: oldData?['description'] ?? '');
    final priceController =
        TextEditingController(text: oldData?['price']?.toString() ?? '');

    String? imageBase64 = oldData?['imageBase64'];
    final picker = ImagePicker();

    final categories = await _getCategories(repo);
    String? selectedCategory = oldData?['category'];

    if (selectedCategory == null || !categories.contains(selectedCategory)) {
      selectedCategory = categories.isNotEmpty ? categories.first : null;
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'تعديل خدمة' : 'إضافة خدمة'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'الاسم'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'الوصف'),
                    ),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'السعر'),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: 'التصنيف'),
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedCategory = value;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    ElevatedButton(
                      onPressed: () async {
                        final picked = await picker.pickImage(
                          source: ImageSource.gallery,
                        );

                        if (picked != null) {
                          final bytes = await picked.readAsBytes();
                          imageBase64 = base64Encode(bytes);
                          setDialogState(() {});
                        }
                      },
                      child: Text(
                        imageBase64 == null || imageBase64!.isEmpty
                            ? 'اختيار صورة'
                            : 'تغيير الصورة',
                      ),
                    ),

                    if (imageBase64 != null && imageBase64!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Image.memory(
                          base64Decode(imageBase64!),
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty ||
                        priceController.text.trim().isEmpty ||
                        imageBase64 == null ||
                        imageBase64!.isEmpty ||
                        selectedCategory == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('أكملي البيانات')),
                      );
                      return;
                    }

                    if (isEdit) {
                      await repo.updateProduct(
                        productId: productId,
                        title: titleController.text.trim(),
                        description: descriptionController.text.trim(),
                        price: int.tryParse(priceController.text.trim()) ?? 0,
                        imageBase64: imageBase64!,
                        category: selectedCategory!,
                      );
                    } else {
                      await repo.addProduct(
                        title: titleController.text.trim(),
                        description: descriptionController.text.trim(),
                        price: int.tryParse(priceController.text.trim()) ?? 0,
                        imageBase64: imageBase64!,
                        category: selectedCategory!,
                      );
                    }

                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  child: Text(isEdit ? 'تحديث' : 'حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteDialog(BuildContext context, AdminRepository repo, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكدة من حذف هذه الخدمة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              await repo.deleteProduct(id);

              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text(
              'حذف',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}