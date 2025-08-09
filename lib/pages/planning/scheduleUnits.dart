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
  final view;

  const SCheduleUnits({super.key, this.view});
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
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: badgeColor.withOpacity(0.1),
          border: Border.all(color: badgeColor, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(badgeIcon, size: 10, color: badgeColor),
            SizedBox(width: 3),
            Text(
              status.toUpperCase(),
              style: TextStyle(
                color: badgeColor,
                fontSize: 9,
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
            : Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.view != null ? Icons.factory : Icons.schedule,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    widget.view != null ? 'Units at Line' : 'Scheduled Units',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(
                _isSearching ? Icons.close : Icons.search,
                size: 20,
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
            Container(
              margin: EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(Icons.refresh, size: 20),
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
                        margin:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
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
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '${vehicles.length}',
                                    style: TextStyle(
                                      color: mycolor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: mycolor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: mycolor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.directions_car,
                                color: mycolor,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // List
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 12),
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
                              margin: EdgeInsets.only(bottom: 8),
                              child: Stack(children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          // Professional avatar
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: mycolor,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "${index + 1}",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12),
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
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 6),
                                                // Enhanced VIN display
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: mycolor
                                                        .withOpacity(0.08),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
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
                                                        size: 14,
                                                        color: mycolor,
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        'VIN: ',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      Flexible(
                                                        child: Text(
                                                          '${vehicles[index].vin}',
                                                          style: TextStyle(
                                                            color: mycolor,
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            letterSpacing: 0.5,
                                                            fontFamily:
                                                                'monospace',
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .inventory_2_outlined,
                                                      size: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'LOT #: ',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${vehicles[index].lot}',
                                                      style: TextStyle(
                                                        color: Colors.grey[800],
                                                        fontSize: 12,
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
                                      SizedBox(height: 12),
                                      // Status and action row
                                      if (widget.view == null)
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
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  _buildStatusBadge(
                                                      UnitRemaining),
                                                ],
                                              ),
                                            ),
                                            // Professional select button
                                            Container(
                                              decoration: BoxDecoration(
                                                color: mycolor,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color:
                                                      mycolor.withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          ChooseComponent(
                                                        vehicle_id:
                                                            vehicles[index].id,
                                                        route_id:
                                                            vehicles[index]
                                                                .route,
                                                        vehicle_line:
                                                            vehicles[index]
                                                                .vehicle_line,
                                                      ),
                                                    ).then((value) {
                                                      fetchData();
                                                      setState(() {});
                                                    });
                                                    // showInDialog(context,
                                                    //         builder: (context) =>
                                                    //             ChooseComponent(
                                                    //               vehicle_id:
                                                    //                   vehicles[
                                                    //                           index]
                                                    //                       .id,
                                                    //               job_no: vehicles[
                                                    //                       index]
                                                    //                   .job,
                                                    //               route_id:
                                                    //                   vehicles[
                                                    //                           index]
                                                    //                       .route,
                                                    //             ),
                                                    //         dialogAnimation:
                                                    //             DialogAnimation
                                                    //                 .SCALE)
                                                    //     .then((value) {
                                                    //   fetchData();
                                                    //   setState(() {});
                                                    // });
                                                  },
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .assignment_turned_in,
                                                          color: Colors.white,
                                                          size: 14,
                                                        ),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          "SELECT",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.w600,
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
