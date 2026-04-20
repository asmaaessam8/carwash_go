import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());

    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        await _firebaseAuth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount googleUser =
            await GoogleSignIn.instance.authenticate();

        final GoogleSignInAuthentication googleAuth =
            googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        await _firebaseAuth.signInWithCredential(credential);
      }

      emit(AuthSuccess('Google sign in successful'));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Google sign in failed'));
    } catch (e) {
      emit(AuthError('Google sign in failed'));
    }
  }
}