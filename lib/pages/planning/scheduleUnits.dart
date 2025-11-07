import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/models/qc_inpection.dart';
import 'package:isuze_pqcs/pages/qc_inspection/chooseComponent.dart';
import 'package:intl/intl.dart';

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
  String selectedLine = 'All'; // Track selected line tab
  List<String> vehicleLines = ['All']; // List of available vehicle lines
  String selectedLot = 'All'; // Track selected lot tab
  List<String> vehicleLots = ['All']; // List of available vehicle lots

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
          _updateVehicleLines();
          _updateVehicleLots();
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

  // Method to update vehicle lines for tabs
  void _updateVehicleLines() {
    Set<String> lines = {'All'};
    for (Vehicle vehicle in vehicles) {
      if (vehicle.vehicle_line.isNotEmpty) {
        lines.add(vehicle.vehicle_line);
      }
    }
    vehicleLines = lines.toList()
      ..sort((a, b) {
        if (a == 'All') return -1;
        if (b == 'All') return 1;
        return a.compareTo(b);
      });

    // Reset selected line if it no longer exists
    if (!vehicleLines.contains(selectedLine)) {
      selectedLine = 'All';
    }
  }

  // Method to update vehicle lots for tabs
  void _updateVehicleLots() {
    Set<String> lots = {'All'};
    for (Vehicle vehicle in vehicles) {
      if (vehicle.lot.isNotEmpty) {
        lots.add(vehicle.lot);
      }
    }
    vehicleLots = lots.toList()
      ..sort((a, b) {
        if (a == 'All') return -1;
        if (b == 'All') return 1;
        return a.compareTo(b);
      });

    // Reset selected lot if it no longer exists
    if (!vehicleLots.contains(selectedLot)) {
      selectedLot = 'All';
    }
  }

  // Method to get filtered vehicles by selected line and lot
  List<Vehicle> _getFilteredVehicles() {
    List<Vehicle> filtered = vehicles;

    // Filter by selected line
    if (selectedLine != 'All') {
      filtered = filtered.where((v) => v.vehicle_line == selectedLine).toList();
    }

    // Filter by selected lot
    if (selectedLot != 'All') {
      filtered = filtered.where((v) => v.lot == selectedLot).toList();
    }

    // Filter by search text
    if (searchText.isNotEmpty) {
      filtered = filtered.where((vehicle) {
        String vin = vehicle.vin.toLowerCase();
        String model = vehicle.model.toLowerCase();
        String lot = vehicle.lot.toLowerCase();
        String searchLower = searchText.toLowerCase();
        return vin.contains(searchLower) ||
            model.contains(searchLower) ||
            lot.contains(searchLower);
      }).toList();
    }

    return filtered;
  }

  // Method to get dynamic filter header text

  // Method to get dynamic empty state message
  String _getEmptyStateMessage() {
    if (selectedLine != 'All' && selectedLot != 'All') {
      return 'No vehicles in Line $selectedLine - Lot $selectedLot';
    } else if (selectedLine != 'All') {
      return 'No vehicles in Line $selectedLine';
    } else if (selectedLot != 'All') {
      return 'No vehicles in Lot $selectedLot';
    } else {
      return 'No vehicles available';
    }
  }

  // Method to format created_at as human readable time
  String _formatTimeAgo(String createdAt) {
    try {
      DateTime createdTime = DateTime.parse(createdAt);
      DateTime now = DateTime.now();
      Duration difference = now.difference(createdTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  TextEditingController searchController = TextEditingController();
  String searchText = '';
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    vehicles.sort((a, b) =>
        DateTime.parse(a.created_at).compareTo(DateTime.parse(b.created_at)));

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
          hintText: 'Search by VIN, Model, or Lot...',
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
                      // Vehicle Line Tabs
                      if (vehicleLines.length > 1)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.only(left: 16, top: 8, bottom: 4),
                              child: Text(
                                'Filter by Vehicle Line',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 12),
                              height: 50,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: vehicleLines.length,
                                itemBuilder: (context, index) {
                                  String line = vehicleLines[index];
                                  bool isSelected = selectedLine == line;
                                  int lineCount = line == 'All'
                                      ? vehicles.length
                                      : vehicles
                                          .where((v) => v.vehicle_line == line)
                                          .length;

                                  return Container(
                                    margin: EdgeInsets.only(right: 8),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () {
                                          setState(() {
                                            selectedLine = line;
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? mycolor
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: isSelected
                                                  ? mycolor
                                                  : Colors.grey.shade300,
                                              width: 1,
                                            ),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: mycolor
                                                          .withOpacity(0.3),
                                                      blurRadius: 8,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ]
                                                : [],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                line == 'All'
                                                    ? Icons.view_module
                                                    : Icons.linear_scale,
                                                size: 16,
                                                color: isSelected
                                                    ? Colors.white
                                                    : mycolor,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                line,
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : mycolor,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(width: 6),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? Colors.white
                                                          .withOpacity(0.2)
                                                      : mycolor
                                                          .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  '$lineCount',
                                                  style: TextStyle(
                                                    color: isSelected
                                                        ? Colors.white
                                                        : mycolor,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
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
                          ],
                        ),

                      // Vehicle Lot Tabs
                      if (vehicleLots.length > 1)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.only(left: 16, top: 8, bottom: 4),
                              child: Text(
                                'Filter by Lot',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              height: 50,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: vehicleLots.length,
                                itemBuilder: (context, index) {
                                  String lot = vehicleLots[index];
                                  bool isSelected = selectedLot == lot;

                                  // Calculate count based on current line filter
                                  int lotCount;
                                  if (lot == 'All') {
                                    lotCount = selectedLine == 'All'
                                        ? vehicles.length
                                        : vehicles
                                            .where((v) =>
                                                v.vehicle_line == selectedLine)
                                            .length;
                                  } else {
                                    lotCount = selectedLine == 'All'
                                        ? vehicles
                                            .where((v) => v.lot == lot)
                                            .length
                                        : vehicles
                                            .where((v) =>
                                                v.lot == lot &&
                                                v.vehicle_line == selectedLine)
                                            .length;
                                  }

                                  return Container(
                                    margin: EdgeInsets.only(right: 8),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () {
                                          setState(() {
                                            selectedLot = lot;
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.orange.shade600
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.orange.shade600
                                                  : Colors.grey.shade300,
                                              width: 1,
                                            ),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: Colors
                                                          .orange.shade600
                                                          .withOpacity(0.3),
                                                      blurRadius: 8,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ]
                                                : [],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                lot == 'All'
                                                    ? Icons.inventory_2
                                                    : Icons.inventory,
                                                size: 16,
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.orange.shade600,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                lot == 'All'
                                                    ? 'All Lots'
                                                    : 'Lot $lot',
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.orange.shade600,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(width: 6),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? Colors.white
                                                          .withOpacity(0.2)
                                                      : Colors.orange.shade600
                                                          .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  '$lotCount',
                                                  style: TextStyle(
                                                    color: isSelected
                                                        ? Colors.white
                                                        : Colors
                                                            .orange.shade600,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
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
                          ],
                        ),
                      SizedBox(height: 8),
                      // Filter Header
                      // List
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            List<Vehicle> filteredVehicles =
                                _getFilteredVehicles();

                            if (filteredVehicles.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.search_off,
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      searchText.isNotEmpty
                                          ? 'No vehicles found matching "$searchText"'
                                          : _getEmptyStateMessage(),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              itemCount: filteredVehicles.length,
                              itemBuilder: (context, index) {
                                Vehicle vehicle = filteredVehicles[index];
                                var UnitRemaining = 'All';
                                if (vehicle.cabin_cockpit_moved == '1') {
                                  UnitRemaining = 'Chassis';
                                } else if (vehicle.chasis_moved == '1') {
                                  UnitRemaining = 'Cabin Or Cockpit';
                                }

                                return Container(
                                  margin: EdgeInsets.only(bottom: 8),
                                  child: Container(
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
                                                    vehicle.model,
                                                    style: TextStyle(
                                                      color: Colors.amber[900],
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(height: 6),
                                                  // Enhanced VIN display
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
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
                                                            color: Colors
                                                                .grey[600],
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        Flexible(
                                                          child: Text(
                                                            vehicle.vin,
                                                            style: TextStyle(
                                                              color: mycolor,
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              letterSpacing:
                                                                  0.5,
                                                              fontFamily:
                                                                  'monospace',
                                                            ),
                                                            overflow:
                                                                TextOverflow
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
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      Text(
                                                        vehicle.lot,
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[800],
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      // Time ago display
                                                      Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 6,
                                                                vertical: 2),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .blue.shade50,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                          border: Border.all(
                                                            color: Colors
                                                                .blue.shade200,
                                                            width: 0.5,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons.access_time,
                                                              size: 10,
                                                              color: Colors.blue
                                                                  .shade600,
                                                            ),
                                                            SizedBox(width: 3),
                                                            Text(
                                                              _formatTimeAgo(
                                                                  vehicle
                                                                      .created_at),
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .blue
                                                                    .shade600,
                                                                fontSize: 9,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ],
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
                                        Row(
                                          children: [
                                            // Show unit remaining status only for scheduled units
                                            if (widget.view == null)
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
                                              )
                                            else
                                              // For units at line, show different info or just take the space
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'ACTION',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      'Tap for details',
                                                      style: TextStyle(
                                                        color: Colors.grey[500],
                                                        fontSize: 9,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            // Professional select/details button
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
                                                    if (widget.view != null) {
                                                      // Show unit details dialog (would need to implement)
                                                      // _showUnitDetailsDialog(vehicle);
                                                    } else {
                                                      // Original functionality for scheduled units
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            ChooseComponent(
                                                          vehicle_id:
                                                              vehicle.id,
                                                          route_id:
                                                              vehicle.route,
                                                          vehicle_line: vehicle
                                                              .vehicle_line,
                                                        ),
                                                      ).then((value) {
                                                        fetchData();
                                                        setState(() {});
                                                      });
                                                    }
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
                                                          widget.view != null
                                                              ? Icons
                                                                  .info_outline
                                                              : Icons
                                                                  .assignment_turned_in,
                                                          color: Colors.white,
                                                          size: 14,
                                                        ),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          widget.view != null
                                                              ? "DETAILS"
                                                              : "SELECT",
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
                                );
                              },
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
