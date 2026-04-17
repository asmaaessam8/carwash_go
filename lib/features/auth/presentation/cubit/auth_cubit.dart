import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());

    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('LOGIN AUTH SUCCESS: ${userCredential.user?.uid}');

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('LOGIN FIRESTORE SUCCESS');

      emit(AuthSuccess('Login successful'));
    } on FirebaseAuthException catch (e) {
      print('LOGIN FIREBASE ERROR: ${e.code} - ${e.message}');
      emit(AuthError(_mapFirebaseAuthError(e)));
    } catch (e) {
      print('LOGIN GENERAL ERROR: $e');
      emit(AuthError(e.toString()));
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
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('REGISTER AUTH SUCCESS: ${userCredential.user?.uid}');

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name,
        'phone': phone,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('REGISTER FIRESTORE SUCCESS');

      emit(AuthSuccess('Register successful'));
    } on FirebaseAuthException catch (e) {
      print('REGISTER FIREBASE ERROR: ${e.code} - ${e.message}');
      emit(AuthError(_mapFirebaseAuthError(e)));
    } catch (e) {
      print('REGISTER GENERAL ERROR: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> forgotPassword({required String email}) async {
    emit(AuthLoading());

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      print('RESET PASSWORD EMAIL SENT TO: $email');
      emit(AuthSuccess('Reset link sent to your email'));
    } on FirebaseAuthException catch (e) {
      print('FORGOT PASSWORD FIREBASE ERROR: ${e.code} - ${e.message}');
      emit(AuthError(_mapFirebaseAuthError(e)));
    } catch (e) {
      print('FORGOT PASSWORD GENERAL ERROR: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());

    try {
      await _firebaseAuth.signOut();
      print('LOGOUT SUCCESS');
      emit(AuthSuccess('Logged out successfully'));
    } on FirebaseAuthException catch (e) {
      print('LOGOUT FIREBASE ERROR: ${e.code} - ${e.message}');
      emit(AuthError(_mapFirebaseAuthError(e)));
    } catch (e) {
      print('LOGOUT GENERAL ERROR: $e');
      emit(AuthError(e.toString()));
    }
  }

  void resetState() {
    emit(AuthInitial());
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Wrong email or password.';
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'network-request-failed':
        return 'Check your internet connection.';
      case 'missing-email':
        return 'Please enter your email.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}
