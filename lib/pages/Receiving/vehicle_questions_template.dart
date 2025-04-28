// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:developer';
import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/pages/Receiving/single_with_description_question.dart';
import 'package:isuze_pqcs/pages/qc_inspection/routing_structure/traceable_question.dart';

import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class VehicleQuestionsTemplate extends StatefulWidget {
  final int vehicleId;
  final int categoryItemId;
  final String categoryName;
  final strippingDone;
  const VehicleQuestionsTemplate({
    super.key,
    required this.categoryItemId,
    required this.categoryName,
    required this.vehicleId,
    this.strippingDone,
  });

  @override
  State<VehicleQuestionsTemplate> createState() =>
      _VehicleQuestionsTemplateState();
}

class _VehicleQuestionsTemplateState extends State<VehicleQuestionsTemplate> {
  var user = {};
  var textLoading = 'No questions found';
  bool isButtonEnabled = true;
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

  @override
  void initState() {
    super.initState();

    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      fetchQuestions(widget.categoryItemId, widget.vehicleId);
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
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        var answ = questions[index]["answer"];
                        print(questions[index]['id']);
                        // print(question["question_type"]);

                        //opentext
                        return SingleWithDescriptionQuestion(
                          index: index,
                          id: questions[index]['id'],
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
                          question: questions[index]["question_name"] as String,
                          hasDescription:
                              questions[index]["has_description"] as String,
                        );
                      },
                    ),
            )),
            Container(
              margin: const EdgeInsets.only(
                  top: 10, bottom: 5, left: 10, right: 10),
              child: Row(
                children: [
                  questions.isEmpty
                      ? Expanded(child: Container())
                      : isButtonEnabled
                          ? Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.white, // Text color
                                  shadowColor:
                                      Colors.transparent, // Removes shadow
                                  side: BorderSide(
                                      color: mycolor, width: 2), // Red border
                                  // shape: RoundedRectangleBorder(
                                  //   borderRadius:
                                  //       BorderRadius.circular(12), // Rounded corners
                                  // ),
                                  // Padding
                                ),
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold, // Bold text
                                    color: Colors
                                        .red, // White text for contrast with red border
                                  ),
                                ),
                              ),
                            )
                          : Expanded(child: Container()),
                  SizedBox(width: 10),
                  questions.isEmpty
                      ? Expanded(child: Container())
                      : isButtonEnabled
                          ? Expanded(
                              child: Container(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          // shape: const RoundedRectangleBorder(),
                                          backgroundColor: mycolor,
                                          foregroundColor: textWhite),
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          questionValues
                                              .clear(); // Clear the map before fetching new values
                                          var answers = [];
                                          for (var quest in questions) {
                                            final int questionId = quest["id"];
                                            var answer = {
                                              "project_id": widget.vehicleId,
                                              "question_idd": question["id"],
                                              "question_id": questionId,
                                              "routing_category_id": question[
                                                  "route_question_item_id"],
                                              "stage_id": widget.categoryItemId,
                                              "question_type":
                                                  question["question_type"],
                                              "defects":
                                                  null, // Default value if no defects are recorded
                                              "answer":
                                                  null, // Default value if no specific answer is set
                                              "description": null,
                                              // Additional fields
                                              "user_id": user["user"]["id"],
                                              "ins": user["user"]["ins"],
                                            };
                                            if (question["question_type"] ==
                                                "Remarks") {
                                              // Retrieve values from OpenTextQuestion
                                              String? value =
                                                  openTextValues[questionId];

                                              // Check if the value is null or empty before saving
                                              if (value != null &&
                                                  value.isNotEmpty) {
                                                answer["answer"] = value;
                                              } else {
                                                // Optionally handle the case where the value is null or empty
                                                // For example, you could log a message or leave the answer out entirely
                                                print(
                                                    "No answer provided for the Remarks question.");
                                              }
                                            }
                                            if (question["question_type"] ==
                                                "Traceable") {
                                              // Retrieve value from TraceableQuestion
                                              String? value =
                                                  traceableValues[questionId];
                                              answer["answer"] = value;
                                            } else if (question[
                                                    "question_type"] ==
                                                "Multiple") {
                                              // Retrieve values from MultipleQuestion
                                              List<dynamic>? values =
                                                  multipleValues[questionId];
                                              String? value =
                                                  multipleValue[questionId];
                                              answer["defects"] = values;
                                              answer["answer"] = value;
                                            } else if (question[
                                                    "question_type"] ==
                                                "Single") {
                                              // Retrieve values from SingleQuestion
                                              String? value =
                                                  singleValues[questionId];
                                              answer["answer"] = value;
                                            } else if (question[
                                                    "question_type"] ==
                                                "Single With Description") {
                                              // Retrieve values from SingleQuestion
                                              String? values =
                                                  singleDescipTextValues[
                                                      questionId];
                                              String? value =
                                                  singleDescripValues[
                                                      questionId];
                                              answer["answer"] = value;
                                              if (value == "ok") {
                                                answer["description"] = values;
                                              } else {
                                                answer["description"] = values;
                                                answer["defects"] = values;
                                              }
                                            } else if (question[
                                                    "question_type"] ==
                                                "Open Text") {
                                              // Retrieve values from OpenQuestion
                                              String? value =
                                                  openTextValues[questionId];
                                              answer["answer"] = value;
                                            } else if (question[
                                                        "question_type"] ==
                                                    "Numeric" &&
                                                widget.strippingDone == null) {
                                              // Retrieve values from NumericQuestion
                                              // print("goo");
                                              String? value =
                                                  numericValues[questionId];
                                              answer["answer"] = value;
                                              print(numericValues[questionId] ==
                                                  null);
                                            } else if (question[
                                                        "question_type"] ==
                                                    "Numeric" &&
                                                widget.strippingDone == 'yes') {
                                              // Retrieve values from NumericQuestion
                                              // print("goo");
                                              String? value =
                                                  numericValues[questionId];
                                              answer["answer"] = value;
                                              // print(numericValues[questionId] == null);
                                            }
                                            if (answer["answer"] != null) {
                                              answers.add(answer);
                                            }
                                          }
                                          print(answers);
                                          if (answers.isNotEmpty) {
                                            //For normal dialog
                                            setState(() {
                                              isButtonEnabled = false;
                                            });
                                            ProgressDialog pr = ProgressDialog(
                                              context,
                                              type: ProgressDialogType.normal,
                                              isDismissible: true,
                                              showLogs: true,
                                            );
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
                                              // print(answers);
                                              setState(() {
                                                isButtonEnabled = true;
                                              });
                                              log(jsonEncode(res));
                                              pr.hide().then((value) {
                                                setState(() {
                                                  isButtonEnabled = true;
                                                });
                                                if (res != null) {
                                                  if (res["message"] ==
                                                      'Answers Recorded Successfully') {
                                                    Navigator.pop(context);
                                                    awesomeTopSnackbar(
                                                      context,
                                                      "Answers Recorded Successfully",
                                                      iconWithDecoration:
                                                          BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        border: Border.all(),
                                                        color: Colors.white,
                                                      ),
                                                      icon: Icon(
                                                        Icons.done,
                                                        color:
                                                            Colors.green[900],
                                                      ),
                                                    );
                                                  } else {
                                                    awesomeTopSnackbar(context,
                                                        "${res["message"]}",
                                                        iconWithDecoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                          border: Border.all(),
                                                          color: Colors.white,
                                                        ),
                                                        backgroundColor:
                                                            Colors.red[900]);
                                                  }
                                                } else {
                                                  setState(() {
                                                    isButtonEnabled = true;
                                                  });
                                                  awesomeTopSnackbar(
                                                    backgroundColor: Colors.red,
                                                    context,
                                                    "Something Wrong or Check internet Connection",
                                                    iconWithDecoration:
                                                        BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      border: Border.all(),
                                                      color: Colors.white,
                                                    ),
                                                  );
                                                }
                                              });
                                            });
                                            Future.delayed(
                                                const Duration(
                                                    seconds: dismissseconds),
                                                () {
                                              if (pr.isShowing()) {
                                                pr.hide();
                                                awesomeTopSnackbar(context,
                                                    "${internetmessage}",
                                                    iconWithDecoration:
                                                        BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      border: Border.all(),
                                                      color: Colors.white,
                                                    ),
                                                    backgroundColor:
                                                        Colors.red[900]);
                                              }
                                            });
                                          } else {
                                            awesomeTopSnackbar(context,
                                                "Please Answer at least one question",
                                                iconWithDecoration:
                                                    BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(),
                                                  // color: Colors.white,
                                                ),
                                                backgroundColor: mycolor);
                                          }
                                        }
                                      },
                                      child: const Text('SAVE')),
                                ),
                              ),
                            )
                          : Expanded(child: Container())
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future saveanswers(answers) async {
    String url = Api.api_url + "Api.endpoint_saveanswers";
    print(url);
    var payload = {"answers": jsonEncode(answers)};
    log(jsonEncode(payload));
    var responsedata =
        await httppostwithtoken(url, user["token"], payload, context);

    return responsedata;
  }

  Future fetchQuestions(id, vehicleId) async {
    ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, showLogs: true, isDismissible: true);
    pr.style(message: 'Fetching questions...');
    // pr.show();
    // String url = "${Api.api_url}${Api.endpoint_route_questions}/$id/$vehicleId";
    String url =
        "https://hal.hanspaulerp.net/api/fetchRoutingQuestions/18/1274";
    print(url);
    var responsedata = await httpget(url, Api.usr, context);

    if (responsedata != null) {
      if (responsedata["question"] != null) {
        pr.hide().whenComplete(() {
          setState(() {
            question = responsedata["question"];
            questions = responsedata["question"]["questionitems"];
          });
        });
      } else {
        pr.hide().whenComplete(() {
          ScaffoldMessenger.of(context)
              .showSnackBar(snackBar(responsedata["message"], Colors.red[500]));
        });
      }
    }
    // Dismiss the progress dialog after a few seconds
    Future.delayed(const Duration(seconds: dismissseconds), () {
      if (pr.isShowing()) {
        pr.hide();
        ScaffoldMessenger.of(context)
            .showSnackBar(snackBar(internetmessage, snackred));
      }
    });
  }
}
