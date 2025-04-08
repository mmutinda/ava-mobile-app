import 'dart:convert';
import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/confirmationDialog.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/pages/home.dart';
import 'package:isuze_pqcs/pages/ShopsScrean.dart';
import 'package:isuze_pqcs/pages/qc_inspection/QcViewlistDefects.dart';
import 'package:isuze_pqcs/pages/qc_inspection/jobcard_questions_template.dart';
import 'package:isuze_pqcs/pages/qc_inspection/scheduleUnits.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class QcCategories extends StatefulWidget {
  final ShopId;
  final res;
  const QcCategories({super.key, required this.ShopId, required this.res});
  @override
  State<QcCategories> createState() => _QcCategoriesState();
}

class _QcCategoriesState extends State<QcCategories> {
  var user = {};
  var textLoading = 'No categories found';
  List categories = [];
  final List<Color> colors = [
    Colors.amber.shade900,
    Colors.indigo,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      fetchCategories(widget.ShopId);
    });
  }

  @override
  Widget build(BuildContext context) {
    print(
      widget.res['data']['vehicledata']['id'],
    );
    return Scaffold(
      floatingActionButton: SpeedDial(
        overlayOpacity: 0.1,
        animatedIcon: AnimatedIcons.menu_close,
        children: [
          SpeedDialChild(
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            child: Icon(Icons.menu_open_outlined),
            label: 'Correct Defects',
            onTap: () {
              QCDefectsPage(vehileId: widget.res['data']['vehicledata']['id'])
                  .launch(context,
                      pageRouteAnimation: PageRouteAnimation.Slide);
            },
          ),
        ],
      ),
      appBar: AppBar(
        title: Text(
          "${widget.res['data']['vehicledata']['vin_no']}",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        actions: [
          InkWell(
            onTap: () {
              fetchCategories(widget.ShopId);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.refresh),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: isLoading
                  ? Center(
                      child: Container(
                        width: double.infinity,
                        child: CustomLoader(),
                      ),
                    )
                  : message.isNotEmpty
                      ? ErrorMessageWidget(
                          errorMessage: message,
                          onRetry: () {
                            fetchCategories(widget.ShopId);
                          },
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            var category = categories[index];
                            Color categoryColor = colors[index % colors.length];
                            return GestureDetector(
                              onTap: () async {
                                // ignore: unused_local_variable
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        JobCardQuestionsTemplate(
                                      query_id: category['id'],
                                      shop_id: widget.ShopId,
                                      vehicle_id: widget.res['data']
                                          ['vehicledata']['id'],
                                      categoryName: category["category_name"],
                                    ),
                                  ),
                                ).then(
                                    (value) => fetchCategories2(widget.ShopId));
                              },
                              child: Container(
                                padding: EdgeInsets.all(12),
                                margin: const EdgeInsets.only(
                                    top: 10, left: 16, bottom: 16, right: 16),
                                decoration: boxDecoration(
                                  radius: 10,
                                  showShadow: true,
                                  bgColor: Colors.white,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        CircleAvatar(
                                          backgroundColor: mycolor,
                                          foregroundColor: textWhite,
                                          child: Text("${index + 1}"),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(category["category_name"]),
                                              Text(
                                                "(${category["query_code"]})",
                                                style: TextStyle(
                                                    color: Colors.amber[900],
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                  '${category["queryanswers"].length} out ${category["queries_count"]} Answered'),
                                            ],
                                          ),
                                        ),
                                        CircleAvatar(
                                          radius: 15,
                                          backgroundColor: categoryColor,
                                          child: Icon(
                                            Icons.arrow_forward_ios,
                                            size: 10,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
          categories.isEmpty
              ? Container()
              : isLoading2
                  ? CustomLoader()
                  : Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    datacheck == '0' ? Colors.red : mycolor,
                                shape: const RoundedRectangleBorder(),
                                foregroundColor: textWhite),
                            onPressed: () async {
                              var validate = true;
                              // for (var i = 0; i < categories.length; i++) {
                              //   var category = categories[i];
                              //   // List<dynamic> question = category["question"];

                              //   if ((category["queryanswers"].length !=
                              //       category["queries_count"].length)) {
                              //     setState(() {
                              //       validate = false;
                              //     });
                              //     break;
                              //   }
                              // }
                              // if (validate == true) {
                              if (defect_exist) {
                                if (widget.ShopId == '15' ||
                                    widget.ShopId == '16' ||
                                    widget.ShopId == '28') {
                                  // showConfirmDialog(
                                  //     context, 'Unit  will hit DRR Score!!',
                                  //     onAccept: (context) async {
                                  //   showDialog(
                                  //     context: context,
                                  //     barrierDismissible: false,
                                  //     builder: (BuildContext context) {
                                  //       return Center(
                                  //         child: CustomLoader(),
                                  //       );
                                  //     },
                                  //   );
                                  //   await saveData();
                                  // },
                                  //     positiveText: 'Push',
                                  //     negativeText: "Don't Push");
                                  CustomConfirmDialog.show(
                                    context: context,
                                    title: 'Confirm Push',
                                    message: 'Unit will hit DRR Score!!',
                                    confirmText: 'Push',
                                    cancelText: "Don't Push",
                                    icon: Icons.warning_amber_rounded,
                                    iconColor: Colors.orange,
                                    confirmColor: Colors.deepOrange,
                                    onConfirm: () async {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) =>
                                            Center(child: CustomLoader()),
                                      );
                                      await saveData();
                                      Navigator.of(context)
                                          .pop(); // dismiss loader
                                    },
                                  );
                                } else {
                                  // showConfirmDialogCustom(
                                  //     primaryColor: Colors.amber[900],
                                  //     context,
                                  //     title: 'Unit has uncorrected defects!!',
                                  //     onAccept: (context) async {
                                  //   // Navigator.pop(context);
                                  //   await saveData();
                                  // },
                                  //     positiveText: 'Push',
                                  //     negativeText: "Don't Push");
                                  CustomConfirmDialog.show(
                                    context: context,
                                    title: 'Confirm Push',
                                    message: "Unit has uncorrected defects!!",
                                    confirmText: 'Push',
                                    cancelText: "Don't Push",
                                    icon: Icons.warning_amber_rounded,
                                    iconColor: Colors.orange,
                                    confirmColor: Colors.deepOrange,
                                    onConfirm: () async {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) =>
                                            Center(child: CustomLoader()),
                                      );
                                      await saveData();
                                      Navigator.of(context)
                                          .pop(); // dismiss loader
                                    },
                                  );
                                }
                              } else {
                                CustomConfirmDialog.show(
                                  context: context,
                                  title: 'Confirm Action',
                                  message:
                                      'Do you want to push ${widget.res['data']['vehicledata']['vin_no']}?',
                                  onConfirm: () async {
                                    await saveData();
                                  },
                                );
                              }
                              // }
                              // else {
                              //   awesomeTopSnackbar(
                              //     context,
                              //     "Please answer all questions",
                              //     iconWithDecoration: BoxDecoration(
                              //       borderRadius: BorderRadius.circular(20),
                              //       border: Border.all(),
                              //       color: Colors.white,
                              //     ),
                              //     backgroundColor: Colors.red,
                              //   );
                              // }
                            },
                            child: const Text('PUSH TO THE NEXT SHOP')),
                      ),
                    )
        ],
      ),
    );
  }

  Future<void> saveData() async {
    setState(() {
      isLoading2 = true;
    });
    print(isLoading2);
    String url = Api.api_url + "moveunit";

    var payload = {
      "shop_id": widget.ShopId,
      "vehicle_id": widget.res['data']['vehicledata']['id'],
      "model_id": widget.res['data']['vehicledata']['model_id'],
      "defect_exist": defect_exist,
    };

    var response = await httppostwithtoken(
      url,
      "${user['data']['token']}",
      payload,
      context,
    );

    setState(() {
      isLoading2 = false;
    });

    if (response['success'] != null) {
      if (response['success']) {
        // ShopsScrean().launch(context, isNewTask: true,);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ShopsScrean()),
          (route) => route
              .isFirst, // Keeps only the first route (Home screen) in the stack
        );
        awesomeTopSnackbar(
          context,
          "${response["msg"]}",
          iconWithDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(),
            color: Colors.white,
          ),
          backgroundColor: Colors.green,
        );
      } else {
        awesomeTopSnackbar(
          context,
          "${response["msg"]}",
          iconWithDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(),
            color: Colors.white,
          ),
          backgroundColor: Colors.red,
        );
      }
    }
  }

  Future finalizeRouting(vehicleId) async {
    String url = "${Api.api_url}${"apiCloseFabricationQc"}";
    print(url);
    var payload = {"project_id": vehicleId};
    var response =
        await httppostwithtoken(url, user["token"], payload, context);
    return response;
  }

  bool isLoading = false;
  bool isLoading2 = false;
  String message = '';
  String datacheck = '';
  late bool defect_exist;

  Future fetchCategories(id) async {
    setState(() {
      message = '';
      isLoading = true;
    });
    ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, showLogs: true, isDismissible: true);

    // pr.show();
    String url =
        "${Api.api_url}${"quizcategory"}/${widget.ShopId}/${widget.res['data']['vehicledata']['model_id']}/${widget.res['data']['vehicledata']['id']}";
    print(url);
    var responsedata = await httpget(url, user['data']["token"], context);
    if (responsedata != null) {
      if (responsedata["data"] != null) {
        pr.hide().whenComplete(() {
          setState(() {
            categories = responsedata['data']["category"];
            datacheck = responsedata['data']['datacheck'].toString();
            defect_exist = responsedata['data']['defect_exist'];
            isLoading = false;
            isLoading2 = false;
            message = '';
          });
        });
      } else {
        pr.hide().whenComplete(() {
          setState(() {
            isLoading = false;
            message = '${responsedata["message"]}';
          });
        });
      }
    }
  }

  Future fetchCategories2(id) async {
    ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, showLogs: true, isDismissible: true);

    // pr.show();
    String url =
        "${Api.api_url}${"quizcategory"}/${widget.ShopId}/${widget.res['data']['vehicledata']['model_id']}/${widget.res['data']['vehicledata']['id']}";
    print(url);
    var responsedata = await httpget(url, user['data']["token"], context);
    if (responsedata != null) {
      if (responsedata["data"] != null) {
        pr.hide().whenComplete(() {
          setState(() {
            categories = responsedata['data']["category"];
            datacheck = responsedata['data']['datacheck'].toString();
            defect_exist = responsedata['data']['defect_exist'];
            isLoading = false;
            isLoading2 = false;
            message = '';
          });
        });
      } else {
        pr.hide().whenComplete(() {});
      }
    }
  }
}
