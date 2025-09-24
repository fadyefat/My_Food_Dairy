class Meal {
  final int? id;
  final String mealType;
  final String mealDetails;
  final String date;
  final String time;
  final String? photoPath;
  final String createdAt;

  Meal({
    this.id,
    required this.mealType,
    required this.mealDetails,
    required this.date,
    required this.time,
    this.photoPath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'meal_type': mealType,
      'meal_details': mealDetails,
      'date': date,
      'time': time,
      'photo_path': photoPath,
      'created_at': createdAt,
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'],
      mealType: map['meal_type'],
      mealDetails: map['meal_details'],
      date: map['date'],
      time: map['time'],
      photoPath: map['photo_path'],
      createdAt: map['created_at'],
    );
  }

  Meal copyWith({
    int? id,
    String? mealType,
    String? mealDetails,
    String? date,
    String? time,
    String? photoPath,
    String? createdAt,
  }) {
    return Meal(
      id: id ?? this.id,
      mealType: mealType ?? this.mealType,
      mealDetails: mealDetails ?? this.mealDetails,
      date: date ?? this.date,
      time: time ?? this.time,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
