import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/meal_model.dart';
import '../../data/repos/meal_repo.dart';
import 'meal_state.dart';

class MealCubit extends Cubit<MealState> {
  final MealRepo _mealRepo;

  MealCubit(this._mealRepo) : super(MealInitial());

  Future<void> saveMeal({
    int? id,
    required String mealType,
    required String mealDetails,
    required String date,
    required String time,
    String? photoPath,
  }) async {
    if (mealDetails.trim().isEmpty) {
      emit(MealSaveError('Please enter meal details'));
      return;
    }

    emit(MealLoading());
    try {
      final meal = MealModel(
        id: id,
        mealType: mealType,
        mealDetails: mealDetails.trim(),
        date: date,
        time: time,
        photoPath: photoPath,
        createdAt: DateTime.now().toIso8601String(),
      );

      if (id != null) {
        await _mealRepo.updateMeal(meal);
        emit(MealSaveSuccess('Meal updated successfully!'));
      } else {
        await _mealRepo.insertMeal(meal);
        emit(MealSaveSuccess('Meal saved successfully!'));
      }
    } catch (e) {
      emit(MealSaveError('Error saving meal: $e'));
    }
  }
}
