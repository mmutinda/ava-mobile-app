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
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/pages/qc_inspection/routing_structure/multiple_question.dart';
import 'package:isuze_pqcs/pages/qc_inspection/routing_structure/numerical_question.dart';
import 'package:isuze_pqcs/pages/qc_inspection/routing_structure/others.dart';
import 'package:isuze_pqcs/pages/qc_inspection/routing_structure/single_question.dart';
import 'package:isuze_pqcs/pages/qc_inspection/routing_structure/traceable_question.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:http/http.dart' as http;

class JobCardQuestionsTemplateEOL extends StatefulWidget {
  final station_id;
  final vehicle_id;
  final shop_id;
  final categoryName;
  final shop_name;
  final chasis_no;

  const JobCardQuestionsTemplateEOL(
      {super.key,
      this.station_id,
      this.vehicle_id,
      this.shop_id,
      this.categoryName,
      required this.shop_name,
      required this.chasis_no});

  @override
  State<JobCardQuestionsTemplateEOL> createState() =>
      _JobCardQuestionsTemplateEOLState();
}

class _JobCardQuestionsTemplateEOLState
    extends State<JobCardQuestionsTemplateEOL> {
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
  Map<int, String> multipleValue = {};
  Map<int, List<dynamic>> multipleValues = {};
  Map<int, List<String>> selectedUsers = {};
  Map<int, File> images = {};
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
  void dispose() {
    EasyLoading.dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(multipleValues);
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
                  ? Center(child: SizedBox.shrink())
                  : Column(
                      children: [
                        if (Category['imageUri'].toString() !=
                                '${Api.main_url}/upload/default.jpg' &&
                            Category['imageUri'].toString() != 'null')
                          Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color:
                                  Colors.grey[200], // background while loading
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: CachedNetworkImage(
                                imageUrl: Category['imageUri'].toString(),
                                fit: BoxFit.fill,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[300],
                                  alignment: Alignment.center,
                                  child: Icon(Icons.broken_image,
                                      color: Colors.grey, size: 40),
                                ),
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
                                      // print(traceableValues);
                                    });
                                  },
                                  onValueChanged2: (value) {
                                    var qid = get['id'];
                                    setState(() {
                                      traceableSignature[qid] = value;
                                      // print(traceableSignature);
                                    });
                                  },
                                  question: get["query_name"] as String,
                                );
                              } else if (get["quiz_type"] == "multiple") {
                                return MultipleQuestion(
                                    intial_option: get["defect_names"],
                                    initialImage: question["answer"]
                                        ?["image_path"],
                                    onImageChanged: (File? image) {
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
                                    users: (get['emails'] as List<dynamic>)
                                        .map((user) {
                                      return {
                                        'name': user['name'].toString(),
                                        'email': user['email'].toString(),
                                      };
                                    }).toList(),
                                    index: index + 1,
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
                                        print(
                                            "multipleValues: $multipleValues");
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
                                        // print(numericValues);
                                      });
                                    },
                                    onValueChanged2: (value) {
                                      var qid = get['id'];
                                      setState(() {
                                        traceableSignature[qid] = value;
                                        // print(traceableSignature);
                                      });
                                    },
                                    question: get["query_name"] as String);
                              } else if (get["quiz_type"] == "single") {
                                //single
                                return SingleQuestion(
                                    initialImage: get["image_url"],
                                    onImageChanged: (File? image) {
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
                                    users: (get['emails'] as List<dynamic>)
                                        .map((user) {
                                      return {
                                        'name': user['name'].toString(),
                                        'email': user['email'].toString(),
                                      };
                                    }).toList(),
                                    initialDecripValue:
                                        get["defect_description"],
                                    hasDescription:
                                        get["additional_field"] as String,
                                    index: index + 1,
                                    id: get['id'],
                                    onValueChanged: (value) {
                                      var qid = get['id'];
                                      setState(() {
                                        singleValues[qid] = value;
                                      });
                                    },
                                    onInputValueChanged: (value) {
                                      var qid = get['id'];
                                      setState(() {
                                        DescipTextValues[qid] = value;
                                      });
                                    },
                                    onValueChanged2: (value) {
                                      var qid = get['id'];
                                      setState(() {
                                        traceableSignature[qid] = value;
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

                                      // print(singleDescipTextValues);
                                    });
                                  },
                                  onValueChanged2: (value) {
                                    var qid = get['id'];
                                    setState(() {
                                      traceableSignature[qid] = value;
                                      // print(traceableSignature);
                                    });
                                  },
                                  onRadioChanged: (value) {
                                    var qid = questions[index]['id'];
                                    setState(() {
                                      singleDescripCategory[qid] = value;
                                      // print(singleDescripCategory);
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
                                      "answer": null,
                                      "defect_description": null,
                                      "defects": null,
                                      "signature":
                                          traceableSignature[questionId],
                                      "users": selectedUsers[questionId],
                                    };

                                    if (quest["quiz_type"] == "traceable") {
                                      String? value =
                                          traceableValues[questionId];
                                      answer["answer"] = value;
                                    } else if (quest["quiz_type"] ==
                                        "multiple") {
                                      List<dynamic>? values =
                                          multipleValues[questionId];
                                      String? value = multipleValue[questionId];
                                      answer["defects"] = values;
                                      answer["answer"] = value;
                                    } else if (quest["quiz_type"] == "single") {
                                      String? value = singleValues[questionId];
                                      answer["answer"] = value;
                                      String? valueInput =
                                          DescipTextValues[questionId];

                                      answer["defect_description"] = valueInput;
                                    } else if (quest["quiz_type"] ==
                                        "numeric") {
                                      String? value = numericValues[questionId];
                                      answer["answer"] = value;
                                    } else if (quest["quiz_type"] == "others") {
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
                                  saveData(answers);
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

  Future<void> saveData(answers) async {
    if (!_formKey.currentState!.validate()) return;

    // Ensure all questions are answered
    if (answers.length != questions.length) {
      awesomeTopSnackbar(context, "Please answer all questions",
          backgroundColor: Colors.red);
      return;
    }

    setState(() => isButtonEnabled = false);
    ProgressDialog pr = ProgressDialog(context);
    pr.style(message: 'Saving answers...');
    await pr.show();

    try {
      String url = Api.api_url + "answerquery2";
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${user['data']["token"]}',
      });
      print('Posting answers: ${jsonEncode(answers)}');
      request.fields['answers'] = jsonEncode(answers);
      request.fields['vehicle_id'] = widget.vehicle_id.toString();
      request.fields['sub_station_id'] = widget.station_id.toString();

      for (var entry in images.entries) {
        request.files.add(await http.MultipartFile.fromPath(
            'images[${entry.key}]', entry.value.path));
        // print("${entry.key}, Path: ${entry.value.path}");
      }

      var response = await request.send();

      var responseData = await response.stream.bytesToString();

      var result = jsonDecode(responseData);

      log(jsonEncode(result));
      await pr.hide();
      setState(() => isButtonEnabled = true);

      if (result["success"]) {
        Navigator.pop(context);
        awesomeTopSnackbar(
            context, result["msg"] ?? "Answers Recorded Successfully",
            backgroundColor: Colors.green);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(result["msg"] ?? "Error")));
      }
    } catch (e) {
      await pr.hide();
      setState(() => isButtonEnabled = true);
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

    final url =
        "${Api.api_url}lodsubstationquiz/${widget.station_id}/${widget.vehicle_id}/${widget.shop_id}";
    print(url);
    final responseData = await httpget(url, user['data']["token"], context);
    // final responseData = await httpget(url, Api.usr, context);
    print(responseData);
    EasyLoading.dismiss(); // Dismiss once, outside branching

    if (responseData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        snackBar("Failed to fetch data", Colors.red[500]),
      );
      return;
    }

    final data = responseData["data"];
    if (data != null) {
      setState(() {
        questions = data["query"] ?? [];
        // Category = data["category"];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        snackBar(
            responseData["message"] ?? "Unexpected error", Colors.red[500]),
      );
    }
  }
}
