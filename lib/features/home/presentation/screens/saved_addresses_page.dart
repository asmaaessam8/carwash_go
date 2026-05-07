import 'package:flutter/material.dart';

class SavedAddressesPage extends StatefulWidget {
  const SavedAddressesPage({super.key});

  @override
  State<SavedAddressesPage> createState() => _SavedAddressesPageState();
}

class _SavedAddressesPageState extends State<SavedAddressesPage> {
  final List<String> addresses = [];

  void _addAddress() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إضافة عنوان'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'اكتب العنوان هنا',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  addresses.add(controller.text.trim());
                });
                Navigator.pop(context);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _deleteAddress(int index) {
    setState(() {
      addresses.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('العناوين المحفوظة'),
        backgroundColor: const Color(0xFF1670FF),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAddress,
        backgroundColor: const Color(0xFF1670FF),
        child: const Icon(Icons.add),
      ),
      body: addresses.isEmpty
          ? const Center(
              child: Text(
                'لا توجد عناوين حالياً',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              itemBuilder: (_, index) {
                return Card(
                  child: ListTile(
                    title: Text(addresses[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteAddress(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}