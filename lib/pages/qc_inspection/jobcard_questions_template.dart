// ignore_for_file: use_build_context_synchronously, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/pages/qc_inspection/routing_structure/multiple_question.dart';
import 'package:isuze_pqcs/pages/qc_inspection/routing_structure/numerical_question.dart';
import 'package:isuze_pqcs/pages/qc_inspection/routing_structure/others.dart';
import 'package:isuze_pqcs/pages/qc_inspection/routing_structure/single_question.dart';
import 'package:isuze_pqcs/pages/qc_inspection/routing_structure/traceable_question.dart';

import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class JobCardQuestionsTemplate extends StatefulWidget {
  final query_id;
  final vehicle_id;
  final shop_id;
  final categoryName;

  const JobCardQuestionsTemplate(
      {super.key,
      this.query_id,
      this.vehicle_id,
      this.shop_id,
      this.categoryName});

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
  Map<int, String> numericValues = {};
  Map<int, String> singleValues = {};
  Map<int, String> singleDescripValues = {};
  Map<int, String> singleDescripCategory = {};
  Map<int, String> multipleValue = {};
  Map<int, List<dynamic>> multipleValues = {};
  String haserror = '';
  List questions = [];
  var Category = {};
  Map question = {};
  Map<int, String> traceableSignature = {};
  List<File> selectedImage = [];
  late File signature;
  List vehicles = [];
  bool isButtonEnabled = true;
  var jobCardId;
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            gap(),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: questions.isEmpty
                  ? Center(
                      child: Text(textLoading),
                    )
                  : Column(
                      children: [
                        if (Category['imageUri'].toString() !=
                                'http://172.16.16.57/upload/default.jpg' &&
                            Category['imageUri'].toString() != 'null')
                          Container(
                            height: 150,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                Category['imageUri'].toString(),
                                fit: BoxFit.fill,

                                //
                              ),
                            ),
                          ),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: questions.length,
                            itemBuilder: (context, index) {
                              var answ = questions[index];
                              var get = questions[index];
                              var can_sign = get['can_sign'];
                              var checkanswered = get['checkanswered'];
                              var answer_given = get['answer_given'];
                              // print(get);
                              print(get['quiz_type']);
                              haserror = get['haserror'].toString();
                              if (get["quiz_type"] == "traceable") {
                                //traceable
                                return TraceableQuestion(
                                  answer_given: answer_given,
                                  can_sign: can_sign,
                                  checkanswered: checkanswered,
                                  id: get['id'],
                                  onValueChanged: (value) {
                                    var qid = get['id'];
                                    setState(() {
                                      traceableValues[qid] = value;
                                      print(traceableValues);
                                    });
                                  },
                                  onValueChanged2: (value) {
                                    var qid = get['id'];
                                    setState(() {
                                      traceableSignature[qid] = value;
                                      print(traceableSignature);
                                    });
                                  },
                                  question: get["query_name"] as String,
                                );
                              } else if (get["quiz_type"] == "multiple") {
                                return MultipleQuestion(
                                    id: get['id'],
                                    options: get["options"],
                                    onRadioChanged: (value) {
                                      var qid = get['id'];
                                      setState(() {
                                        multipleValue[qid] = value;
                                        // print(multipleValue);
                                      });
                                      if (value == "OK") {
                                        setState(() {
                                          multipleValues.clear();
                                        });
                                      }
                                    },
                                    onValuesChanged: (value) {
                                      // print(values);
                                      var qid = get['id'];
                                      setState(() {
                                        multipleValues[qid] = value;
                                        print(multipleValues);
                                      });
                                    },
                                    onValueChanged2: (value) {
                                      var qid = get['id'];
                                      setState(() {
                                        traceableSignature[qid] = value;
                                        print(traceableSignature);
                                      });
                                    },
                                    initialRadioValue: answer_given != ''
                                        ? answer_given
                                        : null,
                                    question: get["query_name"] as String);
                              } else if (get["quiz_type"] == "numeric") {
                                //numeric
                                return NumericQuestion(
                                    initialDecripValue: answer_given != ''
                                        ? answer_given
                                        : null,
                                    id: questions[index]['id'],
                                    onValueChanged: (value) {
                                      var qid = get['id'];
                                      setState(() {
                                        numericValues[qid] = value;
                                        print(numericValues);
                                      });
                                    },
                                    onValueChanged2: (value) {
                                      var qid = get['id'];
                                      setState(() {
                                        traceableSignature[qid] = value;
                                        print(traceableSignature);
                                      });
                                    },
                                    question: get["query_name"] as String);
                              } else if (get["quiz_type"] == "single") {
                                //single
                                return SingleQuestion(
                                    id: get['id'],
                                    onValueChanged: (value) {
                                      var qid = get['id'];
                                      setState(() {
                                        singleValues[qid] = value;
                                        print(singleValues);
                                      });
                                    },
                                    onValueChanged2: (value) {
                                      var qid = get['id'];
                                      setState(() {
                                        traceableSignature[qid] = value;
                                        print(traceableSignature);
                                      });
                                    },
                                    initialRadioValue: answer_given != ''
                                        ? answer_given
                                        : null,
                                    question: get['query_name'] as String);
                              } else if (get["quiz_type"] == "others") {
                                //others
                                return Others(
                                  id: get['id'],
                                  options: get["options"],
                                  onValueChanged: (value) {
                                    var qid = get['id'];
                                    setState(() {
                                      singleDescipTextValues[qid] = value;
                                      print(singleDescipTextValues);
                                    });
                                  },
                                  onValueChanged2: (value) {
                                    var qid = get['id'];
                                    setState(() {
                                      traceableSignature[qid] = value;
                                      print(traceableSignature);
                                    });
                                  },
                                  onRadioChanged: (value) {
                                    var qid = questions[index]['id'];
                                    setState(() {
                                      singleDescripCategory[qid] = value;
                                      print(singleDescripCategory);
                                    });
                                  },
                                  initialDecripValue:
                                      answ != null ? answ["description"] : null,
                                  initialRadioValue:
                                      answer_given != '' ? answer_given : null,
                                  question: get["query_name"] as String,
                                  // hasDescription: get["has_description"] as String,
                                );
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
            )),
            questions.isEmpty
                ? Container()
                : isButtonEnabled
                    ? Container(
                        margin: const EdgeInsets.only(
                            top: 10, bottom: 5, left: 10, right: 10),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: const RoundedRectangleBorder(),
                                  backgroundColor: mycolor,
                                  foregroundColor: textWhite),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  questionValues
                                      .clear(); // Clear the map before fetching new values

                                  var answers = [];

                                  for (var quest in questions) {
                                    final int questionId = quest["id"];

                                    // var answer = {
                                    //   "project_id": widget.shop_id,
                                    //   "question_idd": question["id"],
                                    //   "question_id": questionId,
                                    //   "routing_category_id":
                                    //       question["route_question_item_id"],
                                    //   "stage_id": widget.vehicle_id,
                                    //   "quiz_type": question["quiz_type"],
                                    //   "defects":
                                    //       null, // Default value if no defects are recorded
                                    //   "answer":
                                    //       null, // Default value if no specific answer is set
                                    //   "description": null,
                                    //   // Additional fields
                                    //   "user_id": user["user"]["id"],
                                    //   "ins": user["user"]["ins"],
                                    // };
                                    var answer = {
                                      "vehicle_id": widget.vehicle_id,
                                      "shop_id": widget.shop_id,
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
                                      "defects": '',
                                      "signature":
                                          traceableSignature[questionId],
                                    };

                                    if (quest["quiz_type"] == "traceable") {
                                      // Retrieve value from TraceableQuestion
                                      String? value =
                                          traceableValues[questionId];
                                      answer["answer"] = value;
                                    } else if (quest["quiz_type"] ==
                                        "multiple") {
                                      // Retrieve values from MultipleQuestion
                                      List<dynamic>? values =
                                          multipleValues[questionId];
                                      String? value = multipleValue[questionId];

                                      answer["defects"] = values;
                                      answer["answer"] = value;
                                    } else if (quest["quiz_type"] == "single") {
                                      // Retrieve values from SingleQuestion
                                      String? value = singleValues[questionId];
                                      answer["answer"] = value;
                                    } else if (quest["quiz_type"] ==
                                        "numeric") {
                                      // Retrieve values from NumericQuestion
                                      String? value = numericValues[questionId];
                                      answer["answer"] = value;
                                    } else if (quest["quiz_type"] == "others") {
                                      // Retrieve values from NumericQuestion
                                      String? value =
                                          singleDescipTextValues[questionId];
                                      String? values =
                                          singleDescripCategory[questionId];
                                      answer["answer"] = value;
                                      answer["defects"] = values;
                                    }
                                    if (answer["answer"] != null) {
                                      answers.add(answer);
                                    }
                                  }

                                  if (answers.isNotEmpty) {
                                    //For normal dialog
                                    setState(() {
                                      isButtonEnabled = false;
                                    });
                                    ProgressDialog pr = ProgressDialog(context,
                                        type: ProgressDialogType.normal,
                                        isDismissible: true,
                                        showLogs: true);
                                    pr.style(
                                      message: 'Saving answers...',
                                      borderRadius: 8,
                                      backgroundColor: Colors.white,
                                      progressWidget: const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator())),
                                      elevation: 10.0,
                                      insetAnimCurve: Curves.easeInOut,
                                    );

                                    pr.show();
                                    saveanswers(answers).then((res) {
                                      pr.hide().then((value) {
                                        setState(() {
                                          isButtonEnabled = true;
                                        });
                                        if (res["success"]) {
                                          Navigator.pop(context);
                                          awesomeTopSnackbar(
                                            context,
                                            '${res["msg"]}',
                                            iconWithDecoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(),
                                              color: Colors.white,
                                            ),
                                            icon: Icon(
                                              Icons.done,
                                              color: Colors.green[900],
                                            ),
                                          );
                                        } else {
                                          awesomeTopSnackbar(
                                            backgroundColor: Colors.red,
                                            context,
                                            '${res["msg"]}',
                                            iconWithDecoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(),
                                              color: Colors.white,
                                            ),
                                          );
                                        }
                                      });
                                    });
                                    Future.delayed(
                                        const Duration(seconds: dismissseconds),
                                        () {
                                      if (pr.isShowing()) {
                                        pr.hide();
                                        setState(() {
                                          isButtonEnabled = true;
                                        });
                                        awesomeTopSnackbar(
                                          backgroundColor: Colors.red,
                                          context,
                                          "Something Wrong or Check internet Connection",
                                          iconWithDecoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(),
                                            color: Colors.white,
                                          ),
                                        );
                                      }
                                    });
                                  } else {
                                    awesomeTopSnackbar(context,
                                        "Please Answer at least one question",
                                        iconWithDecoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(),
                                          color: Colors.white,
                                        ),
                                        backgroundColor: mycolor);
                                  }
                                }
                              },
                              child: const Text('SAVE')),
                        ),
                      )
                    : Container()
          ],
        ),
      ),
    );
  }

  Future saveanswers(answers) async {
    String url = Api.api_url + "answerquery2";
    print(url);
    // var payload = {"answers": jsonEncode(answers)};
    var payload = answers;

    var responsedata =
        await httppostwithtoken(url, user['data']["token"], payload, context);
    log(jsonEncode(responsedata));
    return responsedata;
  }

  Future fetchQuestions() async {
    ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, showLogs: true, isDismissible: true);
    pr.style(message: 'Fetching questions...');
    pr.show();
    String url =
        "${Api.api_url}quiz/${widget.query_id}/${widget.vehicle_id}/${widget.shop_id}";
    print(" fetching question url");
    print(url);

    var responseData = await httpget(url, user['data']["token"], context);

    // log(jsonEncode(responseData['data']['query']));
    // print(responseData['data']);

    if (responseData != null) {
      if (responseData["data"] != null) {
        pr.hide().whenComplete(() {
          setState(() {
            // question = responseData["data"];
            questions = responseData["data"]["query"];
            Category = responseData["data"]["category"];
          });
        });
      } else {
        pr.hide().whenComplete(() {
          ScaffoldMessenger.of(context)
              .showSnackBar(snackBar(responseData["message"], Colors.red[500]));
        });
      }
    }
  }
}
