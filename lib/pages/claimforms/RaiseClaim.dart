import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class ClaimForm extends StatefulWidget {
  @override
  State<ClaimForm> createState() => _ClaimFormState();
}

class _ClaimFormState extends State<ClaimForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FocusNode _vehicleFieldFocus = FocusNode();
  final FocusNode _partFieldFocus = FocusNode();

  late TextEditingController _lotNumberController;
  late SingleValueDropDownController _partDropdown;
  late TextEditingController _defectCodeController;
  late TextEditingController _descriptionController;

  List<dynamic> clients = [];
  List<dynamic> checklist = [];
  List<List<dynamic>> checklistData = [];
  Map<String, dynamic> user = {};
  String errorText = '';
  bool isLoading = true;
  bool _isLoadingModels = false;
  var selectedLotId;
  var modelId;

  FocusNode customerTextFieldFocusNode = FocusNode();
  FocusNode customerSearchFocusNode = FocusNode();
  FocusNode carModelTextFieldFocusNode = FocusNode();
  FocusNode carModelSearchFocusNode = FocusNode();
  FocusNode searchFocusNode = FocusNode();
  FocusNode textFieldFocusNode = FocusNode();
  String errorModel = '';
  late List<dynamic> partNOs = [];
  var LotId;

  @override
  void initState() {
    super.initState();
    _lotNumberController = TextEditingController();
    _partDropdown = SingleValueDropDownController();
    _defectCodeController = TextEditingController();
    _descriptionController = TextEditingController();

    getuserdata().then((value) {
      user = jsonDecode(value);
    });
  }

  @override
  void dispose() {
    _lotNumberController.dispose();
    _partDropdown.dispose();
    _defectCodeController.dispose();
    _descriptionController.dispose();
    _vehicleFieldFocus.dispose();
    _partFieldFocus.dispose();
    super.dispose();
  }

  void storeChecklist() {
    try {
      checklistData = checklist
          .where((item) => item['checked'] == 'OK' || item['checked'] == 'NOK')
          .map((item) => [item['id'], item['checked']])
          .toList();
    } catch (e) {
      print('Checklist error: $e');
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    storeChecklist();
    if (checklist.length != checklistData.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please complete all checklist items!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    _postData();
  }

  void _postData() async {
    final data = {
      'lot_number': _lotNumberController.text.trim(),
      'part_number': _partDropdown.dropDownValue?.value,
      'defect_code': _defectCodeController.text.trim(),
      'description': _descriptionController.text.trim(),
    };

    final progress = ProgressDialog(context);
    progress.style(
      message: 'Submitting...',
      child: CustomLoader(),
      borderRadius: 8,
      backgroundColor: Colors.white,
      elevation: 10,
    );
    progress.show();

    try {
      final response = await http
          .post(
            Uri.parse("${Api.api_url}postScheduledUnit"),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer ${user['data']['token']}',
            },
            body: jsonEncode(data),
          )
          .timeout(Duration(seconds: 30));

      final res = jsonDecode(response.body);
      print(res);
      progress.hide();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Claim submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      progress.hide();
      print("Submission failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit claim. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Claim'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
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
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create New Claim',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Fill in the details below',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Form Fields
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (errorModel.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorModel,
                                style: TextStyle(color: Colors.red.shade600, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Lot Number Field
                    const Text(
                      'Lot Number',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _lotNumberController,
                      focusNode: customerTextFieldFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Enter lot number',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: mycolor, width: 2),
                        ),
                        suffixIcon: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: mycolor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: () async {
                              final value = _lotNumberController.text.trim();
                              if (value.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please enter a Lot Number"),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                              selectedLotId = value;
                              setState(() {
                                _isLoadingModels = true;
                                errorModel = '';
                              });

                              try {
                                final response = await fetchpartNO(selectedLotId);
                                print('FetchCarModel Response: $response');
                                if (response != null) {
                                  if (response['data'] != null) {
                                    partNOs = response['data'];
                                  } else {
                                    partNOs = [];
                                    errorModel = 'Error: "data" not found or is not a List.';
                                  }
                                } else {
                                  partNOs = [];
                                  errorModel = 'Response is not a valid Map.';
                                }
                              } on TimeoutException {
                                errorModel = 'Fetching car models timed out.';
                                partNOs = [];
                              } on SocketException {
                                errorModel = 'No internet connection.';
                                partNOs = [];
                              } catch (e) {
                                errorModel = '$e';
                                partNOs = [];
                              } finally {
                                setState(() {
                                  _isLoadingModels = false;
                                  _partDropdown.clearDropDown();
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "*Required";
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Part Number Field
                    const Text(
                      'Part Number',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isLoadingModels
                        ? Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : DropDownTextField(
                            controller: _partDropdown,
                            clearOption: false,
                            dropDownIconProperty: IconProperty(color: mycolor, size: 30),
                            textFieldFocusNode: textFieldFocusNode,
                            textFieldDecoration: InputDecoration(
                              hintText: 'Select part number',
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
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
                            searchFocusNode: searchFocusNode,
                            dropDownItemCount: 10,
                            enableSearch: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "*Required";
                              } else {
                                return null;
                              }
                            },
                            dropDownList: partNOs.map((partNo) {
                              return DropDownValueModel(
                                name: partNo,
                                value: partNo,
                              );
                            }).toList(),
                            onChanged: (val) {
                              modelId = val.value;
                            },
                          ),

                    const SizedBox(height: 20),
                    _buildEnhancedTextField("Defect Code", _defectCodeController),
                    const SizedBox(height: 20),
                    _buildEnhancedTextField(
                      "Description",
                      _descriptionController,
                      minLines: 4,
                      keyboardType: TextInputType.multiline,
                    ),
                    const SizedBox(height: 32),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mycolor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_outlined),
                            SizedBox(width: 8),
                            Text(
                              'Submit Claim',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future fetchClients() async {
    String url = Api.api_url + "loadclients";
    var responsedata = await httpget(url, user['data']['token'], context);
    print(responsedata);
    return responsedata;
  }

  Future fetchpartNO(id) async {
    String url = Api.api_url + "loadPartNumbers/${id}";
    var responsedata = await httpget(url, user['data']['token'], context);
    print(responsedata);
    return responsedata;
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildEnhancedTextField(
    String label,
    TextEditingController controller, {
    int minLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: minLines == 1 ? 1 : null,
          validator: (value) => value == null || value.isEmpty ? '*Required' : null,
          decoration: InputDecoration(
            hintText: 'Enter ${label.toLowerCase()}',
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: mycolor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int minLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: null,
      validator: (value) => value == null || value.isEmpty ? '*Required' : null,
      decoration: _inputDecoration(label),
    );
  }
}
