import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:isuze_pqcs/pages/claimforms/FiveS.dart';
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

Future<Uint8List> generatedocumentPdf(Document document) async {
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
                '1 = Compliant | 0 = Non-Compliant',
                style: pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'NOTE: This document serves as evidence of 5S audit compliance and should be kept for quality management records.',
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
                    '5S AUDIT CHECKLIST (FLOOR)',
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
                        pw.Text(_sanitizeText(document.date),
                            style: pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Doc Ref:', style: pw.TextStyle(fontSize: 9)),
                        pw.Text(_sanitizeText(document.documentRef),
                            style: pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Revision:', style: pw.TextStyle(fontSize: 9)),
                        pw.Text(_sanitizeText(document.revision.toString()),
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
                  'SECTION: ${_sanitizeText(document.section)}',
                  style: pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Text(
                  'AUDITOR: ${_sanitizeText(document.author)}',
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
                  'AUDITEE: ${_sanitizeText(document.author)}',
                  style: pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Text(
                  'DATE: ${_sanitizeText(document.date)}',
                  style: pw.TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 15),

          // Audit Items Grouped by Category
          ..._buildGroupedAuditTables(document),

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
                    pw.Text('${document.items.length}',
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Categories:',
                        style: pw.TextStyle(fontSize: 10)),
                    pw.Text('${_getCategoryCount(document.items)}',
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
                        '${_calculateAverageScore(document.items).toStringAsFixed(2)}',
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Audit Status:', style: pw.TextStyle(fontSize: 10)),
                    pw.Text(
                        '${_getAuditStatus(_calculateAverageScore(document.items))}',
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
                ..._buildCategoryBreakdown(document.items),
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
                    pw.Text('Name: ${_sanitizeText(document.author)}',
                        style: pw.TextStyle(fontSize: 9)),
                    pw.Text('Date: ${_sanitizeText(document.date)}',
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

// Helper function to build grouped audit tables by category
List<pw.Widget> _buildGroupedAuditTables(Document document) {
  // Group items by category
  Map<String, List<Item>> groupedItems = {};
  for (var item in document.items) {
    String category = item.category;
    if (!groupedItems.containsKey(category)) {
      groupedItems[category] = [];
    }
    groupedItems[category]!.add(item);
  }

  List<pw.Widget> tables = [];
  int globalIndex = 1;

  // Create a table for each category
  for (var entry in groupedItems.entries) {
    String category = entry.key;
    List<Item> items = entry.value;

    // Add category header
    tables.add(
      pw.Container(
        margin: pw.EdgeInsets.only(top: 10, bottom: 5),
        padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Text(
          '${_sanitizeText(category.toUpperCase())}',
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
      ),
    );

    // Add table for this category
    tables.add(
      pw.Table(
        border: pw.TableBorder.all(color: PdfColors.black, width: 1),
        columnWidths: {
          0: pw.FixedColumnWidth(25),
          1: pw.FlexColumnWidth(3.5),
          2: pw.FixedColumnWidth(40),
          3: pw.FlexColumnWidth(2.5),
        },
        children: [
          // Header Row
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColors.grey300),
            children: [
              _buildTableCell('S/N', isHeader: true),
              _buildTableCell('PHYSICAL CONDITION', isHeader: true),
              _buildTableCell('SCORE', isHeader: true),
              _buildTableCell('COMMENTS', isHeader: true),
            ],
          ),

          // Data Rows for this category
          for (var i = 0; i < items.length; i++)
            pw.TableRow(
              decoration: pw.BoxDecoration(
                color: i % 2 == 0 ? PdfColors.white : PdfColors.grey50,
              ),
              children: [
                _buildTableCell('${globalIndex++}'),
                _buildTableCell(_sanitizeText(items[i].physicalCondition)),
                _buildTableCell(_sanitizeText(items[i].score.toString())),
                _buildTableCell(_sanitizeText(items[i].comments ?? '')),
              ],
            ),
        ],
      ),
    );

    // Add spacing between category tables
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

// Helper function to build a TableCell
pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
  return pw.Container(
    padding: pw.EdgeInsets.all(4),
    child: pw.Text(
      _sanitizeText(text),
      style: pw.TextStyle(
        fontSize: isHeader ? tableHeaderFontSize : tableContentFontSize,
        fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
      textAlign: pw.TextAlign.center,
    ),
  );
}

// Helper function to calculate average score
double _calculateAverageScore(List<Item> items) {
  if (items.isEmpty) return 0.0;

  double totalScore = 0;
  int validScores = 0;

  for (var item in items) {
    try {
      double score = double.parse(item.score.toString());
      if (score == 0 || score == 1) {
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
  if (averageScore >= 0.8) {
    return 'EXCELLENT';
  } else if (averageScore >= 0.6) {
    return 'GOOD';
  } else if (averageScore >= 0.4) {
    return 'SATISFACTORY';
  } else if (averageScore >= 0.2) {
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

// Helper function to build category breakdown
List<pw.Widget> _buildCategoryBreakdown(List<Item> items) {
  Map<String, List<Item>> groupedItems = {};
  for (var item in items) {
    String category = item.category;
    if (!groupedItems.containsKey(category)) {
      groupedItems[category] = [];
    }
    groupedItems[category]!.add(item);
  }

  List<pw.Widget> breakdown = [];
  for (var entry in groupedItems.entries) {
    String category = entry.key;
    List<Item> categoryItems = entry.value;
    double avgScore = _calculateAverageScore(categoryItems);

    breakdown.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              '${_sanitizeText(category)}:',
              style: pw.TextStyle(fontSize: 9),
            ),
          ),
          pw.Text(
            '${categoryItems.length} items',
            style: pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(width: 10),
          pw.Text(
            'Avg: ${avgScore.toStringAsFixed(1)}',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  return breakdown;
}
