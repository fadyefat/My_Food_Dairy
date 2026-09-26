import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthRepo {
  static const String _userSessionKey = 'current_user_session';
  final SharedPreferences _prefs;

  AuthRepo(this._prefs);

  UserModel? getCurrentUser() {
    final raw = _prefs.getString(_userSessionKey);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || !email.contains('@')) {
      throw ArgumentError('Please enter a valid email address');
    }
    if (password.length < 6) {
      throw ArgumentError('Password must be at least 6 characters');
    }

    final user = UserModel(
      uid: 'user_${email.hashCode.abs()}',
      email: email.trim().toLowerCase(),
      displayName: email.split('@').first,
      createdAt: DateTime.now().toIso8601String(),
    );

    await _prefs.setString(_userSessionKey, jsonEncode(user.toMap()));
    return user;
  }

  Future<UserModel> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Please enter your name');
    }
    if (email.trim().isEmpty || !email.contains('@')) {
      throw ArgumentError('Please enter a valid email address');
    }
    if (password.length < 6) {
      throw ArgumentError('Password must be at least 6 characters');
    }

    final user = UserModel(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email.trim().toLowerCase(),
      displayName: name.trim(),
      createdAt: DateTime.now().toIso8601String(),
    );

    await _prefs.setString(_userSessionKey, jsonEncode(user.toMap()));
    return user;
  }

  Future<UserModel> signInAsGuest() async {
    final user = UserModel(
      uid: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      email: 'guest@fooddiary.app',
      displayName: 'Guest User',
      isGuest: true,
      createdAt: DateTime.now().toIso8601String(),
    );

    await _prefs.setString(_userSessionKey, jsonEncode(user.toMap()));
    return user;
  }

  Future<void> signOut() async {
    await _prefs.remove(_userSessionKey);
  }
}
