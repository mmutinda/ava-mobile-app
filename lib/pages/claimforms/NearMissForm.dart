import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:http/http.dart' as http;
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class NearMissFormPage extends StatefulWidget {
  const NearMissFormPage({Key? key}) : super(key: key);

  @override
  State<NearMissFormPage> createState() => _NearMissFormPageState();
}

class _NearMissFormPageState extends State<NearMissFormPage> {
  final _formKey = GlobalKey<FormState>();
  String? department, riskLevel, category;
  DateTime? selectedDate;
  List<PlatformFile>? uploadedFiles;

  final TextEditingController pfController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: mycolor,
            colorScheme: ColorScheme.light(primary: mycolor),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'ppt',
        'doc',
        'docx',
        'jpg',
        'png',
        'mp4',
        'mp3'
      ],
    );
    if (result != null && result.files.length <= 3) {
      setState(() => uploadedFiles = result.files);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can upload up to 3 files only.')),
      );
    }
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

  Future<void> _submitForm(BuildContext context) async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date of the Near Miss.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final uri = Uri.parse('${Api.api_url}nearmiss');
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer ${user['data']["token"]}',
    });

    // Add fields
    request.fields['department'] = department ?? '';
    request.fields['pf_number'] = pfController.text;
    request.fields['date'] = DateFormat('dd-MM-yyyy').format(selectedDate!);
    request.fields['location'] = locationController.text;
    request.fields['level_of_risk'] = riskLevel ?? '';
    request.fields['category_of_near_miss'] = category ?? '';
    request.fields['description'] = descriptionController.text;

    // Add uploaded files
    if (uploadedFiles != null && uploadedFiles!.isNotEmpty) {
      for (var file in uploadedFiles!) {
        final filePath = file.path;
        if (filePath!.isNotEmpty) {
          request.files.add(await http.MultipartFile.fromPath(
            'files[]', // Use 'files' if your backend doesn't expect an array
            filePath,
          ));
        }
      }
    }

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
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var responseBody = jsonDecode(responseData);

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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: mycolor),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: mycolor),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  var user = {};
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Near Miss Report'),
        backgroundColor: mycolor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _sectionTitle('Employee Info', Icons.person),
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: _inputDecoration('Department'),
                items: [
                  'Finance and Administration',
                  'Innovation and Technology',
                  'Human Resources',
                  'Technical Service Department',
                  'Business Development',
                  'Production',
                  'Quality',
                ]
                    .map((dept) =>
                        DropdownMenuItem(value: dept, child: Text(dept)))
                    .toList(),
                onChanged: (val) => setState(() => department = val),
                validator: (val) =>
                    val == null ? 'Please select a department' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: pfController,
                decoration: _inputDecoration('PF Number'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter PF Number' : null,
              ),
              const SizedBox(height: 24),
              _sectionTitle('Incident Details', Icons.warning),
              ListTile(
                title: Text(
                  selectedDate == null
                      ? 'Select Date of the Near Miss'
                      : 'Date: ${DateFormat('MMMM dd, yyyy').format(selectedDate!)}',
                ),
                trailing: Icon(Icons.calendar_today, color: mycolor),
                onTap: _pickDate,
              ),
              if (selectedDate == null)
                const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Text('Please select a date',
                      style: TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: locationController,
                decoration: _inputDecoration('Location'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter location' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: _inputDecoration('Level of Risk'),
                items: [
                  'HIGH RISK: Stop work and report immediately',
                  'MODERATE RISK: Proceed with caution and report',
                  'LOW RISK: Continue as per SOP and report',
                ]
                    .map((risk) =>
                        DropdownMenuItem(value: risk, child: Text(risk)))
                    .toList(),
                onChanged: (val) => setState(() => riskLevel = val),
                validator: (val) => val == null ? 'Select risk level' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: _inputDecoration('Category'),
                items: [
                  'Unsafe act',
                  'Unsafe condition',
                  'Unsafe equipment',
                  'Unsafe use of equipment',
                ]
                    .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => setState(() => category = val),
                validator: (val) => val == null ? 'Select category' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descriptionController,
                decoration: _inputDecoration('Describe the Near Miss'),
                maxLines: 4,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 24),
              _sectionTitle('Media Upload', Icons.attach_file),
              ElevatedButton.icon(
                onPressed: _pickFiles,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Media (max 3 files)'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: mycolor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              if (uploadedFiles != null)
                ...uploadedFiles!
                    .map((file) => ListTile(title: Text(file.name))),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _submitForm(context),
                child: const Text('Submit'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: mycolor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
