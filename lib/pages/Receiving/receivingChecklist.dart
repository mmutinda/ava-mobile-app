import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:isuze_pqcs/common/ApiService.dart';
import 'package:isuze_pqcs/common/UIHelper.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class QCChecklist extends StatefulWidget {
  final id;
  final title;
  final sku;

  const QCChecklist({super.key, this.id, this.title, this.sku});

  @override
  State<QCChecklist> createState() => _QCChecklistState();
}

class _QCChecklistState extends State<QCChecklist>
    with SingleTickerProviderStateMixin {
  var user = {};
  var errorText = '';
  late List<dynamic> checklist = [];
  bool isLoading = true;

  // Controllers for text fields
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String selectedValue = 'NO';

  @override
  void initState() {
    super.initState();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      _fetchData();
    });
  }

  // Fetch checklist data
  Future<void> _fetchData() async {
    await ApiHelper.fetchMultipleData(
      context: context,
      requests: [fetchChecklist()],
      setLoading: (val) => setState(() => isLoading = val),
      onSuccess: (results) {
        setState(() {
          checklist = results[0]["data"] as List;
        });
      },
      onError: (message) {
        setState(() {
          errorText = message;
        });
      },
    );
  }

  Future fetchChecklist() async {
    String url = Api.api_url + "loadVehicleReceivingChecklist";
    var responsedata = await httpget(url, user['data']['token'], context);
    print(responsedata);
    return responsedata;
  }

  // Capture an image using the camera
  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
      });
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    // Validate if all checklist items are checked
    bool allAnswered = true;
    for (var query in checklist) {
      if (query['checked'] == null || query['checked'].isEmpty) {
        allAnswered = false;
        break;
      }
    }

    if (!allAnswered) {
      UIHelper.showErrorMessage(
        context: context,
        message:
            'Please make sure all checklist items are answered (OK or NOK).',
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    List<Map<String, dynamic>> checklistData = [];
    for (var query in checklist) {
      checklistData.add({
        'question_id': query['id'],
        'query_name': query['query_name'],
        'answer': query['checked'],
      });
    }

    final uri = Uri.parse('${Api.api_url}postVehicleReceivingChecklist');
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer ${user['data']["token"]}',
    });

    request.fields['vehicle_receiving_id'] = widget.id.toString();
    request.fields['questions'] = jsonEncode(checklistData);

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
      print(responseBody);

      if (responseBody['success'] == true) {
        // ✅ Show success message and pop back
        UIHelper.showSuccessMessage(
          context: context,
          message: responseBody['msg'] ?? 'Submitted successfully!',
        );
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
          context: context, message: "Request timed out. Please try again.");
    } catch (e) {
      print("Unexpected Error: $e");
      UIHelper.showErrorMessage(
          context: context, message: 'Failed: ${e.toString()}');
    } finally {
      progressDialog.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Receiving Inspection Sheet'),
            Text('Chassis: ${widget.sku}', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: errorText.isNotEmpty
                        ? ErrorMessageWidget(
                            errorMessage: errorText, onRetry: _fetchData)
                        : SingleChildScrollView(
                            child: Form(
                              key: _formKey,
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: checklist.map((query) {
                                          return Card(
                                            color: Colors.white,
                                            elevation: 1,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                            query['query_name']
                                                                    ?.toString() ??
                                                                'Unknown',
                                                            style: TextStyle(
                                                                fontSize: 16)),
                                                      ),
                                                      Row(
                                                        children: [
                                                          ChoiceChip(
                                                            label: Text('OK'),
                                                            selected: query[
                                                                    'checked'] ==
                                                                'OK',
                                                            selectedColor:
                                                                Colors.green,
                                                            onSelected:
                                                                (selected) {
                                                              setState(() {
                                                                query['checked'] =
                                                                    'OK';
                                                              });
                                                            },
                                                          ),
                                                          SizedBox(width: 10),
                                                          ChoiceChip(
                                                            label: Text('NOK'),
                                                            selected: query[
                                                                    'checked'] ==
                                                                'NOK',
                                                            selectedColor:
                                                                Colors.red,
                                                            onSelected:
                                                                (selected) {
                                                              setState(() {
                                                                query['checked'] =
                                                                    'NOK';
                                                              });
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      const SizedBox(height: 24),
                                      CustomButton(
                                          label: 'SAVE',
                                          onPressed: () =>
                                              _submitForm(context)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
