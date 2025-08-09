import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/pages/claimforms/RaiseClaim.dart';
import 'package:isuze_pqcs/pages/claimforms/pdfscreen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ClaimHome extends StatefulWidget {
  const ClaimHome({super.key});

  @override
  State<ClaimHome> createState() => _ClaimHomeState();
}

class _ClaimHomeState extends State<ClaimHome> {
  var user = {};
  List<dynamic> records = [];
  List<dynamic> filteredRecords = [];
  bool isLoading = true;
  String? errorMessage;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // PDF Generation for individual claim
  Future<void> _generateClaimPdf(Map<String, dynamic> record) async {
    try {
      // Generate PDF for the specific claim record
      final pdfData = await _createClaimPdf(record);

      // Save and preview
      final tempDir = await getTemporaryDirectory();
      final fileName = 'claim_${record['lot_number'] ?? 'unknown'}.pdf';
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(pdfData);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfPreviewScreen(
              filePath: tempFile.path,
              name: "Claim: ${record['lot_number'] ?? 'N/A'}"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Uint8List> _createClaimPdf(Map<String, dynamic> record) async {
    final pdf = pw.Document();

    // Load logo image
    final ByteData logoByteData = await rootBundle.load('images/logo2.png');
    final Uint8List logoUint8List = logoByteData.buffer.asUint8List();
    final pw.MemoryImage logoImage = pw.MemoryImage(logoUint8List);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with logo
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(logoImage, width: 100, height: 50),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'CLAIM REPORT',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Generated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        style: pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 30),

              // Claim Information
              pw.Container(
                padding: pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Claim Details',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 15),

                    // Create rows for claim data
                    ...(_buildClaimDataRows(record)),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Footer
              pw.Container(
                padding: pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Text(
                  'This document serves as a record of the claim submission and should be kept for quality management purposes.',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  List<pw.Widget> _buildClaimDataRows(Map<String, dynamic> record) {
    final List<Map<String, String>> claimData = [
      {
        'label': 'Lot Number',
        'value': record['lot_number']?.toString() ?? 'N/A'
      },
      {
        'label': 'Part Number',
        'value': record['part_number']?.toString() ?? 'N/A'
      },
      {'label': 'Category', 'value': record['category']?.toString() ?? 'N/A'},
      {
        'label': 'Classification',
        'value': record['classification']?.toString() ?? 'N/A'
      },
      {'label': 'Quantity', 'value': record['quantity']?.toString() ?? 'N/A'},
      {
        'label': 'Defect Type',
        'value': record['defect_type']?.toString() ?? 'N/A'
      },
      {
        'label': 'Process Description',
        'value': record['process_description']?.toString() ?? 'N/A'
      },
      {'label': 'Created Date', 'value': _formatDate(record['created_at'])},
      {'label': 'Status', 'value': record['status']?.toString() ?? 'N/A'},
    ];

    return claimData
        .map((item) => pw.Padding(
              padding: pw.EdgeInsets.only(bottom: 8),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                    width: 120,
                    child: pw.Text(
                      '${item['label']}:',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      item['value']!,
                      style: pw.TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  _loadData() async {
    try {
      final userData = await getuserdata();
      user = jsonDecode(userData);
      await fetchRecords();
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load data. Please try again.";
        isLoading = false;
      });
    }
  }

  fetchRecords() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        headers: {
          'Authorization': 'Bearer ${user['data']['token']}',
          'Accept': 'application/json',
        },
        Uri.parse('${Api.api_url}loadClaim/General_Calim'),
      );
      print('${Api.api_url}loadClaim/General_Calimaim');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            records = data['data'] ?? [];
            _applyDateFilter();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = data['msg'] ?? 'Failed to load claims';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load claims';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Something went wrong. Please try again.';
        isLoading = false;
      });
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  void _applyDateFilter() {
    if (selectedDate == null) {
      filteredRecords = List.from(records);
    } else {
      filteredRecords = records.where((record) {
        if (record['created_at'] == null) return false;
        try {
          final recordDate = DateTime.parse(record['created_at']);
          final recordDateOnly =
              DateTime(recordDate.year, recordDate.month, recordDate.day);
          final filterDate = DateTime(
              selectedDate!.year, selectedDate!.month, selectedDate!.day);

          return recordDateOnly.isAtSameMomentAs(filterDate);
        } catch (e) {
          return false;
        }
      }).toList();
    }
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: mycolor,
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
      setState(() {
        selectedDate = picked;
        _applyDateFilter();
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      selectedDate = null;
      _applyDateFilter();
    });
  }

  String _formatSelectedDate() {
    if (selectedDate == null) return '';
    return '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ClaimForm(),
            ),
          ).then((result) {
            if (result == true) {
              fetchRecords();
            }
          });
        },
        backgroundColor: mycolor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('New Claim'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Claims Records'),
            if (selectedDate != null)
              Text(
                _formatSelectedDate(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              selectedDate != null
                  ? Icons.filter_list
                  : Icons.filter_list_outlined,
              color: selectedDate != null ? mycolor : null,
            ),
            onPressed: _showDatePicker,
            tooltip: 'Filter by date',
          ),
          if (selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearDateFilter,
              tooltip: 'Clear filter',
            ),
        ],
      ),
      backgroundColor: Colors.grey.shade50,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: CustomLoader(),
      );
    }

    if (errorMessage != null) {
      return ErrorMessageWidget(
        errorMessage: errorMessage!,
        onRetry: () {
          fetchRecords();
        },
      );
    }

    if (filteredRecords.isEmpty && records.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No claims found for selected date',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try selecting a different date',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _clearDateFilter,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Filter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: mycolor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No claims found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start by creating your first claim',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredRecords.length,
      itemBuilder: (context, index) {
        final record = filteredRecords[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: mycolor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.assignment_outlined,
                    color: mycolor,
                    size: 24,
                  ),
                ),
                title: Text(
                  "Lot No: ${record['lot_number'] ?? 'N/A'}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            record['part_number'] ?? 'N/A',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.category_outlined,
                              size: 14, color: Colors.orange.shade600),
                          const SizedBox(width: 4),
                          Text(
                            record['category'] ?? 'N/A',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.class_outlined,
                              size: 14, color: Colors.blue.shade600),
                          const SizedBox(width: 4),
                          Text(
                            record['classification'] ?? 'N/A',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(record['created_at']),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // PDF Button Row
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => _generateClaimPdf(record),
                        icon: const Icon(Icons.picture_as_pdf, size: 16),
                        label: const Text(
                          'View PDF',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mycolor.withOpacity(0.1),
                          foregroundColor: mycolor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: mycolor.withOpacity(0.3)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
