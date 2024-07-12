part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthSignUp extends AuthEvent {
  final String email;
  final String password;
  final String name;

  AuthSignUp({
    required this.email,
    required this.password,
    required this.name,
  });
}

final class AuthLogin extends AuthEvent {
  final String email;
  final String password;

  AuthLogin({required this.email, required this.password});
}

final class AuthChangePassword extends AuthEvent {
  final String email;
  final String oldPassword;
  final String newPassword;

  AuthChangePassword(
      {required this.email,
      required this.oldPassword,
      required this.newPassword});
}

class AuthLogout extends AuthEvent {}

final class AuthIsUserLoggedIn extends AuthEvent {}
