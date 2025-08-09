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
  // Colors.amber.shade900,
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
          // Sort shops: stations with units first, then empty stations
          fetchedShops.sort((a, b) {
            int aUnits = int.parse(a.number);
            int bUnits = int.parse(b.number);

            // If both have units or both are empty, maintain original order
            if ((aUnits > 0 && bUnits > 0) || (aUnits == 0 && bUnits == 0)) {
              return 0;
            }
            // Stations with units come first
            if (aUnits > 0 && bUnits == 0) return -1;
            if (aUnits == 0 && bUnits > 0) return 1;

            return 0;
          });

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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: mycolor,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.precision_manufacturing, size: 20),
            ),
            SizedBox(width: 12),
            Text(
              "Assembly Stations",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.refresh, size: 20),
              onPressed: fetchData,
              padding: EdgeInsets.all(8),
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
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: mycolor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.factory,
                                color: mycolor,
                                size: 16,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Active Stations',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${shop.length}',
                          style: TextStyle(
                            color: mycolor,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 1,
                    color: Colors.grey.shade200,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.inventory,
                                color: Colors.green[700],
                                size: 16,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Total Units',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${shop.fold(0, (sum, station) => sum + int.parse(station.number))}',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Content area
            Expanded(
              child: isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(mycolor),
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading stations...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
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
                          color: mycolor,
                          backgroundColor: Colors.white,
                          displacement: 20,
                          child: shop.isEmpty
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    Container(
                                      height: 400,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Icon(
                                                Icons.factory_outlined,
                                                size: 48,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                            SizedBox(height: 24),
                                            Text(
                                              "No Stations Found",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[700],
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
                                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              hasUnits ? categoryColor.withOpacity(0.3) : Colors.grey.shade200,
          width: hasUnits ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: categoryColor.withOpacity(0.1),
          highlightColor: categoryColor.withOpacity(0.05),
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
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Station number circle
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: hasUnits ? categoryColor : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      "${index + 1}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
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
                          color: hasUnits
                              ? Colors.grey.shade800
                              : Colors.grey.shade500,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            hasUnits
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            size: 14,
                            color:
                                hasUnits ? Colors.green : Colors.grey.shade400,
                          ),
                          SizedBox(width: 4),
                          Text(
                            hasUnits ? 'Active' : 'Empty',
                            style: TextStyle(
                              color: hasUnits
                                  ? Colors.green
                                  : Colors.grey.shade500,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Unit count and arrow
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: hasUnits
                            ? categoryColor.withOpacity(0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              hasUnits ? categoryColor : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inventory_2,
                            size: 14,
                            color:
                                hasUnits ? categoryColor : Colors.grey.shade500,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '$unitCount',
                            style: TextStyle(
                              color: hasUnits
                                  ? categoryColor
                                  : Colors.grey.shade600,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Units',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 12),

                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: hasUnits ? categoryColor : Colors.grey.shade400,
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
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.grey.shade500,
                  size: 32,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Station Empty',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.grey.shade600,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "0 Units Available",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      "There are currently no units in this station.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: categoryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Refresh & Try Again',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
