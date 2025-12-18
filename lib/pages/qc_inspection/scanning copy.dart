import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/models/qc_inpection.dart';
import 'package:isuze_pqcs/pages/Rework/ReworkList.dart';
import 'package:isuze_pqcs/pages/planning/offlining/GCP.dart';
import 'package:isuze_pqcs/pages/planning/offlining/offliningbaypage.dart';
import 'package:isuze_pqcs/pages/qc_inspection/jobcard_questions_template.dart';
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
    var url = widget.shopId == "17"
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
    log(jsonEncode(response));
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
          // Check if it's a NotFoundHttpException (invalid barcode)
          String errorMessage = "Item not found";
          if (res != null &&
              res["exception"] != null &&
              res["exception"].toString().contains("NotFoundHttpException")) {
            errorMessage = "Invalid barcode";
          } else if (res != null &&
              res["msg"] != null &&
              res["msg"].toString().isNotEmpty) {
            errorMessage = res["msg"].toString();
          }

          awesomeTopSnackbar(
            context,
            errorMessage,
            iconWithDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(),
              color: Colors.white,
            ),
            icon: const Icon(Icons.close, color: Colors.red),
          );
          return;
        }
        if (widget.shopId == '16') {
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
        if (widget.shopId == '18') {
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
        if (widget.shopId == '19') {
          ReworkList(
            unit_movement_id: res['data']['unit_movement_id'].toString(),
            vehicle_id: res['data']['vehicledata']['id'].toString(),
          ).launch(
            context,
            pageRouteAnimation: PageRouteAnimation.Slide,
          );
          return;
        }
        if (widget.shopId == '17') {
          JobCardQuestionsTemplate(
            lotNo: res['data']['vehicledata']['lot_no'],
            chasis_no: res['data']['vehicledata']['vin_no'],
            shop_name: 'EOL station',
            station_id: widget.subStationId,
            shop_id: widget.shopId,
            vehicle_id: res['data']['vehicledata']['id'],
            categoryName: widget.shopName,
            vehicle_receiving_item: res['data']['vehicledata']
                ['vehicle_receiving_item'],
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

  String _formatTimeAgo(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return 'Unknown';

    try {
      final DateTime createdDate = DateTime.parse(createdAt);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(createdDate);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

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
                child: CustomLoader(),
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
                      if (widget.shopId == '18')
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
                      if (widget.shopId == '18')
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ListView.separated(
                              itemCount: vehicles.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final car = vehicles[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: mycolor.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () {
                                        // showTapScanToast(context);
                                        processSKU(car.vin);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            // Car icon container
                                            Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.directions_car_rounded,
                                                color: Colors.white,
                                                size: 26,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // Model and VIN info
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade50,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                        color: Colors
                                                            .grey.shade200,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .confirmation_number_outlined,
                                                          size: 12,
                                                          color: Colors
                                                              .grey.shade600,
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Expanded(
                                                          child: Text(
                                                            car.vin,
                                                            style: TextStyle(
                                                              fontSize: 17,
                                                              color: Colors.grey
                                                                  .shade700,
                                                              fontFamily:
                                                                  'monospace',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 6,
                                                            vertical: 2,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.blue
                                                                .withOpacity(
                                                                    0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                            border: Border.all(
                                                              color: Colors.blue
                                                                  .withOpacity(
                                                                      0.3),
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child: Text(
                                                            _formatTimeAgo(
                                                                car.created_at),
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 10,
                                                              color:
                                                                  Colors.blue,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            // Ageing badge
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 8,
                                                horizontal: 12,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: mycolor
                                                        .withOpacity(0.25),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                children: [
                                                  const Icon(
                                                    Icons.schedule,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    car.ageing,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      if (widget.shopId != '18')
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ListView.separated(
                              itemCount: vehicles.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                Color categoryColor =
                                    colors[index % colors.length];
                                var vin = vehicles[index].vin;
                                var model = vehicles[index].model;

                                if (searchText.isNotEmpty &&
                                    !(vin.toLowerCase().contains(
                                            searchText.toLowerCase()) ||
                                        model.toLowerCase().contains(
                                            searchText.toLowerCase()))) {
                                  return const SizedBox.shrink();
                                }

                                return Card(
                                  color: Colors.white,
                                  // decoration: BoxDecoration(
                                  //   color: Colors.white,
                                  //   borderRadius: BorderRadius.circular(16),
                                  //   // border: Border.all(
                                  //   //   color: categoryColor.withOpacity(0.2),
                                  //   // ),
                                  // ),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () {
                                        if (widget.shopId == '16') {
                                          processSKU(vehicles[index].vin);
                                        } else {
                                          processSKU(vehicles[index].vin);
                                          showTapScanToast(context);
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            // Leading number container
                                            Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    mycolor,
                                                    mycolor.withOpacity(0.8)
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: categoryColor
                                                        .withOpacity(0.3),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "${index + 1}",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // Content
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Model with icon
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .directions_car_rounded,
                                                        color: mycolor,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Expanded(
                                                        child: Text(
                                                          vehicles[index].model,
                                                          style: TextStyle(
                                                            color: mycolor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  // VIN container
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade50,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                        color: Colors
                                                            .grey.shade200,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .confirmation_number_outlined,
                                                          size: 14,
                                                          color: Colors
                                                              .grey.shade600,
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Expanded(
                                                          child: Text(
                                                            'VIN: ${vehicles[index].vin}',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'monospace',
                                                              fontSize: 12,
                                                              color: Colors.grey
                                                                  .shade700,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  // LOT container
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 3),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          mycolor
                                                              .withOpacity(0.1),
                                                          mycolor.withOpacity(
                                                              0.05),
                                                        ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      border: Border.all(
                                                        color: mycolor
                                                            .withOpacity(0.3),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .inventory_2_outlined,
                                                          size: 12,
                                                          color: mycolor,
                                                        ),
                                                        const SizedBox(
                                                            width: 3),
                                                        Text(
                                                          'LOT: ${vehicles[index].lot}',
                                                          style: TextStyle(
                                                            fontSize: 17,
                                                            color: mycolor,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 6,
                                                            vertical: 2,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.blue
                                                                .withOpacity(
                                                                    0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                            border: Border.all(
                                                              color: Colors.blue
                                                                  .withOpacity(
                                                                      0.3),
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child: Text(
                                                            _formatTimeAgo(
                                                                vehicles[index]
                                                                    .created_at),
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 10,
                                                              color:
                                                                  Colors.blue,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Trailing QR icon
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: mycolor.withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Icon(
                                                Icons.qr_code_scanner_rounded,
                                                color: mycolor,
                                                size: 24,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      if (widget.shopId != '16')
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
                                        if (res == null ||
                                            res["data"] == null) {
                                          // Check if it's a NotFoundHttpException (invalid barcode)
                                          String errorMessage =
                                              "Item not found";
                                          if (res != null &&
                                              res["exception"] != null &&
                                              res["exception"]
                                                  .toString()
                                                  .contains(
                                                      "NotFoundHttpException")) {
                                            errorMessage = "Invalid barcode";
                                          } else if (res != null &&
                                              res["msg"] != null &&
                                              res["msg"]
                                                  .toString()
                                                  .isNotEmpty) {
                                            errorMessage =
                                                res["msg"].toString();
                                          }

                                          awesomeTopSnackbar(
                                            context,
                                            errorMessage,
                                            iconWithDecoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(),
                                                color: Colors.white),
                                            icon: Icon(
                                              Icons.close,
                                              color: Colors.red,
                                            ),
                                          );
                                        } else {
                                          if (widget.shopId == '18') {
                                            SummaryGCP(
                                              ageing: res['data']['vehicledata']
                                                  ['vin_no'],
                                              chassis: res['data']
                                                  ['vehicledata']['chassis_no'],
                                              model: res['data']['vehicledata']
                                                  ['model'],
                                              unit_movement_id: res['data']
                                                      ['unit_movement_id']
                                                  .toString(),
                                            ).launch(
                                              context,
                                              pageRouteAnimation:
                                                  PageRouteAnimation.Slide,
                                            );
                                            return;
                                          }
                                          if (widget.shopId == '19') {
                                            ReworkList(
                                                    unit_movement_id: res[
                                                                'data']
                                                            ['unit_movement_id']
                                                        .toString(),
                                                    vehicle_id: res['data']
                                                        ['vehicledata']['id'])
                                                .launch(
                                              context,
                                              pageRouteAnimation:
                                                  PageRouteAnimation.Slide,
                                            );
                                            return;
                                          } else if (widget.shopId == '17') {
                                            JobCardQuestionsTemplate(
                                              lotNo: res['data']['vehicledata']
                                                  ['lot_no'],
                                              chasis_no: res['data']
                                                  ['vehicledata']['vin_no'],
                                              shop_name: 'EOL station',
                                              station_id: widget.subStationId,
                                              shop_id: widget.shopId,
                                              vehicle_id: res['data']
                                                  ['vehicledata']['id'],
                                              categoryName: widget.shopName,
                                              vehicle_receiving_item: res[
                                                      'data']['vehicledata']
                                                  ['vehicle_receiving_item'],
                                            ).launch(
                                              context,
                                              pageRouteAnimation:
                                                  PageRouteAnimation.Slide,
                                            );
                                            return;
                                          } else if (res["data"]['unitcheck'] ==
                                              false) {
                                            showInDialog(context,
                                                builder: (context) =>
                                                    showPosition(
                                                        errorMessage: res[
                                                                    "data"][
                                                                'currentposion']
                                                            .toString()),
                                                dialogAnimation: DialogAnimation
                                                    .SLIDE_TOP_BOTTOM);
                                          } else {
                                            QcCategories(
                                              ShopId: widget.shopId,
                                              res: res,
                                              shop_name: widget.shopName,
                                            ).launch(context,
                                                pageRouteAnimation:
                                                    PageRouteAnimation.Slide);
                                          }
                                        }
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
