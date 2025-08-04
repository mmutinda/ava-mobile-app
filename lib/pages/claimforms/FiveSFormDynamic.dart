import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class FiveSAuditPage extends StatefulWidget {
  @override
  _FiveSAuditPageState createState() => _FiveSAuditPageState();
}

class _FiveSAuditPageState extends State<FiveSAuditPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, int?> scores = {};
  final Map<String, TextEditingController> comments = {};
  final _sectionController = TextEditingController();
  final _authorController = TextEditingController();
  final _dateController = TextEditingController();
  final _creationDateController = TextEditingController();
  final _documentRefController = TextEditingController();
  final _revisionController = TextEditingController();

  List<dynamic> dynamicSections = [];
  Map<String, List<dynamic>> dynamicQuestions = {};
  bool isLoading = true;
  String errorMessage = '';
  var user = {};

  @override
  void initState() {
    super.initState();
    //getting user data from shared preferences
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      // Load 5S settings after getting user data
      _loadFiveSSettings();
    });
  }

  Future<void> _loadFiveSSettings() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await http.get(
        Uri.parse('${Api.api_url}loadFiveSSettings'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${user['data']['token']}',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody['success'] == true) {
          final List<dynamic> sections = responseBody['data'];

          setState(() {
            dynamicSections = sections;
            dynamicQuestions.clear();
            scores.clear();
            comments.clear();

            // Initialize scores and comments for each question
            for (var section in sections) {
              String sectionName = section['name'];
              List<dynamic> items = section['items'] ?? [];

              dynamicQuestions[sectionName] = items;

              for (var item in items) {
                String questionText = item['item_name'];
                scores[questionText] = null;
                comments[questionText] = TextEditingController();
              }
            }

            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = responseBody['msg'] ?? 'Failed to load 5S settings';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load 5S settings';
          isLoading = false;
        });
      }
    } on SocketException {
      setState(() {
        errorMessage = 'No Internet connection';
        isLoading = false;
      });
    } on TimeoutException {
      setState(() {
        errorMessage = 'Request timed out';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Widget _buildQuestion(String question, {String description = ''}) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question, style: TextStyle(fontWeight: FontWeight.bold)),
            if (description.isNotEmpty) ...[
              SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
            ],
            SizedBox(height: 12),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: 'Score (0-1)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              value: scores[question],
              items: List.generate(
                2,
                (i) => DropdownMenuItem(value: i, child: Text('$i')),
              ),
              onChanged: (val) => setState(() => scores[question] = val),
              validator: (val) => val == null ? 'Required' : null,
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: comments[question],
              decoration: InputDecoration(
                labelText: 'Comments',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderField(
    IconData icon,
    String label,
    TextEditingController controller, {
    bool isDate = false,
  }) {
    // Set default values based on the label
    if (controller.text.isEmpty) {
      if (label == 'Document Creation Date') {
        controller.text = '15/09/2023';
      } else if (label == 'Document Ref') {
        controller.text = 'AVA.SHE.D.013';
      } else if (label == 'Revision') {
        controller.text = '1';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: isDate,
        onTap: isDate
            ? () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  controller.text =
                      "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                }
              }
            : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  Widget _buildSection(String title, List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(title,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: mycolor)),
        SizedBox(height: 10),
        for (var item in items) _buildQuestion(item['item_name'] ?? ''),
      ],
    );
  }

  void handleSuccess() {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        margin: const EdgeInsets.all(50),
        padding: const EdgeInsets.all(10),
        behavior: SnackBarBehavior.floating,
        content: Text('Record saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  void showError(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: const EdgeInsets.all(50),
        padding: const EdgeInsets.all(10),
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final progressDialog = ProgressDialog(context);
      progressDialog.style(
        message: 'Submitting ..',
        child: CustomLoader(),
        borderRadius: 8,
        backgroundColor: Colors.white,
        progressWidget: const SizedBox(
            width: 20,
            height: 20,
            child: Center(child: CircularProgressIndicator())),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
      );
      progressDialog.show();
      try {
        List<Map<String, dynamic>> data = [];

        dynamicQuestions.forEach((section, items) {
          for (var item in items) {
            final question = item['item_name'];
            data.add({
              'category': section,
              'physical_condition': question,
              'score': scores[question] ?? 0,
              'comments': comments[question]?.text.trim() ?? '',
            });
          }
        });

        final dataToStore = {
          'section': _sectionController.text.trim(),
          'revision': _revisionController.text.trim(),
          'author': _authorController.text.trim(),
          'date': _dateController.text.trim(),
          'document_creation_date': _creationDateController.text.trim(),
          'document_ref': _documentRefController.text.trim(),
          'items': data,
        };

        final response = await http
            .post(
              Uri.parse(Api.api_url + "fives"),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer ${user['data']['token']}',
              },
              body: jsonEncode(dataToStore),
            )
            .timeout(const Duration(seconds: 30));
        var responseBody = jsonDecode(response.body);
        print(responseBody);
        if (response.statusCode == 200 || responseBody['success'] == true) {
          handleSuccess();
        } else {
          String errorMessage = responseBody['msg'] ??
              responseBody['message'] ??
              "An error occurred";
          if (responseBody['errors'] != null) {
            final errors = responseBody['errors'] as Map<String, dynamic>;
            final errorDetails =
                errors.entries.map((e) => '${e.key}: ${e.value[0]}').join('\n');
            errorMessage += '\n$errorDetails';
          }
          showError(errorMessage);
        }
      } on SocketException {
        showError('No Internet connection.');
      } on TimeoutException {
        showError('Request timed out. Please try again.', color: Colors.orange);
      } catch (e) {
        print("Unexpected Error: $e");
        showError('Failed: ${e.toString()}');
      } finally {
        progressDialog.hide();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('5S Audit Checklist'),
        backgroundColor: mycolor,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CustomLoader())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        'Error Loading Data',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadFiveSSettings,
                        child: Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mycolor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        // === Document Information Header ===
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '📄 Document Information',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                _buildHeaderField(
                                    Icons.calendar_today,
                                    'Document Creation Date',
                                    _creationDateController,
                                    isDate: true),
                                _buildHeaderField(Icons.description,
                                    'Document Ref', _documentRefController),
                                _buildHeaderField(Icons.history_edu, 'Revision',
                                    _revisionController),
                                const SizedBox(height: 12),
                                _buildHeaderField(Icons.article, 'Section',
                                    _sectionController),
                                _buildHeaderField(
                                    Icons.person, 'Auditor', _authorController),
                                _buildHeaderField(
                                    Icons.date_range, 'Date', _dateController,
                                    isDate: true),
                              ],
                            ),
                          ),
                        ),

                        // === Audit Sections ===
                        const Text(
                          '📋 Audit Checklist',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        ...dynamicSections
                            .map((section) => _buildSection(section['name'],
                                dynamicQuestions[section['name']] ?? []))
                            .toList(),

                        const SizedBox(height: 20),

                        // === Submit Button ===
                        ElevatedButton(
                          onPressed: _submitForm,
                          child: const Text('Submit Audit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mycolor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(fontSize: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
