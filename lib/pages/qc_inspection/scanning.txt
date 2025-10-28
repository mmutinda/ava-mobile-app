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
import 'package:isuze_pqcs/pages/planning/offlining/GCP.dart';
import 'package:isuze_pqcs/pages/planning/offlining/offliningbaypage.dart';
import 'package:isuze_pqcs/pages/qc_inspection/jobcard_questions_template.dart';
import 'package:isuze_pqcs/pages/qc_inspection/qcCategoryQuestions.dart';
import 'package:isuze_pqcs/pages/planning/scheduleUnits.dart';
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
        if (widget.shopId == '17') {
          JobCardQuestionsTemplate(
            vehicle_receiving_item: res['data']['vehicledata']
                ['vehicle_receiving_item'],
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
    Widget _buildSearchField() {
      return TextField(
        autofocus: true,
        style: TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        controller: searchController,
        onChanged: (value) {
          setState(() {
            searchText = value;
          });
        },
        decoration: InputDecoration(
            hintText: 'search...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: _isSearching ? _buildSearchField() : Text('${widget.shopName}'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    searchController.clear();
                    searchText = '';
                  }
                });
              },
            ),
          ),
        ],
      ),
      body: isLoading
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
                    fetchData();
                  },
                ) // Show message for success or failure
              : Column(
                  children: [
                    if (widget.shopId == '18')
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                width: 1.5, color: Colors.grey.shade300),
                          ),
                        ),
                        child: Row(
                          children: const [
                            SizedBox(width: 15),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text(
                                  'Model & Chassis',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Ageing',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (widget.shopId == '18')
                      Expanded(
                        child: ListView.separated(
                          itemCount: vehicles.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final car = vehicles[index];
                            return GestureDetector(
                              onTap: () {
                                processSKU(car.vin);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x22000000),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            vehicles[index].model,
                                            style: TextStyle(
                                                color: Colors.amber[900],
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            car.vin,
                                            style:
                                                const TextStyle(fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6, horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: mycolor,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          car.ageing,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
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
                    if (widget.shopId != '18')
                      Expanded(
                        child: ListView.builder(
                          itemCount: vehicles.length,
                          itemBuilder: (context, index) {
                            // ignore: unused_local_variable
                            Color categoryColor = colors[index % colors.length];
                            var vin = vehicles[index].vin;
                            var model = vehicles[index].model;
                            // ignore: unused_local_variabl
                            if (searchText.isNotEmpty &&
                                !(vin
                                        .toLowerCase()
                                        .contains(searchText.toLowerCase()) ||
                                    model
                                        .toLowerCase()
                                        .contains(searchText.toLowerCase()))) {
                              return Container(); // Return an empty container if not matching
                            }
                            return Column(
                              children: [
                                SizedBox(height: 5),
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: boxDecoration(
                                    radius: 10,
                                    showShadow: true,
                                    bgColor: Colors.white,
                                  ),
                                  child: ListTile(
                                    onTap: () {
                                      // showTapScanToast(context);
                                      processSKU(vehicles[index].vin);
                                    },
                                    contentPadding: EdgeInsets.all(0),
                                    leading: CircleAvatar(
                                      backgroundColor: mycolor,
                                      foregroundColor: textWhite,
                                      child: Text("${index + 1}"),
                                    ),
                                    title: Text(
                                      vehicles[index].model,
                                      style: TextStyle(
                                          color: Colors.amber[900],
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('VIN: ${vehicles[index].vin}'),
                                        Row(
                                          children: [
                                            Text('lOT: ${vehicles[index].lot}'),
                                            width(),
                                            if (vehicles[index].job != 'null' &&
                                                // ignore: unnecessary_null_comparison
                                                vehicles[index].job != null)
                                              Text(
                                                  'JOB: ${vehicles[index].job}'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            );
                          },
                        ),
                      ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: const RoundedRectangleBorder(),
                                backgroundColor: mycolor,
                                foregroundColor: textWhite),
                            onPressed: () async {
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
                                              : widget.shopId == '16'
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
                                                  : widget.shopId == '18'
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
                                                      : widget.shopId == '17'
                                                          ? JobCardQuestionsTemplate(
                                                              vehicle_receiving_item: res[
                                                                          'data']
                                                                      [
                                                                      'vehicledata']
                                                                  [
                                                                  'vehicle_receiving_item'],
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
                              // await _invoke(
                              //   (reader) => reader.setProperty(
                              //     BarcodeReaderProperty.trigger
                              //         .scanMode(TriggerScanMode.oneShot),
                              //   ),
                              // );
                              // final supported =
                              //     await _invoke((reader) => reader.claim());
                              // if (supported) {
                              //   await _invoke(
                              //       (reader) => reader.softwareTrigger(true));
                              //   setState(() {
                              //     // isButtonEnabled = false;
                              //   });
                              //   Future.delayed(
                              //     const Duration(seconds: 2),
                              //     () async {
                              //       await _invoke((reader) =>
                              //           reader.softwareTrigger(false));
                              //       // await _invoke((reader) => reader.release());
                              //       setState(() {
                              //         // isButtonEnabled = true;
                              //       });
                              //     },
                              //   );
                              // }
                            },
                            child: const Text('SCAN')),
                      ),
                    ),
                  ],
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
