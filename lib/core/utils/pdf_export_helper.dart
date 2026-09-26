import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/meals/data/models/meal_model.dart';

class PdfExportHelper {
  static Future<void> exportMealsReport({
    required String title,
    required String dateRange,
    required List<MealModel> meals,
    Map<String, int>? categoryBreakdown,
  }) async {
    final pdf = pw.Document();

    final now = DateTime.now();
    final generatedOn = DateFormat('MMMM d, y • hh:mm a').format(now);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 16),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.green700, width: 2),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'My Food Diary',
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green800,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        title,
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey800,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Period: $dateRange',
                        style: const pw.TextStyle(
                          fontSize: 11,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.green50,
                          borderRadius: pw.BorderRadius.circular(6),
                          border: pw.Border.all(color: PdfColors.green300),
                        ),
                        child: pw.Text(
                          'Nutrition Report',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green800,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'Generated: $generatedOn',
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 16),

            // Metrics Summary Cards
            if (categoryBreakdown != null) ...[
              pw.Row(
                children: [
                  _buildMetricCard('Total Meals', '${meals.length}', PdfColors.green700),
                  pw.SizedBox(width: 8),
                  _buildMetricCard('Breakfast', '${categoryBreakdown['Breakfast'] ?? 0}', PdfColors.orange700),
                  pw.SizedBox(width: 8),
                  _buildMetricCard('Lunch', '${categoryBreakdown['Lunch'] ?? 0}', PdfColors.teal700),
                  pw.SizedBox(width: 8),
                  _buildMetricCard('Dinner', '${categoryBreakdown['Dinner'] ?? 0}', PdfColors.blue700),
                  pw.SizedBox(width: 8),
                  _buildMetricCard('Snack', '${categoryBreakdown['Snack'] ?? 0}', PdfColors.purple700),
                ],
              ),
              pw.SizedBox(height: 20),
            ],

            // Section Title
            pw.Text(
              'Detailed Meal Log (${meals.length} records)',
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              ),
            ),
            pw.SizedBox(height: 8),

            // Meals Table
            if (meals.isEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'No meals recorded for this period.',
                  style: const pw.TextStyle(color: PdfColors.grey500),
                ),
              )
            else
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey300,
                  width: 0.5,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(1.8),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(5),
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.green100,
                    ),
                    children: [
                      _buildTableHeaderCell('Date'),
                      _buildTableHeaderCell('Time'),
                      _buildTableHeaderCell('Category'),
                      _buildTableHeaderCell('Meal Details'),
                    ],
                  ),
                  // Rows
                  ...meals.map((meal) {
                    return pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.white,
                      ),
                      children: [
                        _buildTableCell(meal.date),
                        _buildTableCell(meal.time),
                        _buildCategoryCell(meal.mealType),
                        _buildTableCell(meal.mealDetails),
                      ],
                    );
                  }),
                ],
              ),

            pw.SizedBox(height: 24),

            // Footer note
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'My Food Diary • Empowering healthy habits every day.',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Text(
                    'Page 1',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Food_Diary_Report_${DateFormat('yyyyMMdd').format(now)}.pdf',
    );
  }

  static pw.Widget _buildMetricCard(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey50,
          borderRadius: pw.BorderRadius.circular(6),
          border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              label,
              style: const pw.TextStyle(
                fontSize: 8,
                color: PdfColors.grey700,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildTableHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.green900,
        ),
      ),
    );
  }

  static pw.Widget _buildTableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        style: const pw.TextStyle(
          fontSize: 9,
          color: PdfColors.grey900,
        ),
      ),
    );
  }

  static pw.Widget _buildCategoryCell(String category) {
    PdfColor badgeColor = PdfColors.grey600;
    PdfColor badgeBg = PdfColors.grey100;

    switch (category.toLowerCase()) {
      case 'breakfast':
        badgeColor = PdfColors.orange800;
        badgeBg = PdfColors.orange50;
        break;
      case 'lunch':
        badgeColor = PdfColors.teal800;
        badgeBg = PdfColors.teal50;
        break;
      case 'dinner':
        badgeColor = PdfColors.blue800;
        badgeBg = PdfColors.blue50;
        break;
      case 'snack':
        badgeColor = PdfColors.purple800;
        badgeBg = PdfColors.purple50;
        break;
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: pw.BoxDecoration(
          color: badgeBg,
          borderRadius: pw.BorderRadius.circular(4),
          border: pw.Border.all(color: badgeColor, width: 0.5),
        ),
        child: pw.Text(
          category,
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
            color: badgeColor,
          ),
        ),
      ),
    );
  }
}
