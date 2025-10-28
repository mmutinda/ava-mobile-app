import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:http/http.dart' as http;
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class NearMissFormPage extends StatefulWidget {
  final String pfNumber;

  const NearMissFormPage({super.key, required this.pfNumber});

  @override
  State<NearMissFormPage> createState() => _NearMissFormPageState();
}

class _NearMissFormPageState extends State<NearMissFormPage> {
  final _formKey = GlobalKey<FormState>();
  String? department, riskLevel, category;
  DateTime? selectedDate;
  List<PlatformFile>? uploadedFiles;
  File? _pickedImage;

  late final TextEditingController pfController;
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    // Show bottom sheet instead of dialog for better mobile UX
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle indicator
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Add Photo Evidence',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212529),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose how you want to add photo evidence',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Camera Option
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, ImageSource.camera),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mycolor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt_rounded, size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Take Photo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Gallery Option
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.pop(context, ImageSource.gallery),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: mycolor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: mycolor, width: 2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.photo_library_rounded, size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Choose from Gallery',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Cancel Option
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (source != null) {
      try {
        final picked = await picker.pickImage(
          source: source,
          imageQuality: 80, // Compress image for better performance
          maxWidth: 1024, // Limit image size
          maxHeight: 1024,
        );
        if (picked != null) {
          setState(() => _pickedImage = File(picked.path));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error picking image: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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

    // // Add uploaded files
    // if (uploadedFiles != null && uploadedFiles!.isNotEmpty) {
    //   for (var file in uploadedFiles!) {
    //     final filePath = file.path;
    //     if (filePath != null && filePath.isNotEmpty) {
    //       request.files.add(await http.MultipartFile.fromPath(
    //         'files[]', // Use 'files' if your backend doesn't expect an array
    //         filePath,
    //       ));
    //     }
    //   }
    // }
    // Add picked image if present
    if (_pickedImage != null && await _pickedImage!.exists()) {
      request.files.add(await http.MultipartFile.fromPath(
        'files[]',
        _pickedImage!.path,
      ));
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
    super.initState();
    pfController = TextEditingController(text: widget.pfNumber);
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
                enabled: false,
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
              _sectionTitle('Photo Evidence', Icons.attach_file),
              const SizedBox(height: 8),
              if (_pickedImage == null)
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          size: 32,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to add photo evidence',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Optional',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Image.file(
                          _pickedImage!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.green.shade600, size: 16),
                            const SizedBox(width: 8),
                            const Text(
                              'Photo evidence added',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF495057),
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: _pickImage,
                              child: Text(
                                'Change',
                                style: TextStyle(
                                  color: mycolor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
