import '../../../../core/database/database_helper.dart';
import '../models/meal_model.dart';

class MealRepo {
  final DatabaseHelper _databaseHelper;

  MealRepo(this._databaseHelper);

  Future<int> insertMeal(MealModel meal) async {
    return await _databaseHelper.insertMeal(meal.toMap());
  }

  Future<int> updateMeal(MealModel meal) async {
    if (meal.id == null) {
      throw ArgumentError('Meal ID cannot be null for update');
    }
    return await _databaseHelper.updateMeal(meal.id!, meal.toMap());
  }

  Future<int> deleteMeal(int id) async {
    return await _databaseHelper.deleteMeal(id);
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
}
