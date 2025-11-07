// ignore_for_file: use_build_context_synchronously, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/pages/qc_inspection/routing_structure/multiple_question.dart';
import 'package:isuze_pqcs/pages/qc_inspection/routing_structure/single_question.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

class JobCardQuestionsTemplate extends StatefulWidget {
  final query_id;
  final vehicle_id;
  final shop_id;
  final categoryName;
  final shop_name;
  final chasis_no;
  final station_id;
  final vehicle_receiving_item;

  const JobCardQuestionsTemplate({
    super.key,
    this.query_id,
    this.vehicle_id,
    this.shop_id,
    this.categoryName,
    required this.shop_name,
    required this.chasis_no,
    this.station_id,
    required this.vehicle_receiving_item,
  });

  @override
  State<JobCardQuestionsTemplate> createState() =>
      _JobCardQuestionsTemplateState();
}

class _JobCardQuestionsTemplateState extends State<JobCardQuestionsTemplate> {
  var user = {};
  var textLoading = 'No questions found';
  Map<int, dynamic> questionValues = {};
  Map<int, String> traceableValues = {};
  Map<int, String> openTextValues = {};
  Map<int, String> singleDescipTextValues = {};
  Map<int, String> DescipTextValues = {};
  Map<int, String> numericValues = {};
  Map<int, String> singleValues = {};
  Map<int, String> singleDescripValues = {};
  Map<int, String> singleDescripCategory = {};
  Map<int, String> singleDefectCategory = {}; // Add defect category tracking
  Map<int, String> multipleDefectCategory =
      {}; // Add defect category tracking for multiple questions
  Map<int, String> multipleValue = {};
  Map<int, List<dynamic>> multipleValues = {};
  Map<int, List<String>> selectedUsers = {};
  Map<int, File> images = {};
  Map<int, Map<String, dynamic>> claimData =
      {}; // Track claim data for NOK answers
  String haserror = '';
  List questions = [];
  var Category = {};
  var substations = [];
  Map question = {};
  Map<int, String> traceableSignature = {};
  List<File> selectedImage = [];
  late File signature;
  List vehicles = [];
  bool isButtonEnabled = true;
  bool isInitloading = true;
  var jobCardId;
  int? selectedNextStationId; // Changed to int? for better type safety

  // Check if there are any changes made to the current answers
  bool get hasChangesToSave {
    if (questions.isEmpty) return false;

    for (var question in questions) {
      final int questionId = question["id"];
      var previousAnswer = question['answer_given'] ?? '';

      if (question["quiz_type"] == "multiple") {
        String? currentAnswer = multipleValue[questionId];
        if (currentAnswer != null && currentAnswer != previousAnswer) {
          return true; // Found a changed answer
        }
      } else if (question["quiz_type"] == "single") {
        String? currentAnswer = singleValues[questionId];
        if (currentAnswer != null && currentAnswer != previousAnswer) {
          return true; // Found a changed answer
        }
      }
    }
    return false; // No changes detected
  }

  // Check if all required questions are answered (for validation)
  bool get areAllQuestionsAnswered {
    if (questions.isEmpty) return false;

    for (var question in questions) {
      final int questionId = question["id"];
      bool hasAnswer = false;

      if (question["quiz_type"] == "multiple") {
        hasAnswer = multipleValue[questionId] != null;
      } else if (question["quiz_type"] == "single") {
        hasAnswer = singleValues[questionId] != null;
      }

      if (!hasAnswer) {
        return false; // Found an unanswered question
      }
    }
    return true; // All questions are answered
  }

  @override
  void initState() {
    super.initState();

    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      fetchQuestions();
    });
  }

  final _formKey = GlobalKey<FormState>();

  // Initialize claim template for job card format
  Map<String, dynamic> initializeClaimTemplate(
      int questionId, String questionText) {
    return {
      'question_id': questionId,
      'issue_description': '',
      'part_number': '',
      'issue_category': null,
      'issue_type': null,
      'defect_classification': null,
      'image_path': null,
    };
  }

  @override
  void dispose() {
    EasyLoading.dismiss();
    super.dispose();
  }

  // Handle claim data callback from SingleQuestion
  void handleClaimData(int questionId, Map<String, dynamic>? claimDataResult) {
    if (claimDataResult != null) {
      setState(() {
        claimData[questionId] = claimDataResult;
        print('Claim data stored for question $questionId: $claimDataResult');
      });
    } else {
      setState(() {
        claimData.remove(questionId);
        print('Claim data removed for question $questionId');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Substation data: $claimData');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                mycolor,
                mycolor.withOpacity(0.8),
              ],
            ),
          ),
        ),
        title: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.categoryName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.chasis_no,
                  // textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: questions.isEmpty && !isInitloading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.quiz_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No questions available',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap refresh to try again',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 24),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    mycolor,
                                    mycolor.withOpacity(0.8),
                                  ],
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    fetchQuestions();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.refresh_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Refresh',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          if ((Category['imageUri'] ?? '').toString() !=
                                  '${Api.main_url}/upload/default.jpg' &&
                              (Category['imageUri'] ?? '').toString() !=
                                  'null' &&
                              (Category['imageUri'] ?? '')
                                  .toString()
                                  .isNotEmpty)
                            Container(
                              height: 180,
                              width: double.infinity,
                              margin: EdgeInsets.only(bottom: 16),
                              child: CachedNetworkImage(
                                imageUrl:
                                    (Category['imageUri'] ?? '').toString(),
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) => Center(
                                  child: Text('Image not available'),
                                ),
                              ),
                            ),
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: questions.length,
                              itemBuilder: (context, index) {
                                var get = questions[index];
                                // var can_sign = get['can_sign'] ?? '';
                                var answer_given = get['answer_given'] ?? '';
                                // print(get);
                                // print('Quiz type: ${get['quiz_type']}');
                                haserror = (get['haserror'] ?? '').toString();

                                Widget questionWidget;

                                if (get["quiz_type"] == "multiple") {
                                  questionWidget = MultipleQuestion(
                                      initialDefectCategory:
                                          (get['defectcategory'] is String)
                                              ? get['defectcategory']
                                              : null,
                                      onDefectCategoryChanged: (String value) {
                                        var qid = get['id'];
                                        setState(() {
                                          multipleDefectCategory[qid] = value;
                                          print(
                                              'Multiple Question - Defect category selected: $value for question $qid');
                                        });
                                      },
                                      onInputValueChanged: (value) {
                                        var qid = get['id'];
                                        setState(() {
                                          DescipTextValues[qid] = value;
                                        });
                                      },
                                      initialDecripValue:
                                          get["defect_description"],
                                      hasDescription:
                                          (get["additional_field"] ?? 'false')
                                              as String,
                                      instruction:
                                          (get["instruction"] ?? '') as String,
                                      intial_option: get["defect_names"],
                                      initialImage: (get["image_url"] == null ||
                                              get["image_url"]
                                                  .toString()
                                                  .isEmpty)
                                          ? null
                                          : get["image_url"],
                                      onImageChanged: (File? image) {
                                        print("image path $image");
                                        setState(() {
                                          if (image == null) {
                                            images.remove(get['id']);
                                          } else {
                                            images[get['id']] = image;
                                          }
                                        });
                                      },
                                      onUsersSelected: (List<String> value) {
                                        var qid = get['id'];
                                        setState(() {
                                          selectedUsers[qid] = value;
                                        });
                                      },
                                      users: (get['emails'] as List<dynamic>? ??
                                              [])
                                          .map((user) {
                                        return {
                                          'name': (user['name'] ?? 'Unknown')
                                              .toString(),
                                          'email':
                                              (user['email'] ?? '').toString(),
                                        };
                                      }).toList(),
                                      index: index,
                                      id: get['id'],
                                      options: get["options"],
                                      onRadioChanged: (value) {
                                        var qid = get['id'];
                                        setState(() {
                                          multipleValue[qid] = value;

                                          if (value == "OK") {
                                            multipleValues[qid] =
                                                multipleValues[qid] ?? [];
                                            multipleValues[qid]!.clear();
                                          }
                                        });
                                      },
                                      onValuesChanged: (value) {
                                        // print(values);
                                        var qid = get['id'];
                                        setState(() {
                                          multipleValues[qid] = value;
                                          // print(multipleValues);
                                        });
                                      },
                                      onValueChanged2: (value) {
                                        var qid = get['id'];
                                        setState(() {
                                          traceableSignature[qid] = value;
                                          // print(traceableSignature);
                                        });
                                      },
                                      initialRadioValue: answer_given != ''
                                          ? answer_given
                                          : null,
                                      question: (get["query_name"] ??
                                          'No question text') as String);
                                } else if (get["quiz_type"] == "single") {
                                  //single
                                  questionWidget = SingleQuestion(
                                      scandata: get['parts_to_scan'].toString().toLowerCase() ==
                                              'engine'
                                          ? widget.vehicle_receiving_item[
                                              'engine_number']
                                          : get['parts_to_scan'].toString().toLowerCase() ==
                                                  'cabin'
                                              ? widget.vehicle_receiving_item[
                                                  'cabin']
                                              : get['parts_to_scan']
                                                          .toString()
                                                          .toLowerCase() ==
                                                      'gear_box'
                                                  ? widget.vehicle_receiving_item[
                                                      'gear_box']
                                                  : get['parts_to_scan']
                                                              .toString()
                                                              .toLowerCase() ==
                                                          'chassis'
                                                      ? widget.vehicle_receiving_item[
                                                          'chassis_number']
                                                      : get,
                                      parts_to_scan: (get['parts_to_scan'] is String)
                                          ? get['parts_to_scan']
                                          : null,
                                      initialDefectCategory:
                                          (get['defectCategoryGiven'] is String)
                                              ? get['defectCategoryGiven']
                                              : null,
                                      onDefectCategoryChanged: (String value) {
                                        var qid = get['id'];
                                        setState(() {
                                          singleDefectCategory[qid] = value;
                                          print(
                                              'Defect category selected: $value for question $qid');
                                        });
                                      },
                                      instruction:
                                          (get["instruction"] ?? '') as String,
                                      initialImage: (get["image_url"] == null ||
                                              get["image_url"].toString().isEmpty)
                                          ? null
                                          : get["image_url"],
                                      onImageChanged: (File? image) {
                                        print("image path $image");
                                        setState(() {
                                          if (image == null) {
                                            images.remove(get['id']);
                                          } else {
                                            images[get['id']] = image;
                                          }
                                        });
                                      },
                                      onUsersSelected: (List<String> value) {
                                        var qid = get['id'];
                                        setState(() {
                                          selectedUsers[qid] = value;
                                        });
                                      },
                                      users: (get['emails'] as List<dynamic>? ?? []).map((user) {
                                        return {
                                          'name': (user['name'] ?? 'Unknown')
                                              .toString(),
                                          'email':
                                              (user['email'] ?? '').toString(),
                                        };
                                      }).toList(),
                                      initialDecripValue: get["defect_description"],
                                      hasDescription: (get["additional_field"] ?? 'false') as String,
                                      index: index,
                                      id: get['id'],
                                      onValueChanged: (value) {
                                        var qid = get['id'];
                                        setState(() {
                                          singleValues[qid] = value;
                                          print(singleValues);
                                        });
                                      },
                                      onInputValueChanged: (value) {
                                        var qid = get['id'];
                                        setState(() {
                                          DescipTextValues[qid] = value;
                                          print(DescipTextValues);
                                        });
                                      },
                                      onValueChanged2: (value) {
                                        var qid = get['id'];
                                        setState(() {
                                          traceableSignature[qid] = value;
                                          print(traceableSignature);
                                        });
                                      },
                                      onClaimDataChanged: (Map<String, dynamic>? claimDataResult) {
                                        var qid = get['id'];
                                        handleClaimData(qid, claimDataResult);
                                      },
                                      initialRadioValue: answer_given != '' ? answer_given : null,
                                      question: (get['query_name'] ?? 'No question text') as String);
                                } else {
                                  // Handle unrecognized or missing quiz types
                                  questionWidget = Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: mycolor,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          color: mycolor,
                                          size: 24,
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Unsupported Question Type',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Quiz type "${get["quiz_type"] ?? "unknown"}" is not supported',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: mycolor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return questionWidget;
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            questions.isEmpty
                ? Container()
                : isButtonEnabled
                    ? Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              mycolor,
                              mycolor.withOpacity(0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: mycolor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                // For EOL checks (when station_id is not null), validate all questions are answered
                                if (widget.station_id != null) {
                                  if (!areAllQuestionsAnswered) {
                                    List<String> unansweredQuestions = [];

                                    for (int i = 0; i < questions.length; i++) {
                                      var quest = questions[i];
                                      final int questionId = quest["id"];
                                      bool hasAnswer = false;

                                      if (quest["quiz_type"] == "multiple") {
                                        hasAnswer =
                                            multipleValue[questionId] != null;
                                      } else if (quest["quiz_type"] ==
                                          "single") {
                                        hasAnswer =
                                            singleValues[questionId] != null;
                                      }

                                      if (!hasAnswer) {
                                        unansweredQuestions
                                            .add("Question ${i + 1}");
                                      }
                                    }
                                    // Show error dialog for unanswered questions
                                    await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          backgroundColor: Colors.transparent,
                                          child: Container(
                                            padding: EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.warning_amber_rounded,
                                                  color: Colors.orange,
                                                  size: 48,
                                                ),
                                                SizedBox(height: 16),
                                                Text(
                                                  'Complete All Questions',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey[800],
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  'EOL checklist requires all questions to be answered. Please complete the following:',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(height: 12),
                                                Container(
                                                  padding: EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red.shade50,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                        color: Colors
                                                            .red.shade200),
                                                  ),
                                                  child: Text(
                                                    unansweredQuestions
                                                        .join(", "),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.red.shade700,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                SizedBox(height: 20),
                                                Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    color: mycolor,
                                                  ),
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 12),
                                                        child: Text(
                                                          'OK',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                    return; // Don't proceed with save
                                  }
                                }

                                // Show confirmation dialog
                                bool? confirmSave = await showDialog<bool>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      backgroundColor: Colors.transparent,
                                      child: Container(
                                        padding: EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              widget.station_id != null
                                                  ? Icons.checklist_rtl
                                                  : Icons.save_outlined,
                                              color: mycolor,
                                              size: 48,
                                            ),
                                            SizedBox(height: 16),
                                            Text(
                                              widget.station_id != null
                                                  ? 'Complete Checklist'
                                                  : 'Confirm Save',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              widget.station_id != null
                                                  ? substations.isNotEmpty
                                                      ? 'Are you sure you want to complete the ${widget.categoryName} checklist? Please select the next station to route the vehicle. This will mark all checks as finished.'
                                                      : 'Are you sure you want to complete the ${widget.categoryName} checklist? This will mark all checks as finished.'
                                                  : 'Are you sure you want to save your answers? This action cannot be undone.',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            if (widget.station_id != null &&
                                                (substations).isNotEmpty)
                                              Column(
                                                children: [
                                                  SizedBox(height: 16),
                                                  Container(
                                                    padding: EdgeInsets.all(12),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.blue.shade50,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                          color: Colors
                                                              .blue.shade200),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .route_outlined,
                                                              color: Colors.blue
                                                                  .shade700,
                                                              size: 20,
                                                            ),
                                                            SizedBox(width: 8),
                                                            Text(
                                                              'Select Next Station: *',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .blue
                                                                    .shade700,
                                                              ),
                                                            ),
                                                            SizedBox(width: 4),
                                                            Text(
                                                              '(Required)',
                                                              style: TextStyle(
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Colors
                                                                    .red
                                                                    .shade600,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 8),
                                                        StatefulBuilder(
                                                          builder: (context,
                                                              setStateDialog) {
                                                            // Create a snapshot of the substations data to avoid modification during build
                                                            final stationsSnapshot = List<
                                                                    Map<String,
                                                                        dynamic>>.from(
                                                                substations);

                                                            // Get valid station IDs to ensure selectedNextStationId is valid
                                                            Set<int>
                                                                validStationIds =
                                                                {};

                                                            for (var station
                                                                in stationsSnapshot) {
                                                              if (station[
                                                                      'sub_stations_id'] !=
                                                                  null) {
                                                                int stationId = station[
                                                                            'sub_stations_id']
                                                                        is int
                                                                    ? station[
                                                                        'sub_stations_id']
                                                                    : int.tryParse(
                                                                            station['sub_stations_id'].toString()) ??
                                                                        0;

                                                                if (stationId >
                                                                    0) {
                                                                  validStationIds
                                                                      .add(
                                                                          stationId);
                                                                }
                                                              }
                                                            }

                                                            // Validate selectedNextStationId
                                                            if (selectedNextStationId !=
                                                                    null &&
                                                                !validStationIds
                                                                    .contains(
                                                                        selectedNextStationId)) {
                                                              selectedNextStationId =
                                                                  null;
                                                            }

                                                            return DropdownButtonFormField<
                                                                int>(
                                                              value:
                                                                  selectedNextStationId,
                                                              decoration:
                                                                  InputDecoration(
                                                                contentPadding:
                                                                    EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            12,
                                                                        vertical:
                                                                            8),
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              6),
                                                                  borderSide: BorderSide(
                                                                      color: Colors
                                                                          .grey
                                                                          .shade300),
                                                                ),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              6),
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              mycolor),
                                                                ),
                                                              ),
                                                              hint: Text(
                                                                'Choose next station (Required)',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade600,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                              items: () {
                                                                // First, get unique station data from snapshot
                                                                Map<
                                                                        int,
                                                                        Map<String,
                                                                            dynamic>>
                                                                    uniqueStations =
                                                                    {};

                                                                print(
                                                                    '=== DEBUG: Building dropdown items ===');
                                                                print(
                                                                    'Total substations: ${stationsSnapshot.length}');

                                                                for (var station
                                                                    in stationsSnapshot) {
                                                                  if (station[
                                                                          'sub_stations_id'] !=
                                                                      null) {
                                                                    int stationId = station['sub_stations_id']
                                                                            is int
                                                                        ? station[
                                                                            'sub_stations_id']
                                                                        : int.tryParse(station['sub_stations_id'].toString()) ??
                                                                            0;

                                                                    print(
                                                                        'Processing station: ID=$stationId, exists=${uniqueStations.containsKey(stationId)}');

                                                                    if (stationId >
                                                                        0) {
                                                                      // Only keep the first occurrence of each station ID
                                                                      if (!uniqueStations
                                                                          .containsKey(
                                                                              stationId)) {
                                                                        uniqueStations[stationId] =
                                                                            station;
                                                                        print(
                                                                            'Added unique station: $stationId');
                                                                      } else {
                                                                        print(
                                                                            'Skipped duplicate station: $stationId');
                                                                      }
                                                                    }
                                                                  }
                                                                }

                                                                // Create dropdown items
                                                                List<
                                                                        DropdownMenuItem<
                                                                            int>>
                                                                    items = [];
                                                                uniqueStations.forEach(
                                                                    (stationId,
                                                                        station) {
                                                                  String
                                                                      stationName =
                                                                      '';
                                                                  if (station['station'] !=
                                                                          null &&
                                                                      station['station']
                                                                              [
                                                                              'name'] !=
                                                                          null) {
                                                                    stationName =
                                                                        station['station']['name']
                                                                            .toString();
                                                                  } else {
                                                                    stationName =
                                                                        'Station ${stationId}';
                                                                  }

                                                                  items.add(
                                                                      DropdownMenuItem<
                                                                          int>(
                                                                    value:
                                                                        stationId,
                                                                    child: Text(
                                                                      stationName,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              12),
                                                                    ),
                                                                  ));
                                                                });

                                                                print(
                                                                    'Created ${items.length} dropdown items');
                                                                print(
                                                                    'Item values: ${items.map((item) => item.value).toList()}');

                                                                return items;
                                                              }(),
                                                              validator:
                                                                  (value) {
                                                                if (widget.station_id !=
                                                                        null &&
                                                                    substations
                                                                        .isNotEmpty &&
                                                                    value ==
                                                                        null) {
                                                                  return 'Next station selection is required';
                                                                }
                                                                return null;
                                                              },
                                                              onChanged:
                                                                  (int? value) {
                                                                print(
                                                                    '=== DEBUG: Dropdown selection changed ===');
                                                                print(
                                                                    'Selected value: $value');
                                                                print(
                                                                    'Previous value: $selectedNextStationId');
                                                                setStateDialog(
                                                                    () {
                                                                  selectedNextStationId =
                                                                      value;
                                                                  print(
                                                                      'Updated selectedNextStationId: $selectedNextStationId');
                                                                });
                                                              },
                                                            );
                                                          },
                                                        ),
                                                        SizedBox(height: 8),
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .info_outline,
                                                              size: 14,
                                                              color: Colors.blue
                                                                  .shade600,
                                                            ),
                                                            SizedBox(width: 6),
                                                            Expanded(
                                                              child: Text(
                                                                'You must select a next station before completing the checklist',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .blue
                                                                      .shade600,
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .italic,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            SizedBox(height: 20),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                          color: Colors
                                                              .grey[300]!),
                                                    ),
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        onTap: () {
                                                          Navigator.of(context)
                                                              .pop(false);
                                                        },
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 12),
                                                          child: Text(
                                                            'Cancel',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .grey[600],
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: mycolor,
                                                    ),
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        onTap: () {
                                                          Navigator.of(context)
                                                              .pop(true);
                                                        },
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 12),
                                                          child: Text(
                                                            widget.station_id !=
                                                                    null
                                                                ? 'Complete'
                                                                : 'Save',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
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

                                // Only proceed if user confirmed
                                if (confirmSave == true) {
                                  // Additional validation for next station selection
                                  if (widget.station_id != null &&
                                      substations.isNotEmpty &&
                                      selectedNextStationId == null) {
                                    awesomeTopSnackbar(context,
                                        "Please select the next station to continue",
                                        backgroundColor: Colors.orange);
                                    return;
                                  }
                                  // Show loading dialog
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: Container(
                                          padding: EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(mycolor),
                                                strokeWidth: 3,
                                              ),
                                              SizedBox(height: 16),
                                              Text(
                                                'Saving Answers...',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Please wait while we save your responses',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );

                                  questionValues
                                      .clear(); // Clear the map before fetching new values

                                  var answers = [];

                                  for (var quest in questions) {
                                    final int questionId = quest["id"];
                                    var answer = {
                                      "vehicle_id": widget.vehicle_id,
                                      "shop_id": widget.shop_id,
                                      "shop_name": widget.shop_name,
                                      "chassis_no": widget.chasis_no,
                                      "quiz_id": Category['id'],
                                      "item_id": quest['id'],
                                      "item_name": quest['query_name'],
                                      "quiz_type": quest["quiz_type"],
                                      "checkanswered": quest["checkanswered"],
                                      "options": quest["options"],
                                      "total_options": quest["total_options"],
                                      "correct_answers":
                                          quest["correct_answers"],
                                      "haserror": quest['haserror'],
                                      "can_sign": quest['can_sign'],
                                      "answer_given": quest['answer_given'],
                                      "answer": '',
                                      // "defect_description": '',
                                      // "defect_category":
                                      //     '', // Add defect category field
                                      "defects": '',
                                      "signature":
                                          traceableSignature[questionId],
                                      "users": selectedUsers[questionId],
                                      // Claim data fields
                                      // "issue_description": '',
                                      "defect_description": '',
                                      "part_number": '',
                                      "defect_category": null,
                                      "issue_type": null,
                                      "defect_classification": null,
                                      "has_claim_image": false,
                                    };

                                    if (quest["quiz_type"] == "multiple") {
                                      // Retrieve values from MultipleQuestion
                                      List<dynamic>? values =
                                          multipleValues[questionId];
                                      String? value = multipleValue[questionId];
                                      String? defectCategory =
                                          multipleDefectCategory[questionId];

                                      answer["defects"] = values;
                                      answer["answer"] = value;
                                      answer["defect_category"] =
                                          defectCategory;

                                      // Add claim data if available for NOK answers
                                      if (value == "NOK" &&
                                          claimData.containsKey(questionId)) {
                                        var claimInfo = claimData[questionId];

                                        // Extract specific claim fields to answer
                                        answer["defect_description"] =
                                            claimInfo?['issue_description'] ??
                                                '';
                                        answer["part_number"] =
                                            claimInfo?['part_number'] ?? '';
                                        answer["defect_category"] =
                                            claimInfo?['issue_category'];
                                        answer["issue_type"] =
                                            claimInfo?['issue_type'];
                                        answer["defect_classification"] =
                                            claimInfo?['defect_classification'];

                                        // Handle image separately for multipart upload
                                        if (claimInfo?['image'] != null) {
                                          // Store claim image in images map with special key for claim
                                          images[questionId] =
                                              claimInfo!['image'];
                                          answer["has_claim_image"] = true;
                                        }
                                      }
                                    } else if (quest["quiz_type"] == "single") {
                                      // Retrieve values from SingleQuestion
                                      String? value = singleValues[questionId];
                                      answer["answer"] = value;
                                      String? valueInput =
                                          DescipTextValues[questionId];
                                      String? defectCategory =
                                          singleDefectCategory[questionId];

                                      answer["defect_description"] = valueInput;
                                      answer["defect_category"] =
                                          defectCategory;

                                      // Add claim data if available for NOK answers
                                      if (value == "NOK" &&
                                          claimData.containsKey(questionId)) {
                                        var claimInfo = claimData[questionId];

                                        // Extract specific claim fields to answer
                                        answer["defect_description"] =
                                            claimInfo?['issue_description'] ??
                                                '';
                                        answer["part_number"] =
                                            claimInfo?['part_number'] ?? '';
                                        answer["defect_category"] =
                                            claimInfo?['issue_category'];
                                        answer["issue_type"] =
                                            claimInfo?['issue_type'];
                                        answer["defect_classification"] =
                                            claimInfo?['defect_classification'];

                                        // Handle image separately for multipart upload
                                        if (claimInfo?['image'] != null) {
                                          // Store claim image in images map with special key for claim
                                          images[questionId] =
                                              claimInfo!['image'];
                                          answer["has_claim_image"] = true;
                                        }

                                        print(
                                            "Added claim fields for question $questionId: issue_description=${claimInfo?['issue_description']}, part_number=${claimInfo?['part_number']}, category=${claimInfo?['issue_category']}");
                                      }
                                      // print(
                                      //     "-->${DescipTextValues[questionId]}");
                                    }

                                    // Include answer if:
                                    // 1. There's a current answer, OR
                                    // 2. There's a previous answer (for re-saving), OR
                                    // 3. There are changes to save
                                    if (answer["answer"] != null ||
                                        quest['answer_given'] != null &&
                                            quest['answer_given'] != '' ||
                                        hasChangesToSave) {
                                      // If no current answer but has previous answer, use previous answer
                                      if (answer["answer"] == null &&
                                          quest['answer_given'] != null &&
                                          quest['answer_given'] != '') {
                                        answer["answer"] =
                                            quest['answer_given'];
                                      }
                                      answers.add(answer);
                                    }
                                  }

                                  if (answers.isNotEmpty) {
                                    //For normal dialog
                                    await saveData(answers, claimData);
                                    // Close loading dialog
                                    Navigator.of(context).pop();
                                  } else {
                                    // Close loading dialog first
                                    Navigator.of(context).pop();

                                    // Check if there are changes to save
                                    if (!hasChangesToSave) {
                                      awesomeTopSnackbar(
                                          context, "No changes to save",
                                          iconWithDecoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(),
                                            color: Colors.white,
                                          ),
                                          backgroundColor: Colors.orange);
                                    } else {
                                      awesomeTopSnackbar(context,
                                          "Please Answer at least one question",
                                          iconWithDecoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(),
                                            color: Colors.white,
                                          ),
                                          backgroundColor: Colors.red);
                                    }
                                  }
                                }
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    widget.station_id != null
                                        ? Icons.checklist_rtl
                                        : Icons.save_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    widget.station_id != null
                                        ? 'COMPLETE CHECKLIST'
                                        : hasChangesToSave
                                            ? 'SAVE CHANGES'
                                            : 'SAVE ANSWERS',
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
                        ),
                      )
                    : Container()
          ],
        ),
      ),
    );
  }

  Future<void> saveData(answers,
      [Map<int, Map<String, dynamic>>? claimDataMap]) async {
    if (!_formKey.currentState!.validate()) return;

    if (answers.isEmpty) {
      // Check if there are any changes to save
      if (!hasChangesToSave) {
        awesomeTopSnackbar(context, "No changes to save",
            backgroundColor: Colors.orange);
      } else {
        awesomeTopSnackbar(context, "Please answer at least one question",
            backgroundColor: Colors.red);
      }
      return;
    }

    setState(() => isButtonEnabled = false);
    // Removed ProgressDialog since we're using custom loading dialog

    try {
      String url = Api.api_url + "answerquery2";
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer ${user['data']["token"]}',
      });
      request.fields['answers'] = jsonEncode(answers);
      request.fields['vehicle_id'] = widget.vehicle_id.toString();

      // Add claim data as separate field - always include, null if no claims
      if (claimDataMap != null && claimDataMap.isNotEmpty) {
        // Convert claim data map to array format and clean File objects
        List<Map<String, dynamic>> claimDataArray =
            claimDataMap.values.map((claimData) {
          // Create a copy of claim data without the File object
          Map<String, dynamic> cleanClaimData =
              Map<String, dynamic>.from(claimData);

          // Remove the File object from claim data (it's handled separately in multipart upload)
          if (cleanClaimData.containsKey('image')) {
            // Convert File reference to string path or remove it
            if (cleanClaimData['image'] != null) {
              cleanClaimData['image_path'] = cleanClaimData['image'].toString();
            }
            cleanClaimData.remove('image'); // Remove the actual File object
          }

          return cleanClaimData;
        }).toList();

        request.fields['claim_data'] = jsonEncode(claimDataArray);
      } else {
        // Set to null if no claims
        request.fields['claim_data'] = 'null';
      }

      request.fields['sub_station_id'] =
          widget.station_id != null ? widget.station_id.toString() : '';
      if (selectedNextStationId != null) {
        request.fields['next_station_id'] = selectedNextStationId.toString();
      }

      if (selectedNextStationId != null) {
        request.fields['current_station_id'] = selectedNextStationId.toString();
      }
      for (var entry in images.entries) {
        request.files.add(await http.MultipartFile.fromPath(
            'images[${entry.key}]', entry.value.path));
      }
      print("=== PAYLOAD DEBUG ===");
      print("Answers: ${jsonEncode(answers)}");
      if (claimDataMap != null && claimDataMap.isNotEmpty) {
        // Clean claim data for debug output (same as payload)
        List<Map<String, dynamic>> claimDataArray =
            claimDataMap.values.map((claimData) {
          Map<String, dynamic> cleanClaimData =
              Map<String, dynamic>.from(claimData);
          if (cleanClaimData.containsKey('image')) {
            if (cleanClaimData['image'] != null) {
              cleanClaimData['image_path'] = cleanClaimData['image'].toString();
            }
            cleanClaimData.remove('image');
          }
          return cleanClaimData;
        }).toList();
        print("Claim Data: ${jsonEncode(claimDataArray)}");
      } else {
        print("Claim Data: null");
      }
      print("Vehicle ID: ${widget.vehicle_id}");
      print("Station ID: ${widget.station_id}");
      print("Next Station ID: $selectedNextStationId");
      print("Images count: ${images.length}");
      print("=====================");
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      // print("===>${responseData}");
      var result = jsonDecode(responseData);
      // print(result);
      // Log the complete payload for debugging

      log(jsonEncode(result));

      setState(() => isButtonEnabled = true);

      if (result["success"]) {
        if (widget.station_id != null) {
          // For EOL screens, navigate back to EOLScreenCategory
          Navigator.pop(context);
          Navigator.pop(context);
        } else {
          Navigator.pop(context);
        }
        awesomeTopSnackbar(
            context, result["msg"] ?? "Answers Recorded Successfully",
            backgroundColor: Colors.green);
      } else {
        awesomeTopSnackbar(context, result["msg"] ?? "Error",
            backgroundColor: Colors.red);
      }
    } catch (e) {
      setState(() => isButtonEnabled = true);
      print("==============");
      print(e);
      print("==============");
      awesomeTopSnackbar(
          context, "Something went wrong. Check your internet connection.",
          backgroundColor: Colors.red);
    }
  }

  Future<void> fetchQuestions() async {
    EasyLoading.show(
      status: "Loading Questions...",
      maskType: EasyLoadingMaskType.black,
    );

    final url = widget.station_id != null
        ? "${Api.api_url}lodsubstationquiz/${widget.station_id}/${widget.vehicle_id}/${widget.shop_id}"
        : "${Api.api_url}quiz/${widget.query_id}/${widget.vehicle_id}/${widget.shop_id}";
    print(url);
    final responseData = await httpget(url, user['data']["token"], context);
    // final responseData = await httpget(url, Api.usr, context);
    // print(responseData['data']['substation']);
    EasyLoading.dismiss(); // Dismiss once, outside branching
    setState(() {
      isInitloading = false;
    });
    if (responseData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        snackBar("Failed to fetch data", Colors.red[500]),
      );
      return;
    }

    final dataMain = responseData["data"];
    if (dataMain != null) {
      setState(() {
        questions = dataMain["query"] ?? [];
        Category = dataMain["category"] ?? {};
        substations = dataMain["substation"] ?? [];
        print('Substation data: $substations');

        // Initialize previous answers for re-editing
        for (var question in questions) {
          final int questionId = question["id"];
          var previousAnswer = question['answer_given'] ?? '';

          if (previousAnswer.isNotEmpty) {
            if (question["quiz_type"] == "multiple") {
              multipleValue[questionId] = previousAnswer;
            } else if (question["quiz_type"] == "single") {
              singleValues[questionId] = previousAnswer;
            }
          }

          // Initialize description values if available
          var previousDescription = question['defect_description'] ?? '';
          if (previousDescription.isNotEmpty) {
            DescipTextValues[questionId] = previousDescription;
          }
        }

        // Debug: Print substations structure
        for (int i = 0; i < substations.length; i++) {
          var station = substations[i];
          print(
              'Station $i: sub_stations_id=${station['sub_stations_id']}, station=${station['station']}');
        }

        // Reset selectedNextStationId when new data is loaded
        selectedNextStationId = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        snackBar(
            responseData["message"] ?? "Unexpected error", Colors.red[500]),
      );
    }
  }
}
