import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/services/firebase_service.dart';
import '../models/meal_model.dart';

class MealRemoteDataSource {
  final FirebaseFirestore? _firestore;
  final FirebaseStorage? _storage;

  MealRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore,
        _storage = storage;

  FirebaseFirestore? get _db {
    if (!FirebaseService.isInitialized) return null;
    return _firestore ?? FirebaseFirestore.instance;
  }

  FirebaseStorage? get _st {
    if (!FirebaseService.isInitialized) return null;
    return _storage ?? FirebaseStorage.instance;
  }

  Future<String?> uploadMealImage({
    required String userId,
    required String localPath,
  }) async {
    final storage = _st;
    if (storage == null) return localPath;

    final file = File(localPath);
    if (!await file.exists()) return localPath;

    final fileName = 'meal_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = storage.ref().child('users').child(userId).child('meals').child(fileName);

    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> saveMeal({
    required String userId,
    required MealModel meal,
  }) async {
    final db = _db;
    if (db == null) return;

    final docId = meal.id != null ? meal.id.toString() : db.collection('users').doc(userId).collection('meals').doc().id;

    await db
        .collection('users')
        .doc(userId)
        .collection('meals')
        .doc(docId)
        .set(meal.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteMeal({
    required String userId,
    required int mealId,
  }) async {
    final db = _db;
    if (db == null) return;

    await db
        .collection('users')
        .doc(userId)
        .collection('meals')
        .doc(mealId.toString())
        .delete();
  }

  Future<List<MealModel>> fetchMeals(String userId) async {
    final db = _db;
    if (db == null) return [];

    final snapshot = await db
        .collection('users')
        .doc(userId)
        .collection('meals')
        .get();

    return snapshot.docs.map((doc) => MealModel.fromMap(doc.data())).toList();
  }
}
