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
import 'package:isuze_pqcs/pages/assembly/assembly_stations.dart';
import 'package:isuze_pqcs/pages/qc_inspection/QcViewlistDefects.dart';
import 'package:isuze_pqcs/pages/qc_inspection/jobcard_questions_template.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class QcCategories extends StatefulWidget {
  final ShopId;
  final shop_name;
  final res;
  const QcCategories(
      {super.key,
      required this.ShopId,
      required this.res,
      required this.shop_name});
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
      floatingActionButton: !defect_exist
          ? null
          : SpeedDial(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              overlayColor: Colors.black,
              overlayOpacity: 0.4,
              animatedIcon: AnimatedIcons.menu_close,
              spacing: 15,
              spaceBetweenChildren: 10,
              elevation: 12,
              buttonSize: Size(60, 60),
              children: [
                SpeedDialChild(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                  labelBackgroundColor: Colors.white,
                  child: Icon(Icons.check_circle_outline, size: 24),
                  label: 'Correct Defects',
                  onTap: () {
                    QCDefectsPage(
                      vehileId: widget.res['data']['vehicledata']['id'],
                    )
                        .launch(context,
                            pageRouteAnimation: PageRouteAnimation.Slide)
                        .then((val) {
                      fetchCategories2(widget.ShopId);
                    });
                  },
                ),
              ],
            ),
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assessment, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.shop_name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.res['data']['vehicledata']['vin_no'],
                  textAlign: TextAlign.center,
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
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
            child: IconButton(
              onPressed: () {
                fetchCategories(widget.ShopId);
              },
              icon: Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Refresh Categories',
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: isLoading & categories.isEmpty
                    ? Center(
                        child: Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomLoader(),
                              SizedBox(height: 16),
                              Text(
                                'Loading categories...',
                                style: TextStyle(
                                  color: mycolor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
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
                              Color categoryColor =
                                  colors[index % colors.length];
                              return GestureDetector(
                                onTap: () async {
                                  // ignore: unused_local_variable
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          JobCardQuestionsTemplate(
                                        lotNo: widget.res['data']['vehicledata']
                                            ['lot_no'],
                                        vehicle_receiving_item:
                                            widget.res['data']['vehicledata']
                                                ['vehicle_receiving_item'],
                                        chasis_no: widget.res['data']
                                            ['vehicledata']['vin_no'],
                                        shop_name: widget.shop_name,
                                        query_id: category['id'],
                                        shop_id: widget.ShopId,
                                        vehicle_id: widget.res['data']
                                            ['vehicledata']['id'],
                                        categoryName: category["category_name"],
                                      ),
                                    ),
                                  ).then((value) =>
                                      fetchCategories2(widget.ShopId));
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: mycolor.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    mycolor,
                                                    mycolor.withOpacity(0.8),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: mycolor
                                                        .withOpacity(0.3),
                                                    blurRadius: 6,
                                                    offset: Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "${index + 1}",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    category["category_name"],
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: categoryColor
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Text(
                                                      "(${category["query_code"]})",
                                                      style: TextStyle(
                                                        color: categoryColor,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.quiz_outlined,
                                                        size: 16,
                                                        color: Colors
                                                            .grey.shade600,
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        '${category["queryanswers"].length} of ${category["queries_count"]} answered',
                                                        style: TextStyle(
                                                          color: Colors
                                                              .grey.shade600,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: categoryColor
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Icon(
                                                Icons.arrow_forward_ios,
                                                size: 16,
                                                color: categoryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
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
                    ? Container(
                        padding: EdgeInsets.all(20),
                        child: CustomLoader(),
                      )
                    : Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: datacheck == '0'
                                ? [Colors.red.shade600, Colors.red.shade800]
                                : [
                                    mycolor,
                                    mycolor,
                                  ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (datacheck == '0' ? Colors.red : mycolor)
                                  .withOpacity(0.3),
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
                              if (defect_exist) {
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
                                    // showDialog(
                                    //   context: context,
                                    //   barrierDismissible: false,
                                    //   builder: (BuildContext context) =>
                                    //       Center(child: CustomLoader()),
                                    // );
                                    await saveData();
                                    // Navigator.of(context)
                                    //     .pop(); // dismiss loader
                                  },
                                );
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
                            },
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'PUSH TO THE NEXT SHOP',
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
          ],
        ),
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
    log(jsonEncode(response));
    setState(() {
      isLoading2 = false;
    });

    if (response['success'] != null) {
      if (response['success']) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AssemblyStations()),
          (route) =>
              route.isFirst, // This skeeps only the first route (HomePage)
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
  bool defect_exist = false;
  Future<void> fetchCategories(id) async {
    setState(() {
      message = '';
      isLoading = true;
      isLoading2 = true;
    });

    final url =
        "${Api.api_url}quizcategory/${widget.ShopId}/${widget.res['data']['vehicledata']['model_id']}/${widget.res['data']['vehicledata']['id']}";
    print(url);

    final responsedata = await httpget(url, user['data']["token"], context);

    if (responsedata == null) {
      setState(() {
        message = 'Failed to load data.';
        isLoading = false;
        isLoading2 = false;
      });
      return;
    }

    final data = responsedata['data'];
    if (data != null) {
      final fetchedCategories = data["category"] ?? [];

      setState(() {
        categories = fetchedCategories;
        datacheck = data['datacheck'].toString();
        defect_exist = data['defect_exist'];
        isLoading = false;
        isLoading2 = false;
        message = fetchedCategories.isEmpty ? 'No categories found' : '';
      });
    } else {
      setState(() {
        message = responsedata["message"] ?? 'Unknown error occurred';
        isLoading = false;
        isLoading2 = false;
      });
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
