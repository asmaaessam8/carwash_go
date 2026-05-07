import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection('products');

  CollectionReference<Map<String, dynamic>> get _categories =>
      _firestore.collection('categories');

  // ================= Products CRUD =================

  Future<void> addProduct({
    required String title,
    required String description,
    required int price,
    required String imageBase64,
    required String category,
  }) async {
    await _products.add({
      'title': title,
      'description': description,
      'price': price,
      'imageBase64': imageBase64,
      'category': category,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProduct({
    required String productId,
    required String title,
    required String description,
    required int price,
    required String imageBase64,
    required String category,
  }) async {
    await _products.doc(productId).update({
      'title': title,
      'description': description,
      'price': price,
      'imageBase64': imageBase64,
      'category': category,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteProduct(String productId) async {
    await _products.doc(productId).delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchAdminProducts() {
    return _products.orderBy('createdAt', descending: true).snapshots();
  }

  // ================= Categories CRUD =================

  Future<void> addCategory(String name) async {
    await _categories.add({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchCategories() {
    return _categories.orderBy('createdAt', descending: false).snapshots();
  }

  Future<void> updateCategory(String id, String name) async {
    await _categories.doc(id).update({
      'name': name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteCategory(String id) async {
    await _categories.doc(id).delete();
  }
}