// // ignore_for_file: use_build_context_synchronously

// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:isuze_pqcs/common/api.dart';
// import 'package:isuze_pqcs/common/constants.dart';
// import 'package:isuze_pqcs/common/functions.dart';
// import 'package:isuze_pqcs/common/widgets.dart';
// import 'package:isuze_pqcs/pages/qc_inspection/routing_structure/multiple_question.dart';
// import 'package:isuze_pqcs/pages/qc_inspection/routing_structure/numerical_question.dart';
// import 'package:isuze_pqcs/pages/qc_inspection/routing_structure/open_text_question.dart';
// import 'package:isuze_pqcs/pages/qc_inspection/routing_structure/single_with_description_question.dart';
// import 'package:isuze_pqcs/pages/qc_inspection/routing_structure/traceable_question.dart';

// import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';


// class RoutingTemplateWithoutStages extends StatefulWidget {
//   // final int category;
//   final List questions;
//   final int stageId;
//   final int modelId;
//   final int vehicleId;
//   const RoutingTemplateWithoutStages({
//     super.key,
//     required this.vehicleId,
//     required this.stageId,
//     required this.modelId,
//     required this.questions,
//   });

//   @override
//   State<RoutingTemplateWithoutStages> createState() =>
//       _RoutingTemplateWithoutStagesState();
// }

// class _RoutingTemplateWithoutStagesState
//     extends State<RoutingTemplateWithoutStages> {
//   var user = {};
//   var textLoading = 'Loading questions...';
//   Map<int, dynamic> questionValues = {};
//   Map<int, String> traceableValues = {};
//   Map<int, String> openTextValues = {};
//   Map<int, String> singleDescipTextValues = {};
//   Map<int, String> numericValues = {};
//   Map<int, String> singleValues = {};
//   Map<int, String> singleDescripValues = {};
//   Map<int, String> multipleValue = {};
//   Map<int, List<dynamic>> multipleValues = {};

//   @override
//   void initState() {
//     super.initState();
//     getuserdata().then((value) {
//       setState(() {
//         user = jsonDecode(value);
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             'Vehicle Name - AJKHSDHASJDKASD867876ASD876ASD',
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 16),
//             overflow: TextOverflow.ellipsis,
//             maxLines: 2,
//           ),
//         ),
//         body: Column(
//           children: [
//             gap(),
//             Expanded(
//                 child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: widget.questions.isEmpty
//                   ? const Center(
//                       child: Text('Loading questions...'),
//                     )
//                   : ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: widget.questions.length,
//                       itemBuilder: (context, index) {
//                         if (widget.questions[index]["question_type"] ==
//                             "traceable") {
//                           //traceable
//                           return TraceableQuestion(
//                               id: widget.questions[index]['id'],
//                               onValueChanged: (value) {
//                                 var qid = widget.questions[index]['id'];
//                                 setState(() {
//                                   traceableValues[qid] = value;
//                                 });
//                               },
//                               question: widget.questions[index]
//                                   ["route_question"] as String);
//                         } else if (widget.questions[index]["question_type"] ==
//                             "open-text") {
//                           //opentext
//                           return OpenTextQuestion(
//                               id: widget.questions[index]['id'],
//                               onValueChanged: (value) {
//                                 var qid = widget.questions[index]['id'];
//                                 setState(() {
//                                   openTextValues[qid] = value;
//                                 });
//                               },
//                               question: widget.questions[index]
//                                   ["route_question"] as String);
//                         } else if (widget.questions[index]["question_type"] ==
//                             "single_with_description") {
//                           //opentext
//                           return SingleWithDescriptionQuestion(
//                               id: widget.questions[index]['id'],
//                               onValueChanged: (value) {
//                                 var qid = widget.questions[index]['id'];
//                                 setState(() {
//                                   singleDescipTextValues[qid] = value;
//                                 });
//                               },
//                               onRadioChanged: (value) {
//                                 var qid = widget.questions[index]['id'];
//                                 setState(() {
//                                   singleDescripValues[qid] = value;
//                                 });
//                               },
//                               question: widget.questions[index]
//                                   ["route_question"] as String);
//                         } else if (widget.questions[index]["question_type"] ==
//                             "multiple") {
//                           //multiple
//                           var option =
//                               widget.questions[index]["option"]["options"];
//                           var options = jsonDecode(option);
//                           return MultipleQuestion(
//                               id: widget.questions[index]['id'],
//                               options: options as List,
//                               onRadioChanged: (value) {
//                                 var qid = widget.questions[index]['id'];
//                                 setState(() {
//                                   multipleValue[qid] = value;
//                                 });
//                                 if (value == "ok") {
//                                   setState(() {
//                                     multipleValues.clear();
//                                   });
//                                 }
//                               },
//                               onValuesChanged: (values) {
//                                 var qid = widget.questions[index]['id'];
//                                 setState(() {
//                                   multipleValues[qid] = values;
//                                 });
//                               },
//                               question: widget.questions[index]
//                                   ["route_question"] as String);
//                         } else if (widget.questions[index]["question_type"] ==
//                             "numeric") {
//                           //numeric
//                           return NumericQuestion(
//                               id: widget.questions[index]['id'],
//                               onValueChanged: (value) {
//                                 var qid = widget.questions[index]['id'];
//                                 setState(() {
//                                   numericValues[qid] = value;
//                                 });
//                               },
//                               question: widget.questions[index]
//                                   ["route_question"] as String);
//                         } else if (widget.questions[index]["question_type"] ==
//                             "single") {
//                           //single
//                           return SingeQuestion(
//                               id: widget.questions[index]['id'],
//                               onValueChanged: (value) {
//                                 var qid = widget.questions[index]['id'];
//                                 setState(() {
//                                   singleValues[qid] = value;
//                                 });
//                               },
//                               question: widget.questions[index]
//                                   ["route_question"] as String);
//                         }
//                         return null;
//                       },
//                     ),
//             )),
//             Container(
//               margin: const EdgeInsets.only(
//                   top: 10, bottom: 5, left: 10, right: 10),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                         shape: const RoundedRectangleBorder(),
//                         backgroundColor: app_colorPrimary,
//                         foregroundColor: textWhite),
//                     onPressed: () {
//                       // Check if all questions are answered
//                       bool allQuestionsAnswered = true;
//                       for (var question in widget.questions) {
//                         final int questionId = question["id"];

//                         if (question["question_type"] == "traceable") {
//                           if (traceableValues[questionId] == null) {
//                             allQuestionsAnswered = false;
//                             break;
//                           }
//                         } else if (question["question_type"] == "multiple") {
//                           if (multipleValue[questionId] == null) {
//                             allQuestionsAnswered = false;
//                             break;
//                           } else if (multipleValue[questionId] == "nok") {
//                             if (multipleValues[questionId] == null) {
//                               allQuestionsAnswered = false;
//                               break;
//                             }
//                           }
//                         } else if (question["question_type"] == "single") {
//                           if (singleValues[questionId] == null) {
//                             allQuestionsAnswered = false;
//                             break;
//                           }
//                         } else if (question["question_type"] ==
//                             "single_with_description") {
//                           if (singleDescripValues[questionId] == null) {
//                             allQuestionsAnswered = false;
//                             break;
//                           } else if (singleDescripValues[questionId] == "nok") {
//                             if (singleDescipTextValues[questionId] == null) {
//                               allQuestionsAnswered = false;
//                               break;
//                             }
//                           }
//                         } else if (question["question_type"] == "open-text") {
//                           if (openTextValues[questionId] == null) {
//                             allQuestionsAnswered = false;
//                             break;
//                           }
//                         } else if (question["question_type"] == "numeric") {
//                           if (numericValues[questionId] == null) {
//                             allQuestionsAnswered = false;
//                             break;
//                           }
//                         }
//                       }

//                       if (allQuestionsAnswered) {
//                         questionValues
//                             .clear(); // Clear the map before fetching new values

//                         var answers = [];

//                         for (var question in widget.questions) {
//                           final int questionId = question["id"];
//                           var answer = {
//                             "project_id": widget.vehicleId,
//                             "question_id": questionId,
//                             "question_type": question["question_type"],
//                             "stage_id": widget.stageId,
//                             "routing_category_id":
//                                 question["routing_category_id"],
//                             "defects":
//                                 null, // Default value if no defects are recorded
//                             "answer":
//                                 null, // Default value if no specific answer is set

//                             // Additional fields
//                             "user_id": user["user"]["id"],
//                             "ins": user["user"]["ins"],
//                           };

//                           if (question["question_type"] == "traceable") {
//                             // Retrieve value from TraceableQuestion
//                             String? value = traceableValues[questionId];
//                             answer["answer"] = value;
//                           } else if (question["question_type"] == "multiple") {
//                             // Retrieve values from MultipleQuestion
//                             List<dynamic>? values = multipleValues[questionId];
//                             String? value = multipleValue[questionId];
//                             answer["defects"] = values;
//                             answer["answer"] = value;
//                           } else if (question["question_type"] == "single") {
//                             // Retrieve values from SingleQuestion
//                             String? value = singleValues[questionId];
//                             answer["answer"] = value;
//                           } else if (question["question_type"] ==
//                               "single_with_description") {
//                             // Retrieve values from SingleQuestion
//                             String? values = singleDescipTextValues[questionId];
//                             String? value = singleDescripValues[questionId];
//                             answer["answer"] = value;
//                             answer["defects"] = values;
//                           } else if (question["question_type"] == "open-text") {
//                             // Retrieve values from OpenQuestion
//                             String? value = openTextValues[questionId];
//                             answer["answer"] = value;
//                           } else if (question["question_type"] == "numeric") {
//                             // Retrieve values from NumericQuestion
//                             String? value = numericValues[questionId];
//                             answer["answer"] = value;
//                           }

//                           answers.add(answer);
//                         }

//                         //For normal dialog
//                         ProgressDialog pr = ProgressDialog(context,
//                             type: ProgressDialogType.normal,
//                             isDismissible: true,
//                             showLogs: true);
//                         pr.style(
//                           message: 'Saving answers...',
//                           borderRadius: 8,
//                           backgroundColor: Colors.white,
//                           progressWidget: const SizedBox(
//                               width: 20,
//                               height: 20,
//                               child:
//                                   Center(child: CircularProgressIndicator())),
//                           elevation: 10.0,
//                           insetAnimCurve: Curves.easeInOut,
//                         );

//                         pr.show();
//                         saveanswers(answers).then((res) {
//                           pr
//                               .hide()
//                               .then((value) => ScaffoldMessenger.of(context)
//                                   .showSnackBar(
//                                       snackBar(res["message"], Colors.blue)))
//                               .then((value) {
//                             Navigator.of(context).pop(true);
//                           });
//                         });
//                         Future.delayed(const Duration(seconds: dismissseconds),
//                             () {
//                           if (pr.isShowing()) {
//                             pr.hide();
//                             ScaffoldMessenger.of(context).showSnackBar(
//                                 snackBar(internetmessage, snackred));
//                           }
//                         });
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(snackBar(
//                             "Please Fill all Questions",
//                             const Color.fromARGB(255, 56, 56, 56)));
//                       }
//                     },
//                     child: const Text('SAVE')),
//               ),
//             )
//           ],
//         ));
//   }

//   Future saveanswers(answers) async {
//     String url = Api.api_url + "Api.endpoint_saveanswers";
//     var payload = {"answers": jsonEncode(answers)};

//     var responsedata =
//         await httppostwithtoken(url, user["token"], payload, context);

//     if (responsedata != null) {
//       return responsedata;
//     } else {
//       return responsedata;
//     }
//   }
// }
