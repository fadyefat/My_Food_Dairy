import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_model.dart';
import '../../data/repos/auth_repo.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo _authRepo;

  AuthCubit(this._authRepo) : super(AuthInitial()) {
    checkAuthStatus();
  }

  void checkAuthStatus() {
    final user = _authRepo.getCurrentUser();
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  UserModel? get currentUser => _authRepo.getCurrentUser();

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _authRepo.signInWithEmail(email: email, password: password);
      emit(Authenticated(user, successMessage: 'Welcome back, ${user.displayName}!'));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '').replaceAll('ArgumentError: ', '')));
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _authRepo.signUpWithEmail(
        name: name,
        email: email,
        password: password,
      );
      emit(Authenticated(user, successMessage: 'Account created successfully!'));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '').replaceAll('ArgumentError: ', '')));
    }
  }

  Future<void> signInAsGuest() async {
    emit(AuthLoading());
    try {
      final user = await _authRepo.signInAsGuest();
      emit(Authenticated(user, successMessage: 'Continuing as Guest'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    await _authRepo.signOut();
    emit(Unauthenticated());
  }
}
