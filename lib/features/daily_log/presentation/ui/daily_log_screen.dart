import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_food_diary/core/routing/routes.dart';
import 'package:my_food_diary/core/theme/app_colors.dart';
import 'package:my_food_diary/core/theme/app_styles.dart';
import 'package:my_food_diary/core/utils/pdf_export_helper.dart';
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
  final TextEditingController searchController = TextEditingController();
  String selectedCategory = 'All';
  final List<String> categories = ['All', 'Breakfast', 'Lunch', 'Dinner', 'Snack'];

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
        searchController.clear();
        selectedCategory = 'All';
      });
      context.read<DailyLogCubit>().loadMealsForDate(selectedDate);
    }
  }

  Future<void> _exportPdf(List<MealModel> meals) async {
    if (meals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No meals to export for this day.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final breakdown = <String, int>{
      'Breakfast': 0,
      'Lunch': 0,
      'Dinner': 0,
      'Snack': 0,
    };
    for (var m in meals) {
      breakdown[m.mealType] = (breakdown[m.mealType] ?? 0) + 1;
    }

    await PdfExportHelper.exportMealsReport(
      title: 'Daily Meal Log',
      dateRange: formattedSelectedDate,
      meals: meals,
      categoryBreakdown: breakdown,
    );
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
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<DailyLogCubit, DailyLogState>(
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
        List<MealModel> allMeals = [];
        List<MealModel> meals = [];
        bool isLoading = false;

        if (state is DailyLogLoading) {
          isLoading = true;
        } else if (state is DailyLogLoaded) {
          allMeals = state.allMeals;
          meals = state.meals;
          selectedCategory = state.selectedCategory;
        }

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkScaffoldBackground : AppColors.lightGreenBackground,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDark ? Colors.white : Colors.green[800],
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Daily Log",
              style: TextStyle(
                color: isDark ? Colors.white : Colors.green[800],
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.primaryGreen),
                tooltip: 'Export PDF Report',
                onPressed: () => _exportPdf(allMeals),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Selection Container
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCardBackground : AppColors.white,
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
                        Text(
                          "Date",
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _selectDate,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark ? AppColors.darkBorder : Colors.grey[300]!,
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
                              style: TextStyle(
                                color: isDark ? AppColors.darkTextPrimary : Colors.black87,
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

                const SizedBox(height: 24),

                // Meals Container
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCardBackground : AppColors.white,
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
                    padding: const EdgeInsets.all(20.0),
                    child: isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                              ),
                            ),
                          )
                        : allMeals.isEmpty
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Meals for $formattedSelectedDate",
                                        style: AppStyles.font16SemiBoldGreen,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryGreen.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          "${allMeals.length} total",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryGreen,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Search Bar
                                  Container(
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.darkSurface : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isDark ? AppColors.darkBorder : Colors.grey[300]!,
                                      ),
                                    ),
                                    child: TextField(
                                      controller: searchController,
                                      style: TextStyle(
                                        color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                                        fontSize: 14,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "Search meals by name or details...",
                                        hintStyle: TextStyle(
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.greyText,
                                          fontSize: 13,
                                        ),
                                        prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen, size: 20),
                                        suffixIcon: searchController.text.isNotEmpty
                                            ? IconButton(
                                                icon: const Icon(Icons.clear, size: 18),
                                                onPressed: () {
                                                  searchController.clear();
                                                  context.read<DailyLogCubit>().filterMeals(query: '');
                                                },
                                              )
                                            : null,
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      ),
                                      onChanged: (val) {
                                        setState(() {});
                                        context.read<DailyLogCubit>().filterMeals(query: val);
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Filter Chips
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: categories.map((cat) {
                                        final isSelected = selectedCategory.toLowerCase() == cat.toLowerCase();
                                        final catColor = cat == 'All' ? AppColors.primaryGreen : AppColors.getMealTypeColor(cat);
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: FilterChip(
                                            label: Text(
                                              cat,
                                              style: TextStyle(
                                                color: isSelected ? Colors.white : (isDark ? AppColors.darkTextPrimary : Colors.black87),
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                fontSize: 12,
                                              ),
                                            ),
                                            selected: isSelected,
                                            selectedColor: catColor,
                                            backgroundColor: isDark ? AppColors.darkSurface : Colors.grey[100],
                                            showCheckmark: false,
                                            onSelected: (selected) {
                                              final newCat = isSelected && cat != 'All' ? 'All' : cat;
                                              setState(() {
                                                selectedCategory = newCat;
                                              });
                                              context.read<DailyLogCubit>().filterMeals(category: newCat);
                                            },
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Filtered Meals List or Empty Search
                                  if (meals.isEmpty)
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                                        child: Column(
                                          children: [
                                            Icon(Icons.search_off, size: 40, color: Colors.grey[400]),
                                            const SizedBox(height: 8),
                                            Text(
                                              "No meals match your filter",
                                              style: AppStyles.font14Grey,
                                            ),
                                            const SizedBox(height: 8),
                                            TextButton(
                                              onPressed: () {
                                                searchController.clear();
                                                setState(() => selectedCategory = 'All');
                                                context.read<DailyLogCubit>().filterMeals(query: '', category: 'All');
                                              },
                                              child: const Text(
                                                "Reset Filters",
                                                style: TextStyle(
                                                  color: AppColors.primaryGreen,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  else
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
                                            color: isDark ? AppColors.darkSurface : Colors.grey[50],
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
                                                  style: TextStyle(
                                                    color: isDark ? AppColors.darkTextPrimary : Colors.black87,
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
          ),
        );
      },
    );
  }
}
