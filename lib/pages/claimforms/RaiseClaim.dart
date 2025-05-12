import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'dart:io';

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
  @override
  void initState() {
    super.initState();
    _lotNumberController = TextEditingController();
    _partDropdown = SingleValueDropDownController();
    _defectCodeController = TextEditingController();
    _descriptionController = TextEditingController();

    getuserdata().then((value) {
      user = jsonDecode(value);
      // _fetchData();
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

  FocusNode customerTextFieldFocusNode = FocusNode();
  FocusNode customerSearchFocusNode = FocusNode();
  FocusNode carModelTextFieldFocusNode = FocusNode();
  FocusNode carModelSearchFocusNode = FocusNode();
  FocusNode searchFocusNode = FocusNode();
  FocusNode textFieldFocusNode = FocusNode();
  String errorModel = '';
  late List<dynamic> partNOs = [];
  var LotId;
  // Future<void> _fetchData() async {
  //   setState(() {
  //     isLoading = true;
  //     errorText = '';
  //   });
  //   try {
  //     final results = await Future.wait([fetchClients()]);
  //     if (results.any((r) => r == null || r["data"] == null)) {
  //       throw Exception("Invalid response from server.");
  //     }
  //     setState(() {
  //       clients = results[0]["data"];
  //       checklist = results[1]["data"];
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       errorText = e.toString();
  //       isLoading = false;
  //     });
  //   }
  // }

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
      // Add success message or navigation here
    } catch (e) {
      progress.hide();
      print("Submission failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Claim Form'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
                  TextFormField(
                    controller: _lotNumberController,
                    focusNode: customerTextFieldFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Lot Number',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search, color: mycolor),
                        onPressed: () async {
                          final value = _lotNumberController.text.trim();
                          if (value.isEmpty) {
                            // Optionally show an error or return
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("Please enter a Lot Number")),
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
                            // print(response)
                            print('FetchCarModel Response: $response');
                            if (response != null) {
                              if (response['data'] != null) {
                                partNOs = response['data'];
                              } else {
                                partNOs = [];
                                errorModel =
                                    'Error: "data" not found or is not a List.';
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "*Required";
                      }
                      return null;
                    },

                    // onChanged: (value) async {
                    //   selectedLotId = value; // Assign directly from user input
                    //   setState(() {
                    //     _isLoadingModels = true;
                    //   });

                    //   try {
                    //     final response = await fetchpartNO(selectedLotId);
                    //     print('FetchCarModel Response: $response');
                    //     if (response != null &&
                    //         response is Map<String, dynamic>) {
                    //       if (response.containsKey('data') &&
                    //           response['data'] is List) {
                    //         partNOs = List<Map<String, dynamic>>.from(
                    //             response['data']);
                    //       } else {
                    //         partNOs = [];
                    //         errorModel =
                    //             'Error: "data" not found or is not a List.';
                    //       }
                    //     } else {
                    //       partNOs = [];
                    //       errorModel = 'Response is not a valid Map.';
                    //     }
                    //   } on TimeoutException {
                    //     errorModel = 'Fetching car models timed out.';
                    //     partNOs = [];
                    //   } on SocketException {
                    //     errorModel = 'No internet connection.';
                    //     partNOs = [];
                    //   } catch (e) {
                    //     errorModel = '$e';
                    //     partNOs = [];
                    //   } finally {
                    //     setState(() {
                    //       _isLoadingModels = false;
                    //       _partDropdown.clearDropDown();
                    //     });
                    //   }
                    // },
                  ),
                  const SizedBox(height: 8),
                  // Text("${partNOs}"),
                  _isLoadingModels
                      ? Center(child: CircularProgressIndicator())
                      : DropDownTextField(
                          controller: _partDropdown,
                          clearOption: false,
                          dropDownIconProperty:
                              IconProperty(color: mycolor, size: 30),
                          textFieldFocusNode: textFieldFocusNode,
                          textFieldDecoration: InputDecoration(
                            labelText: 'Part Number',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
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

                  const SizedBox(height: 12),
                  _buildTextField("Defect Code", _defectCodeController),
                  const SizedBox(height: 12),
                  _buildTextField(
                    "Description",
                    _descriptionController,
                    minLines: 3,
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _submitForm,
                      icon: const Icon(Icons.save),
                      label: const Text("Save"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
