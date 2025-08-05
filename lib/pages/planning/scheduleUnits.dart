import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/models/qc_inpection.dart';
import 'package:isuze_pqcs/pages/qc_inspection/chooseComponent.dart';
import 'package:nb_utils/nb_utils.dart';

class SCheduleUnits extends StatefulWidget {
  @override
  _SCheduleUnitsState createState() => _SCheduleUnitsState();
}

class _SCheduleUnitsState extends State<SCheduleUnits> {
  final List<Color> colors = [
    Colors.amber.shade900,
    Colors.indigo,
    Colors.teal,
  ];
  List<Vehicle> vehicles = []; // List to hold vehicles fetched from API
  var user = {};
  bool isLoading = false;
  String message = '';

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
    final shouldShowLoading = vehicles.isEmpty;

    if (shouldShowLoading) {
      EasyLoading.show(
        status: "Loading scheduled units...",
        maskType: EasyLoadingMaskType.black,
      );
    }

    setState(() {
      isLoading = shouldShowLoading;
      message = '';
    });

    final url = "${Api.api_url}sheduledunits";
    print(url);

    try {
      final response = await httpget(url, user['data']['token'], context);

      if (response == null) {
        setState(() {
          isLoading = false;
          message = 'Something went wrong. Check your internet connection.';
        });
        EasyLoading.dismiss();
        return;
      }

      if (response['success'] && response['data'] != null) {
        final List<Vehicle> fetchedVehicles = (response['data'] as List)
            .map((vehicleData) => Vehicle.fromJson(vehicleData))
            .toList();

        setState(() {
          vehicles = fetchedVehicles;
          isLoading = false;
          message = '';
        });
        if (vehicles.isEmpty) {
          setState(() {
            message = "No scheduled units found.";
          });
          EasyLoading.dismiss();
        }
      } else {
        setState(() {
          isLoading = false;
          message = response['msg'] ?? 'Unexpected error';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        message = 'Network problem: $e';
      });
      print('Error fetching data: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  void dispose() {
    if (isLoading) {
      EasyLoading.dismiss(); // Dismiss loading when navigating away
    }
    super.dispose();
  }

  TextEditingController searchController = TextEditingController();
  String searchText = '';
  bool _isSearching = false;
  @override
  Widget build(BuildContext context) {
    vehicles.sort((a, b) =>
        DateTime.parse(b.created_at).compareTo(DateTime.parse(a.created_at)));

    Widget _buildSearchField() {
      return TextField(
        autofocus: true,
        style: TextStyle(color: Colors.white, fontSize: 16),
        cursorColor: Colors.white,
        controller: searchController,
        onChanged: (value) {
          setState(() {
            searchText = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search by VIN or Model...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.white70, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.white70),
        ),
      );
    }

    Widget _buildStatusBadge(String status) {
      Color badgeColor;
      IconData badgeIcon;

      switch (status.toLowerCase()) {
        case 'all':
          badgeColor = Colors.green;
          badgeIcon = Icons.check_circle;
          break;
        case 'chassis':
          badgeColor = Colors.orange;
          badgeIcon = Icons.build;
          break;
        case 'cabin or cockpit':
          badgeColor = Colors.blue;
          badgeIcon = Icons.car_repair;
          break;
        default:
          badgeColor = Colors.grey;
          badgeIcon = Icons.info;
      }

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: badgeColor.withOpacity(0.1),
          border: Border.all(color: badgeColor, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(badgeIcon, size: 12, color: badgeColor),
            SizedBox(width: 4),
            Text(
              status.toUpperCase(),
              style: TextStyle(
                color: badgeColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: mycolor,
        foregroundColor: Colors.white,
        title: _isSearching
            ? _buildSearchField()
            : Text(
                'Scheduled Units',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              icon: Icon(
                _isSearching ? Icons.close : Icons.search,
                size: 24,
              ),
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
          if (!_isSearching)
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
        decoration: BoxDecoration(),
        child: isLoading
            ? Center(child: SizedBox.shrink()) // Keep an empty widget
            : message.isNotEmpty
                ? ErrorMessageWidget(
                    errorMessage: message,
                    onRetry: () {
                      fetchData();
                    },
                  ) // Show message for success or failure
                : Column(
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
                                    'Total Units',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${vehicles.length}',
                                    style: TextStyle(
                                      color: mycolor,
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
                                Icons.directions_car,
                                color: mycolor,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // List
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: vehicles.length,
                          itemBuilder: (context, index) {
                            var vin = vehicles[index].vin;
                            var model = vehicles[index].model;
                            var UnitRemaining = 'All';
                            if (vehicles[index].cabin_cockpit_moved == '1') {
                              UnitRemaining = 'Chassis';
                            } else if (vehicles[index].chasis_moved == '1') {
                              UnitRemaining = 'Cabin Or Cockpit';
                            }

                            if (searchText.isNotEmpty &&
                                !(vin
                                        .toLowerCase()
                                        .contains(searchText.toLowerCase()) ||
                                    model
                                        .toLowerCase()
                                        .contains(searchText.toLowerCase()))) {
                              return Container(); // Return an empty container if not matching
                            }
                            return Container(
                              margin: EdgeInsets.only(bottom: 12),
                              child: Stack(children: [
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: boxDecoration(
                                    radius: 12,
                                    showShadow: true,
                                    bgColor: Colors.white,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          // Professional avatar with gradient
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  mycolor.withOpacity(0.7),
                                                  mycolor.withOpacity(0.9),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color:
                                                      mycolor.withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
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
                                          // Vehicle info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  vehicles[index].model,
                                                  style: TextStyle(
                                                    color: Colors.amber[900],
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                // Enhanced VIN display
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: mycolor
                                                        .withOpacity(0.08),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                      color: mycolor
                                                          .withOpacity(0.2),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.qr_code_2,
                                                        size: 16,
                                                        color: mycolor,
                                                      ),
                                                      SizedBox(width: 6),
                                                      Text(
                                                        'VIN: ',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${vehicles[index].vin}',
                                                        style: TextStyle(
                                                          color: mycolor,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          letterSpacing: 1.2,
                                                          fontFamily:
                                                              'monospace',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .inventory_2_outlined,
                                                      size: 16,
                                                      color: Colors.grey[600],
                                                    ),
                                                    SizedBox(width: 6),
                                                    Text(
                                                      'LOT: ',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${vehicles[index].lot}',
                                                      style: TextStyle(
                                                        color: Colors.grey[800],
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      // Status and action row
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'UNIT REMAINING',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                                SizedBox(height: 6),
                                                _buildStatusBadge(
                                                    UnitRemaining),
                                              ],
                                            ),
                                          ),
                                          // Professional select button
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  mycolor.withOpacity(0.7),
                                                  mycolor.withOpacity(0.9),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.amber[900]!
                                                      .withOpacity(0.3),
                                                  blurRadius: 6,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                onTap: () {
                                                  showInDialog(context,
                                                          builder: (context) =>
                                                              ChooseComponent(
                                                                vehicle_id:
                                                                    vehicles[
                                                                            index]
                                                                        .id,
                                                                job_no: vehicles[
                                                                        index]
                                                                    .job,
                                                                route_id:
                                                                    vehicles[
                                                                            index]
                                                                        .route,
                                                              ),
                                                          dialogAnimation:
                                                              DialogAnimation
                                                                  .SCALE)
                                                      .then((value) {
                                                    fetchData();
                                                    setState(() {});
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 12,
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .assignment_turned_in,
                                                        color: Colors.white,
                                                        size: 18,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        "SELECT",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          letterSpacing: 0.5,
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
                                    ],
                                  ),
                                ),

                                // 🔷 Customer badge (top-right)
                              ]),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

BoxDecoration boxDecoration({
  double radius = 12,
  bool showShadow = true,
  Color bgColor = Colors.white,
}) {
  return BoxDecoration(
    color: bgColor,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: Colors.grey.withOpacity(0.1),
      width: 1,
    ),
    boxShadow: showShadow
        ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
              spreadRadius: -2,
            ),
          ]
        : [],
  );
}
