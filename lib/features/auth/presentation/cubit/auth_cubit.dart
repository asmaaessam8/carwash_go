import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ================= LOGIN =================
  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());

    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uId': userCredential.user!.uid,
        'email': email,
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      emit(AuthSuccess('Login successful'));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Login failed'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ================= REGISTER =================
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

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uId': userCredential.user!.uid,
        'name': name,
        'phone': phone,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      emit(AuthSuccess('Account created successfully'));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Register failed'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ================= GOOGLE SIGN IN =================
  Future<void> signInWithGoogle() async {
    emit(AuthLoading());

    try {
      // تسجيل خروج قبل تسجيل الدخول (مهم)
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        emit(AuthError('Google sign in cancelled'));
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      final user = userCredential.user;

      await _firestore.collection('users').doc(user!.uid).set({
        'uId': user.uid,
        'email': user.email,
        'name': user.displayName,
        'photo': user.photoURL,
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      emit(AuthSuccess('Google sign in successful'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ================= FORGOT PASSWORD =================
  Future<void> forgotPassword({required String email}) async {
    emit(AuthLoading());

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      emit(AuthSuccess('Reset link sent to your email'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    emit(AuthLoading());

    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();

      emit(AuthSuccess('Logged out successfully'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // ================= RESET =================
  void resetState() {
    emit(AuthInitial());
  }
}
