import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/models/shops.dart';
import 'package:isuze_pqcs/pages/qc_inspection/scanning.dart';
import 'package:isuze_pqcs/services/sqlite_db_helper.dart';
import 'package:isuze_pqcs/widgets/shops.dart';

import 'package:nb_utils/nb_utils.dart';

class AssemblyStations extends StatefulWidget {
  const AssemblyStations({super.key});

  @override
  State<AssemblyStations> createState() => _AssemblyStationsState();
}

List<shops> shop = []; // List to hold vehicles fetched from API
final List<Color> colors = [
  Colors.amber.shade900,
  Colors.indigo,
  Colors.teal,
];

class _AssemblyStationsState extends State<AssemblyStations> {
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

  // Future<void> fetchData() async {
  //   try {
  //     // Optional: show EasyLoading ONLY when NOT refreshing:
  //     if (!mounted || !_isRefreshing) {
  //       EasyLoading.show(
  //         status: "Loading Shops...",
  //         maskType: EasyLoadingMaskType.black,
  //       );
  //     }

  //     // Load cached shops first
  //     List<shops> cachedShops = await DBHelper.getCachedShops();
  //     if (cachedShops.isNotEmpty) {
  //       setState(() {
  //         shop = cachedShops;
  //         message = '';
  //       });
  //     }

  //     var url = "${Api.api_url}home";
  //     var response = await httpget(url, user['data']['token'], context);

  //     if (response != null && response['success'] && response['data'] != null) {
  //       List<dynamic> responseData = response['data']['shop'];
  //       List<shops> fetchedShops = responseData.map((shopData) {
  //         return shops.fromJson(shopData);
  //       }).toList();

  //       if (fetchedShops.isNotEmpty) {
  //         setState(() {
  //           shop = fetchedShops;
  //           message = '';
  //         });
  //         await DBHelper.insertShops(fetchedShops);
  //       } else {
  //         setState(() {
  //           message = "No Shops Found";
  //         });
  //       }
  //     } else {
  //       setState(() {
  //         message = response['msg'] ?? "Failed to fetch data";
  //       });
  //     }
  //   } catch (e) {
  //     print("Error: $e");
  //     setState(() {
  //       message = "Network Problem";
  //     });
  //   } finally {
  //     if (!mounted || !_isRefreshing) {
  //       EasyLoading.dismiss();
  //     }
  //   }
  // }

  Future<void> fetchData() async {
    print("Fetching Data...");
    EasyLoading.show(
      status: "Loading Station...",
      maskType: EasyLoadingMaskType.black,
    );

    var url = "${Api.api_url}home";
    print(url);
    try {
      var response = await httpget(url, user['data']['token'], context);

      if (response != null && response['success'] && response['data'] != null) {
        List<dynamic> responseData = response['data']['shop'];
        List<shops> fetchedShops = responseData.map((shopData) {
          return shops.fromJson(shopData);
        }).toList();

        if (fetchedShops.isNotEmpty) {
          setState(() {
            shop = fetchedShops;
            message = '';
            _isRefreshing == false;
          });
          // await DBHelper.insertShops(fetchedShops); // Update SQLite
        } else {
          setState(() {
            message = "No Shops Found";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "All Stations",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : message.isNotEmpty
                ? ErrorMessageWidget(
                    errorMessage: message,
                    onRetry: fetchData,
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      // mark that this is a pull-to-refresh:
                      _isRefreshing = true;
                      await fetchData();
                      _isRefreshing = false;
                    },
                    displacement: 40,
                    edgeOffset: 0,
                    child: shop.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(
                                height: 300,
                                child: Center(
                                  child: Text("No Shops Found"),
                                ),
                              )
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: shop.length,
                            itemBuilder: (context, index) {
                              Color categoryColor =
                                  colors[index % colors.length];
                              return StationsItems(
                                index: index + 1,
                                dividerColor: categoryColor,
                                name: shop[index].name,
                                number: shop[index].number,
                                onTap: () {
                                  if (shop[index].number == "0") {
                                    showNoUnitsDialog(context, categoryColor);
                                  } else {
                                    Scanning(
                                      shopId: shop[index].id,
                                      shopName: shop[index].name,
                                    ).launch(
                                      context,
                                      pageRouteAnimation:
                                          PageRouteAnimation.Slide,
                                    );
                                  }
                                },
                              );
                            },
                          ),
                  ),
      ),
    );
  }
}

void showNoUnitsDialog(BuildContext context, Color categoryColor) {
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
                color: categoryColor,
                size: 50,
              ),
              const SizedBox(height: 15),
              Text(
                "No Units Available",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: categoryColor,
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
                  backgroundColor: categoryColor,
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
