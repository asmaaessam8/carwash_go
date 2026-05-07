abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

/// كلاس عام لكل حالات النجاح
class AuthSuccess extends AuthState {
  final String message;
  AuthSuccess(this.message);
}

/// حالات فرعية من النجاح
class LoginSuccess extends AuthSuccess {
  LoginSuccess(String message) : super(message);
}

class RegisterSuccess extends AuthSuccess {
  RegisterSuccess(String message) : super(message);
}

class ResetPasswordSuccess extends AuthSuccess {
  ResetPasswordSuccess(String message) : super(message);
}

class GoogleSignInSuccess extends AuthSuccess {
  GoogleSignInSuccess(String message) : super(message);
}