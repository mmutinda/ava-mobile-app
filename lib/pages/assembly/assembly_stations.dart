import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/models/shops.dart';
import 'package:isuze_pqcs/pages/planning/EOL/EOLScreen.dart';
import 'package:isuze_pqcs/pages/qc_inspection/scanning%20copy.dart';
// import 'package:isuze_pqcs/pages/qc_inspection/scanning.dart';
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: mycolor,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.precision_manufacturing, size: 24),
            SizedBox(width: 8),
            Text(
              "Assembly Stations",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              icon: Icon(Icons.refresh, size: 24),
              onPressed: fetchData,
            ),
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: [
            // Header with stats
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Stations',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${shop.length}',
                          style: TextStyle(
                            color: mycolor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Units',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${shop.fold(0, (sum, station) => sum + int.parse(station.number))}',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: mycolor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.factory,
                      color: mycolor,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            // Content area
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : message.isNotEmpty
                      ? ErrorMessageWidget(
                          errorMessage: message,
                          onRetry: fetchData,
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            _isRefreshing = true;
                            await fetchData();
                            _isRefreshing = false;
                          },
                          displacement: 40,
                          edgeOffset: 0,
                          child: shop.isEmpty
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    SizedBox(
                                      height: 300,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.factory_outlined,
                                              size: 64,
                                              color: Colors.grey[400],
                                            ),
                                            SizedBox(height: 16),
                                            Text(
                                              "No Stations Found",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              "Pull down to refresh",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: shop.length,
                                  itemBuilder: (context, index) {
                                    Color categoryColor =
                                        colors[index % colors.length];
                                    return _buildStationCard(
                                        context, index, categoryColor);
                                  },
                                ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationCard(
      BuildContext context, int index, Color categoryColor) {
    final station = shop[index];
    final unitCount = int.parse(station.number);
    final hasUnits = unitCount > 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (station.number == "0") {
              showNoUnitsDialog(context, categoryColor);
            } else {
              if (station.id == "17") {
                EOLScreenCategory(
                  ShopId: station.id,
                ).launch(
                  context,
                  pageRouteAnimation: PageRouteAnimation.Slide,
                );
              } else {
                Scanning(
                  shopId: station.id,
                  shopName: station.name,
                ).launch(
                  context,
                  pageRouteAnimation: PageRouteAnimation.Slide,
                );
              }
            }
          },
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasUnits
                    ? categoryColor.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Station icon with gradient
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: hasUnits
                          ? [
                              categoryColor.withOpacity(0.8),
                              categoryColor,
                            ]
                          : [
                              Colors.grey[400]!,
                              Colors.grey[500]!,
                            ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (hasUnits ? categoryColor : Colors.grey[400]!)
                            .withOpacity(0.3),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "${index + 1}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                // Station info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.name,
                        style: TextStyle(
                          color: hasUnits ? mycolor : Colors.grey[600],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Unit count badge
                Column(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: hasUnits
                            ? categoryColor.withOpacity(0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: hasUnits ? categoryColor : Colors.grey[400]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            hasUnits
                                ? Icons.inventory
                                : Icons.inventory_2_outlined,
                            size: 16,
                            color: hasUnits ? categoryColor : Colors.grey[500],
                          ),
                          SizedBox(width: 6),
                          Text(
                            '$unitCount',
                            style: TextStyle(
                              color:
                                  hasUnits ? categoryColor : Colors.grey[500],
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      hasUnits ? 'Units' : 'Empty',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 8),
                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  color: hasUnits ? categoryColor : Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
          elevation: 8,
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  mycolor.withOpacity(0.02),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: mycolor,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Station Empty",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: mycolor,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "0 Units Available",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        "There are currently no units in this station.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              mycolor.withOpacity(0.8),
                              mycolor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: categoryColor.withOpacity(0.3),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Refresh & Try Again",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
