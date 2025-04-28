import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader2.dart' as loader2;
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/pages/Receiving/form_conversion_receiving.dart';
import 'package:isuze_pqcs/pages/Receiving/vehicle_receiving_conversion.dart';
import 'package:isuze_pqcs/pages/qc_inspection/scheduleUnits.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class DisplayVehicles extends StatefulWidget {
  @override
  State<DisplayVehicles> createState() => _DisplayVehiclesState();
}

class _DisplayVehiclesState extends State<DisplayVehicles> {
  var user = {};
  var vehicles = [];
  // var vehicles;
  var loadingText = '';
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();
  String searchText = '';
  bool _isSearching = false;
  final List<Color> colors = [
    Colors.amber.shade900,
    Colors.indigo,
    Colors.teal,
  ];
  @override
  void initState() {
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      fetchVehicles().then(
        (value) {
          if (vehicles.isEmpty) {
            print(value);
            setState(() {
              loadingText = 'No vehicles available at the moment';
            });
          }
        },
      );
      ;
    });
    super.initState();
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
            hintText: 'Chassis Number or RegNo...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: _isSearching ? _buildSearchField() : Text('Receiving Units'),
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
      body: RefreshIndicator(
        color: mycolor,
        onRefresh: () {
          return Future.delayed(
            const Duration(seconds: 1),
            () {
              fetchVehicles().then(
                (value) {
                  toasty(context, "Refreshed",
                      bgColor: mycolor,
                      textColor: textWhite,
                      padding: EdgeInsets.all(12));
                },
              );
            },
          );
        },
        child: SizedBox(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : loadingText.isNotEmpty
                    ? loader2.ErrorMessageWidget(
                        errorMessage: loadingText,
                        onRetry: () {
                          fetchVehicles().then(
                            (value) {
                              if (vehicles.isEmpty) {
                                setState(() {
                                  loadingText =
                                      'No vehicles available at the moment';
                                });
                              }
                            },
                          );
                        },
                      )
                    : SizedBox(
                        child: ListView.builder(
                          itemCount: vehicles.length,
                          itemBuilder: (context, index) {
                            // Sort vehicles by delivery_date in descending order
                            vehicles.sort((a, b) {
                              // Assuming delivery_date is in a format that can be directly compared as strings
                              return b['created_at'].compareTo(a['created_at']);
                            });
                            var vehicle = vehicles[index];
                            var vin_no = vehicle["vin_no"];
                            var engine_no = vehicles[index]["engine_no"];
                            var client = vehicles[index]["client"]["name"];
                            Color categoryColor = colors[index % colors.length];
                            // Check if the title contains the search text
                            // if (searchText.isNotEmpty &&
                            //     !(chasisNo
                            //         .toLowerCase()
                            //         .contains(searchText.toLowerCase()))||) {
                            //   return Container();
                            // }
                            if (searchText.isNotEmpty &&
                                !(vin_no
                                        .toLowerCase()
                                        .contains(searchText.toLowerCase()) ||
                                    engine_no
                                        .toLowerCase()
                                        .contains(searchText.toLowerCase()) ||
                                    client
                                        .toLowerCase()
                                        .contains(searchText.toLowerCase()))) {
                              return Container(); // Return an empty container if not matching
                            }
                            return Column(
                              children: [
                                SizedBox(height: 5),
                                Stack(children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: boxDecoration(
                                      radius: 10,
                                      showShadow: true,
                                      bgColor: Colors.white,
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.all(0),
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            Color.fromARGB(255, 168, 88, 32),
                                        foregroundColor: Colors.white,
                                        child: Text("${index + 1}"),
                                      ),
                                      title: Text(
                                        vehicles[index]['model']?['model_name'],
                                        style: TextStyle(
                                            color: Colors.amber[900],
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              'VIN: ${vehicles[index]['vin_no']}'),
                                          // Text('VIN: ${vehicles[index].vin}'),
                                          Row(
                                            children: [
                                              Text(
                                                  'lOT: ${vehicles[index]['lot_no']}'),
                                              width(),
                                              // if (vehicles[index]['job_no'] !=
                                              //     null)
                                              Text(
                                                  'JOB: ${vehicles[index]['job_no'] ?? 'N/A'}'),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: categoryColor),
                                              borderRadius: BorderRadius.only(
                                                  topRight:
                                                      Radius.circular(10))),
                                          child: TextButton(
                                            onPressed: () {},
                                            child: Text(
                                              "SELECT",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                VehicleReceivingConversion(
                                              type: "receive",
                                              vehicleId: vehicles[index]["id"],
                                              vehicleName: vehicles[index]
                                                  ['model']?['model_name'],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  // 🔷 Badge (top-right)
                                  Positioned(
                                    right: 10,
                                    top: 0,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: vehicles[index]['client'] != null
                                            ? Colors.amber[900]
                                            : null,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        vehicles[index]['client']?['name'] ??
                                            '',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                                SizedBox(height: 10),
                              ],
                            );
                            // return Padding(
                            //   padding: const EdgeInsets.all(10),
                            //   child: InkWell(
                            //     onTap: () async {
                            //       final result = await Navigator.push(
                            //         context,
                            //         MaterialPageRoute(
                            //             builder: (context) =>
                            //                 VehicleReceivingConversion(
                            //                   type: "receive",
                            //                   vehicleId: vehicles[index]["id"],
                            //                   vehicleName: vehicles[index]
                            //                       ["product"]["name"],
                            //                 )
                            //             // ? VehicleChecklistScreen()

                            //             ),
                            //       );
                            //       if (result != null) {
                            //         fetchVehicles();
                            //       }
                            //     },
                            //     child: Card(
                            //       color: Colors.white,
                            //       elevation: 3,
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(12),
                            //       ),
                            //       child: Padding(
                            //         padding: const EdgeInsets.fromLTRB(
                            //             20, 10, 0, 10),
                            //         child: Row(
                            //           children: [
                            //             CircleAvatar(
                            //               backgroundColor: categoryColor,
                            //               foregroundColor: Colors.white,
                            //               radius: 20,
                            //               child: Text(
                            //                 "${index + 1}",
                            //                 style: const TextStyle(
                            //                   fontWeight: FontWeight.bold,
                            //                 ),
                            //               ),
                            //             ),
                            //             const SizedBox(width: 12),
                            //             Expanded(
                            //               child: Column(
                            //                 mainAxisAlignment:
                            //                     MainAxisAlignment.center,
                            //                 crossAxisAlignment:
                            //                     CrossAxisAlignment.start,
                            //                 children: [
                            //                   Text(
                            //                       '${vehicles[index]["product"]["name"]}'),
                            //                   Text(
                            //                     "${vehicles[index]["product"]['sku']}",
                            //                     style: TextStyle(
                            //                         fontWeight:
                            //                             FontWeight.bold),
                            //                   ),
                            //                   Text('${halModel["name"] ?? ''}'),
                            //                 ],
                            //               ),
                            //             ),
                            //             Container(
                            //               margin: const EdgeInsets.only(
                            //                   top: 10, bottom: 5, right: 5),
                            //               alignment: Alignment.center,
                            //               child: GestureDetector(
                            //                 onTap: () async {
                            //                   final result =
                            //                       await Navigator.push(
                            //                     context,
                            //                     MaterialPageRoute(
                            //                         builder: (context) =>
                            //                             VehicleReceivingConversion(
                            //                               type: 'receive',
                            //                               vehicleId:
                            //                                   vehicles[index]
                            //                                       ["id"],
                            //                               vehicleName: vehicles[
                            //                                           index]
                            //                                       ["product"]
                            //                                   ["name"],
                            //                             )),
                            //                   );
                            //                   if (result != null) {
                            //                     fetchVehicles();
                            //                   }
                            //                 },
                            //                 child: Container(
                            //                   padding: EdgeInsets.all(12),
                            //                   decoration: BoxDecoration(
                            //                       border: Border.all(
                            //                           color: categoryColor),
                            //                       borderRadius:
                            //                           BorderRadius.only(
                            //                               topRight:
                            //                                   Radius.circular(
                            //                                       10))),
                            //                   child: Text(
                            //                     "SELECT",
                            //                     style: TextStyle(
                            //                       fontWeight: FontWeight.bold,
                            //                     ),
                            //                   ),
                            //                 ),
                            //                 // child: Icon(Icons.forward),
                            //                 // child: Icon(Icons.forward),
                            //               ),
                            //             ),
                            //           ],
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // );
                          },
                        ),
                      )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return Conversion_receive_form();
            },
          )).then(
            (value) {
              fetchVehicles().then(
                (value) {
                  if (vehicles.isEmpty) {
                    // print(value);
                    setState(() {
                      loadingText = 'No vehicles available at the moment';
                    });
                  }
                },
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future fetchVehicles() async {
    setState(() {
      loadingText = '';
      isLoading = vehicles.isEmpty ? true : false;
    });
    String url = "${Api.api_url}loaAPiShedulledUnits";
    print(url);
    ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
    pr.style(
      message: 'Fetching vehicles...',
      borderRadius: 8,
      backgroundColor: Colors.white,
      progressWidget: const SizedBox(
          width: 20,
          height: 20,
          child: Center(child: CircularProgressIndicator())),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
    );

    // pr.show();
    var responsedata = await httpget(url, user['data']["token"], context);
    // print(responsedata);
    if (responsedata != null) {
      pr.hide();

      setState(() {
        isLoading = false;
        vehicles = (responsedata["data"] as List<dynamic>) ?? [];
      });
    } else {
      pr.hide().whenComplete(() {
        setState(() {
          isLoading = false;
          loadingText = responsedata["message"].toString();
        });
        toasty(context, "${responsedata["message"]}",
            bgColor: Colors.red, textColor: textWhite);
      });
    }
    Future.delayed(const Duration(seconds: dismissseconds), () {
      if (pr.isShowing()) {
        pr.hide();
        setState(() {
          isLoading = false;
          loadingText = internetmessage;
        });
        // ScaffoldMessenger.of(context)
        //     .showSnackBar(snackBar(internetmessage, snackred));
      }
    });
  }
}
