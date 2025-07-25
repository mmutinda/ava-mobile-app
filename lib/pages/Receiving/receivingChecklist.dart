import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:isuze_pqcs/common/ApiService.dart';
import 'package:isuze_pqcs/common/UIHelper.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
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
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Controllers for text fields
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String selectedValue = 'NO';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      _fetchData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
        _animationController.forward();
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
      setState(() {});
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
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [mycolor.withOpacity(0.8), mycolor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.checklist, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Receiving Inspection',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Chassis: ${widget.sku}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(mycolor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading inspection checklist...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Progress indicator header
                if (checklist.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          mycolor.withOpacity(0.1),
                          mycolor.withOpacity(0.2)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: mycolor.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: mycolor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.assignment_turned_in,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Inspection Progress',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${checklist.where((item) => item['checked'] != null && item['checked'].isNotEmpty).length}/${checklist.length}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: mycolor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircularProgressIndicator(
                          value: checklist.isEmpty
                              ? 0
                              : checklist
                                      .where((item) =>
                                          item['checked'] != null &&
                                          item['checked'].isNotEmpty)
                                      .length /
                                  checklist.length,
                          backgroundColor: mycolor.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(mycolor),
                          strokeWidth: 6,
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: errorText.isNotEmpty
                        ? ErrorMessageWidget(
                            errorMessage: errorText, onRetry: _fetchData)
                        : FadeTransition(
                            opacity: _fadeAnimation,
                            child: SingleChildScrollView(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    ...checklist.asMap().entries.map((entry) {
                                      int index = entry.key;
                                      var query = entry.value;
                                      bool isAnswered =
                                          query['checked'] != null &&
                                              query['checked'].isNotEmpty;
                                      bool isOK = query['checked'] == 'OK';

                                      return AnimatedContainer(
                                        duration: Duration(
                                            milliseconds: 300 + (index * 100)),
                                        margin:
                                            const EdgeInsets.only(bottom: 16),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: isAnswered
                                                ? (isOK
                                                    ? [
                                                        Colors.green.shade50,
                                                        Colors.green.shade100
                                                      ]
                                                    : [
                                                        Colors.red.shade50,
                                                        Colors.red.shade100
                                                      ])
                                                : [
                                                    Colors.white,
                                                    Colors.grey.shade50
                                                  ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isAnswered
                                                ? (isOK
                                                    ? Colors.green.shade300
                                                    : Colors.red.shade300)
                                                : Colors.grey.shade200,
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isAnswered
                                                  ? (isOK
                                                      ? Colors.green
                                                          .withOpacity(0.1)
                                                      : Colors.red
                                                          .withOpacity(0.1))
                                                  : Colors.black
                                                      .withOpacity(0.05),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 40,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: isAnswered
                                                            ? (isOK
                                                                ? [
                                                                    Colors.green
                                                                        .shade400,
                                                                    Colors.green
                                                                        .shade600
                                                                  ]
                                                                : [
                                                                    Colors.red
                                                                        .shade400,
                                                                    Colors.red
                                                                        .shade600
                                                                  ])
                                                            : [
                                                                Colors.grey
                                                                    .shade300,
                                                                Colors.grey
                                                                    .shade400
                                                              ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '${index + 1}',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Text(
                                                      query['query_name']
                                                              ?.toString() ??
                                                          'Unknown',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors
                                                            .grey.shade800,
                                                        height: 1.4,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 20),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          query['checked'] =
                                                              'OK';
                                                        });
                                                      },
                                                      child: AnimatedContainer(
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    200),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 12,
                                                                horizontal: 20),
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient: query[
                                                                      'checked'] ==
                                                                  'OK'
                                                              ? LinearGradient(
                                                                  colors: [
                                                                    Colors.green
                                                                        .shade400,
                                                                    Colors.green
                                                                        .shade600
                                                                  ],
                                                                  begin: Alignment
                                                                      .topLeft,
                                                                  end: Alignment
                                                                      .bottomRight,
                                                                )
                                                              : null,
                                                          color:
                                                              query['checked'] ==
                                                                      'OK'
                                                                  ? null
                                                                  : Colors.grey
                                                                      .shade100,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          border: Border.all(
                                                            color: query[
                                                                        'checked'] ==
                                                                    'OK'
                                                                ? Colors.green
                                                                    .shade600
                                                                : Colors.grey
                                                                    .shade300,
                                                            width: 2,
                                                          ),
                                                          boxShadow:
                                                              query['checked'] ==
                                                                      'OK'
                                                                  ? [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .green
                                                                            .withOpacity(0.3),
                                                                        blurRadius:
                                                                            8,
                                                                        offset: const Offset(
                                                                            0,
                                                                            4),
                                                                      ),
                                                                    ]
                                                                  : [],
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .check_circle,
                                                              color: query[
                                                                          'checked'] ==
                                                                      'OK'
                                                                  ? Colors.white
                                                                  : Colors.green
                                                                      .shade600,
                                                              size: 20,
                                                            ),
                                                            const SizedBox(
                                                                width: 8),
                                                            Text(
                                                              'OK',
                                                              style: TextStyle(
                                                                color: query[
                                                                            'checked'] ==
                                                                        'OK'
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .green
                                                                        .shade600,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          query['checked'] =
                                                              'NOK';
                                                        });
                                                      },
                                                      child: AnimatedContainer(
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    200),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 12,
                                                                horizontal: 20),
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient: query[
                                                                      'checked'] ==
                                                                  'NOK'
                                                              ? LinearGradient(
                                                                  colors: [
                                                                    Colors.red
                                                                        .shade400,
                                                                    Colors.red
                                                                        .shade600
                                                                  ],
                                                                  begin: Alignment
                                                                      .topLeft,
                                                                  end: Alignment
                                                                      .bottomRight,
                                                                )
                                                              : null,
                                                          color:
                                                              query['checked'] ==
                                                                      'NOK'
                                                                  ? null
                                                                  : Colors.grey
                                                                      .shade100,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          border: Border.all(
                                                            color: query[
                                                                        'checked'] ==
                                                                    'NOK'
                                                                ? Colors.red
                                                                    .shade600
                                                                : Colors.grey
                                                                    .shade300,
                                                            width: 2,
                                                          ),
                                                          boxShadow:
                                                              query['checked'] ==
                                                                      'NOK'
                                                                  ? [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .red
                                                                            .withOpacity(0.3),
                                                                        blurRadius:
                                                                            8,
                                                                        offset: const Offset(
                                                                            0,
                                                                            4),
                                                                      ),
                                                                    ]
                                                                  : [],
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons.cancel,
                                                              color: query[
                                                                          'checked'] ==
                                                                      'NOK'
                                                                  ? Colors.white
                                                                  : Colors.red
                                                                      .shade600,
                                                              size: 20,
                                                            ),
                                                            const SizedBox(
                                                                width: 8),
                                                            Text(
                                                              'NOK',
                                                              style: TextStyle(
                                                                color: query[
                                                                            'checked'] ==
                                                                        'NOK'
                                                                    ? Colors
                                                                        .white
                                                                    : Colors.red
                                                                        .shade600,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                    const SizedBox(height: 32),
                                    // Enhanced Save Button
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            mycolor.withOpacity(0.8),
                                            mycolor
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: mycolor.withOpacity(0.3),
                                            blurRadius: 12,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 18),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        ),
                                        onPressed: () => _submitForm(context),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.save_rounded,
                                              color: Colors.white,
                                              size: 22,
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              'SAVE INSPECTION',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                  ],
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
