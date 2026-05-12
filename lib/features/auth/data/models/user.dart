import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String fcmToken;

  final String area;
  final bool isAvailable;
  final bool isActive;

  final String carType;
  final String carNumber;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.fcmToken,
    required this.area,
    required this.isAvailable,
    required this.isActive,
    required this.carType,
    required this.carNumber,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isWorker => role == 'worker';
  bool get isCustomer => role == 'user';

  factory UserModel.empty() {
    return const UserModel(
      id: '',
      name: '',
      email: '',
      phone: '',
      role: 'user',
      fcmToken: '',
      area: '',
      isAvailable: false,
      isActive: true,
      carType: '',
      carNumber: '',
    );
  }

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return UserModel.fromMap(data, doc.id);
  }

  factory UserModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return UserModel(
      id: id,
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      role: map['role']?.toString() ?? 'user',
      fcmToken: map['fcmToken']?.toString() ?? '',
      area: map['area']?.toString() ?? '',
      isAvailable: map['isAvailable'] == true,
      isActive: map['isActive'] != false,
      carType: map['carType']?.toString() ?? '',
      carNumber: map['carNumber']?.toString() ?? '',
      createdAt: _dateFromValue(map['createdAt']),
      updatedAt: _dateFromValue(map['updatedAt']),
      lastLoginAt: _dateFromValue(map['lastLoginAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'fcmToken': fcmToken,
      'area': area,
      'isAvailable': isAvailable,
      'isActive': isActive,
      'carType': carType,
      'carNumber': carNumber,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastLoginAt': lastLoginAt,
    };
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'fcmToken': fcmToken,
      'area': area,
      'isAvailable': isAvailable,
      'isActive': isActive,
      'carType': carType,
      'carNumber': carNumber,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'phone': phone,
      'role': role,
      'fcmToken': fcmToken,
      'area': area,
      'isAvailable': isAvailable,
      'isActive': isActive,
      'carType': carType,
      'carNumber': carNumber,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? fcmToken,
    String? area,
    bool? isAvailable,
    bool? isActive,
    String? carType,
    String? carNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      fcmToken: fcmToken ?? this.fcmToken,
      area: area ?? this.area,
      isAvailable: isAvailable ?? this.isAvailable,
      isActive: isActive ?? this.isActive,
      carType: carType ?? this.carType,
      carNumber: carNumber ?? this.carNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  static DateTime? _dateFromValue(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}