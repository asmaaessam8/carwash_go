import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> saveFcmToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      final token = await FirebaseMessaging.instance.getToken();

      if (user != null && token != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'fcmToken': token,
          'fcmTokens': FieldValue.arrayUnion([token]),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        debugPrint('FCM TOKEN SAVED FROM AUTH CUBIT');
      }
    } catch (e) {
      debugPrint('FCM TOKEN ERROR: $e');
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await saveFcmToken();

      emit(LoginSuccess('تم تسجيل الدخول بنجاح'));
    } on FirebaseAuthException catch (e) {
      emit(AuthError('${e.code} - ${e.message ?? 'فشل تسجيل الدخول'}'));
    } catch (e) {
      emit(AuthError('فشل تسجيل الدخول: $e'));
    }
  }

  Future<bool> isCurrentUserAdmin() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) return false;

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) return false;

    final data = doc.data();

    return data?['role'] == 'admin';
  }

  Future<String> getCurrentUserRole() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) return 'user';

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) return 'user';

    final data = doc.data();

    return data?['role'] ?? 'user';
  }

  Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);

      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': name,
        'phone': phone,
        'email': email,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await saveFcmToken();

      emit(RegisterSuccess('تم إنشاء الحساب بنجاح'));
    } on FirebaseAuthException catch (e) {
      emit(AuthError('${e.code} - ${e.message ?? 'فشل إنشاء الحساب'}'));
    } catch (e) {
      emit(AuthError('فشل إنشاء الحساب: $e'));
    }
  }

  Future<void> forgotPassword({required String email}) async {
    emit(AuthLoading());

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);

      emit(
        ResetPasswordSuccess(
          'تم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني',
        ),
      );
    } on FirebaseAuthException catch (e) {
      emit(AuthError('${e.code} - ${e.message ?? 'فشل إرسال رابط إعادة التعيين'}'));
    } catch (e) {
      emit(AuthError('فشل إرسال رابط إعادة التعيين: $e'));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());

    try {
      UserCredential credential;

      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        credential = await _firebaseAuth.signInWithPopup(googleProvider);
      } else {
        await _googleSignIn.signOut();

        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          emit(AuthError('تم إلغاء تسجيل الدخول عبر Google'));
          return;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential authCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        credential = await _firebaseAuth.signInWithCredential(authCredential);
      }

      final user = credential.user;

      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'name': user.displayName ?? 'مستخدم',
            'phone': '',
            'email': user.email ?? '',
            'role': 'user',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      await saveFcmToken();

      emit(GoogleSignInSuccess('تم تسجيل الدخول عبر Google'));
    } on FirebaseAuthException catch (e) {
      emit(AuthError('${e.code} - ${e.message ?? 'فشل تسجيل الدخول عبر Google'}'));
    } catch (e) {
      emit(AuthError('فشل تسجيل الدخول عبر Google: $e'));
    }
  }

  void resetState() {
    emit(AuthInitial());
  }
}