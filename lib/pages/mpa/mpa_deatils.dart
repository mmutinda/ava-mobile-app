import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/pages/mpa/mpaFormAdd.dart';
import 'package:isuze_pqcs/pages/mpa/mpa_pdf.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:share_plus/share_plus.dart';

class DocumentReference {
  final int id;
  final String refType;
  final String refNo;
  final String dateCreated;
  final String? dateRevised;
  final int revision;

  DocumentReference({
    required this.id,
    required this.refType,
    required this.refNo,
    required this.dateCreated,
    this.dateRevised,
    required this.revision,
  });

  factory DocumentReference.fromJson(Map<String, dynamic> json) {
    return DocumentReference(
      id: json['id'],
      refType: json['ref_type'],
      refNo: json['ref_no'],
      dateCreated: json['date_created'],
      dateRevised: json['date_revised'],
      revision: json['revision'],
    );
  }
}

class QflT {
  final int id;
  final String project_model_Variant;
  final String audit_department;
  final String period;
  final String station_number;
  final String document_ref;
  final String revision;
  final String date;
  final List<Item> items;

  QflT({
    required this.id,
    required this.project_model_Variant,
    required this.audit_department,
    required this.period,
    required this.station_number,
    required this.document_ref,
    required this.revision,
    required this.date,
    required this.items,
  });

  factory QflT.fromApiResponse(
      Map<String, dynamic> json,
      List<Item> items,
      String projectModelVariant,
      String auditDepartment,
      DocumentReference? docRef) {
    // Since the response is just items, we'll create a mock record with widget data
    return QflT(
      id: json['id'] ?? 0,
      project_model_Variant: projectModelVariant,
      audit_department: auditDepartment,
      period: 'N/A',
      station_number: 'N/A',
      document_ref: docRef?.refNo ?? 'N/A',
      revision: docRef?.revision.toString() ?? 'N/A',
      date: DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
      items: items,
    );
  }
}

class Item {
  final int qfl3_id;
  final String category;
  final String query_name;
  final int rating;
  final String resp;
  final String? comment;

  Item({
    required this.qfl3_id,
    required this.category,
    required this.query_name,
    required this.rating,
    required this.resp,
    this.comment,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      qfl3_id: json['id'],
      category: json['mpa_setting']['category'],
      query_name: json['mpa_setting']['query_name'],
      rating: json['rating'],
      resp: json['mpa_setting']['responsible'],
      comment: json['comment'],
    );
  }
}

class QFLThreeDetails extends StatefulWidget {
  final id;
  final project_model_Variant;
  final audit_line;

  const QFLThreeDetails(
      {super.key,
      required this.id,
      required this.project_model_Variant,
      required this.audit_line});

  @override
  State<QFLThreeDetails> createState() => _QFLThreeDetailsState();
}

class _QFLThreeDetailsState extends State<QFLThreeDetails> {
  Future<List<QflT>>? futureRecords;
  var user = {};
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasError = false;
  DocumentReference? _documentReference;
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });

      final userData = await getuserdata();
      setState(() {
        user = jsonDecode(userData);
      });

      // Load both MPA records and document reference
      final results = await Future.wait([
        fetchMpaRecords(),
        fetchDocumentReference(),
      ]);

      futureRecords = Future.value(results[0] as List<QflT>);
      _documentReference = results[1] as DocumentReference?;

      setState(() {
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<List<QflT>> fetchMpaRecords() async {
    print("${Api.api_url}load-mpa-items/${widget.id}");
    try {
      final response = await http.get(
        headers: {
          'Authorization': 'Bearer ${user['data']['token']}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        Uri.parse('${Api.api_url}load-mpa-items/${widget.id}'),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception(
              'Request timeout. Please check your internet connection.');
        },
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);

          if (data == null) {
            throw Exception('Received null response from server');
          }

          if (!data.containsKey('data')) {
            throw Exception('Invalid response format: missing data field');
          }

          final dynamic recordData = data['data'];

          if (recordData == null) {
            throw Exception('No MPA record data found for this ID');
          }

          if (recordData is! List) {
            throw Exception('Invalid response format: data is not a list');
          }

          try {
            // Parse items from the response array
            List<Item> items = [];
            for (var itemJson in recordData) {
              try {
                final item = Item.fromJson(itemJson);
                items.add(item);
              } catch (e) {
                print('Warning: Failed to parse item: $e');
                continue;
              }
            }

            // Create a QflT record with the parsed items
            final record = QflT.fromApiResponse({
              'id': widget.id,
            }, items, widget.project_model_Variant, widget.audit_line,
                _documentReference);

            return [record]; // Wrap it in a list
          } catch (e) {
            throw Exception('Failed to parse record data: $e');
          }
        } catch (e) {
          print(e);
          throw Exception('Failed to parse response data: $e');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception(
            'Access denied. You don\'t have permission to view this data.');
      } else if (response.statusCode == 404) {
        throw Exception('MPA record not found. It may have been deleted.');
      } else if (response.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        throw Exception(
            'Client error (${response.statusCode}). Please check your request.');
      } else if (response.statusCode >= 500) {
        throw Exception(
            'Server error (${response.statusCode}). Please try again later.');
      } else {
        throw Exception(
            'Unexpected response: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } on http.ClientException {
      throw Exception('Network error: Please check your internet connection.');
    } on FormatException {
      throw Exception('Invalid response format from server.');
    } on Exception {
      // Re-throw our custom exceptions
      rethrow;
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<DocumentReference?> fetchDocumentReference() async {
    try {
      final response = await http.get(
        headers: {
          'Authorization': 'Bearer ${user['data']['token']}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        Uri.parse('${Api.api_url}load-documents-ref/Mpa'),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception(
              'Request timeout. Please check your internet connection.');
        },
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);

          if (data == null) {
            throw Exception('Received null response from server');
          }

          if (!data.containsKey('data')) {
            throw Exception('Invalid response format: missing data field');
          }

          final dynamic docData = data['data'];

          if (docData == null) {
            return null; // No document reference found
          }

          if (docData is! Map<String, dynamic>) {
            throw Exception(
                'Invalid response format: data is not a valid document reference');
          }

          try {
            return DocumentReference.fromJson(docData);
          } catch (e) {
            throw Exception('Failed to parse document reference data: $e');
          }
        } catch (e) {
          throw Exception('Failed to parse response data: $e');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception(
            'Access denied. You don\'t have permission to view this data.');
      } else if (response.statusCode == 404) {
        throw Exception('Document reference not found.');
      } else if (response.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception(
            'Unexpected response: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } on http.ClientException {
      throw Exception('Network error: Please check your internet connection.');
    } on FormatException {
      throw Exception('Invalid response format from server.');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> _generateAndSharePdf(QflT qflRecord) async {
    try {
      setState(() {
        _isGeneratingPdf = true;
      });

      // Generate PDF
      final pdfBytes = await generateQfl3Pdf(qflRecord, _documentReference);

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final fileName =
          'QFL3_Audit_${qflRecord.project_model_Variant}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');

      // Write PDF to file
      await file.writeAsBytes(pdfBytes);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'QFL3 Audit Report - ${qflRecord.project_model_Variant}',
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF generated and shared successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isGeneratingPdf = false;
      });
    }
  }

  Future<void> _viewPdf(QflT qflRecord) async {
    try {
      setState(() {
        _isGeneratingPdf = true;
      });

      // Generate PDF
      final pdfBytes = await generateQfl3Pdf(qflRecord, _documentReference);

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final fileName =
          'MPA_Audit_${qflRecord.project_model_Variant}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');

      // Write PDF to file
      await file.writeAsBytes(pdfBytes);

      // Navigate to PDF viewer
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(
            filePath: file.path,
            title: 'QFL3 Audit Report - ${qflRecord.project_model_Variant}',
          ),
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isGeneratingPdf = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: mycolor.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          onPressed: () {
            AuditChecklistPageAdd(id: widget.id)
                .launch(context, pageRouteAnimation: PageRouteAnimation.Slide)
                .then((result) {
              _loadData(); // Use the new loading method
            });
          },
          backgroundColor: mycolor,
          icon: const Icon(Icons.add_circle_outline, size: 20),
          label: Text(
            'Add Items',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: mycolor,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                mycolor,
                mycolor.withOpacity(0.8),
              ],
            ),
          ),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('MPA Details',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ])),
            Text('Model: ${widget.project_model_Variant}',
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ])),
            Text('Audit Line: ${widget.audit_line}',
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ])),
          ],
        ),
        actions: [
          // PDF Viewer Button
          FutureBuilder<List<QflT>>(
            future: futureRecords,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return Container(
                  margin: EdgeInsets.only(right: 4),
                  child: IconButton(
                    icon: _isGeneratingPdf
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            Icons.picture_as_pdf_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                    onPressed: _isGeneratingPdf
                        ? null
                        : () => _viewPdf(snapshot.data!.first),
                    tooltip: 'View PDF Report',
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(),
        child: _isLoading
            ? _buildLoadingState()
            : _hasError
                ? _buildErrorState()
                : FutureBuilder<List<QflT>>(
                    future: futureRecords,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoadingState();
                      } else if (snapshot.hasError) {
                        return _buildErrorStateWithSnapshot(
                            "${snapshot.error}");
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildEmptyState();
                      }

                      final records = snapshot.data!;
                      return _buildContent(records);
                    },
                  ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomLoader(),
            const SizedBox(height: 20),
            Text(
              'Loading MPA Details...',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                color: Colors.white,
                elevation: 2,
                // shadowColor: Colors.red.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Container(
                  // decoration: BoxDecoration(
                  //   gradient: LinearGradient(
                  //     begin: Alignment.topLeft,
                  //     end: Alignment.bottomRight,
                  //     colors: [
                  //       Colors.white,
                  //       Colors.red.withOpacity(0.02),
                  //     ],
                  //   ),
                  //   borderRadius: BorderRadius.circular(16),
                  // ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.shade100,
                                Colors.red.shade50,
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: Colors.red.shade600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Unable to Load Details',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage ?? 'An unexpected error occurred',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [mycolor, mycolor.withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: mycolor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _loadData,
                            icon: Icon(Icons.refresh_rounded, size: 18),
                            label: Text(
                              'Try Again',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorStateWithSnapshot(String error) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ErrorMessageWidget(
                errorMessage: error,
                onRetry: _loadData,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Audit Items Found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This MPA record doesn\'t have any audit items yet.\nTap the "Add Items" button to get started.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<QflT> records) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          // Items list
          ...records[0].items.map((item) => Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  color: Colors.white,
                  // shadowColor: mycolor.withOpacity(0.2),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              mycolor.withOpacity(0.1),
                              mycolor.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.inventory, color: mycolor),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(item.category,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: mycolor,
                                )),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: mycolor.withOpacity(0.3)),
                            ),
                            child: Text(item.resp,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: mycolor,
                                )),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            item.query_name,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Text(
                              '${item.comment ?? 'No comments'}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.shade100,
                              Colors.amber.shade50,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 20),
                            Text('${item.rating}',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade800)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class PdfViewerScreen extends StatelessWidget {
  final String filePath;
  final String title;

  const PdfViewerScreen({
    Key? key,
    required this.filePath,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: mycolor,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                mycolor,
                mycolor.withOpacity(0.8),
              ],
            ),
          ),
        ),
        title: Text(
          'PDF Report',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          // Share button
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () async {
              await Share.shareXFiles(
                [XFile(filePath)],
                text: title,
              );
            },
            tooltip: 'Share PDF',
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: PdfViewer.file(
          filePath,
          params: const PdfViewerParams(
            minScale: 0.5,
            maxScale: 4.0,
            panEnabled: true,
            scaleEnabled: true,
          ),
        ),
      ),
    );
  }
}
