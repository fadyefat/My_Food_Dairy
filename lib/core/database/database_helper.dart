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
    final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final List<String> daysInWeek = [];
    for (int i = 0; i < 7; i++) {
      final d = weekStart.add(Duration(days: i));
      daysInWeek.add('${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}');
    }

    final db = await database;
    final placeholders = List.filled(daysInWeek.length, '?').join(',');
    return await db.query(
      'meals',
      where: 'date IN ($placeholders)',
      whereArgs: daysInWeek,
      orderBy: 'date ASC, time ASC',
    );
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

    // Count meal types for today
    final mealTypeCounts = <String, int>{
      'Breakfast': 0,
      'Lunch': 0,
      'Dinner': 0,
      'Snack': 0,
    };
    for (var meal in todayMeals) {
      final type = meal['meal_type'] as String;
      mealTypeCounts[type] = (mealTypeCounts[type] ?? 0) + 1;
    }

    final nonZeroTypes = mealTypeCounts.values.where((c) => c > 0).length;

    return {
      'totalMeals': totalMeals,
      'mealTypes': nonZeroTypes,
      'mealTypeCounts': mealTypeCounts,
      'meals': todayMeals,
    };
  }

  // Get weekly statistics
  Future<Map<String, dynamic>> getWeeklyStatistics() async {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dailyMealCounts = <String, int>{};
    for (var name in dayNames) {
      dailyMealCounts[name] = 0;
    }

    final weeklyMeals = await getWeeklyMeals();
    final totalMeals = weeklyMeals.length;
    final avgMealsPerDay = totalMeals / 7.0;

    // Count meal types
    final mealTypeCounts = <String, int>{
      'Breakfast': 0,
      'Lunch': 0,
      'Dinner': 0,
      'Snack': 0,
    };
    for (var meal in weeklyMeals) {
      final type = meal['meal_type'] as String;
      mealTypeCounts[type] = (mealTypeCounts[type] ?? 0) + 1;

      // Extract day of week from date 'dd/MM/yyyy'
      final dateStr = meal['date'] as String;
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final d = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2]);
        if (d != null && m != null && y != null) {
          final dt = DateTime(y, m, d);
          final weekdayIndex = dt.weekday - 1; // 0=Mon, 6=Sun
          if (weekdayIndex >= 0 && weekdayIndex < 7) {
            final dayKey = dayNames[weekdayIndex];
            dailyMealCounts[dayKey] = (dailyMealCounts[dayKey] ?? 0) + 1;
          }
        }
      }
    }

    String mostCommonMeal = 'None';
    final nonZeroTypes = mealTypeCounts.entries.where((e) => e.value > 0).toList();
    if (nonZeroTypes.isNotEmpty) {
      mostCommonMeal = nonZeroTypes
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    }

    return {
      'totalMeals': totalMeals,
      'avgMealsPerDay': avgMealsPerDay,
      'mostCommonMeal': mostCommonMeal,
      'mealTypeCounts': mealTypeCounts,
      'dailyMealCounts': dailyMealCounts,
      'meals': weeklyMeals,
    };
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
