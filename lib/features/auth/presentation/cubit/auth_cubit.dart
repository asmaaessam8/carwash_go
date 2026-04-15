import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    await Future.delayed(const Duration(seconds: 2));

    if (email == 'test@gmail.com' && password == '123456') {
      emit(AuthSuccess('Login successful'));
    } else {
      emit(AuthError('Invalid email or password'));
    }
  }

  Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    await Future.delayed(const Duration(seconds: 2));

    if (name.isNotEmpty &&
        phone.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty) {
      emit(AuthSuccess('Register successful'));
    } else {
      emit(AuthError('Please fill all fields'));
    }
  }

  Future<void> forgotPassword({
    required String email,
  }) async {
    emit(AuthLoading());

    await Future.delayed(const Duration(seconds: 2));

    if (email.isNotEmpty && email.contains('@')) {
      emit(AuthSuccess('Reset link sent to your email'));
    } else {
      emit(AuthError('Enter a valid email'));
    }
  }

  void resetState() {
    emit(AuthInitial());
  }
}