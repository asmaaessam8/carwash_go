import 'package:firebase_auth/firebase_auth.dart';
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

      emit(AuthSuccess('Login successful'));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseAuthError(e)));
    } catch (_) {
      emit(AuthError('Something went wrong'));
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
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      emit(AuthSuccess('Register successful'));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseAuthError(e)));
    } catch (_) {
      emit(AuthError('Something went wrong'));
    }
  }

  Future<void> forgotPassword({
    required String email,
  }) async {
    emit(AuthLoading());

    try {
      await _firebaseAuth.sendPasswordResetEmail(
        email: email,
      );

      emit(AuthSuccess('Reset link sent to your email'));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseAuthError(e)));
    } catch (_) {
      emit(AuthError('Something went wrong'));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());

    try {
      await _firebaseAuth.signOut();
      emit(AuthSuccess('Logged out successfully'));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseAuthError(e)));
    } catch (_) {
      emit(AuthError('Something went wrong'));
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