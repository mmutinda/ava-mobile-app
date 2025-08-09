import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/pages/claimforms/FiveSForm.dart';
import 'package:isuze_pqcs/pages/claimforms/pdf5s.dart';
import 'package:isuze_pqcs/pages/claimforms/pdfscreen.dart';
import 'package:path_provider/path_provider.dart';

// ------------------ Models ------------------

class Document {
  final section;
  final author;
  final date;
  final documentCreationDate;
  final documentRef;
  final revision;
  final createdBy;
  final List<Item> items;

  Document({
    required this.section,
    required this.author,
    required this.date,
    required this.documentCreationDate,
    required this.documentRef,
    required this.revision,
    required this.createdBy,
    required this.items,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      section: json['section'].toString(),
      author: json['author'].toString(),
      date: json['date'].toString(),
      documentCreationDate: json['document_creation_date'].toString(),
      documentRef: json['document_ref'].toString(),
      revision: json['revision'].toString(),
      createdBy: json['created_by']['name'].toString(),
      items:
          (json['items'] as List).map((item) => Item.fromJson(item)).toList(),
    );
  }
}

class Item {
  final fiveSId;
  final category;
  final physicalCondition;
  final score;
  final comments;

  Item({
    required this.fiveSId,
    required this.category,
    required this.physicalCondition,
    required this.score,
    required this.comments,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      fiveSId: json['id'],
      category: json['five_s_items_setting']['setting']['name'],
      physicalCondition: json['five_s_items_setting']['item_name'],
      score: json['score'],
      comments: json['comments'],
    );
  }
}

// ------------------ Main Page ------------------

class DocumentListPage extends StatefulWidget {
  const DocumentListPage({super.key});

  @override
  State<DocumentListPage> createState() => _DocumentListPageState();
}

class _DocumentListPageState extends State<DocumentListPage> {
  Future<List<Document>>? futureDocuments;
  var user = {};
  List<Document> allDocuments = [];
  List<Document> filteredDocuments = [];
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final userData = await getuserdata();
      setState(() {
        user = jsonDecode(userData);
        futureDocuments = fetchDocuments();
      });
    } catch (e) {
      setState(() {
        futureDocuments = Future.error('Failed to load user data');
      });
    }
  }

  Future<List<Document>> fetchDocuments() async {
    final response = await http.get(
      headers: {
        'Authorization': 'Bearer ${user['data']['token']}',
        'Accept': 'application/json',
      },
      Uri.parse('${Api.api_url}loadFiveS'),
    );
    print(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List docs = data['data'];
      final documents = docs.map((json) => Document.fromJson(json)).toList();

      // Store all documents and apply current filter
      allDocuments = documents;
      _applyDateFilter();

      return filteredDocuments;
    } else {
      throw Exception('Failed to load documents');
    }
  }

  void _applyDateFilter() {
    if (selectedDate == null) {
      filteredDocuments = List.from(allDocuments);
    } else {
      filteredDocuments = allDocuments.where((document) {
        try {
          final documentDate = DateTime.parse(document.date);
          final documentDateOnly =
              DateTime(documentDate.year, documentDate.month, documentDate.day);
          final filterDate = DateTime(
              selectedDate!.year, selectedDate!.month, selectedDate!.day);

          return documentDateOnly.isAtSameMomentAs(filterDate);
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
        futureDocuments = Future.value(filteredDocuments);
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      selectedDate = null;
      _applyDateFilter();
      futureDocuments = Future.value(filteredDocuments);
    });
  }

  String _formatSelectedDate() {
    if (selectedDate == null) return '';
    return '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FiveSAuditPage(),
              ),
            ).then((result) {
              _initializeData();
            });
          },
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: const Icon(Icons.add_circle_outline, size: 20),
          label: const Text(
            'New Audit',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '5S Audit Records',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
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
        elevation: 0,
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  theme.primaryColor.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      body: futureDocuments == null
          ? _buildLoadingState()
          : FutureBuilder<List<Document>>(
              future: futureDocuments,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                } else if (snapshot.hasError) {
                  return _buildErrorState();
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // Check if we have data but filter resulted in empty list
                  if (allDocuments.isNotEmpty && selectedDate != null) {
                    return _buildNoFilterResultsState();
                  }
                  return _buildEmptyState();
                }

                final documents = snapshot.data!;
                return Column(
                  children: [
                    // _buildStatsHeader(documents),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          final doc = documents[index];
                          return _buildDocumentCard(context, doc, index);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading 5S audit records...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to load 5S audit records. Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                _initializeData();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.assessment_outlined,
                size: 48,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No 5S Audits Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No 5S audit records have been created yet. Start by conducting your first audit.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FiveSAuditPage(),
                  ),
                ).then((result) {
                  _initializeData();
                });
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Start First Audit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoFilterResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              'No audits found for selected date',
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
      ),
    );
  }

  Widget _buildDocumentCard(BuildContext context, Document doc, int index) {
    final theme = Theme.of(context);

    // Calculate average score for this document

    Color scoreColor = mycolor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scoreColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: scoreColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Header with score stripe
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    scoreColor.withOpacity(0.1),
                    scoreColor.withOpacity(0.05),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: scoreColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.documentRef,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rev: ${doc.revision}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section and Auditor
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoChip(
                          Icons.folder_special_outlined,
                          doc.section,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoChip(
                          Icons.person_outline,
                          doc.author,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Date and Items count
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoChip(
                          Icons.calendar_today_outlined,
                          _formatDate(doc.date),
                          Colors.purple,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoChip(
                          Icons.inventory_outlined,
                          '${doc.items.length} items',
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // View button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DocumentDetailPage(document: doc),
                          ),
                        );
                      },
                      icon: const Icon(Icons.visibility_outlined, size: 16),
                      label: const Text(
                        'View Details',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreChip(double score, Color color) {
    String scoreText = score.toStringAsFixed(1);
    IconData scoreIcon;

    if (score >= 4.0) {
      scoreIcon = Icons.stars;
    } else if (score >= 3.0) {
      scoreIcon = Icons.star;
    } else if (score >= 2.0) {
      scoreIcon = Icons.star_half;
    } else {
      scoreIcon = Icons.star_border;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            scoreIcon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            scoreText,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color.withOpacity(0.8),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 4.0) {
      return Colors.green;
    } else if (score >= 3.0) {
      return Colors.amber;
    } else if (score >= 2.0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _formatDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      DateTime now = DateTime.now();
      int difference = now.difference(date).inDays;

      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Yesterday';
      } else if (difference < 7) {
        return '${difference}d ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateStr;
    }
  }
}

// ------------------ Detail Page ------------------

class DocumentDetailPage extends StatelessWidget {
  final Document document;
  const DocumentDetailPage({super.key, required this.document});
  Future<void> previewPdf(
      BuildContext context, Uint8List pdfData, invoiceNo) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/${invoiceNo}.pdf');
    await tempFile.writeAsBytes(pdfData);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PdfPreviewScreen(filePath: tempFile.path, name: invoiceNo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate overall statistics
    double totalScore = 0;
    int itemCount = 0;
    Map<String, int> categoryCount = {};

    for (var item in document.items) {
      try {
        totalScore += double.parse(item.score.toString());
        itemCount++;
        categoryCount[item.category] = (categoryCount[item.category] ?? 0) + 1;
      } catch (e) {
        // Skip invalid scores
      }
    }

    double avgScore = itemCount > 0 ? totalScore / itemCount : 0;
    _getScoreColor(avgScore);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          document.documentRef,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  theme.primaryColor.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.picture_as_pdf_outlined,
                // color: theme.primaryColor,
                size: 20,
              ),
              tooltip: 'Generate PDF',
              onPressed: () async {
                final pdfData = await generatedocumentPdf(document);
                await previewPdf(context, pdfData, "${document.documentRef}");
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Card with Score

            const SizedBox(height: 16),

            // Document Information
            _buildDocumentInfoCard(),
            const SizedBox(height: 16),

            // Statistics Card
            _buildStatisticsCard(categoryCount, totalScore),
            const SizedBox(height: 16),

            // Items Section
            _buildItemsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: mycolor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Document Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  Icons.refresh_rounded,
                  'Revision',
                  document.revision,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoTile(
                  Icons.description_outlined,
                  'Reference',
                  document.documentRef,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  Icons.folder_special_outlined,
                  'Section',
                  document.section,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoTile(
                  Icons.person_outline,
                  'Auditor',
                  document.author,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(
      Map<String, int> categoryCount, double totalScore) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: mycolor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Audit Statistics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatChip(
                  'Categories',
                  categoryCount.length.toString(),
                  Icons.category_outlined,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatChip(
                  'Total Items',
                  document.items.length.toString(),
                  Icons.inventory_outlined,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatChip(
                  'Total Points',
                  totalScore.toStringAsFixed(1),
                  Icons.star_outline,
                  Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.checklist_outlined,
                color: mycolor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Audit Items',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: mycolor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${document.items.length} items',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: mycolor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...document.items.asMap().entries.map((entry) {
            int index = entry.key;
            Item item = entry.value;
            return _buildItemCard(item, index);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildItemCard(Item item, int index) {
    double score;
    try {
      score = double.parse(item.score.toString());
    } catch (e) {
      score = 0;
    }

    Color scoreColor = _getScoreColor(score);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scoreColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scoreColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: scoreColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.category,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              _buildScoreChip(score, scoreColor),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.build_outlined,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Physical Condition',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.physicalCondition,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade800,
                  ),
                ),
                if (item.comments != null &&
                    item.comments.toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.comment_outlined,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Comments',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.comments ?? 'No comments',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade800,
                      fontStyle: item.comments == null
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreChip(double score, Color color) {
    IconData scoreIcon = _getScoreIcon(score);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            scoreIcon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            score.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 1.0) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  IconData _getScoreIcon(double score) {
    if (score >= 1.0) {
      return Icons.check_circle;
    } else {
      return Icons.cancel;
    }
  }

  String _getScoreStatus(double score) {
    if (score >= 1.0) {
      return 'Pass';
    } else {
      return 'Fail';
    }
  }

  String _formatDetailDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}

Widget _buildInfoTile(IconData icon, String label, String value) {
  return Container(
    margin: const EdgeInsets.all(8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          blurRadius: 6,
          offset: const Offset(0, 3),
        )
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFFEA4C89), size: 20),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    ),
  );
}
