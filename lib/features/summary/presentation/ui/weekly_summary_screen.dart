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

class WeeklySummaryScreen extends StatefulWidget {
  const WeeklySummaryScreen({super.key});

  @override
  State<WeeklySummaryScreen> createState() => _WeeklySummaryScreenState();
}

class _WeeklySummaryScreenState extends State<WeeklySummaryScreen> {
  int _touchedPieIndex = -1;
  int _touchedBarIndex = -1;

  @override
  void initState() {
    super.initState();
    context.read<SummaryCubit>().loadWeeklyStatistics();
  }

  String _getCurrentWeekRange() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return '${months[weekStart.month - 1]} ${weekStart.day} - ${months[weekEnd.month - 1]} ${weekEnd.day}, ${weekEnd.year}';
  }

  Future<void> _navigateToAddMeal() async {
    final result = await Navigator.pushNamed(context, Routes.mealScreen);
    if (result == true && mounted) {
      context.read<SummaryCubit>().loadWeeklyStatistics();
    }
  }

  Future<void> _exportPdf(List<Map<String, dynamic>> rawMeals, Map<String, int> mealTypeCounts) async {
    if (rawMeals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No meals recorded this week to export.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final meals = rawMeals.map((m) => MealModel.fromMap(m)).toList();
    await PdfExportHelper.exportMealsReport(
      title: 'Weekly Nutrition Summary',
      dateRange: _getCurrentWeekRange(),
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
        double avgMealsPerDay = 0.0;
        String mostCommonMeal = "None";
        Map<String, int> mealTypeCounts = {};
        Map<String, int> dailyMealCounts = {};
        List<Map<String, dynamic>> rawMeals = [];

        if (state is WeeklySummaryLoaded) {
          totalMeals = state.totalMeals;
          avgMealsPerDay = state.avgMealsPerDay;
          mostCommonMeal = state.mostCommonMeal;
          mealTypeCounts = state.mealTypeCounts;
          dailyMealCounts = state.dailyMealCounts;
          rawMeals = state.meals;
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
              "Weekly Summary",
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
                tooltip: 'Export Weekly PDF Report',
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
                      // Week Overview Container
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Week Overview",
                                style: TextStyle(
                                  color: isDark ? AppColors.darkTextPrimary : Colors.green[700],
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getCurrentWeekRange(),
                                style: AppStyles.font14Grey,
                              ),
                              const SizedBox(height: 20),

                              // Statistics Row
                              Row(
                                children: [
                                  // Total Meals
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: isDark ? AppColors.darkSurface : Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            totalMeals.toString(),
                                            style: TextStyle(
                                              color: Colors.orange.shade600,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            "Total Meals",
                                            style: TextStyle(
                                              color: AppColors.greyText,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // Avg/Day
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: isDark ? AppColors.darkSurface : Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            avgMealsPerDay.toStringAsFixed(1),
                                            style: TextStyle(
                                              color: Colors.green.shade600,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            "Avg/Day",
                                            style: TextStyle(
                                              color: AppColors.greyText,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // Most Common
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: isDark ? AppColors.darkSurface : Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            mostCommonMeal == 'None' ? '-' : mostCommonMeal,
                                            style: TextStyle(
                                              color: Colors.blue.shade600,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            "Top Meal",
                                            style: TextStyle(
                                              color: AppColors.greyText,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
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
                      ),

                      const SizedBox(height: 16),

                      // Bar Chart: Meals per Day
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
                                  "Daily Activity",
                                  style: TextStyle(
                                    color: isDark ? AppColors.darkTextPrimary : Colors.green[800],
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Icon(Icons.bar_chart, color: AppColors.primaryGreen, size: 22),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Number of meals logged per day this week",
                              style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.greyText),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 190,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: _calculateMaxBarY(dailyMealCounts),
                                  barTouchData: BarTouchData(
                                    touchCallback: (FlTouchEvent event, barTouchResponse) {
                                      setState(() {
                                        if (!event.isInterestedForInteractions ||
                                            barTouchResponse == null ||
                                            barTouchResponse.spot == null) {
                                          _touchedBarIndex = -1;
                                          return;
                                        }
                                        _touchedBarIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                                      });
                                    },
                                    touchTooltipData: BarTouchTooltipData(
                                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                        final day = days[group.x.toInt()];
                                        return BarTooltipItem(
                                          '$day\n${rod.toY.toInt()} meals',
                                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                        );
                                      },
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (double value, TitleMeta meta) {
                                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                          final int index = value.toInt();
                                          if (index >= 0 && index < days.length) {
                                            final isToday = (DateTime.now().weekday - 1) == index;
                                            return SideTitleWidget(
                                              axisSide: meta.axisSide,
                                              child: Text(
                                                days[index],
                                                style: TextStyle(
                                                  color: isToday
                                                      ? AppColors.primaryOrange
                                                      : (isDark ? AppColors.darkTextSecondary : AppColors.greyText),
                                                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 2,
                                        reservedSize: 28,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            value.toInt().toString(),
                                            style: TextStyle(
                                              color: isDark ? AppColors.darkTextSecondary : AppColors.greyText,
                                              fontSize: 10,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: 2,
                                    getDrawingHorizontalLine: (value) => FlLine(
                                      color: isDark ? AppColors.darkBorder : Colors.grey.shade200,
                                      strokeWidth: 1,
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups: _buildBarGroups(dailyMealCounts, isDark),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Weekly Category Pie Chart
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
                                  "Weekly Category Distribution",
                                  style: TextStyle(
                                    color: isDark ? AppColors.darkTextPrimary : Colors.green[800],
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Icon(Icons.donut_large, color: AppColors.primaryGreen, size: 20),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (totalMeals == 0)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                                  child: Text(
                                    "No meals logged yet this week",
                                    style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.greyText),
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
                                                _touchedPieIndex = -1;
                                                return;
                                              }
                                              _touchedPieIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                            });
                                          },
                                        ),
                                        borderData: FlBorderData(show: false),
                                        sectionsSpace: 3,
                                        centerSpaceRadius: 38,
                                        sections: _buildPieChartSections(mealTypeCounts, totalMeals),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
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

                      // Status & Actions Container
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
                            children: [
                              Text(
                                totalMeals == 0
                                    ? "No meals recorded this week"
                                    : "Keep it up! You've recorded $totalMeals meal${totalMeals > 1 ? 's' : ''} this week",
                                style: TextStyle(
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.greyText,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              CustomButton(
                                text: totalMeals == 0
                                    ? "Start Tracking Your Meals"
                                    : "Add Another Meal",
                                icon: Icons.add,
                                onPressed: _navigateToAddMeal,
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

  double _calculateMaxBarY(Map<String, int> dailyCounts) {
    if (dailyCounts.isEmpty) return 6;
    int maxVal = 0;
    for (var count in dailyCounts.values) {
      if (count > maxVal) maxVal = count;
    }
    return (maxVal < 4 ? 6 : maxVal + 2).toDouble();
  }

  List<BarChartGroupData> _buildBarGroups(Map<String, int> dailyCounts, bool isDark) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final todayWeekday = DateTime.now().weekday - 1; // 0=Mon, 6=Sun

    return List.generate(days.length, (i) {
      final dayName = days[i];
      final count = dailyCounts[dayName] ?? 0;
      final isToday = todayWeekday == i;
      final isTouched = _touchedBarIndex == i;

      Color barColor = isToday ? AppColors.primaryOrange : AppColors.primaryGreen;
      if (isTouched) {
        barColor = barColor.withValues(alpha: 0.8);
      }

      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: barColor,
            width: 18,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _calculateMaxBarY(dailyCounts),
              color: isDark ? AppColors.darkSurface : Colors.grey.shade100,
            ),
          ),
        ],
      );
    });
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
        final isTouched = idx == _touchedPieIndex;
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
