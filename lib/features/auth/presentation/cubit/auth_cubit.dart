import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      emit(LoginSuccess('تم تسجيل الدخول بنجاح'));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'فشل تسجيل الدخول'));
    } catch (_) {
      emit(AuthError('فشل تسجيل الدخول'));
    }
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

      emit(RegisterSuccess('تم إنشاء الحساب بنجاح'));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'فشل إنشاء الحساب'));
    } catch (_) {
      emit(AuthError('فشل إنشاء الحساب'));
    }
  }

  Future<void> forgotPassword({
    required String email,
  }) async {
    emit(AuthLoading());

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);

      emit(ResetPasswordSuccess('تم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني'));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'فشل إرسال رابط إعادة التعيين'));
    } catch (_) {
      emit(AuthError('فشل إرسال رابط إعادة التعيين'));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());

    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        await _firebaseAuth.signInWithPopup(googleProvider);
        emit(GoogleSignInSuccess('تم تسجيل الدخول عبر Google'));
      } else {
        emit(AuthError('Google Sign-In على هذا الجهاز غير مفعّل حاليًا'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'فشل تسجيل الدخول عبر Google'));
    } catch (_) {
      emit(AuthError('فشل تسجيل الدخول عبر Google'));
    }
  }

  void resetState() {
    emit(AuthInitial());
  }
}