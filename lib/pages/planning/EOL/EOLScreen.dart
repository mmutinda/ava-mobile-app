import 'dart:convert';
import 'dart:developer';

import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/confirmationDialog.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
// import 'package:isuze_pqcs/pages/assembly/assembly_stations.dart';
import 'package:isuze_pqcs/pages/planning/EOL/jobcard_questions_template_EOL.dart';
import 'package:isuze_pqcs/pages/qc_inspection/scanning.dart';
import 'package:nb_utils/nb_utils.dart';

class EOL {
  final id;
  final name;
  final number;
  final pending;
  final completed;
  IconData icon;

  EOL({
    required this.id,
    required this.name,
    required this.number,
    required this.pending,
    required this.completed,
    required this.icon,
  });

  factory EOL.fromJson(Map<String, dynamic> json) {
    return EOL(
      id: json['id'].toString(),
      name: json['name'].toString(),
      pending: json['pending'].toString(),
      completed: json['completed'].toString(),
      number: "${json['stationunits'].length}",
      icon: (() {
        final stationName = json['name'].toString().toLowerCase();
        switch (stationName) {
          case 'brake test':
            return Icons.directions_car;
          case 'wheel alignment':
            return Icons.tune;
          case 'ac':
            return Icons.water_damage;
          case 'road test':
            return Icons.emoji_transportation;
          case 'ac refilling':
            return Icons.ac_unit;
          case 'qc':
            return Icons.verified;
          case 'paint rec':
            return Icons.format_paint;
          case 'qfl4':
            return Icons.label;
          case 'sale station':
            return Icons.storefront;
          default:
            return Icons.label;
        }
      })(),
    );
  }
}

class EOLScreenCategory extends StatefulWidget {
  final ShopId;

  const EOLScreenCategory({
    super.key,
    required this.ShopId,
  });

  @override
  State<EOLScreenCategory> createState() => _EOLScreenCategoryState();
}

class _EOLScreenCategoryState extends State<EOLScreenCategory> {
  var user = {};
  bool isLoading = false;
  String message = '';
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      fetchData();
    });
  }

  List<EOL> data = [];
  bool isLoading2 = false;

  Future<void> fetchData() async {
    print("Fetching Data...");
    EasyLoading.show(
      status: "Loading EOL Substation...",
      maskType: EasyLoadingMaskType.black,
    );

    // var url = "${Api.api_url}loadUnitsInSubstation/${widget.ShopId}";
    var url = "${Api.api_url}loadSubstationsWithUnits/${widget.ShopId}";
    print(url);
    try {
      var response = await httpget(url, user['data']['token'], context);

      if (response != null && response['success'] && response['data'] != null) {
        List<dynamic> responseData = response['data'];
        List<EOL> fetcheddata = responseData.map((shopData) {
          return EOL.fromJson(shopData);
        }).toList();

        if (fetcheddata.isNotEmpty) {
          setState(() {
            data = fetcheddata;
            message = '';
            _isRefreshing == false;
          });
          // await DBHelper.insertShops(fetchedShops); // Update SQLite
        } else {
          setState(() {
            message = "No data Found";
            _isRefreshing == false;
          });
        }
        EasyLoading.dismiss(); // Always dismiss loader
      } else {
        setState(() {
          message = response['msg'] ?? "Failed to fetch data";
          _isRefreshing == false;
        });
        EasyLoading.dismiss(); // Always dismiss loader
      }
    } catch (e) {
      EasyLoading.dismiss(); // Always dismiss loaders
      print("Error fetching data: $e");

      setState(() {
        message = "Network Problem";
        _isRefreshing == false;
      });
    }
  }

  // void Submit() {
  //   // ✅ Add your START EOL logic here

  //   CustomConfirmDialog.show(
  //     context: context,
  //     title: 'Confirm Action',
  //     message: 'Do you want to push to EOL',
  //     onConfirm: () async {
  //       await saveData();
  //     },
  //   );
  //   // Proceed with selectedOps
  // }

  // Future<void> saveData() async {
  //   setState(() {
  //     isLoading2 = true;
  //   });
  //   print(isLoading2);
  //   String url = Api.api_url + "moveunitToEOL";

  //   // ✅ Build the selected operations array

  //   var payload = {
  //     "shop_id": widget.ShopId,
  //     "next_shop_id": 11,
  //   };

  //   print("Payload: $payload"); // Debug log

  //   var response = await httppostwithtoken(
  //     url,
  //     "${user['data']['token']}",
  //     payload,
  //     context,
  //   );

  //   setState(() {
  //     isLoading2 = false;
  //   });
  //   log(jsonEncode(response));
  //   if (response['success'] != null) {
  //     if (response['success']) {
  //       Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(builder: (context) => AssemblyStations()),
  //         (route) => route.isFirst,
  //       );
  //       awesomeTopSnackbar(
  //         context,
  //         "${response["msg"]}",
  //         iconWithDecoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(20),
  //           border: Border.all(),
  //           color: Colors.white,
  //         ),
  //         backgroundColor: Colors.green,
  //       );
  //     } else {
  //       awesomeTopSnackbar(
  //         context,
  //         "${response["msg"]}",
  //         iconWithDecoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(20),
  //           border: Border.all(),
  //           color: Colors.white,
  //         ),
  //         backgroundColor: Colors.red,
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EOL Stations',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // mark that this is a pull-to-refresh:
                _isRefreshing = true;
                await fetchData();
                _isRefreshing = false;
              },
              displacement: 40,
              edgeOffset: 0,
              child: data.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(
                          height: 300,
                          child: Center(
                            child: Text("No Data Found"),
                          ),
                        )
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final station = data[index];
                        // Color categoryColor = colors[index % colors.length];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 1,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            onTap: () {
                              if (station.number == "0") {
                                showNoUnitsDialog(context);
                                return;
                              }
                              Scanning(
                                shopId: "11",
                                shopName: station.name,
                                subStationId: station.id,
                              ).launch(
                                context,
                                pageRouteAnimation: PageRouteAnimation.Slide,
                              );
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) =>
                              //         JobCardQuestionsTemplateEOL(
                              //       chasis_no: widget.chasis,
                              //       shop_name: '',
                              //       station_id: station.id,
                              //       shop_id: widget.ShopId,
                              //       vehicle_id: widget.vId,
                              //       categoryName: station.name,
                              //     ),
                              //   ),
                              // );
                              // if (station.name == 'Brake Test') {
                              //   Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) =>
                              //           BrakeTestList(EOLType: 'BT'),
                              //     ),
                              //   );
                              //   return;
                              // }
                              // if (station.name == 'Wheel Alignment') {
                              //   Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) =>
                              //           BrakeTestList(EOLType: 'WA'),
                              //     ),
                              //   );
                              //   return;
                              // }
                            },
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade50,
                              child: Icon(station.icon, color: mycolor),
                            ),
                            title: Text(
                              station.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Builder(
                              builder: (context) {
                                int unitCount =
                                    int.tryParse(station.number.toString()) ??
                                        0;
                                String unitText;
                                if (unitCount == 0) {
                                  unitText = "No Unit Found";
                                } else if (unitCount == 1) {
                                  unitText = "1 Unit Found";
                                } else {
                                  unitText = "$unitCount Units Found";
                                }
                                return Text(
                                  unitText,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
                            ),
                            trailing: station.number != null
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: mycolor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      station.number.toString(),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                : const SizedBox(),
                          ),
                        );
                      },
                    ),
            ),
          ),
          // isLoading2
          //     ? CustomLoader()
          //     : Container(
          //         width: double.infinity,
          //         child: ElevatedButton(
          //           style: ElevatedButton.styleFrom(
          //             backgroundColor: mycolor,
          //             padding: const EdgeInsets.symmetric(vertical: 16),
          //             elevation: 0,
          //             shape: RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(8),
          //             ),
          //           ),
          //           onPressed: Submit,
          //           child: const Text(
          //             "PUSH",
          //             style: TextStyle(
          //               color: Colors.white,
          //               fontWeight: FontWeight.bold,
          //               letterSpacing: 1.1,
          //             ),
          //           ),
          //         ),
          //       ),
        ],
      ),
    );
  }
}

void showNoUnitsDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 4,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                color: mycolor,
                size: 50,
              ),
              const SizedBox(height: 15),
              Text(
                "No Units Available",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: mycolor,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "There are currently no units in this station.\n"
                "Pull down the screen to refresh.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mycolor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "OK",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
