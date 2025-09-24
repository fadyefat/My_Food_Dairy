import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'food_diary.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE meals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        meal_type TEXT NOT NULL,
        meal_details TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        photo_path TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // Insert a new meal
  Future<int> insertMeal(Map<String, dynamic> meal) async {
    final db = await database;
    return await db.insert('meals', meal);
  }

  // Get all meals for a specific date
  Future<List<Map<String, dynamic>>> getMealsByDate(String date) async {
    final db = await database;
    return await db.query(
      'meals',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'time ASC',
    );
  }

  // Get all meals for today
  Future<List<Map<String, dynamic>>> getTodayMeals() async {
    final today = DateTime.now();
    final dateString = '${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}';
    return await getMealsByDate(dateString);
  }

  // Get meals for a date range (for weekly summary)
  Future<List<Map<String, dynamic>>> getMealsInDateRange(String startDate, String endDate) async {
    final db = await database;
    return await db.query(
      'meals',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date ASC, time ASC',
    );
  }

  // Get meals for current week
  Future<List<Map<String, dynamic>>> getWeeklyMeals() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(Duration(days: 6));

    final startDate = '${weekStart.day.toString().padLeft(2, '0')}/${weekStart.month.toString().padLeft(2, '0')}/${weekStart.year}';
    final endDate = '${weekEnd.day.toString().padLeft(2, '0')}/${weekEnd.month.toString().padLeft(2, '0')}/${weekEnd.year}';

    return await getMealsInDateRange(startDate, endDate);
  }

  // Update a meal
  Future<int> updateMeal(int id, Map<String, dynamic> meal) async {
    final db = await database;
    return await db.update(
      'meals',
      meal,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a meal
  Future<int> deleteMeal(int id) async {
    final db = await database;
    return await db.delete(
      'meals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get meal by ID
  Future<Map<String, dynamic>?> getMealById(int id) async {
    final db = await database;
    final results = await db.query(
      'meals',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Get meal statistics
  Future<Map<String, dynamic>> getMealStatistics() async {
    final db = await database;

    // Total meals
    final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM meals');
    final totalMeals = totalResult.first['count'] as int;

    // Meals by type
    final typeResult = await db.rawQuery('''
      SELECT meal_type, COUNT(*) as count 
      FROM meals 
      GROUP BY meal_type 
      ORDER BY count DESC
    ''');

    // Most common meal type
    String mostCommonType = 'None';
    if (typeResult.isNotEmpty) {
      mostCommonType = typeResult.first['meal_type'] as String;
    }

    return {
      'totalMeals': totalMeals,
      'mostCommonType': mostCommonType,
      'mealsByType': typeResult,
    };
  }

  // Get today's statistics
  Future<Map<String, dynamic>> getTodayStatistics() async {
    final todayMeals = await getTodayMeals();
    final totalMeals = todayMeals.length;

    // Count unique meal types for today
    final mealTypes = <String>{};
    for (var meal in todayMeals) {
      mealTypes.add(meal['meal_type'] as String);
    }

    return {
      'totalMeals': totalMeals,
      'mealTypes': mealTypes.length,
    };
  }

  // Get weekly statistics
  Future<Map<String, dynamic>> getWeeklyStatistics() async {
    final weeklyMeals = await getWeeklyMeals();
    final totalMeals = weeklyMeals.length;
    final avgMealsPerDay = totalMeals / 7.0;

    // Count meal types
    final mealTypeCounts = <String, int>{};
    for (var meal in weeklyMeals) {
      final type = meal['meal_type'] as String;
      mealTypeCounts[type] = (mealTypeCounts[type] ?? 0) + 1;
    }

    String mostCommonMeal = 'None';
    if (mealTypeCounts.isNotEmpty) {
      mostCommonMeal = mealTypeCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    }

    return {
      'totalMeals': totalMeals,
      'avgMealsPerDay': avgMealsPerDay,
      'mostCommonMeal': mostCommonMeal,
    };
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}