import 'dart:convert';
import 'dart:developer';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/pages/qc_inspection/jobcard_questions_template.dart';
import 'package:isuze_pqcs/pages/qc_inspection/scheduleUnits.dart';

import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

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
    // print(widget.res);
    return Scaffold(
      floatingActionButton: SpeedDial(
        // overlayColor: Colors.transparent,
        overlayOpacity: 0.1,
        animatedIcon: AnimatedIcons.menu_close,
        children: [
          SpeedDialChild(
            child: Icon(Icons.check),
            label: 'Correct Defects',
            onTap: () {
              // Add your action here
              print('Add button pressed');
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
                        child: FacebookLikeShimmer(),
                      ),
                    )
                  : message.isNotEmpty
                      ? ErrorMessageWidget(
                          errorMessage: message,
                          onRetry: () {
                            fetchCategories(widget.ShopId);
                          },
                        ) // Show message for success or failure
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            var category = categories[index];
                            // List<dynamic> question = category["question"];
                            Color categoryColor = colors[index % colors.length];
                            // print("+++");
                            // print(category['queries_count']);
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
                                    (value) => fetchCategories(widget.ShopId));
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
                                // padding: const EdgeInsets.all(16),
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
                                              // Text(
                                              //     '${category["answers_count"]} out ${question.isEmpty ? 0 : question[0]["questionitems_count"]} Answered'),
                                              Text(
                                                  '${category["queryanswers"].length} out ${category["queries_count"]} Answered'),
                                            ],
                                          ),
                                        ),
                                        CircleAvatar(
                                          radius: 15,
                                          backgroundColor:
                                              categoryColor, // Use the category color here
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
              : Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                        icon: Icon(Icons.save),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: mycolor,
                            shape: const RoundedRectangleBorder(),
                            foregroundColor: textWhite),
                        onPressed: () async {
                          await saveData(categories);
                          print("object");
                        },
                        label: const Text('Save Data')),
                  ),
                )
        ],
      ),
    );
  }

  Future saveData(categories) async {
    var validate = true;
    for (var i = 0; i < categories.length; i++) {
      var category = categories[i];

      List<dynamic> question = category["question"];
      if ((category["answers_count"] != question[0]["questionitems_count"]) &&
          (question[0]["questionitems_count"] != 0)) {
        setState(() {
          validate = false;
        });

        break;
      }
    }
    if (validate == true) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Align(
                alignment: Alignment.center,
                child: const Text('Finalize Routing'),
              ),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              content: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          final ProgressDialog progressDialog =
                              ProgressDialog(context);
                          progressDialog.style(
                            message: 'Finalizing routing...',
                            child: CustomLoader(),
                            progressWidget: CircularProgressIndicator(),
                          );
                          await progressDialog.show();

                          try {
                            String url = Api.api_url + "apiCloseFabricationQc";
                            var payload = {"project_id": widget.ShopId};
                            print(payload);
                            print(url);
                            var response = await httppostwithtoken(
                                url, user["token"], payload, context);
                            log(jsonEncode(response['msg']));
                            if (response['success']) {
                              Navigator.pop(context);
                              print("done");
                              showTopSnackBar(
                                Overlay.of(context),
                                CustomSnackBar.info(
                                  message: "${response['msg']}",
                                ),
                              );
                            } else {
                              Navigator.pop(context);
                              print("done");
                              showTopSnackBar(
                                Overlay.of(context),
                                CustomSnackBar.error(
                                  message: "${response['msg']}",
                                ),
                              );
                            }
                            return response;
                          } catch (e) {
                            print("error : $e");
                          } finally {
                            await progressDialog.hide();
                          }
                          // ProgressDialog pr = ProgressDialog(context,
                          //     type: ProgressDialogType.normal,
                          //     isDismissible: false,
                          //     showLogs: true);
                          // pr.style(
                          //   message: 'Finalizing routing...',
                          //   borderRadius: 8,
                          //   backgroundColor: Colors.white,
                          //   progressWidget: const SizedBox(
                          //       width: 20,
                          //       height: 20,
                          //       child:
                          //           Center(child: CircularProgressIndicator())),
                          //   elevation: 10.0,
                          //   insetAnimCurve: Curves.easeInOut,
                          // );

                          // pr.show();
                          // finalizeRouting(widget.VehicleId).then((res) {
                          //   pr
                          //       .hide()
                          //       .then((value) => ScaffoldMessenger.of(context)
                          //           .showSnackBar(
                          //               snackBar(res["message"], Colors.grey)))
                          //       .then((value) {
                          //     print("ok");
                          //     Navigator.of(context).pop();
                          //   });
                          // });

                          // Future.delayed(
                          //     const Duration(seconds: dismissseconds), () {
                          //   if (pr.isShowing()) {
                          //     pr.hide();
                          //     ScaffoldMessenger.of(context).showSnackBar(
                          //         snackBar(internetmessage, snackred));
                          //   }
                          // });
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            foregroundColor: textWhite),
                        child: const Text('Complete routing')),
                  ],
                ),
              ),
            );
          }).then((value) {
        Navigator.of(context).pop(true);
      });
    } else {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Failed!',
        desc: 'Please Answer All Categories Above',
        btnOkColor: mycolor,
        btnOkOnPress: () {},
      )..show();
    }
  }

  Future finalizeRouting(vehicleId) async {
    String url = "${Api.api_url}${"apiCloseFabricationQc"}";
    print(url);
    var payload = {"project_id": vehicleId};
    var response =
        await httppostwithtoken(url, user["token"], payload, context);
    // print(payload);
    // log(jsonEncode(response));
    return response;
  }

  bool isLoading = false;
  String message = '';
  Future fetchCategories(id) async {
    setState(() {
      isLoading = true;
    });
    ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, showLogs: true, isDismissible: true);

    pr.show();
    String url =
        "${Api.api_url}${"quizcategory"}/${widget.ShopId}/${widget.res['data']['vehicledata']['model_id']}/${widget.res['data']['vehicledata']['id']}";
    print(url);
    var responsedata = await httpget(url, user['data']["token"], context);
    // print(responsedata);
    log(jsonEncode(responsedata));
    if (responsedata != null) {
      if (responsedata["data"] != null) {
        pr.hide().whenComplete(() {
          setState(() {
            // categories = responsedata["category"]["routingitems"];
            categories = responsedata['data']["category"];
            isLoading = false;
            message = '';
          });
        });
      } else {
        pr.hide().whenComplete(() {
          setState(() {
            isLoading = false;
            message = '${responsedata["message"]}';
          });
          // ScaffoldMessenger.of(context)
          //     .showSnackBar(snackBar(responsedata["message"], Colors.red[500]));
        });
      }
    }
    // Dismiss the progress dialog after a few seconds
  }
}
