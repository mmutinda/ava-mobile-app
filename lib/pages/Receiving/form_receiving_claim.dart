import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isuze_pqcs/common/ApiService.dart';
import 'package:isuze_pqcs/common/UIHelper.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class ReceivingFormClaim extends StatefulWidget {
  @override
  State<ReceivingFormClaim> createState() => _ReceivingFormClaimState();
}

class _ReceivingFormClaimState extends State<ReceivingFormClaim> {
  late SingleValueDropDownController _carModel;
  late SingleValueDropDownController _customerModel;
  late TextEditingController _lotNo;
  final TextEditingController _fileController = TextEditingController();
  final TextEditingController _fileController2 = TextEditingController();

  List<dynamic> clients = [];
  List<dynamic> models = [];
  String errorText = '';
  String errorModel = '';
  String selectedValue = 'NO';
  bool isLoading = false;
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
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      // _fetchData();
    });
    super.initState();
  }

  @override
  void dispose() {
    _customerModel.dispose();
    _carModel.dispose();
    _lotNo.dispose();
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

  File? _imageFile;
  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Raise Claim Form')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 8),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 15.0),
                //   child: ProgressSteps(
                //     currentStep: 2,
                //     totalSteps: 4,
                //     stepLabels: [
                //       'Receiving', // current step
                //       'Raise Claim', // next step
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
                                          labelText: 'Part No',
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
                                      ),
                                      const SizedBox(height: 8),
                                      DropDownTextField(
                                        controller: _customerModel,
                                        clearOption: false,
                                        dropDownIconProperty: IconProperty(
                                            color: mycolor, size: 30),
                                        textFieldDecoration: InputDecoration(
                                          labelText: 'Issue Category',
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
                                      ),
                                      const SizedBox(height: 8),
                                      DropDownTextField(
                                        controller: _customerModel,
                                        clearOption: false,
                                        dropDownIconProperty: IconProperty(
                                            color: mycolor, size: 30),
                                        textFieldDecoration: InputDecoration(
                                          labelText: 'Defect Classification',
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
                                      ),
                                      const SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: _captureImage,
                                        child: Container(
                                          width: double.infinity,
                                          height: 180,
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            image: _imageFile != null
                                                ? DecorationImage(
                                                    image:
                                                        FileImage(_imageFile!),
                                                    fit: BoxFit.cover)
                                                : null,
                                          ),
                                          child: _imageFile == null
                                              ? Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(Icons.camera_alt,
                                                          size: 40,
                                                          color: Colors.grey),
                                                      SizedBox(height: 8),
                                                      Text("Tap to capture",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.grey)),
                                                    ],
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ),
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
    // QClist().launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
    if (!_formKey.currentState!.validate()) return;

    final uri = Uri.parse('${Api.api_url}geologyFile');
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer ${user['data']["token"]}',
    });

    // Add fields
    request.fields['customer_id'] = _customerModel.dropDownValue!.value;
    request.fields['modoel_id'] = _carModel.dropDownValue!.value;
    request.fields['lot_no'] = _lotNo.text;
    request.fields['has_claim'] = selectedValue;

    // Add uploaded files
    if (parkingFile != null) {
      final filePath = parkingFile?.path;
      request.files.add(await http.MultipartFile.fromPath(
        'parkingFile', // Use 'files' if your backend doesn't expect an array
        filePath.toString(),
      ));
    }
    if (geologyFile != null) {
      final filePath = geologyFile?.path;
      request.files.add(await http.MultipartFile.fromPath(
        'geologyFile', // Use 'files' if your backend doesn't expect an array
        filePath.toString(),
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
        UIHelper.showSuccessMessage;
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

        UIHelper.showErrorMessage(context: context, message: errorMessage);
      }
    } on SocketException {
      UIHelper.showErrorMessage(
          context: context, message: "No Internet connection.");
    } on TimeoutException {
      UIHelper.showErrorMessage(
          context: context, message: "Request timed out. Please try again");
    } catch (e) {
      print("Unexpected Error: $e");

      UIHelper.showErrorMessage(
          context: context, message: 'Failed: ${e.toString()}');
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
