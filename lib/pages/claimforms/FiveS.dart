import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/pages/claimforms/FiveSAuditPage%20.dart';
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
      createdBy: json['created_by'].toString(),
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
      category: json['category'],
      physicalCondition: json['physical_condition'],
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
  late Future<List<Document>> futureDocuments;
  var user = {};
  @override
  void initState() {
    super.initState();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      futureDocuments = fetchDocuments();
    });
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
      return docs.map((json) => Document.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load documents');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FiveSAuditPage(),
            ),
          ).then((result) {
            setState(() {
              futureDocuments = fetchDocuments();
            });
          });
          ;
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('5S Audit Record'),
      ),
      body: FutureBuilder<List<Document>>(
        future: futureDocuments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CustomLoader();
          } else if (snapshot.hasError) {
            return ErrorMessageWidget(
              errorMessage: "${snapshot.error}",
              onRetry: () {
                setState(() {
                  futureDocuments = fetchDocuments();
                });
              },
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No documents found.'));
          }

          final documents = snapshot.data!;
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final doc = documents[index];
              return Card(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    child: Text("${index + 1}"),
                  ),
                  title: Text(
                    doc.documentRef,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: mycolor),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Auditor: ${doc.author}'),
                      Text('${doc.date}'),
                    ],
                  ),
                  trailing: Text(doc.date),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DocumentDetailPage(document: doc),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
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
    return Scaffold(
      appBar: AppBar(
        title: Text(document.documentRef,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 20),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Generate PDF',
            // onPressed: () => generatedocumentPdf(document),
            onPressed: () async {
              final pdfData = await generatedocumentPdf(document);
              await previewPdf(context, pdfData, "${document.documentRef}");
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildInfoTile(
                      Icons.refresh, 'Revision', document.revision),
                ),
                Expanded(
                  child: _buildInfoTile(Icons.description, 'Document Reference',
                      document.documentRef),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildInfoTile(
                      Icons.folder_special, 'Section', document.section),
                ),
                Expanded(
                  child:
                      _buildInfoTile(Icons.person, 'Auditor', document.author),
                ),
              ],
            ),

            // Text('Items:',
            //     style: GoogleFonts.poppins(
            //         fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            ...document.items.map((item) => Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 1,
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.inventory, color: mycolor),
                    title: Text(item.category,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: mycolor,
                        )),
                    subtitle: Text(
                      '${item.physicalCondition}\nComments: ${item.comments ?? 'No comments'}',
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        Text('${item.score}',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
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
}
