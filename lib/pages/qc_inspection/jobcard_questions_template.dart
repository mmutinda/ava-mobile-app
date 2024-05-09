// ignore_for_file: use_build_context_synchronously, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/pages/qc_inspection/routing_structure/multiple_question.dart';
import 'package:isuze_pqcs/pages/qc_inspection/routing_structure/numerical_question.dart';
import 'package:isuze_pqcs/pages/qc_inspection/routing_structure/others.dart';
import 'package:isuze_pqcs/pages/qc_inspection/routing_structure/single_question.dart';
import 'package:isuze_pqcs/pages/qc_inspection/routing_structure/single_with_description_question.dart';
import 'package:isuze_pqcs/pages/qc_inspection/routing_structure/traceable_question.dart';

import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'routing_structure/open_text_question.dart';

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
  Map<int, String> multipleValue = {};
  Map<int, List<dynamic>> multipleValues = {};
  List questions = [];
  Map question = {};

  List vehicles = [];
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
        actions: [
          InkWell(
            onTap: () {
              fetchQuestions();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.refresh),
            ),
          ),
        ],
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
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        var answ = questions[index];
                        var get = questions[index];
                        var can_sign = get['can_sign'];
                        var checkanswered = get['checkanswered'];
                        print(get);
                        // var noptions = get["options"];
                        // List<dynamic> responseData = noptions;
                        // print(responseData);
                        // print(get["quiz_type"]);
                        if (get["quiz_type"] == "traceable") {
                          //traceable
                          return TraceableQuestion(
                              can_sign: can_sign,
                              checkanswered: checkanswered,
                              id: get['id'],
                              onValueChanged: (value) {
                                var qid = questions[index]['id'];
                                setState(() {
                                  traceableValues[qid] = value;
                                });
                              },
                              question:
                                  questions[index]["query_name"] as String);
                        } else if (questions[index]["quiz_type"] ==
                            "open-text") {
                          //opentext
                          return OpenTextQuestion(
                              id: get['id'],
                              onValueChanged: (value) {
                                var qid = questions[index]['id'];
                                setState(() {
                                  openTextValues[qid] = value;
                                });
                              },
                              question: get["query_name"] as String);
                        } else if (get["quiz_type"] ==
                            "Single With Description") {
                          //Single With Description
                          return SingleWithDescriptionQuestion(
                            id: questions[index]['id'],
                            onValueChanged: (value) {
                              var qid = get['id'];
                              setState(() {
                                singleDescipTextValues[qid] = value;
                              });
                            },
                            onRadioChanged: (value) {
                              var qid = questions[index]['id'];
                              setState(() {
                                singleDescripValues[qid] = value;
                              });
                            },
                            initialDecripValue:
                                answ != null ? answ["description"] : null,
                            initialRadioValue:
                                answ != null ? answ["selected"] : null,
                            question: get["query_name"] as String,
                            hasDescription:
                                questions[index]["has_description"] as String,
                          );
                        } else if (get["quiz_type"] == "multiple") {
                          return MultipleQuestion(
                              id: get['id'],
                              options: get["options"],
                              onRadioChanged: (value) {
                                var qid = questions[index]['id'];
                                setState(() {
                                  multipleValue[qid] = value;
                                });
                                if (value == "ok") {
                                  setState(() {
                                    multipleValues.clear();
                                  });
                                }
                              },
                              onValuesChanged: (values) {
                                var qid = questions[index]['id'];
                                setState(() {
                                  multipleValues[qid] = values;
                                });
                              },
                              question: get["query_name"] as String);
                        } else if (get["quiz_type"] == "numeric") {
                          //numeric
                          return NumericQuestion(
                              id: questions[index]['id'],
                              onValueChanged: (value) {
                                var qid = questions[index]['id'];
                                setState(() {
                                  numericValues[qid] = value;
                                });
                              },
                              question: get["query_name"] as String);
                        } else if (get["quiz_type"] == "single") {
                          //single
                          return SingleQuestion(
                              id: get['id'],
                              onValueChanged: (value) {
                                var qid = questions[index]['id'];
                                setState(() {
                                  singleValues[qid] = value;
                                });
                              },
                              initialRadioValue:
                                  answ != null ? answ["selected"] : null,
                              question: get['query_name'] as String);
                        } else if (get["quiz_type"] == "others") {
                          //others
                          return Others(
                            id: get['id'],
                            options: get["options"],
                            onValueChanged: (value) {
                              var qid = questions[index]['id'];
                              setState(() {
                                singleDescipTextValues[qid] = value;
                              });
                            },
                            onRadioChanged: (value) {
                              var qid = questions[index]['id'];
                              setState(() {
                                singleDescripValues[qid] = value;
                              });
                            },
                            initialDecripValue:
                                answ != null ? answ["description"] : null,
                            initialRadioValue:
                                answ != null ? answ["selected"] : null,
                            question: get["query_name"] as String,
                            // hasDescription: get["has_description"] as String,
                          );
                        }
                        return null;
                      },
                    ),
            )),
            questions.isEmpty
                ? Container()
                : Container(
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
                            // if (_formKey.currentState!.validate()) {
                            //   questionValues
                            //       .clear(); // Clear the map before fetching new values

                            //   var answers = [];

                            //   for (var quest in questions) {
                            //     final int questionId = quest["id"];

                            //     var answer = {
                            //       "project_id": widget.jobCardId,
                            //       "question_idd": question["id"],
                            //       "question_id": questionId,
                            //       "routing_category_id":
                            //           question["route_question_item_id"],
                            //       "stage_id": widget.categoryItemId,
                            //       "question_type": question["question_type"],
                            //       "defects":
                            //           null, // Default value if no defects are recorded
                            //       "answer":
                            //           null, // Default value if no specific answer is set
                            //       "description": null,
                            //       // Additional fields
                            //       "user_id": user["user"]["id"],
                            //       "ins": user["user"]["ins"],
                            //     };

                            //     if (question["question_type"] == "Traceable") {
                            //       // Retrieve value from TraceableQuestion
                            //       String? value = traceableValues[questionId];
                            //       answer["answer"] = value;
                            //     } else if (question["question_type"] ==
                            //         "Multiple") {
                            //       // Retrieve values from MultipleQuestion
                            //       List<dynamic>? values =
                            //           multipleValues[questionId];
                            //       String? value = multipleValue[questionId];
                            //       answer["defects"] = values;
                            //       answer["answer"] = value;
                            //     } else if (question["question_type"] ==
                            //         "Single") {
                            //       // Retrieve values from SingleQuestion
                            //       String? value = singleValues[questionId];
                            //       answer["answer"] = value;
                            //     } else if (question["question_type"] ==
                            //         "Single With Description") {
                            //       // Retrieve values from SingleQuestion
                            //       String? values =
                            //           singleDescipTextValues[questionId];
                            //       String? value =
                            //           singleDescripValues[questionId];
                            //       answer["answer"] = value;
                            //       if (value == "ok") {
                            //         answer["description"] = values;
                            //       } else {
                            //         answer["description"] = values;
                            //         answer["defects"] = values;
                            //       }
                            //     } else if (question["question_type"] ==
                            //         "Open Text") {
                            //       // Retrieve values from OpenQuestion
                            //       String? value = openTextValues[questionId];
                            //       answer["answer"] = value;
                            //     } else if (question["question_type"] ==
                            //         "Numeric") {
                            //       // Retrieve values from NumericQuestion
                            //       String? value = numericValues[questionId];
                            //       answer["answer"] = value;
                            //     }
                            //     if (answer["answer"] != null) {
                            //       answers.add(answer);
                            //     }
                            //   }

                            //   if (answers.isNotEmpty) {
                            //     //For normal dialog
                            //     ProgressDialog pr = ProgressDialog(context,
                            //         type: ProgressDialogType.normal,
                            //         isDismissible: true,
                            //         showLogs: true);
                            //     pr.style(
                            //       message: 'Saving answers...',
                            //       borderRadius: 8,
                            //       backgroundColor: Colors.white,
                            //       progressWidget: const SizedBox(
                            //           width: 20,
                            //           height: 20,
                            //           child: Center(
                            //               child: CircularProgressIndicator())),
                            //       elevation: 10.0,
                            //       insetAnimCurve: Curves.easeInOut,
                            //     );

                            //     pr.show();
                            //     saveanswers(answers).then((res) {
                            //       pr.hide().then((value) {
                            //         if (res["message"] ==
                            //             'Answers Recorded Successfully') {
                            //           AwesomeDialog(
                            //             context: context,
                            //             dialogType: DialogType.success,
                            //             animType: AnimType.rightSlide,
                            //             title: 'Answers Recorded Successfull',
                            //             btnOkColor: mycolor,
                            //             onDismissCallback: (type) {
                            //               Navigator.pop(context);
                            //             },
                            //             btnOkOnPress: () {},
                            //           )..show();
                            //         } else {
                            //           ScaffoldMessenger.of(context)
                            //               .showSnackBar(snackBar(
                            //                   res["message"], Colors.blue));
                            //         }
                            //       });
                            //     });
                            //     Future.delayed(
                            //         const Duration(seconds: dismissseconds),
                            //         () {
                            //       if (pr.isShowing()) {
                            //         pr.hide();
                            //         ScaffoldMessenger.of(context).showSnackBar(
                            //             snackBar(internetmessage, snackred));
                            //       }
                            //     });
                            //   } else {
                            //     ScaffoldMessenger.of(context).showSnackBar(
                            //         snackBar(
                            //             "Please Answer at least one question",
                            //             const Color.fromARGB(255, 56, 56, 56)));
                            //   }
                            // }
                          },
                          child: const Text('SAVE')),
                    ),
                  )
          ],
        ),
      ),
    );
  }

  Future saveanswers(answers) async {
    String url = Api.api_url + "Api.endpoint_saveanswers";
    var payload = {"answers": jsonEncode(answers)};

    var responsedata =
        await httppostwithtoken(url, user["token"], payload, context);

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
    // log(jsonEncode(responseData['data']['query']));

    if (responseData != null) {
      if (responseData["data"] != null) {
        pr.hide().whenComplete(() {
          setState(() {
            // question = responseData["data"];
            questions = responseData["data"]["query"];
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
