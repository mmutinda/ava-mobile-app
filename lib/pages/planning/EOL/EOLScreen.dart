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
import 'package:isuze_pqcs/pages/assembly/assembly_stations.dart';
import 'package:isuze_pqcs/pages/planning/EOL/EOLlist.dart';

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
  final vId;

  const EOLScreenCategory({
    super.key,
    required this.ShopId,
    required this.vId,
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
      status: "Loading EOL sections...",
      maskType: EasyLoadingMaskType.black,
    );

    var url =
        "${Api.api_url}loadUnitsInSubstation/${widget.ShopId}/${widget.vId}";
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

  void Submit() {
    // ✅ Add your START EOL logic here

    CustomConfirmDialog.show(
      context: context,
      title: 'Confirm Action',
      message: 'Do you want to push to EOL',
      onConfirm: () async {
        await saveData();
      },
    );
    // Proceed with selectedOps
  }

  Future<void> saveData() async {
    setState(() {
      isLoading2 = true;
    });
    print(isLoading2);
    String url = Api.api_url + "moveunitToEOL";

    // ✅ Build the selected operations array

    var payload = {
      "shop_id": widget.ShopId,
      "next_shop_id": 11,
    };

    print("Payload: $payload"); // Debug log

    var response = await httppostwithtoken(
      url,
      "${user['data']['token']}",
      payload,
      context,
    );

    setState(() {
      isLoading2 = false;
    });
    log(jsonEncode(response));
    if (response['success'] != null) {
      if (response['success']) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AssemblyStations()),
          (route) => route.isFirst,
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
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 1,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            onTap: () {
                              if (station.name == 'Brake Test') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BrakeTestList(EOLType: 'BT'),
                                  ),
                                );
                                return;
                              }
                              if (station.name == 'Wheel Alignment') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BrakeTestList(EOLType: 'WA'),
                                  ),
                                );
                                return;
                              }
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
          isLoading2
              ? CustomLoader()
              : Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mycolor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: Submit,
                    child: const Text(
                      "PUSH",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
