import '../../data/models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;
  final String? successMessage;

  Authenticated(this.user, {this.successMessage});
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String error;

  AuthError(this.error);
}
