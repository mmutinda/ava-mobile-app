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

  final List<String> sections = [
    'SORT (KUCHAGUA)',
    'SET IN ORDER (KUPANGA)',
    'SHINE (KUSAFISHA)',
    'STANDARDIZE (KUSANIFISHA)',
    'SUSTAIN (KUDUMISHA)',
  ];

  final Map<String, List<String>> questions = {
    'SORT (KUCHAGUA)': [
      'Are all items, packaging, raw materials needed?',
      'Are all machines, benches, tools needed?',
      'Are all tools, cleaning/testing equipment needed?',
      'Is all paperwork at the workstation required?',
      'Are all surfaces/floor clean of items that are not currently needed?',
      'Are all the furniture present in the work place needed?',
    ],
    'SET IN ORDER (KUPANGA)': [
      'Are the work areas and its processes identified? Machines are clearly labelled.',
      'Are all locations for materials clearly marked and respected?',
      'All gangways are clearly marked and respected?',
      'Are all location of equipment clearly marked and respected?',
      'Are all equipment clearly marked?',
      'The floor layout allows for easy process flow?',
    ],
    'SHINE (KUSAFISHA)': [
      'Is there a cleaning schedule? Is it being used?',
      'Are all floors/ stairs free from dirt, dust, trip and fall hazards, slip?',
      'Are all machines clean – underneath, surface and inside machine?',
      'Are walls painted and clean?',
      'Are all rubbish and reject material in an appropriate bin?',
      'Lighting and ventilation are okay for the job being done?',
      'Are all PPE maintained in a sanitary and reliable condition',
    ],
    'STANDARDIZE (KUSANIFISHA)': [
      'Visual management is practiced in the place. Is it possible to identify items at a glance?',
      'Do the workstation have SOP sheets displayed?',
      'Areas of improvement identified during the previous audit have been completed?',
      'Is there a display of the team’s performance in 5S',
      'Does the team use and respect the 5S standards?',
    ],
    'SUSTAIN (KUDUMISHA)': [
      'Does the team constantly conduct self-audit?',
      'All PPE being worn correctly?',
      'All 5S members are assigned 5S activities to be completed at least once a week?',
      'Does the place look tidy and clean?',
      'Everyone understands what 5S is and puts it in practice constantly',
    ],
  };
  final Map<String, List<String>> questionsDesc = {
    'SORT (KUCHAGUA)': [
      'Look for excess material/ unwanted material',
      'Unnecessary equipment, tools, stands etc.',
      'Look in lockers, drawers, cabinets, on top of machines for unnecessary items',
      'Out-dated or otherwise unnecessary posters, memos, announcements, reports.',
      'Look on top of machines, benches, tool trolleys and the work area',
      'Look for excess or otherwise unnecessary chairs, benches and/or broken furniture',
    ],
    'SET IN ORDER (KUPANGA)': [
      'Everyone understands what 5S is and puts it in practice constantly?',
      'Check max/min stock values safely staked? Check floor/ shelf marking',
      'Look for non-standard marking, blockage or gangways.',
      'Look for equipment locations, are they respected?',
      'Check for unlabeled items, wrong-labelled items, illegible marking?',
      'Look for placement of raw materials, blockages of production boards etc.',
    ],
    'SHINE (KUSAFISHA)': [
      'Check if the schedule is displayed in the workplace. Are people doing their responsibilities as stipulated?',
      'Look for presence of dirt, dust on the floors, water or oil spills on the floors.',
      'Check oil, grease, dust and product/by-product contaminations. Also  check for grime accumulation',
      'Check for dirty walls, cobwebs, unrequired stickers on the walls',
      'Look for cluttered floor, benches, check what is in the reject bins.',
      'Look for broken or blown off bulb/fluorescent tubes, poorly ventilated areas and broken switches.',
      'Look for dirty, oily overalls, helmets etc.',
    ],
    'STANDARDIZE (KUSANIFISHA)': [
      'Look for broken or blown off bulb/fluorescent tubes, poorly ventilated areas and broken switches',
      'Visual check that the SOP is displayed at or near each workstation',
      'Look for evidence of improvement of the Section, action plans, completion dates',
      'Look for visual display of graphs or radar charts?',
      'Look for wrongly painted equipment, piping, wrong color labelling, wrong font, non-standard notices, displays, etc.',
    ],
    'SUSTAIN (KUDUMISHA)': [
      'Look for visual display of audit results and actions for improvement',
      'Look for visual display of audit results and actions for improvement',
      'Is the RTM Board updated with current information. Also check noticeboard or evidence of responsibilities.',
      'Look at the entire place for cobwebs, dusty floor, broken boards, unemptied bins etc.',
      'elect and interview members randomly. Ask what they know about 5S',
    ],
  };
  var user = {};
  @override
  void initState() {
    super.initState();
//getting user data from shared preferences
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
    });

    /// Initialize scores and comments for each question
    for (var section in questions.keys) {
      for (var q in questions[section]!) {
        scores[q] = null;
        comments[q] = TextEditingController();
      }
    }
  }

  Widget _buildQuestion(String question, String description) {
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
            SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
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

  Widget _buildSection(String title, List<String> qs, List<String> descs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(title,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: mycolor)),
        SizedBox(height: 10),
        for (int i = 0; i < qs.length; i++) _buildQuestion(qs[i], descs[i]),
      ],
    );
  }

  void handleSuccess() {
    if (!context.mounted) return; // ✅ Add this check
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        margin: const EdgeInsets.all(50),
        padding: const EdgeInsets.all(10),
        behavior: SnackBarBehavior.floating,
        content: Text('Record saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    // Optional: Clear form fields if necessary

    Navigator.pop(context); // ✅ Now safely navigates back
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

        questions.forEach((section, qs) {
          for (int i = 0; i < qs.length; i++) {
            final question = qs[i];
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
          'items': data, // <== array of question entries
        };

        // // print(data);
        // log(jsonEncode(data));
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
          // Check for 'errors' key
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
        appBar:
            AppBar(title: Text('5S Audit Checklist'), backgroundColor: mycolor),
        body: Padding(
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
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        _buildHeaderField(Icons.calendar_today,
                            'Document Creation Date', _creationDateController,
                            isDate: true),
                        _buildHeaderField(Icons.description, 'Document Ref',
                            _documentRefController),
                        _buildHeaderField(
                            Icons.history_edu, 'Revision', _revisionController),
                        const SizedBox(height: 12),
                        _buildHeaderField(
                            Icons.article, 'Section', _sectionController),
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...sections
                    .map((s) =>
                        _buildSection(s, questions[s]!, questionsDesc[s]!))
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
        ));
  }
}
