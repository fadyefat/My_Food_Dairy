import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_food_diary/core/routing/routes.dart';
import 'package:my_food_diary/core/theme/app_colors.dart';
import 'package:my_food_diary/core/theme/app_styles.dart';
import 'package:my_food_diary/core/widgets/custom_button.dart';
import 'package:my_food_diary/features/meals/data/models/meal_model.dart';
import '../cubit/daily_log_cubit.dart';
import '../cubit/daily_log_state.dart';

class DailyLogScreen extends StatefulWidget {
  const DailyLogScreen({super.key});

  @override
  State<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  DateTime selectedDate = DateTime.now();
  final TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dateController.text = DateFormat('MM/dd/yyyy').format(selectedDate);
    context.read<DailyLogCubit>().loadMealsForDate(selectedDate);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade700,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      if (!mounted) return;
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('MM/dd/yyyy').format(selectedDate);
      });
      context.read<DailyLogCubit>().loadMealsForDate(selectedDate);
    }
  }

  Future<void> _deleteMeal(MealModel meal) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Meal'),
          content: const Text('Are you sure you want to delete this meal?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true && meal.id != null) {
      if (!mounted) return;
      context.read<DailyLogCubit>().deleteMeal(meal.id!);
    }
  }

  Future<void> _editMeal(MealModel meal) async {
    final result = await Navigator.pushNamed(
      context,
      Routes.mealScreen,
      arguments: meal,
    );

    if (result == true && mounted) {
      context.read<DailyLogCubit>().refreshCurrentDate();
    }
  }

  IconData _getMealTypeIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.local_cafe;
      default:
        return Icons.restaurant;
    }
  }

  String get formattedSelectedDate {
    return DateFormat('EEEE, MMMM d, y').format(selectedDate);
  }

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightGreenBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.green[800],
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Daily Log",
          style: TextStyle(
            color: Colors.green[800],
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocConsumer<DailyLogCubit, DailyLogState>(
        listener: (context, state) {
          if (state is DailyLogError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          } else if (state is MealDeletedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.primaryGreen),
            );
          }
        },
        builder: (context, state) {
          List<MealModel> meals = [];
          bool isLoading = false;

          if (state is DailyLogLoading) {
            isLoading = true;
          } else if (state is DailyLogLoaded) {
            meals = state.meals;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Selection Container
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: AppColors.primaryGreen,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Select Date",
                              style: AppStyles.font16SemiBoldGreen,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Date",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _selectDate,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: dateController,
                              enabled: false,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                suffixIcon: Icon(
                                  Icons.calendar_today,
                                  color: AppColors.greyText,
                                  size: 18,
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          formattedSelectedDate,
                          style: AppStyles.font14Grey,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Meals Container
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                              ),
                            ),
                          )
                        : meals.isEmpty
                            ? Column(
                                children: [
                                  const Text(
                                    "No meals recorded for this date",
                                    style: AppStyles.font16MediumDark,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  CustomButton(
                                    text: "Add Your First Meal",
                                    onPressed: () async {
                                      final result = await Navigator.pushNamed(
                                        context,
                                        Routes.mealScreen,
                                      );
                                      if (result == true && context.mounted) {
                                        context.read<DailyLogCubit>().refreshCurrentDate();
                                      }
                                    },
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Meals for $formattedSelectedDate",
                                    style: AppStyles.font16SemiBoldGreen,
                                  ),
                                  const SizedBox(height: 16),
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: meals.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final meal = meals[index];
                                      final mealColor = AppColors.getMealTypeColor(meal.mealType);

                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: mealColor.withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    _getMealTypeIcon(meal.mealType),
                                                    color: mealColor,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    meal.mealType,
                                                    style: TextStyle(
                                                      color: mealColor,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Text(
                                                    meal.time,
                                                    style: AppStyles.font14Grey,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  PopupMenuButton<String>(
                                                    onSelected: (value) {
                                                      if (value == 'edit') {
                                                        _editMeal(meal);
                                                      } else if (value == 'delete') {
                                                        _deleteMeal(meal);
                                                      }
                                                    },
                                                    itemBuilder: (context) => [
                                                      const PopupMenuItem(
                                                        value: 'edit',
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.edit, size: 18),
                                                            SizedBox(width: 8),
                                                            Text('Edit'),
                                                          ],
                                                        ),
                                                      ),
                                                      const PopupMenuItem(
                                                        value: 'delete',
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.delete,
                                                                size: 18, color: Colors.red),
                                                            SizedBox(width: 8),
                                                            Text('Delete',
                                                                style: TextStyle(color: Colors.red)),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                    child: const Icon(
                                                      Icons.more_vert,
                                                      color: AppColors.greyText,
                                                      size: 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                meal.mealDetails,
                                                style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              if (meal.photoPath != null)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 8),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(8),
                                                    child: Image.file(
                                                      File(meal.photoPath!),
                                                      height: 100,
                                                      width: 100,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (context, error, stackTrace) {
                                                        return Container(
                                                          height: 100,
                                                          width: 100,
                                                          color: Colors.grey[300],
                                                          child: const Icon(
                                                            Icons.broken_image,
                                                            color: AppColors.greyText,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  CustomButton(
                                    text: "Add Another Meal",
                                    icon: Icons.add,
                                    onPressed: () async {
                                      final result = await Navigator.pushNamed(
                                        context,
                                        Routes.mealScreen,
                                      );
                                      if (result == true && context.mounted) {
                                        context.read<DailyLogCubit>().refreshCurrentDate();
                                      }
                                    },
                                  ),
                                ],
                              ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
