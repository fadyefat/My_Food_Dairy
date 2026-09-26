import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/firebase_service.dart';
import '../models/user_model.dart';

class AuthRepo {
  static const String _userSessionKey = 'current_user_session';
  final SharedPreferences _prefs;
  final FirebaseAuth? _firebaseAuth;
  final FirebaseFirestore? _firestore;

  AuthRepo(
    this._prefs, {
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  FirebaseAuth? get _auth {
    if (!FirebaseService.isInitialized) return null;
    return _firebaseAuth ?? FirebaseAuth.instance;
  }

  FirebaseFirestore? get _db {
    if (!FirebaseService.isInitialized) return null;
    return _firestore ?? FirebaseFirestore.instance;
  }

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

    final auth = _auth;
    if (auth != null) {
      try {
        final credential = await auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final fbUser = credential.user;
        final user = UserModel(
          uid: fbUser?.uid ?? 'user_${email.hashCode.abs()}',
          email: fbUser?.email ?? email.trim().toLowerCase(),
          displayName: fbUser?.displayName ?? email.split('@').first,
          createdAt: fbUser?.metadata.creationTime?.toIso8601String() ?? DateTime.now().toIso8601String(),
        );

        await _prefs.setString(_userSessionKey, jsonEncode(user.toMap()));
        return user;
      } on FirebaseAuthException catch (e) {
        throw Exception(_mapFirebaseAuthError(e));
      }
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

    final auth = _auth;
    if (auth != null) {
      try {
        final credential = await auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final fbUser = credential.user;
        await fbUser?.updateDisplayName(name.trim());

        final user = UserModel(
          uid: fbUser?.uid ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
          email: fbUser?.email ?? email.trim().toLowerCase(),
          displayName: name.trim(),
          createdAt: fbUser?.metadata.creationTime?.toIso8601String() ?? DateTime.now().toIso8601String(),
        );

        final db = _db;
        if (db != null) {
          await db.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': user.email,
            'displayName': user.displayName,
            'createdAt': user.createdAt,
          }, SetOptions(merge: true));
        }

        await _prefs.setString(_userSessionKey, jsonEncode(user.toMap()));
        return user;
      } on FirebaseAuthException catch (e) {
        throw Exception(_mapFirebaseAuthError(e));
      }
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
    final auth = _auth;
    if (auth != null) {
      try {
        final credential = await auth.signInAnonymously();
        final fbUser = credential.user;
        final user = UserModel(
          uid: fbUser?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}',
          email: 'guest@fooddiary.app',
          displayName: 'Guest User',
          isGuest: true,
          createdAt: DateTime.now().toIso8601String(),
        );

        await _prefs.setString(_userSessionKey, jsonEncode(user.toMap()));
        return user;
      } on FirebaseAuthException catch (e) {
        throw Exception(_mapFirebaseAuthError(e));
      }
    }

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
    final auth = _auth;
    if (auth != null) {
      try {
        await auth.signOut();
      } catch (_) {}
    }
    await _prefs.remove(_userSessionKey);
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'operation-not-allowed':
        return 'Sign-in method is not enabled in Firebase Console.';
      case 'network-request-failed':
        return 'Network error occurred. Please check your connection.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
