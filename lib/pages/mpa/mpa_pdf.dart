import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:isuze_pqcs/pages/mpa/mpa_deatils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// Define default font sizes for different sections
const double companyInfoFontSize = 12.0;
const double documentHeaderFontSize = 15.0;
const double customerInfoFontSize = 12.0;
const double tableHeaderFontSize = 10.0;
const double tableContentFontSize = 9.0;
const double totalFontSize = 14.0;
const double termsFontSize = 12.0;

Future<Uint8List> generateQfl3Pdf(
    QflT qflRecord, DocumentReference? docRef) async {
  final pdf = pw.Document();

  // Load logo image
  final ByteData logoByteData = await rootBundle.load('images/logo2.png');
  final Uint8List logoUint8List = logoByteData.buffer.asUint8List();
  final pw.MemoryImage logoImage = pw.MemoryImage(logoUint8List);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(20),
      build: (pw.Context context) {
        var container = pw.Container(
          padding: pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            borderRadius: pw.BorderRadius.circular(5),
            color: PdfColors.grey100,
          ),
          width: double.infinity,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'SCORING CRITERIA:',
                style:
                    pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                '3 = Excellent | 2 = Good | 1 = Satisfactory | 0 = Non-Compliant',
                style: pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'NOTE: This document serves as evidence of MPA audit compliance and should be kept for quality management records.',
                style:
                    pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic),
              ),
            ],
          ),
        );
        return [
          // Header Section
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo
              pw.Container(
                height: 80,
                width: 80,
                child: pw.Image(logoImage),
              ),

              pw.SizedBox(width: 10),

              // Title (Centered)
              pw.Expanded(
                flex: 3,
                child: pw.Container(
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'MPA AUDIT CHECKLIST',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ),

              pw.SizedBox(width: 10),

              // Metadata (Right-aligned)
              pw.Container(
                width: 140,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Date:', style: pw.TextStyle(fontSize: 9)),
                        pw.Text(_sanitizeText(qflRecord.date),
                            style: pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Doc Ref:', style: pw.TextStyle(fontSize: 9)),
                        pw.Text(_sanitizeText(docRef?.refNo ?? 'N/A'),
                            style: pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Revision:', style: pw.TextStyle(fontSize: 9)),
                        pw.Text(
                            _sanitizeText(docRef?.revision.toString() ?? 'N/A'),
                            style: pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 10),
          pw.Divider(),
          pw.SizedBox(height: 5),

          // Audit Information
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  'PROJECT MODEL VARIANT: ${_sanitizeText(qflRecord.project_model_Variant)}',
                  style: pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Text(
                  'AUDIT LINE: ${_sanitizeText(qflRecord.audit_department)}',
                  style: pw.TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  'TOTAL AUDIT ITEMS: ${qflRecord.items.length}',
                  style: pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Text(
                  'DATE: ${_sanitizeText(qflRecord.date)}',
                  style: pw.TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 15),

          // Audit Items Grouped by Category
          ..._buildGroupedAuditTables(qflRecord),

          pw.SizedBox(height: 15),

          // Summary Section
          pw.Container(
            padding: pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black),
              color: PdfColors.grey100,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'AUDIT SUMMARY',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Items Audited:',
                        style: pw.TextStyle(fontSize: 10)),
                    pw.Text('${qflRecord.items.length}',
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Categories:',
                        style: pw.TextStyle(fontSize: 10)),
                    pw.Text('${_getCategoryCount(qflRecord.items)}',
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Responsible Persons:',
                        style: pw.TextStyle(fontSize: 10)),
                    pw.Text('${_getResponsibleCount(qflRecord.items)}',
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Average Score:',
                        style: pw.TextStyle(fontSize: 10)),
                    pw.Text(
                        '${_calculateAverageScore(qflRecord.items).toStringAsFixed(2)}',
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Audit Status:', style: pw.TextStyle(fontSize: 10)),
                    pw.Text(
                        '${_getAuditStatus(_calculateAverageScore(qflRecord.items))}',
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 0.5),
                pw.SizedBox(height: 4),
                pw.Text(
                  'CATEGORY BREAKDOWN:',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                ..._buildCategoryBreakdown(qflRecord.items),
              ],
            ),
          ),

          pw.SizedBox(height: 15),

          // Signatures Section
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('AUDITOR SIGNATURE:',
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 15),
                    pw.Container(height: 1, color: PdfColors.black),
                    pw.SizedBox(height: 5),
                    pw.Text('Name: ___________________',
                        style: pw.TextStyle(fontSize: 9)),
                    pw.Text('Date: ${_sanitizeText(qflRecord.date)}',
                        style: pw.TextStyle(fontSize: 9)),
                  ],
                ),
              ),
              pw.SizedBox(width: 30),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('SUPERVISOR SIGNATURE:',
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 15),
                    pw.Container(height: 1, color: PdfColors.black),
                    pw.SizedBox(height: 5),
                    pw.Text('Name: ___________________',
                        style: pw.TextStyle(fontSize: 9)),
                    pw.Text('Date: ___________________',
                        style: pw.TextStyle(fontSize: 9)),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 10),

          // Footer Note
          container,
        ];
      },
      footer: (context) {
        return pw.Text("Page ${context.pageNumber} of ${context.pagesCount}",
            style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.center);
      },
    ),
  );

  return pdf.save();
}

// Helper function to build grouped audit tables by category and responsible
List<pw.Widget> _buildGroupedAuditTables(QflT qflRecord) {
  // Group items by category first, then by responsible person
  Map<String, Map<String, List<Item>>> groupedItems = {};

  for (var item in qflRecord.items) {
    String category = item.category;
    String responsible = item.resp;

    if (!groupedItems.containsKey(category)) {
      groupedItems[category] = {};
    }
    if (!groupedItems[category]!.containsKey(responsible)) {
      groupedItems[category]![responsible] = [];
    }
    groupedItems[category]![responsible]!.add(item);
  }

  List<pw.Widget> tables = [];
  int globalIndex = 1;

  // Create tables for each category and responsible person
  for (var categoryEntry in groupedItems.entries) {
    String category = categoryEntry.key;
    Map<String, List<Item>> responsibleGroups = categoryEntry.value;

    // Add category header
    tables.add(
      pw.Container(
        margin: pw.EdgeInsets.only(top: 15, bottom: 8),
        padding: pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(5),
          border: pw.Border.all(color: PdfColors.grey300, width: 1),
        ),
        child: pw.Row(
          children: [
            pw.Text(
              'GROUP: ${_sanitizeText(category.toUpperCase())}',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                // color: PdfColors.grey800,
              ),
            ),
          ],
        ),
      ),
    );

    // Create a sub-table for each responsible person within this category
    for (var responsibleEntry in responsibleGroups.entries) {
      String responsible = responsibleEntry.key;
      List<Item> items = responsibleEntry.value;

      // Add responsible person sub-header
      tables.add(
        pw.Container(
          margin: pw.EdgeInsets.only(top: 8, bottom: 5, left: 20),
          padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(4),
            border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
          ),
          child: pw.Row(
            children: [
              pw.Text(
                'RESPONSIBLE: ${_sanitizeText(responsible.toUpperCase())}',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  // color: PdfColors.ora800,
                ),
              ),
              pw.Spacer(),
              pw.Text(
                '(${items.length} item${items.length != 1 ? 's' : ''})',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontStyle: pw.FontStyle.italic,
                  color: PdfColors.orange700,
                ),
              ),
            ],
          ),
        ),
      );

      // Add table for this responsible person's items
      tables.add(
        pw.Container(
          margin: pw.EdgeInsets.only(left: 20, right: 0, bottom: 5),
          child: pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
            columnWidths: {
              0: pw.FixedColumnWidth(25),
              1: pw.FlexColumnWidth(4),
              2: pw.FixedColumnWidth(35),
              3: pw.FlexColumnWidth(2.5),
            },
            children: [
              // Header Row
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableCell('S/N', isHeader: true),
                  _buildTableCell('AUDIT CRITERIA', isHeader: true),
                  _buildTableCell('RATING', isHeader: true),
                  _buildTableCell('COMMENTS', isHeader: true),
                ],
              ),

              // Data Rows for this responsible person
              for (var i = 0; i < items.length; i++)
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: i % 2 == 0 ? PdfColors.white : PdfColors.grey50,
                  ),
                  children: [
                    _buildTableCell('${globalIndex++}'),
                    _buildTableCell(_sanitizeText(items[i].query_name)),
                    _buildTableCell(
                      _sanitizeText(items[i].rating.toString()),
                      isRating: true,
                      ratingValue: items[i].rating,
                    ),
                    _buildTableCell(_sanitizeText(items[i].comment ?? '')),
                  ],
                ),
            ],
          ),
        ),
      );

      // Add summary for this responsible person
      double avgScore = _calculateAverageScore(items);
      tables.add(
        pw.Container(
          margin: pw.EdgeInsets.only(left: 20, right: 100, bottom: 8),
          padding: pw.EdgeInsets.all(6),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(3),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Average Score:',
                style:
                    pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                '${avgScore.toStringAsFixed(2)} - ${_getAuditStatus(avgScore)}',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: _getStatusColor(avgScore),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Add spacing between categories
    tables.add(pw.SizedBox(height: 10));
  }

  return tables;
}

// Helper function to sanitize text and remove problematic Unicode characters
String _sanitizeText(String text) {
  return text
      .replaceAll('\u2019', "'") // Replace smart quote with regular quote
      .replaceAll('\u2013', "-") // Replace en dash with regular dash
      .replaceAll('\u2014', "-") // Replace em dash with regular dash
      .replaceAll('\u201C', '"') // Replace smart quotes
      .replaceAll('\u201D', '"');
}

// Helper function to build a TableCell with optional rating colors
pw.Widget _buildTableCell(String text,
    {bool isHeader = false, bool isRating = false, int? ratingValue}) {
  PdfColor? textColor;

  // Apply rating-based colors

  return pw.Container(
    padding: pw.EdgeInsets.all(4),
    child: pw.Text(
      _sanitizeText(text),
      style: pw.TextStyle(
        fontSize: isHeader ? tableHeaderFontSize : tableContentFontSize,
        fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: textColor ?? (isHeader ? PdfColors.black : PdfColors.black),
      ),
      textAlign: pw.TextAlign.center,
    ),
  );
}

// Helper function to get status color based on average score
PdfColor _getStatusColor(double averageScore) {
  if (averageScore >= 2.5) {
    return PdfColors.green700;
  } else if (averageScore >= 2.0) {
    return PdfColors.blue700;
  } else if (averageScore >= 1.0) {
    return PdfColors.orange700;
  } else {
    return PdfColors.red700;
  }
}

// Helper function to calculate average score
double _calculateAverageScore(List<Item> items) {
  if (items.isEmpty) return 0.0;

  double totalScore = 0;
  int validScores = 0;

  for (var item in items) {
    try {
      double score = item.rating.toDouble();
      if (score >= 0 && score <= 3) {
        totalScore += score;
        validScores++;
      }
    } catch (e) {
      // Skip invalid scores
    }
  }

  return validScores > 0 ? totalScore / validScores : 0.0;
}

// Helper function to get audit status based on average score
String _getAuditStatus(double averageScore) {
  if (averageScore >= 2.5) {
    return 'EXCELLENT';
  } else if (averageScore >= 2.0) {
    return 'GOOD';
  } else if (averageScore >= 1.5) {
    return 'SATISFACTORY';
  } else if (averageScore >= 1.0) {
    return 'NEEDS IMPROVEMENT';
  } else {
    return 'POOR';
  }
}

// Helper function to get count of unique categories
int _getCategoryCount(List<Item> items) {
  Set<String> categories = {};
  for (var item in items) {
    categories.add(item.category);
  }
  return categories.length;
}

// Helper function to get count of unique responsible persons
int _getResponsibleCount(List<Item> items) {
  Set<String> responsiblePersons = {};
  for (var item in items) {
    responsiblePersons.add(item.resp);
  }
  return responsiblePersons.length;
}

// Helper function to build category breakdown with responsible persons
List<pw.Widget> _buildCategoryBreakdown(List<Item> items) {
  // Group items by category, then by responsible person
  Map<String, Map<String, List<Item>>> groupedItems = {};

  for (var item in items) {
    String category = item.category;
    String responsible = item.resp;

    if (!groupedItems.containsKey(category)) {
      groupedItems[category] = {};
    }
    if (!groupedItems[category]!.containsKey(responsible)) {
      groupedItems[category]![responsible] = [];
    }
    groupedItems[category]![responsible]!.add(item);
  }

  List<pw.Widget> breakdown = [];

  for (var categoryEntry in groupedItems.entries) {
    String category = categoryEntry.key;
    Map<String, List<Item>> responsibleGroups = categoryEntry.value;

    // Calculate total items for this category
    int totalCategoryItems =
        responsibleGroups.values.fold(0, (sum, items) => sum + items.length);
    double categoryAvgScore = _calculateAverageScore(
        responsibleGroups.values.expand((items) => items).toList());

    // Add category header
    breakdown.add(
      pw.Container(
        margin: pw.EdgeInsets.only(top: 3, bottom: 2),
        padding: pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey50,
          borderRadius: pw.BorderRadius.circular(2),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              flex: 3,
              child: pw.Text(
                '${_sanitizeText(category)}',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
            ),
            pw.Text(
              '$totalCategoryItems items',
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
            pw.SizedBox(width: 5),
            pw.Text(
              'Avg: ${categoryAvgScore.toStringAsFixed(1)}',
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: _getStatusColor(categoryAvgScore),
              ),
            ),
          ],
        ),
      ),
    );

    // Add responsible person breakdown for this category
    for (var responsibleEntry in responsibleGroups.entries) {
      String responsible = responsibleEntry.key;
      List<Item> responsibleItems = responsibleEntry.value;
      double responsibleAvgScore = _calculateAverageScore(responsibleItems);

      breakdown.add(
        pw.Container(
          margin: pw.EdgeInsets.only(left: 10, top: 1, bottom: 1),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                flex: 3,
                child: pw.Text(
                  '${_sanitizeText(responsible)}',
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
              pw.Text(
                '${responsibleItems.length} items',
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
              pw.SizedBox(width: 5),
              pw.Text(
                '${responsibleAvgScore.toStringAsFixed(1)}',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: _getStatusColor(responsibleAvgScore),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  return breakdown;
}
