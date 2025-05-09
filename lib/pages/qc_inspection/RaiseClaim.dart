import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader2.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class ClaimForm extends StatefulWidget {
  final vehileId;

  const ClaimForm({super.key, this.vehileId});
  @override
  State<ClaimForm> createState() => _ClaimFormState();
}

class _ClaimFormState extends State<ClaimForm>
    with SingleTickerProviderStateMixin {
  var user = {};
  FocusNode searchFocusNode = FocusNode();
  FocusNode textFieldFocusNode = FocusNode();
  late SingleValueDropDownController _carModel;
  late SingleValueDropDownController _partNoModel;

  late TextEditingController _defectCodeController;
  late TextEditingController _descriptionController;

  var errorText = '';
  var selectedCustomerId;
  var modelId;
  var payd;
  // late List<dynamic> models = [];
  late List<dynamic> models = [];
  // var checklistData;
  late List<dynamic> clients = [];
  late List<dynamic> checklist = [];
  List<Map<String, dynamic>> filteredModels = [];
  late List<dynamic> countries = [];
  bool isLoading = true;
  String? error;
  String errorModel = '';
  FocusNode _partNoModelFieldFocusNode = FocusNode();
  FocusNode _partNoModelFocusNode = FocusNode();

// Define your FocusNodes
  final FocusNode routeTextFieldFocusNode = FocusNode();
  final FocusNode routeSearchFocusNode = FocusNode();
  final FocusNode lineTextFieldFocusNode = FocusNode();
  final FocusNode lineSearchFocusNode = FocusNode();
// Sample color
  final Color mycolor = Colors.blue; // or whatever color you are using
  @override
  void initState() {
    _carModel = SingleValueDropDownController();
    _partNoModel = SingleValueDropDownController();

    _defectCodeController = TextEditingController();
    _descriptionController = TextEditingController();

    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      _fetchData();
    });
    super.initState();
  }

  Future<void> _fetchData() async {
    setState(() {
      errorText = ''; // Initialize error text before fetching
      isLoading = true; // Show loading indicator
    });
    try {
      final results = await Future.wait([fetchClients(), fetchChecklist()]);
      // Check if any result is null or missing expected keys
      if (results[0] == null ||
          results[1] == null ||
          results[0]["data"] == null ||
          results[1]["data"] == null) {
        throw Exception("Failed to fetch data: Missing required information.");
      }
      setState(() {
        clients = results[0]["data"] as List;
        checklist = results[1]["data"] as List;
        // filteredModels = List.from(models);
        // countries = results[1]["data"] as List;
        isLoading = false; // Stop loading indicator
      });
    } catch (e) {
      // Handle exceptions and update error text
      setState(() {
        errorText = e.toString(); // Display error message
        isLoading = false; // Stop loading indicator
      });
    }
  }

  @override
  void dispose() {
    _partNoModel.dispose();
    _carModel.dispose();
    _partNoModelFieldFocusNode.dispose();
    _partNoModelFocusNode.dispose();

    super.dispose();
  }

  List<List<dynamic>> checklistData = [];
  void storeChecklist() {
    try {
      checklistData = checklist.where((query) {
        return query['checked'] == 'OK' || query['checked'] == 'NOK';
      }).map((query) {
        return [query['id'], query['checked']];
      }).toList();
    } catch (e) {
      print('Error storing checklist: $e');
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    // print(checklistData);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Claim  Form',
          style: TextStyle(
            // fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          // style: TextStyle(fontSize: 14),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: errorText.isNotEmpty
                  ? ErrorMessageWidget(
                      errorMessage: errorText,
                      onRetry: () {
                        _fetchData();
                      },
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(0),
                      child: Form(
                        key: _formKey,
                        child: Card(
                          color: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (errorModel.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      errorText,
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                DropDownTextField(
                                  controller: _partNoModel,
                                  clearOption: false,
                                  dropDownIconProperty:
                                      IconProperty(color: mycolor, size: 30),
                                  textFieldDecoration: InputDecoration(
                                    labelText: 'Part Number',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    // hintText: 'Choose Vehicle Model',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  textFieldFocusNode:
                                      _partNoModelFieldFocusNode,
                                  searchFocusNode: _partNoModelFocusNode,
                                  dropDownItemCount: 5,
                                  enableSearch: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "*Required";
                                    } else {
                                      return null;
                                    }
                                  },
                                  dropDownList:
                                      clients.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final client = entry.value;
                                    return DropDownValueModel(
                                      name: "part no $index",
                                      value: client['id'],
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 8),
                                CustomTextFormField(
                                  label: 'Defect Code',
                                  hint: '',
                                  controller: _defectCodeController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '*Required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 8),
                                CustomTextFormField(
                                  minLines: 3,
                                  keyboardType: TextInputType.multiline,
                                  label: 'Description',
                                  hint: '',
                                  controller: _descriptionController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '*Required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),
                                CustomButton(
                                  label: 'SAVE',
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      // Save the form data.
                                      if (_formKey.currentState!.validate()) {
                                        if (checklist.length !=
                                            (checklistData.length)) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              margin: const EdgeInsets.all(50),
                                              padding: const EdgeInsets.all(10),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              content: Text(
                                                  'Please fill all checklist items!'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }
                                        PostData();
                                      }
                                      print('Form submitted');
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
    );
  }

  void PostData() async {
    final dataToStore = {
      'vehicle_id': widget.vehileId,
      'part_no': _partNoModel.dropDownValue?.value,
      'defect_code': _defectCodeController.text.trim(),
      'description': _descriptionController.text.trim(),
    };
    // print(dataToStore);
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
      final response = await http
          .post(
            Uri.parse(Api.api_url + "postScheduledUnit"),
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
    } on TimeoutException {
      showError('Request timed out. Please try again.', color: Colors.orange);
    } on SocketException {
      showError('No Internet connection.');
    } catch (e) {
      print("Unexpected Error: $e");
      showError('Failed: ${e.toString()}');
    } finally {
      progressDialog.hide();
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
    _partNoModel.setDropDown(null);
    _defectCodeController.clear();
    _descriptionController.clear();
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

  Future fetchCarModel(customerId) async {
    setState(() {
      errorModel = ''; // Initialize error text before fetching
    });
    String url = Api.api_url + "loadClientModels/$customerId";
    print(url);
    var responsedata = await httpget(url, user['data']['token'], context);
    return responsedata;
  }

  Future fetchClients() async {
    String url = Api.api_url + "loadclients";
    var responsedata = await httpget(url, user['data']['token'], context);
    print(responsedata);
    return responsedata;
  }

  Future fetchChecklist() async {
    String url = Api.api_url + "loadVehicleReceiving";
    var responsedata = await httpget(url, user['data']['token'], context);
    print(responsedata);
    return responsedata;
  }
}

class CustomTextFormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  // final int? maxLines;
  final int? minLines;

  const CustomTextFormField({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.minLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType == null ? TextInputType.text : keyboardType,
      controller: controller,
      validator: validator,
      maxLines: null,
      minLines: minLines,
      decoration: InputDecoration(
        labelText: label,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}

class CustomDropdownField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final List<Map<String, String>> items;
  final Function(String?) onChanged;
  const CustomDropdownField({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.items,
    required this.onChanged,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      onChanged: onChanged,
      items: items
          .map((item) => DropdownMenuItem(
                value: item['value'],
                child: Text(item['name']!),
              ))
          .toList(),
    );
  }
}

class CustomDateField extends StatelessWidget {
  final String label;
  final DateTime selectedDate;
  final VoidCallback onTap;
  const CustomDateField({
    Key? key,
    required this.label,
    required this.selectedDate,
    required this.onTap,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.blue
                  .shade50, // Light blue background like Bootstrap alert-primary
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue, width: 1), // Blue border
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade900, // Darker blue for text
                    ),
                  ),
                ),
                Text(
                  DateFormat('dd-MM-yyyy').format(selectedDate),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade800, // Matching text color
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const CustomButton({
    Key? key,
    required this.label,
    required this.onPressed,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
