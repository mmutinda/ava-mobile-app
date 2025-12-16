import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:isuze_pqcs/common/ApiService.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/pages/qc_inspection/routing_structure/issuedialog.dart';

class QCChecklist extends StatefulWidget {
  final id;
  final title;
  final sku;
  final lotNO;

  const QCChecklist(
      {super.key, this.id, this.title, this.sku, required this.lotNO});

  @override
  State<QCChecklist> createState() => _QCChecklistState();
}

class _QCChecklistState extends State<QCChecklist>
    with SingleTickerProviderStateMixin {
  var user = {};
  var errorText = '';
  late List<dynamic> checklist = [];
  bool isLoading = true;
  bool isSubmitting = false;
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

          // Initialize each checklist item with proper structure
          for (var item in checklist) {
            // Initialize checked field if answer exists from API
            if (item['answer'] != null &&
                item['answer'].toString().isNotEmpty) {
              item['checked'] = item['answer'];
            } else {
              item['checked'] = null;
            }

            // Initialize description if exists
            if (item['description'] == null) {
              item['description'] = '';
            }

            // Initialize image if exists
            if (item['image'] == null) {
              item['image'] = null;
            }

            // Initialize nokData to store dialog data
            if (item['nokData'] == null) {
              item['nokData'] = null;
            }
          }
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

  // Initialize claim template with job card format
  Map<String, dynamic> _initializeClaimTemplate() {
    return {
      'question_id': widget.id,
      'issue_description': '',
      'part_number': '',
      'issue_category': null,
      'issue_type': null,
      'defect_classification': null,
      'image_path': null,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  Future fetchChecklist() async {
    String url = Api.api_url + "loadVehicleReceivingChecklist";
    var responsedata = await httpget(url, user['data']['token'], context);
    print(responsedata);
    return responsedata;
  }

  // Capture an image using the camera
  Future<void> _captureImage(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        checklist[index]['image'] = File(pickedFile.path);
      });
    }
  }

  // Show confirmation dialog before submitting
  Future<void> _showConfirmDialog(BuildContext context) async {
    // Count OK and NOK items
    int okCount = checklist.where((item) => item['checked'] == 'OK').length;
    int nokCount = checklist.where((item) => item['checked'] == 'NOK').length;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              // gradient: LinearGradient(
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              //   colors: [
              //     Colors.white,
              //     mycolor.withOpacity(0.05),
              //   ],
              // ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [mycolor.withOpacity(0.8), mycolor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: mycolor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.assignment_turned_in,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Confirm Submission',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  'Are you sure you want to submit this inspection?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Items:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            '${checklist.length}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: mycolor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.green.shade600, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'OK Items:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$okCount',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.cancel,
                                  color: Colors.red.shade600, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'NOK Items:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$nokCount',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mycolor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
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
      },
    );

    if (confirmed == true) {
      _submitForm(context);
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    try {
      // ✅ 1. Validate checklist
      bool allAnswered = true;
      List<String> missingDescriptions = [];

      for (int i = 0; i < checklist.length; i++) {
        final query = checklist[i];

        if (query['checked'] == null || query['checked'].toString().isEmpty) {
          allAnswered = false;
          break;
        }

        if (query['checked'] == 'NOK' &&
            (query['description'] == null ||
                query['description'].toString().trim().isEmpty)) {
          missingDescriptions.add('Item ${i + 1}: ${query['query_name']}');
        }
      }

      if (!allAnswered) {
        UIHelper.showErrorMessage(
          context: context,
          message: 'Please answer all checklist items (OK or NOK).',
        );
        return;
      }

      if (missingDescriptions.isNotEmpty) {
        UIHelper.showErrorMessage(
          context: context,
          message:
              'Please provide descriptions for NOK items:\n${missingDescriptions.join('\n')}',
        );
        return;
      }

      if (!_formKey.currentState!.validate()) return;

      // ✅ 2. Prepare checklist data
      final List<Map<String, dynamic>> checklistData = [];
      final List<Map<String, dynamic>> imageFiles = [];

      for (int i = 0; i < checklist.length; i++) {
        final query = checklist[i];
        final item = {
          'vehicle_receiving_checklist_id': query['id'],
          'answer': query['checked'],
          'description':
              query['checked'] == 'NOK' ? (query['description'] ?? '') : null,
        };
        checklistData.add(item);

        // Collect images for NOK items
        if (query['checked'] == 'NOK' && query['image'] != null) {
          imageFiles.add({
            'id': query['id'],
            'path': query['image'].path,
          });
        }
      }

      // ✅ 3. Build request
      final uri = Uri.parse('${Api.api_url}postVehicleReceivingChecklistt');
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll({
          'Accept': 'application/json',
          'Authorization': 'Bearer ${user['data']["token"]}',
        })
        ..fields['vehicle_receiving_id'] = widget.id.toString()
        ..fields['questions'] = jsonEncode(checklistData);

      // ✅ 4. Attach image files directly (no compression)
      for (int i = 0; i < imageFiles.length; i++) {
        final imageInfo = imageFiles[i];
        final file = File(imageInfo['path']);
        final multipart = await http.MultipartFile.fromPath(
          'images[${imageInfo['id']}]', // maps image to question ID
          file.path,
        );
        request.files.add(multipart);
      }

      // ✅ 5. Set submitting state and show loader
      setState(() {
        isSubmitting = true;
      });
      UIHelper.showLoader(context, message: 'Submitting checklist...');

      // ✅ 6. Send request
      final response =
          await request.send().timeout(const Duration(seconds: 60));
      final responseBody = jsonDecode(await response.stream.bytesToString());
      log(jsonEncode(responseBody));
      // ✅ 7. Handle response
      UIHelper.hideLoader(context);
      setState(() {
        isSubmitting = false;
      });

      if (responseBody['success'] == true) {
        UIHelper.showSuccessMessage(
          context: context,
          message: responseBody['msg'] ?? 'Submitted successfully!',
        );
        Navigator.pop(context);
      } else {
        String message = responseBody['msg'] ??
            responseBody['message'] ??
            "An error occurred";
        if (responseBody['errors'] != null) {
          final errors = responseBody['errors'] as Map<String, dynamic>;
          final details =
              errors.entries.map((e) => '${e.key}: ${e.value[0]}').join('\n');
          message += '\n$details';
        }
        UIHelper.showErrorMessage(context: context, message: message);
      }
    } on SocketException {
      UIHelper.hideLoader(context);
      setState(() {
        isSubmitting = false;
      });
      UIHelper.showErrorMessage(
          context: context, message: "No Internet connection.");
    } on TimeoutException {
      UIHelper.hideLoader(context);
      setState(() {
        isSubmitting = false;
      });
      UIHelper.showErrorMessage(
          context: context, message: "Request timed out. Please try again.");
    } catch (e) {
      UIHelper.hideLoader(context);
      setState(() {
        isSubmitting = false;
      });
      UIHelper.showErrorMessage(
          context: context, message: 'Unexpected error: $e');
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(60),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.assignment_outlined,
              size: 60,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Checklist Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no inspection items\navailable for this vehicle.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: mycolor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: mycolor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _fetchData,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text(
                'Refresh',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Go Back',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
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
                    'Chassis: ${widget.lotNO}',
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
                // Progress indicator header - only show if checklist has data
                if (checklist.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: mycolor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: mycolor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.assignment_turned_in,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Inspection Progress',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${checklist.where((item) => item['checked'] != null && item['checked'].isNotEmpty).length}/${checklist.length}',
                                style: TextStyle(
                                  fontSize: 20,
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
                          strokeWidth: 4,
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: errorText.isNotEmpty
                        ? ErrorMessageWidget(
                            errorMessage: errorText, onRetry: _fetchData)
                        : checklist.isEmpty
                            ? _buildEmptyState()
                            : FadeTransition(
                                opacity: _fadeAnimation,
                                child: SingleChildScrollView(
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        ...checklist
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          int index = entry.key;
                                          var query = entry.value;
                                          bool isAnswered =
                                              query['checked'] != null &&
                                                  query['checked'].isNotEmpty;
                                          bool isOK = query['checked'] == 'OK';

                                          return Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isAnswered
                                                    ? (isOK
                                                        ? Colors.green.shade300
                                                        : Colors.red.shade300)
                                                    : Colors.grey.shade200,
                                                width: 1,
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 32,
                                                        height: 32,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: isAnswered
                                                              ? (isOK
                                                                  ? Colors.green
                                                                      .shade500
                                                                  : Colors.red
                                                                      .shade500)
                                                              : Colors.grey
                                                                  .shade400,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            '${index + 1}',
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Text(
                                                          query['query_name']
                                                                  ?.toString() ??
                                                              'Unknown',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors
                                                                .grey.shade800,
                                                            height: 1.3,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 16),
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
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        10,
                                                                    horizontal:
                                                                        16),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: query[
                                                                          'checked'] ==
                                                                      'OK'
                                                                  ? Colors.green
                                                                      .shade500
                                                                  : Colors.grey
                                                                      .shade100,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              border:
                                                                  Border.all(
                                                                color: query[
                                                                            'checked'] ==
                                                                        'OK'
                                                                    ? Colors
                                                                        .green
                                                                        .shade500
                                                                    : Colors
                                                                        .grey
                                                                        .shade300,
                                                                width: 1,
                                                              ),
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
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .green
                                                                          .shade600,
                                                                  size: 18,
                                                                ),
                                                                const SizedBox(
                                                                    width: 6),
                                                                Text(
                                                                  'OK',
                                                                  style:
                                                                      TextStyle(
                                                                    color: query['checked'] ==
                                                                            'OK'
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .green
                                                                            .shade600,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            // Show issue dialog when NOK is tapped
                                                            final result =
                                                                await showModalBottomSheet<
                                                                    Map<String,
                                                                        dynamic>?>(
                                                              context: context,
                                                              isScrollControlled:
                                                                  true,
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              builder:
                                                                  (context) =>
                                                                      Container(
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.9,
                                                                child:
                                                                    IssueDialog(
                                                                  lotNo: widget
                                                                          .lotNO ??
                                                                      '',
                                                                  initialDescription:
                                                                      query['nokData']
                                                                          ?[
                                                                          'description'],
                                                                  initialPartNo:
                                                                      query['nokData']
                                                                          ?[
                                                                          'partNo'],
                                                                  initialCategory:
                                                                      query['nokData']
                                                                          ?[
                                                                          'category'],
                                                                  initialType:
                                                                      query['nokData']
                                                                          ?[
                                                                          'type'],
                                                                  initialClassification:
                                                                      query['nokData']
                                                                          ?[
                                                                          'classification'],
                                                                  initialImage:
                                                                      query['nokData']
                                                                          ?[
                                                                          'image'],
                                                                ),
                                                              ),
                                                            );

                                                            if (result !=
                                                                null) {
                                                              // User completed the dialog with data
                                                              setState(() {
                                                                query['checked'] =
                                                                    'NOK';
                                                                query['nokData'] =
                                                                    result;
                                                                query['description'] =
                                                                    result[
                                                                        'description'];
                                                                query['image'] =
                                                                    result[
                                                                        'image'];
                                                              });
                                                            }
                                                          },
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              vertical: 10,
                                                              horizontal: 16,
                                                            ),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: query[
                                                                          'checked'] ==
                                                                      'NOK'
                                                                  ? Colors.red
                                                                      .shade500
                                                                  : Colors.grey
                                                                      .shade100,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              border:
                                                                  Border.all(
                                                                color: query[
                                                                            'checked'] ==
                                                                        'NOK'
                                                                    ? Colors.red
                                                                        .shade500
                                                                    : Colors
                                                                        .grey
                                                                        .shade300,
                                                                width: 1,
                                                              ),
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
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .red
                                                                          .shade600,
                                                                  size: 18,
                                                                ),
                                                                const SizedBox(
                                                                    width: 6),
                                                                Text(
                                                                  'NOK',
                                                                  style:
                                                                      TextStyle(
                                                                    color: query['checked'] ==
                                                                            'NOK'
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .red
                                                                            .shade600,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  // Show description and image capture for NOK items
                                                  if (query['checked'] ==
                                                      'NOK') ...[
                                                    const SizedBox(height: 16),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.red.shade50,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                          color: Colors
                                                              .red.shade200,
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Theme(
                                                        data: Theme.of(context)
                                                            .copyWith(
                                                                dividerColor: Colors
                                                                    .transparent),
                                                        child: ExpansionTile(
                                                          initiallyExpanded:
                                                              false,
                                                          tilePadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      14,
                                                                  vertical: 4),
                                                          childrenPadding:
                                                              const EdgeInsets
                                                                  .fromLTRB(14,
                                                                  0, 14, 14),
                                                          title: Text(
                                                            'Issue Description',
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Colors
                                                                  .red.shade700,
                                                            ),
                                                          ),
                                                          iconColor: Colors
                                                              .red.shade700,
                                                          collapsedIconColor:
                                                              Colors
                                                                  .red.shade700,
                                                          children: [
                                                            TextFormField(
                                                              initialValue:
                                                                  query['description'] ??
                                                                      '',
                                                              onChanged:
                                                                  (value) {
                                                                query['description'] =
                                                                    value;
                                                              },
                                                              maxLines: null,
                                                              decoration:
                                                                  InputDecoration(
                                                                hintText:
                                                                    'Describe the issue found...',
                                                                hintStyle:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade500,
                                                                  fontSize: 14,
                                                                ),
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade300,
                                                                  ),
                                                                ),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: Colors
                                                                        .red
                                                                        .shade400,
                                                                    width: 2,
                                                                  ),
                                                                ),
                                                                filled: true,
                                                                fillColor:
                                                                    Colors
                                                                        .white,
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        12),
                                                              ),
                                                              validator:
                                                                  (value) {
                                                                if (query['checked'] ==
                                                                        'NOK' &&
                                                                    (value ==
                                                                            null ||
                                                                        value
                                                                            .trim()
                                                                            .isEmpty)) {
                                                                  return 'Description is required for NOK items';
                                                                }
                                                                return null;
                                                              },
                                                            ),
                                                            const SizedBox(
                                                                height: 12),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  'Capture Evidence',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Colors
                                                                        .red
                                                                        .shade700,
                                                                  ),
                                                                ),
                                                                const Spacer(),
                                                                GestureDetector(
                                                                  onTap: () =>
                                                                      _captureImage(
                                                                          index),
                                                                  child:
                                                                      Container(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            10),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: query['image'] !=
                                                                              null
                                                                          ? Colors
                                                                              .green
                                                                              .shade100
                                                                          : Colors
                                                                              .grey
                                                                              .shade100,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              6),
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: query['image'] !=
                                                                                null
                                                                            ? Colors.green.shade300
                                                                            : Colors.grey.shade300,
                                                                        width:
                                                                            1,
                                                                      ),
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        Icon(
                                                                          query['image'] != null
                                                                              ? Icons.check_circle
                                                                              : Icons.camera_alt,
                                                                          color: query['image'] != null
                                                                              ? Colors.green.shade600
                                                                              : Colors.grey.shade600,
                                                                          size:
                                                                              18,
                                                                        ),
                                                                        const SizedBox(
                                                                            width:
                                                                                6),
                                                                        Text(
                                                                          query['image'] != null
                                                                              ? 'Captured'
                                                                              : 'Camera',
                                                                          style:
                                                                              TextStyle(
                                                                            color: query['image'] != null
                                                                                ? Colors.green.shade600
                                                                                : Colors.grey.shade600,
                                                                            fontSize:
                                                                                13,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            if (query[
                                                                    'image'] !=
                                                                null) ...[
                                                              const SizedBox(
                                                                  height: 10),
                                                              Container(
                                                                height: 80,
                                                                width: double
                                                                    .infinity,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              6),
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade300,
                                                                  ),
                                                                ),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              6),
                                                                  child: Image
                                                                      .file(
                                                                    query[
                                                                        'image'],
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                        const SizedBox(height: 24),
                                        // Enhanced Save Button
                                        Container(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isSubmitting
                                                  ? Colors.grey.shade400
                                                  : mycolor,
                                              foregroundColor: Colors.white,
                                              elevation: isSubmitting ? 0 : 2,
                                              shadowColor:
                                                  mycolor.withOpacity(0.3),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 14),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            onPressed: isSubmitting
                                                ? null
                                                : () =>
                                                    _showConfirmDialog(context),
                                            child: isSubmitting
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          valueColor:
                                                              const AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      const Text(
                                                        'SUBMITTING...',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.save_rounded,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        'SAVE INSPECTION',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(height: 24),
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

class UIHelper {
  static void showLoader(BuildContext context, {String? message}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Container with gradient
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [mycolor.withOpacity(0.8), mycolor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: mycolor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  message ?? 'Please wait...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Processing your request',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void hideLoader(BuildContext context) {
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  static void showErrorMessage({
    required BuildContext context,
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showSuccessMessage({
    required BuildContext context,
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
