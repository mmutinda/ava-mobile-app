import 'dart:async';
import 'dart:convert';
import 'dart:developer';
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
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.blue.shade50],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.blue.shade100, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: mycolor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.help_outline, color: mycolor, size: 16),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    question,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Score (0-1)',
                  prefixIcon: Icon(Icons.stars, color: mycolor),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: mycolor, width: 2),
                  ),
                ),
                value: scores[question],
                items: List.generate(
                  2,
                  (i) => DropdownMenuItem(
                    value: i,
                    child: Row(
                      children: [
                        Icon(
                          i == 1 ? Icons.check_circle : Icons.cancel,
                          color: i == 1 ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text('$i'),
                      ],
                    ),
                  ),
                ),
                onChanged: (val) => setState(() => scores[question] = val),
                validator: (val) => val == null ? 'Required' : null,
              ),
            ),
            SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                controller: comments[question],
                decoration: InputDecoration(
                  labelText: 'Comments',
                  prefixIcon: Icon(Icons.comment, color: mycolor),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: mycolor, width: 2),
                  ),
                ),
                maxLines: 2,
              ),
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
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
            prefixIcon: Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: mycolor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: mycolor, size: 20),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: mycolor, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            labelStyle: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Please enter $label' : null,
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [mycolor, mycolor.withOpacity(0.8)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: mycolor.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.checklist, color: Colors.white, size: 18),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${items.length} items',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
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
              'five_s_setting_id': item['five_s_setting_id'] ?? 0,
              'five_s_items_setting_id': item['id'] ?? 0,
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
        // print(dataToStore);
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
        log(jsonEncode(responseBody));
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.assignment_turned_in,
                  color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),
            Text('5S Audit Checklist',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: mycolor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? Container(
              decoration: BoxDecoration(),
              child: Center(
                child: CustomLoader(),
              ))
          : errorMessage.isNotEmpty
              ? Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.red.shade50, Colors.orange.shade50],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      margin: EdgeInsets.all(20),
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.error_outline,
                                size: 48, color: Colors.red.shade400),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Error Loading Data',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800]),
                          ),
                          SizedBox(height: 12),
                          Text(
                            errorMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 14),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _loadFiveSSettings,
                            icon: Icon(Icons.refresh),
                            label: Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mycolor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.shade50,
                        Colors.indigo.shade50,
                        Colors.purple.shade50
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          // === Document Information Header ===
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: mycolor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(Icons.description,
                                            color: mycolor, size: 24),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Document Information',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[800]),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  _buildHeaderField(
                                      Icons.calendar_today,
                                      'Document Creation Date',
                                      _creationDateController,
                                      isDate: true),
                                  _buildHeaderField(Icons.description,
                                      'Document Ref', _documentRefController),
                                  _buildHeaderField(Icons.history_edu,
                                      'Revision', _revisionController),
                                  const SizedBox(height: 12),
                                  _buildHeaderField(Icons.article, 'Section',
                                      _sectionController),
                                  _buildHeaderField(Icons.person, 'Auditor',
                                      _authorController),
                                  _buildHeaderField(
                                      Icons.date_range, 'Date', _dateController,
                                      isDate: true),
                                ],
                              ),
                            ),
                          ),

                          // === Audit Sections ===
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 16),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: mycolor.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: mycolor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.assignment,
                                      color: Colors.white, size: 20),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Audit Checklist',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800]),
                                ),
                              ],
                            ),
                          ),
                          ...dynamicSections
                              .map((section) => _buildSection(section['name'],
                                  dynamicQuestions[section['name']] ?? []))
                              .toList(),

                          const SizedBox(height: 30),

                          // === Submit Button ===
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [mycolor, mycolor.withOpacity(0.8)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: mycolor.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: _submitForm,
                              icon: Icon(Icons.send, color: Colors.white),
                              label: Text(
                                'Submit Audit',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
