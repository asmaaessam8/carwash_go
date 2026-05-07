import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/widgets/admin_permission_wrapper.dart';
import '../../data/repositories/admin_repository.dart';

class AdminCategoriesPage extends StatelessWidget {
  const AdminCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = AdminRepository();

    return AdminPermissionWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة التصنيفات'),
          backgroundColor: const Color(0xFF1670FF),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF1670FF),
          onPressed: () => _addDialog(context, repo),
          child: const Icon(Icons.add),
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: repo.fetchCategories(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return const Center(child: Text('لا يوجد تصنيفات'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, i) {
                final data = docs[i].data();
                final id = docs[i].id;
                final name = data['name'] ?? '';

                return Card(
                  child: ListTile(
                    title: Text(name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () =>
                              _editDialog(context, repo, id, name),
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
      ),
    );
  }

  void _addDialog(BuildContext context, AdminRepository repo) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إضافة تصنيف'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'اسم التصنيف'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;

              await repo.addCategory(controller.text.trim());

              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _editDialog(
    BuildContext context,
    AdminRepository repo,
    String id,
    String name,
  ) {
    final controller = TextEditingController(text: name);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تعديل التصنيف'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'اسم التصنيف'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;

              await repo.updateCategory(id, controller.text.trim());

              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text('تحديث'),
          ),
        ],
      ),
    );
  }

  void _deleteDialog(BuildContext context, AdminRepository repo, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكدة من حذف هذا التصنيف؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              await repo.deleteCategory(id);

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