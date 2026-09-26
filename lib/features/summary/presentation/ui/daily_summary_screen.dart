import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/utils/pdf_export_helper.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../meals/data/models/meal_model.dart';
import '../cubit/summary_cubit.dart';
import '../cubit/summary_state.dart';

class DailySummaryScreen extends StatefulWidget {
  const DailySummaryScreen({super.key});

  @override
  State<DailySummaryScreen> createState() => _DailySummaryScreenState();
}

class _DailySummaryScreenState extends State<DailySummaryScreen> {
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    context.read<SummaryCubit>().loadTodayStatistics();
  }

  String getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  Future<void> _navigateToAddMeal() async {
    final result = await Navigator.pushNamed(context, Routes.mealScreen);
    if (result == true && mounted) {
      context.read<SummaryCubit>().loadTodayStatistics();
    }
  }

  Future<void> _exportPdf(List<Map<String, dynamic>> rawMeals, Map<String, int> mealTypeCounts) async {
    if (rawMeals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No meals recorded today to export.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final meals = rawMeals.map((m) => MealModel.fromMap(m)).toList();
    await PdfExportHelper.exportMealsReport(
      title: "Today's Nutrition Summary",
      dateRange: getCurrentDate(),
      meals: meals,
      categoryBreakdown: mealTypeCounts,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<SummaryCubit, SummaryState>(
      listener: (context, state) {
        if (state is SummaryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        int totalMeals = 0;
        int mealTypes = 0;
        Map<String, int> mealTypeCounts = {};
        List<Map<String, dynamic>> rawMeals = [];

        if (state is DailySummaryLoaded) {
          totalMeals = state.totalMeals;
          mealTypes = state.mealTypes;
          mealTypeCounts = state.mealTypeCounts;
          rawMeals = state.meals;
        }

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkScaffoldBackground : AppColors.cardLightGreen,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: isDark ? Colors.white : AppColors.primaryGreen,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              "Today's Summary",
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.primaryGreen,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.primaryGreen),
                tooltip: 'Export PDF Report',
                onPressed: () => _exportPdf(rawMeals, mealTypeCounts),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: state is SummaryLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Date & Metrics Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  color: AppColors.primaryGreen,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  getCurrentDate(),
                                  style: AppStyles.font14SemiBoldGreen,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                // Total Meals Card
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.darkSurface : AppColors.lightOrange,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          totalMeals.toString(),
                                          style: AppStyles.font32BoldOrange,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Total Meals',
                                          style: TextStyle(
                                            color: isDark ? AppColors.darkTextSecondary : AppColors.greyText,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Meal Types Card
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.darkSurface : AppColors.cardLightGreen,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          mealTypes.toString(),
                                          style: AppStyles.font32BoldGreen,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Meal Types',
                                          style: TextStyle(
                                            color: isDark ? AppColors.darkTextSecondary : AppColors.greyText,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Chart Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Meal Breakdown",
                                  style: TextStyle(
                                    color: isDark ? AppColors.darkTextPrimary : Colors.green[800],
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Icon(Icons.pie_chart, color: AppColors.primaryGreen, size: 20),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (totalMeals == 0)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                                  child: Column(
                                    children: [
                                      Icon(Icons.restaurant, size: 48, color: Colors.grey[400]),
                                      const SizedBox(height: 8),
                                      Text(
                                        "No meals recorded yet today",
                                        style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.greyText),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Column(
                                children: [
                                  SizedBox(
                                    height: 180,
                                    child: PieChart(
                                      PieChartData(
                                        pieTouchData: PieTouchData(
                                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                            setState(() {
                                              if (!event.isInterestedForInteractions ||
                                                  pieTouchResponse == null ||
                                                  pieTouchResponse.touchedSection == null) {
                                                _touchedIndex = -1;
                                                return;
                                              }
                                              _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                            });
                                          },
                                        ),
                                        borderData: FlBorderData(show: false),
                                        sectionsSpace: 3,
                                        centerSpaceRadius: 40,
                                        sections: _buildPieChartSections(mealTypeCounts, totalMeals),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Legend
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 8,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      _buildLegendItem('Breakfast', mealTypeCounts['Breakfast'] ?? 0, AppColors.breakfastColor, isDark),
                                      _buildLegendItem('Lunch', mealTypeCounts['Lunch'] ?? 0, AppColors.lunchColor, isDark),
                                      _buildLegendItem('Dinner', mealTypeCounts['Dinner'] ?? 0, AppColors.dinnerColor, isDark),
                                      _buildLegendItem('Snack', mealTypeCounts['Snack'] ?? 0, AppColors.snackColor, isDark),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Action Button Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
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
                        child: Column(
                          children: [
                            Text(
                              totalMeals == 0
                                  ? 'No meals recorded for today'
                                  : 'Great job! You\'ve tracked $totalMeals meal${totalMeals > 1 ? 's' : ''} today',
                              style: TextStyle(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.greyText,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            CustomButton(
                              text: totalMeals == 0 ? 'Add Your First Meal' : 'Add Another Meal',
                              icon: Icons.add,
                              onPressed: _navigateToAddMeal,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  List<PieChartSectionData> _buildPieChartSections(Map<String, int> counts, int total) {
    final categories = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
    final colors = [AppColors.breakfastColor, AppColors.lunchColor, AppColors.dinnerColor, AppColors.snackColor];

    final List<PieChartSectionData> sections = [];
    int idx = 0;

    for (int i = 0; i < categories.length; i++) {
      final cat = categories[i];
      final count = counts[cat] ?? 0;
      if (count > 0) {
        final isTouched = idx == _touchedIndex;
        final radius = isTouched ? 48.0 : 40.0;
        final fontSize = isTouched ? 14.0 : 12.0;

        sections.add(
          PieChartSectionData(
            color: colors[i],
            value: count.toDouble(),
            title: '${((count / total) * 100).round()}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
        idx++;
      }
    }
    return sections;
  }

  Widget _buildLegendItem(String title, int count, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '$title: $count',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkTextPrimary : Colors.black87,
          ),
        ),
      ],
    );
  }
}
