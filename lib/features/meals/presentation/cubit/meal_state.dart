abstract class MealState {}

class MealInitial extends MealState {}

class MealLoading extends MealState {}

class MealSaveSuccess extends MealState {
  final String message;
  MealSaveSuccess(this.message);
}

class MealSaveError extends MealState {
  final String error;
  MealSaveError(this.error);
}
