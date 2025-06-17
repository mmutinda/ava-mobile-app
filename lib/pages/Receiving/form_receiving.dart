import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer'; // For logging
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isuze_pqcs/common/ApiService.dart';
import 'package:isuze_pqcs/common/UIHelper.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/pages/Receiving/WizardForm.dart';
import 'package:http/http.dart' as http;
import 'package:isuze_pqcs/pages/Receiving/form_receiving_claim.dart';
import 'package:isuze_pqcs/pages/planning/widget.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class ReceivingForm extends StatefulWidget {
  @override
  State<ReceivingForm> createState() => _ReceivingFormState();
}

class _ReceivingFormState extends State<ReceivingForm> {
  late SingleValueDropDownController _carModel;
  late SingleValueDropDownController _customerModel;
  late TextEditingController _lotNo;
  late TextEditingController _lotQty;
  final TextEditingController _fileController = TextEditingController();
  final TextEditingController _fileController2 = TextEditingController();

  List<dynamic> clients = [];
  List<dynamic> models = [];
  String errorText = '';
  String errorModel = '';
  String selectedValue = 'NO';
  Map<String, dynamic>? issueData;

  void _showIssueDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => IssueDialog(),
    );

    if (result != null) {
      setState(() {
        issueData = result;
      });
    }
  }

  bool isLoading = true;
  bool _isLoadingModels = false;
  dynamic selectedCustomerId;
  dynamic modelId;
  File? parkingFile;
  File? geologyFile;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Color mycolor = Colors.blue;
  var user = {};
  @override
  void initState() {
    _carModel = SingleValueDropDownController();
    _customerModel = SingleValueDropDownController();
    _lotNo = TextEditingController();
    _lotQty = TextEditingController();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      _fetchData();
    });
    super.initState();
  }

  @override
  void dispose() {
    _customerModel.dispose();
    _carModel.dispose();
    _lotNo.dispose();
    _lotQty.dispose();
    _fileController.dispose();
    _fileController2.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    await ApiHelper.fetchMultipleData(
      context: context,
      requests: [fetchClients()],
      setLoading: (val) => setState(() => isLoading = val),
      onSuccess: (results) {
        setState(() {
          clients = results[0]["data"] as List;
        });
      },
      onError: (message) {
        setState(() {
          errorText = message;
        });
      },
    );
  }

  Future<void> _pickFile(int type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'csv'],
    );
    if (result != null) {
      setState(() {
        if (type == 0) {
          parkingFile = File(result.files.single.path!);
          _fileController.text = result.files.single.name;
        } else {
          geologyFile = File(result.files.single.path!);
          _fileController2.text = result.files.single.name;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Receiving Form')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 8),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 15.0),
                //   child: ProgressSteps(
                //     currentStep: 1,
                //     totalSteps: selectedValue == 'YES' ? 4 : 3,
                //     stepLabels: [
                //       'Receiving', // current step
                //       if (selectedValue == 'YES') 'Raise Claim', // next step
                //       'QC list',

                //       'Qc Checklist',
                //     ],
                //   ),
                // ),
                const SizedBox(height: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: errorText.isNotEmpty
                        ? ErrorMessageWidget(
                            errorMessage: errorText,
                            onRetry: _fetchData,
                          )
                        : SingleChildScrollView(
                            child: Form(
                              key: _formKey,
                              child: Card(
                                color: Colors.white,
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (errorModel.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            errorModel,
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      DropDownTextField(
                                        controller: _customerModel,
                                        clearOption: false,
                                        dropDownIconProperty: IconProperty(
                                            color: mycolor, size: 30),
                                        textFieldDecoration: InputDecoration(
                                          labelText: 'Customer',
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey.shade50,
                                        ),
                                        dropDownItemCount: 5,
                                        enableSearch: true,
                                        validator: (value) =>
                                            (value == null || value.isEmpty)
                                                ? "*Required"
                                                : null,
                                        dropDownList: clients.map((client) {
                                          return DropDownValueModel(
                                            name: client['name'] ?? 'Unknown',
                                            value: client['id'],
                                          );
                                        }).toList(),
                                        onChanged: (val) async {
                                          selectedCustomerId = val.value;
                                          setState(
                                              () => _isLoadingModels = true);
                                          try {
                                            final response =
                                                await fetchCarModel(
                                                    selectedCustomerId);
                                            models = response['data'] ?? [];
                                          } catch (e) {
                                            models = [];
                                            errorModel =
                                                'Failed to load models: $e';
                                          } finally {
                                            setState(() {
                                              _isLoadingModels = false;
                                              _carModel.clearDropDown();
                                            });
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      _isLoadingModels
                                          ? Center(
                                              child:
                                                  CircularProgressIndicator())
                                          : DropDownTextField(
                                              controller: _carModel,
                                              clearOption: false,
                                              dropDownIconProperty:
                                                  IconProperty(
                                                      color: mycolor, size: 30),
                                              textFieldDecoration:
                                                  InputDecoration(
                                                labelText: 'Vehicle Model',
                                                floatingLabelBehavior:
                                                    FloatingLabelBehavior
                                                        .always,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                filled: true,
                                                fillColor: Colors.grey.shade50,
                                              ),
                                              dropDownItemCount: 5,
                                              enableSearch: true,
                                              validator: (value) =>
                                                  (value == null ||
                                                          value.isEmpty)
                                                      ? "*Required"
                                                      : null,
                                              dropDownList: models.map((model) {
                                                return DropDownValueModel(
                                                  name:
                                                      model['model_name'] ?? '',
                                                  value: model['id'],
                                                );
                                              }).toList(),
                                              onChanged: (val) {
                                                modelId = val.value;
                                              },
                                            ),
                                      const SizedBox(height: 8),
                                      CustomTextFormField(
                                        label: 'Lot No',
                                        hint: 'Enter Lot number',
                                        controller: _lotNo,
                                        validator: (value) =>
                                            (value == null || value.isEmpty)
                                                ? '*Required'
                                                : null,
                                      ),
                                      const SizedBox(height: 8),
                                      CustomTextFormField(
                                        label: 'Lot Quantity',
                                        hint: 'Enter Lot number',
                                        controller: _lotQty,
                                        validator: (value) =>
                                            (value == null || value.isEmpty)
                                                ? '*Required'
                                                : null,
                                      ),
                                      const SizedBox(height: 16),
                                      CustomUploadFormField(
                                        label: 'Upload Parking List (Excel)',
                                        hint: 'No file chosen',
                                        controller: _fileController,
                                        onUploadPressed: () => _pickFile(0),
                                      ),
                                      const SizedBox(height: 15),
                                      CustomUploadFormField(
                                        label: 'Upload Geology Data (Excel)',
                                        hint: 'No file chosen',
                                        controller: _fileController2,
                                        onUploadPressed: () => _pickFile(1),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        // crossAxisAlignment: WrapCrossAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Any Packaging Issue?",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: mycolor,
                                                letterSpacing: 1.2,
                                              ),
                                            ),
                                          ),
                                          ChoiceChip(
                                            label: Text('YES'),
                                            selected: selectedValue == 'YES',
                                            selectedColor: Colors.red,
                                            onSelected: (selected) {
                                              setState(() {
                                                selectedValue = 'YES';
                                              });
                                              _showIssueDialog();
                                            },
                                            labelStyle: TextStyle(
                                              color: selectedValue == 'YES'
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          ChoiceChip(
                                            label: Text('NO'),
                                            selected: selectedValue == 'NO',
                                            selectedColor: Colors.green,
                                            onSelected: (selected) {
                                              setState(() {
                                                selectedValue = 'NO';
                                              });
                                            },
                                            labelStyle: TextStyle(
                                              color: selectedValue == 'NO'
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (issueData != null) ...[
                                        SizedBox(height: 20),
                                        Text("Issue Summary",
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            "Part No: ${issueData!['partNo']}"),
                                        Text(
                                            "Category: ${issueData!['category']}"),
                                        Text(
                                            "Classification: ${issueData!['classification']}"),
                                        if (issueData!['image'] != null)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 10),
                                            child: Image.file(
                                                issueData!['image'],
                                                height: 100),
                                          ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: Container(
                    width: double.infinity,
                    child: ElevatedButton(
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
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _submitForm(BuildContext context) async {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => ReceivingFormClaim()),
    // );
    // return;
    if (!_formKey.currentState!.validate()) return;

    final uri = Uri.parse('${Api.api_url}postScheduledUnit');
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer ${user['data']["token"]}',
    });

    // Add form fields
    request.fields['customer_id'] =
        _customerModel.dropDownValue!.value.toString();
    request.fields['unit_model_id'] = _carModel.dropDownValue!.value.toString();
    request.fields['lot_number'] = _lotNo.text;
    request.fields['lot_qty'] = _lotQty.text;
    request.fields['packing_list_issue'] = selectedValue;
    request.fields['part_number'] = issueData?['partNo'] ?? '';
    request.fields['category'] = issueData?['category'] ?? '';
    request.fields['classification'] = issueData?['classification'] ?? '';

    // Add uploaded files
    if (parkingFile != null && parkingFile!.path.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
        'packing_list',
        parkingFile!.path,
      ));
    }

    if (geologyFile != null && geologyFile!.path.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
        'geology_data',
        geologyFile!.path,
      ));
    }
    if (issueData != null && issueData?['image']!.path.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
        'images',
        issueData!['image']!.path,
      ));
    }

    // Debug print for request fields
    request.fields.forEach((key, value) {
      print('Field: $key = $value');
    });

    final progressDialog = ProgressDialog(context);
    progressDialog.style(
      message: 'Submitting ..',
      child: CustomLoader(),
      borderRadius: 8,
      backgroundColor: Colors.white,
      progressWidget: const SizedBox(
        width: 20,
        height: 20,
        child: Center(child: CircularProgressIndicator()),
      ),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
    );

    progressDialog.show();

    try {
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var responseBody = jsonDecode(responseData);

      // Fixed: log expects a String, not a Map
      log(jsonDecode(responseData));
      log(jsonDecode(responseData));

      if (response.statusCode == 200 || responseBody['success'] == true) {
        UIHelper.showSuccessMessage(
          context: context,
          message: "Submitted successfully",
        );
      } else {
        String errorMessage = responseBody['msg'] ??
            responseBody['message'] ??
            "An error occurred";

        if (responseBody['errors'] != null) {
          final errors = responseBody['errors'];
          final errorDetails =
              errors.entries.map((e) => '${e.key}: ${e.value[0]}').join('\n');
          errorMessage += '\n$errorDetails';
        }

        UIHelper.showErrorMessage(context: context, message: errorMessage);
      }
    } on SocketException {
      UIHelper.showErrorMessage(
        context: context,
        message: "No Internet connection.",
      );
    } on TimeoutException {
      UIHelper.showErrorMessage(
        context: context,
        message: "Request timed out. Please try again",
      );
    } catch (e) {
      print("Unexpected Error: $e");
      UIHelper.showErrorMessage(
        context: context,
        message: 'Failed: ${e.toString()}',
      );
    } finally {
      progressDialog.hide();
    }
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
}
