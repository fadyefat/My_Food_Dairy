import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/models/meal_model.dart';
import '../cubit/meal_cubit.dart';
import '../cubit/meal_state.dart';

class MealScreen extends StatefulWidget {
  final MealModel? editMeal;

  const MealScreen({super.key, this.editMeal});

  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  String selectedMealType = 'Breakfast';
  final TextEditingController mealDetailsController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  final List<String> mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.editMeal != null) {
      selectedMealType = widget.editMeal!.mealType;
      mealDetailsController.text = widget.editMeal!.mealDetails;
      dateController.text = widget.editMeal!.date;
      timeController.text = widget.editMeal!.time;
    } else {
      final now = DateTime.now();
      dateController.text =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
      timeController.text =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';
    }
  }

  void _onSaveMeal() {
    context.read<MealCubit>().saveMeal(
          id: widget.editMeal?.id,
          mealType: selectedMealType,
          mealDetails: mealDetailsController.text,
          date: dateController.text,
          time: timeController.text,
          photoPath: widget.editMeal?.photoPath,
        );
  }

  @override
  void dispose() {
    mealDetailsController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MealCubit, MealState>(
      listener: (context, state) {
        if (state is MealSaveSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
          Navigator.of(context).pop(true);
        } else if (state is MealSaveError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final bool isLoading = state is MealLoading;

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          appBar: AppBar(
            backgroundColor: AppColors.scaffoldBackground,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.primaryGreen,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              widget.editMeal != null ? 'Edit Meal' : 'Add Meal',
              style: AppStyles.font18SemiBoldGreen,
            ),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meal Type Section
                const Text(
                  'Meal Type',
                  style: AppStyles.font16SemiBoldGreen,
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderGrey),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedMealType,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.greyText),
                    items: mealTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryOrange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              type,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.darkText,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedMealType = newValue;
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Meal Details Section
                const Text(
                  'Meal Details',
                  style: AppStyles.font16SemiBoldGreen,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: CustomTextField(
                    controller: mealDetailsController,
                    hintText: 'e.g. Eggs + Bread + Tea',
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                  ),
                ),

                const SizedBox(height: 24),

                // Date Section
                const Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.primaryGreen,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Date',
                      style: AppStyles.font16SemiBoldGreen,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: dateController,
                  readOnly: true,
                  suffixIcon: const Icon(
                    Icons.calendar_today,
                    color: AppColors.greyText,
                    size: 20,
                  ),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() {
                        dateController.text =
                            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                      });
                    }
                  },
                ),

                const SizedBox(height: 24),

                // Time Section
                const Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: AppColors.primaryGreen,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Time',
                      style: AppStyles.font16SemiBoldGreen,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: timeController,
                  readOnly: true,
                  suffixIcon: const Icon(
                    Icons.access_time,
                    color: AppColors.greyText,
                    size: 20,
                  ),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        final hour = picked.hourOfPeriod;
                        final minute = picked.minute.toString().padLeft(2, '0');
                        final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
                        timeController.text =
                            '${hour.toString().padLeft(2, '0')}:$minute $period';
                      });
                    }
                  },
                ),

                const SizedBox(height: 24),

                // Photo Section
                const Text(
                  'Photo (Optional)',
                  style: AppStyles.font16SemiBoldGreen,
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.lightOrange,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.orangeBorder),
                  ),
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Photo selection feature coming soon!'),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          color: AppColors.primaryOrange,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Add Photo',
                          style: TextStyle(
                            color: AppColors.primaryOrange,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // Save Button
                CustomButton(
                  text: widget.editMeal != null ? 'Update Meal' : 'Save Meal',
                  icon: Icons.save_outlined,
                  isLoading: isLoading,
                  onPressed: _onSaveMeal,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
