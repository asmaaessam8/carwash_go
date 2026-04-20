abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class LoginSuccess extends AuthState {
  final String message;
  LoginSuccess(this.message);
}

class RegisterSuccess extends AuthState {
  final String message;
  RegisterSuccess(this.message);
}

class ResetPasswordSuccess extends AuthState {
  final String message;
  ResetPasswordSuccess(this.message);
}

class GoogleSignInSuccess extends AuthState {
  final String message;
  GoogleSignInSuccess(this.message);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}