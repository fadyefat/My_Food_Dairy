import '../../../../core/database/database_helper.dart';
import '../../../auth/data/repos/auth_repo.dart';
import '../datasources/meal_remote_data_source.dart';
import '../models/meal_model.dart';

class MealRepo {
  final DatabaseHelper _databaseHelper;
  final MealRemoteDataSource? _remoteDataSource;
  final AuthRepo? _authRepo;

  MealRepo(
    this._databaseHelper, {
    MealRemoteDataSource? remoteDataSource,
    AuthRepo? authRepo,
  })  : _remoteDataSource = remoteDataSource,
        _authRepo = authRepo;

  Future<int> insertMeal(MealModel meal) async {
    final localId = await _databaseHelper.insertMeal(meal.toMap());
    final insertedMeal = meal.copyWith(id: localId);

    // Sync to Cloud Firestore & Storage if user is logged in
    final currentUser = _authRepo?.getCurrentUser();
    if (currentUser != null && _remoteDataSource != null) {
      try {
        var cloudMeal = insertedMeal;
        if (insertedMeal.photoPath != null &&
            !insertedMeal.photoPath!.startsWith('http')) {
          final cloudUrl = await _remoteDataSource.uploadMealImage(
            userId: currentUser.uid,
            localPath: insertedMeal.photoPath!,
          );
          if (cloudUrl != null) {
            cloudMeal = cloudMeal.copyWith(photoPath: cloudUrl);
          }
        }
        await _remoteDataSource.saveMeal(
          userId: currentUser.uid,
          meal: cloudMeal,
        );
      } catch (_) {
        // Local save succeeded; background cloud sync can retry later
      }
    }

    return localId;
  }

  Future<int> updateMeal(MealModel meal) async {
    if (meal.id == null) {
      throw ArgumentError('Meal ID cannot be null for update');
    }
    final rows = await _databaseHelper.updateMeal(meal.id!, meal.toMap());

    final currentUser = _authRepo?.getCurrentUser();
    if (currentUser != null && _remoteDataSource != null) {
      try {
        var cloudMeal = meal;
        if (meal.photoPath != null && !meal.photoPath!.startsWith('http')) {
          final cloudUrl = await _remoteDataSource.uploadMealImage(
            userId: currentUser.uid,
            localPath: meal.photoPath!,
          );
          if (cloudUrl != null) {
            cloudMeal = cloudMeal.copyWith(photoPath: cloudUrl);
          }
        }
        await _remoteDataSource.saveMeal(
          userId: currentUser.uid,
          meal: cloudMeal,
        );
      } catch (_) {}
    }

    return rows;
  }

  Future<int> deleteMeal(int id) async {
    final rows = await _databaseHelper.deleteMeal(id);

    final currentUser = _authRepo?.getCurrentUser();
    if (currentUser != null && _remoteDataSource != null) {
      try {
        await _remoteDataSource.deleteMeal(
          userId: currentUser.uid,
          mealId: id,
        );
      } catch (_) {}
    }

    return rows;
  }

  Future<List<MealModel>> getMealsByDate(String date) async {
    final list = await _databaseHelper.getMealsByDate(date);
    return list.map((map) => MealModel.fromMap(map)).toList();
  }

  Future<List<MealModel>> getTodayMeals() async {
    final list = await _databaseHelper.getTodayMeals();
    return list.map((map) => MealModel.fromMap(map)).toList();
  }

  Future<Map<String, dynamic>> getTodayStatistics() async {
    return await _databaseHelper.getTodayStatistics();
  }

  Future<Map<String, dynamic>> getWeeklyStatistics() async {
    return await _databaseHelper.getWeeklyStatistics();
  }

  Future<void> syncFromCloud() async {
    final currentUser = _authRepo?.getCurrentUser();
    if (currentUser == null || _remoteDataSource == null) return;

    try {
      final remoteMeals = await _remoteDataSource.fetchMeals(currentUser.uid);
      for (final meal in remoteMeals) {
        if (meal.id != null) {
          final existing = await _databaseHelper.getMealsByDate(meal.date);
          final exists = existing.any((m) => m['id'] == meal.id);
          if (!exists) {
            await _databaseHelper.insertMeal(meal.toMap());
          }
        }
      }
    } catch (_) {}
  }
}
