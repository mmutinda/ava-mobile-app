import 'dart:convert';

import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/models/qc_inpection.dart';
import 'package:isuze_pqcs/pages/planning/EOL/jobcard_questions_template_EOL.dart';
import 'package:isuze_pqcs/pages/planning/offlining/GCP.dart';
import 'package:isuze_pqcs/pages/planning/offlining/offliningbaypage.dart';
import 'package:isuze_pqcs/pages/qc_inspection/qcCategoryQuestions.dart';
import 'package:isuze_pqcs/scanning.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class Scanning extends StatefulWidget {
  final shopName;
  final shopId;
  final subStationId;

  const Scanning(
      {super.key,
      required this.shopName,
      required this.shopId,
      this.subStationId});
  @override
  _ScanningState createState() => _ScanningState();
}

class _ScanningState extends State<Scanning> {
  final List<Color> colors = [
    Colors.amber.shade900,
    Colors.indigo,
    Colors.teal,
  ];
  List<Vehicle2> vehicles = []; // List to hold vehicles fetched from API
  var user = {};
  bool isLoading = false;
  String message = '';
  String? data;

  @override
  void initState() {
    super.initState();

    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      fetchData();
    });

    // fetchData(); // Fetch data when the page is initialized
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      message = '';
    });
    var url = widget.shopId == "11"
        ? "${Api.api_url}loadUnitsInSubstation/${widget.subStationId}"
        : "${Api.api_url}unitsinshop/${widget.shopId}";
    print(url);

    try {
      var response = await httpget(url, user['data']['token'], context);
      log(jsonEncode(response));
      if (response == null) {
        print("No Internet");
        // Handle no internet scenario
        return;
      }

      if (response['success'] && response['data'] != null) {
        List<dynamic> responseData = response['data'];

        List<Vehicle2> fetchedVehicles = responseData.map((vehicleData) {
          return Vehicle2.fromJson(vehicleData);
        }).toList();

        setState(() {
          vehicles = fetchedVehicles;
          isLoading = false;
          message = '';
        });
        if (vehicles.isEmpty) {
          setState(() {
            message = "No Units Found";
          });
        }
      } else {
        // Handle other scenarios
        setState(() {
          isLoading = false;
          message = '${response['msg']}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        message = 'Network Problem';
      });
      // message = '${"Network Problem"}';
      print('Error fetching data: $e');
    }
  }

  Future fetchproduct(sku) async {
    String url = "${Api.api_url}checkunitshop/$sku/${widget.shopId}";
    print(url);
    var response = await httpget(url, user['data']['token'], context);
    // log(jsonEncode(response));
    return response;
  }

  Future<void> processSKU(String sku) async {
    ProgressDialog pr = ProgressDialog(
      context,
      type: ProgressDialogType.normal,
      isDismissible: false,
      showLogs: true,
    );

    pr.style(
      borderRadius: 8,
      backgroundColor: Colors.white,
      progressWidget: const SizedBox(
        width: 20,
        height: 20,
        child: Center(child: CircularProgressIndicator()),
      ),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
    );

    // pr.show();
    EasyLoading.show(
        status: "Loading Categories...", maskType: EasyLoadingMaskType.black);

    try {
      final res = await fetchproduct(sku);

      EasyLoading.dismiss().whenComplete(() {
        if (res == null || res["data"] == null) {
          awesomeTopSnackbar(
            context,
            "${res?["msg"] ?? "Item not found"}",
            iconWithDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(),
              color: Colors.white,
            ),
            icon: const Icon(Icons.close, color: Colors.red),
          );
          return;
        }
        if (widget.shopId == '2046') {
          OffliningBayPage(
            ShopId: widget.shopId,
            res: res,
            shop_name: widget.shopName,
          ).launch(
            context,
            pageRouteAnimation: PageRouteAnimation.Slide,
          );
          return;
        }
        if (widget.shopId == '2047') {
          SummaryGCP(
            ageing: res['data']['vehicledata']['vin_no'].toString(),
            chassis: res['data']['vehicledata']['vin_no'].toString(),
            model: res['data']['vehicledata']['model']['model_name'].toString(),
            unit_movement_id: res['data']['unit_movement_id'].toString(),
          ).launch(
            context,
            pageRouteAnimation: PageRouteAnimation.Slide,
          );
          return;
        }
        if (widget.shopId == '11') {
          JobCardQuestionsTemplateEOL(
            chasis_no: res['data']['vehicledata']['vin_no'],
            shop_name: 'EOL station',
            station_id: widget.subStationId,
            shop_id: widget.shopId,
            vehicle_id: res['data']['vehicledata']['id'],
            categoryName: widget.shopName,
          ).launch(
            context,
            pageRouteAnimation: PageRouteAnimation.Slide,
          );
        } else if (res["data"]['unitcheck'] == false) {
          showInDialog(
            context,
            builder: (context) => showPosition(
              errorMessage: res["data"]['currentposion'].toString(),
            ),
            dialogAnimation: DialogAnimation.SLIDE_TOP_BOTTOM,
          );
        } else {
          QcCategories(
            ShopId: widget.shopId,
            res: res,
            shop_name: widget.shopName,
          ).launch(
            context,
            pageRouteAnimation: PageRouteAnimation.Slide,
          );
        }
      });
    } catch (e) {
      // pr.hide();
      EasyLoading.dismiss();
      awesomeTopSnackbar(
        context,
        "Something went wrong",
        iconWithDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(),
          color: Colors.white,
        ),
        icon: const Icon(Icons.close, color: Colors.red),
        backgroundColor: Colors.red[900],
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  TextEditingController searchController = TextEditingController();
  String searchText = '';
  bool _isSearching = false;

  @override
  void dispose() {
    if (isLoading) {
      EasyLoading.dismiss(); // Dismiss loading when navigating away
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: Text(
          '${widget.shopName}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Container(
        child: isLoading
            ? Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
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
                        'Loading units...',
                        style: TextStyle(
                          color: mycolor,
                          fontWeight: FontWeight.w600,
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
                      fetchData();
                    },
                  )
                : Column(
                    children: [
                      if (widget.shopId == '2047')
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 15),
                          margin: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                mycolor.withOpacity(0.1),
                                Colors.amber.shade50
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: mycolor.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.info_outline, color: Colors.amber),
                              SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Model & Chassis',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'Ageing',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (widget.shopId == '2047')
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: ListView.separated(
                              itemCount: vehicles.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final car = vehicles[index];
                                return GestureDetector(
                                  onTap: () {
                                    processSKU(car.vin);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: mycolor.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                          spreadRadius: 1,
                                        ),
                                      ],
                                      border: Border.all(
                                        color: mycolor.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                mycolor,
                                                Colors.amber.shade700
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.directions_car,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                vehicles[index].model,
                                                style: TextStyle(
                                                  color: mycolor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  car.vin,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey.shade700,
                                                    fontFamily: 'monospace',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                              horizontal: 16,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  mycolor,
                                                  Colors.amber.shade700
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color:
                                                      mycolor.withOpacity(0.3),
                                                  blurRadius: 4,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              car.ageing,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      if (widget.shopId != '2047')
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: ListView.builder(
                              itemCount: vehicles.length,
                              itemBuilder: (context, index) {
                                // ignore: unused_local_variable
                                Color categoryColor =
                                    colors[index % colors.length];
                                var vin = vehicles[index].vin;
                                var model = vehicles[index].model;
                                // ignore: unused_local_variabl
                                if (searchText.isNotEmpty &&
                                    !(vin.toLowerCase().contains(
                                            searchText.toLowerCase()) ||
                                        model.toLowerCase().contains(
                                            searchText.toLowerCase()))) {
                                  return Container(); // Return an empty container if not matching
                                }
                                return Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: categoryColor.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                        spreadRadius: 1,
                                      ),
                                    ],
                                    border: Border.all(
                                      color: categoryColor.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: ListTile(
                                    onTap: () {
                                      processSKU(vehicles[index].vin);
                                      // showTapScanToast(context);
                                    },
                                    contentPadding: EdgeInsets.all(16),
                                    leading: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            categoryColor,
                                            categoryColor.withOpacity(0.7)
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                categoryColor.withOpacity(0.3),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
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
                                    title: Row(
                                      children: [
                                        Icon(Icons.directions_car,
                                            color: categoryColor, size: 20),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            vehicles[index].model,
                                            style: TextStyle(
                                              color: categoryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'VIN: ${vehicles[index].vin}',
                                              style: TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 13,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: categoryColor
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  'LOT: ${vehicles[index].lot}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: categoryColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              if (vehicles[index].job !=
                                                      'null' &&
                                                  vehicles[index]
                                                      .job
                                                      .isNotEmpty) ...[
                                                SizedBox(width: 8),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.amber
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    'JOB: ${vehicles[index].job}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.amber.shade800,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    trailing: Icon(
                                      Icons.qr_code_scanner,
                                      color: categoryColor,
                                      size: 28,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      Container(
                        margin: const EdgeInsets.all(20),
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
                              showInDialog(context,
                                      contentPadding: EdgeInsets.all(0),
                                      builder: (context) => QRScanDialog(),
                                      dialogAnimation: DialogAnimation.SCALE)
                                  .then((value) {
                                print(value);
                                if (value != null) {
                                  // fetchData();
                                  EasyLoading.show(
                                      status: "Loading Categories...",
                                      maskType: EasyLoadingMaskType.black);

                                  fetchproduct(value).then((res) {
                                    EasyLoading.dismiss().whenComplete(() {
                                      res == null
                                          ? null
                                          : res["data"] == null
                                              ? awesomeTopSnackbar(
                                                  context,
                                                  "${res["msg"]}",
                                                  iconWithDecoration:
                                                      BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                          border: Border.all(),
                                                          color: Colors.white),
                                                  icon: Icon(
                                                    Icons.close,
                                                    color: Colors.red,
                                                  ),
                                                )
                                              : widget.shopId == '2046'
                                                  ? OffliningBayPage(
                                                      ShopId: widget.shopId,
                                                      res: res,
                                                      shop_name:
                                                          widget.shopName,
                                                    ).launch(
                                                      context,
                                                      pageRouteAnimation:
                                                          PageRouteAnimation
                                                              .Slide,
                                                    )
                                                  : widget.shopId == '2047'
                                                      ? SummaryGCP(
                                                          ageing: res['data'][
                                                                  'vehicledata']
                                                              ['vin_no'],
                                                          chassis: res['data'][
                                                                  'vehicledata']
                                                              ['chassis_no'],
                                                          model: res['data'][
                                                                  'vehicledata']
                                                              ['model'],
                                                          unit_movement_id: res[
                                                                      'data'][
                                                                  'unit_movement_id']
                                                              .toString(),
                                                        ).launch(
                                                          context,
                                                          pageRouteAnimation:
                                                              PageRouteAnimation
                                                                  .Slide,
                                                        )
                                                      : widget.shopId == '11'
                                                          ? JobCardQuestionsTemplateEOL(
                                                              chasis_no: res[
                                                                          'data']
                                                                      [
                                                                      'vehicledata']
                                                                  ['vin_no'],
                                                              shop_name:
                                                                  'EOL station',
                                                              station_id: widget
                                                                  .subStationId,
                                                              shop_id:
                                                                  widget.shopId,
                                                              vehicle_id: res[
                                                                          'data']
                                                                      [
                                                                      'vehicledata']
                                                                  ['id'],
                                                              categoryName:
                                                                  widget
                                                                      .shopName,
                                                            ).launch(
                                                              context,
                                                              pageRouteAnimation:
                                                                  PageRouteAnimation
                                                                      .Slide,
                                                            )
                                                          : res["data"][
                                                                      'unitcheck'] ==
                                                                  false
                                                              ? showInDialog(
                                                                  context,
                                                                  builder: (context) => showPosition(
                                                                      errorMessage:
                                                                          res["data"]['currentposion']
                                                                              .toString()),
                                                                  dialogAnimation:
                                                                      DialogAnimation
                                                                          .SLIDE_TOP_BOTTOM)
                                                              : QcCategories(
                                                                  ShopId: widget
                                                                      .shopId,
                                                                  res: res,
                                                                  shop_name: widget
                                                                      .shopName,
                                                                ).launch(
                                                                  context,
                                                                  pageRouteAnimation:
                                                                      PageRouteAnimation
                                                                          .Slide);
                                    });
                                  });
                                }
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.qr_code_scanner,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'SCAN QR CODE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
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
      ),
    );
  }

  void showTapScanToast(BuildContext context) {
    toasty(
      context,
      "Tap Scan below 👇",
      bgColor: mycolor,
      textColor: Colors.white,
      length: Toast.LENGTH_SHORT,
    );
  }
}
