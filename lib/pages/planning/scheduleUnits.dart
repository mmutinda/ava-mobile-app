import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/models/qc_inpection.dart';
import 'package:isuze_pqcs/pages/qc_inspection/chooseComponent.dart';

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
      return 'No vehicles in $selectedLine - $selectedLot';
    } else if (selectedLine != 'All') {
      return 'No vehicles in $selectedLine';
    } else if (selectedLot != 'All') {
      return 'No vehicles in $selectedLot';
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

  // Check if any filters are active
  bool get _hasActiveFilters {
    return selectedLine != 'All' || selectedLot != 'All';
  }

  // Get active filters count
  int get _activeFiltersCount {
    int count = 0;
    if (selectedLine != 'All') count++;
    if (selectedLot != 'All') count++;
    return count;
  }

  // Build filter subtitle for app bar
  String _buildFilterSubtitle() {
    List<String> filters = [];
    if (selectedLine != 'All') filters.add('Line: $selectedLine');
    if (selectedLot != 'All') filters.add('Lot: $selectedLot');
    return filters.join(' • ');
  }

  // Method to show filter bottom sheet
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.65,
              minChildSize: 0.4,
              maxChildSize: 0.85,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white,
                        Colors.grey.shade50,
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Enhanced Handle bar
                      Container(
                        width: 50,
                        height: 5,
                        margin: EdgeInsets.only(top: 15, bottom: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              mycolor.withOpacity(0.3),
                              mycolor.withOpacity(0.7)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),

                      // Enhanced Header with modern design
                      Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              mycolor,
                              mycolor.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: mycolor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.tune_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Filter & Sort',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Customize your view',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: Icon(Icons.close_rounded,
                                    color: Colors.white, size: 22),
                                padding: EdgeInsets.all(8),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content - Scrollable
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Vehicle Line Filter Section
                              Text(
                                'Vehicle Line',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: vehicleLines.map((line) {
                                  bool isSelected = selectedLine == line;
                                  int lineCount = line == 'All'
                                      ? vehicles.length
                                      : vehicles
                                          .where((v) => v.vehicle_line == line)
                                          .length;

                                  return InkWell(
                                    onTap: () {
                                      setModalState(() {
                                        selectedLine = line;
                                      });
                                      setState(() {
                                        selectedLine = line;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? mycolor
                                            : Colors.grey[100],
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected
                                              ? mycolor
                                              : Colors.grey[300]!,
                                          width: 1,
                                        ),
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
                                                : Colors.grey[600],
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            line,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.grey[800],
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
                                                  : Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              '$lineCount',
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.grey[600],
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              SizedBox(height: 24),

                              // Vehicle Lot Filter Section
                              Text(
                                'Vehicle Lot',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: vehicleLots.map((lot) {
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

                                  return InkWell(
                                    onTap: () {
                                      setModalState(() {
                                        selectedLot = lot;
                                      });
                                      setState(() {
                                        selectedLot = lot;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.orange[600]
                                            : Colors.grey[100],
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.orange[600]!
                                              : Colors.grey[300]!,
                                          width: 1,
                                        ),
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
                                                : Colors.grey[600],
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            lot == 'All'
                                                ? 'All Lots'
                                                : 'Lot $lot',
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.grey[800],
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
                                                  : Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              '$lotCount',
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.grey[600],
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),

                      // Footer - Reset and Apply buttons
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: Offset(0, -1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setModalState(() {
                                    selectedLine = 'All';
                                    selectedLot = 'All';
                                  });
                                  setState(() {
                                    selectedLine = 'All';
                                    selectedLot = 'All';
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  side: BorderSide(color: mycolor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Reset',
                                  style: TextStyle(
                                    color: mycolor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: mycolor,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Apply',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Method to show unit details bottom sheet
  void _showUnitDetailsDialog(Vehicle vehicle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Content - Scrollable
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // VIN Section
                          _buildDetailRow(
                            'VIN Number',
                            vehicle.vin,
                            Icons.qr_code_2,
                            Colors.blue,
                          ),
                          SizedBox(height: 16),

                          // Model Section
                          _buildDetailRow(
                            'Model',
                            vehicle.model,
                            Icons.directions_car,
                            Colors.orange,
                          ),
                          SizedBox(height: 16),

                          // Client Section
                          _buildDetailRow(
                            'Client',
                            vehicle.customer_name ?? 'N/A',
                            Icons.business,
                            Colors.green,
                          ),
                          SizedBox(height: 16),

                          // Route Section
                          _buildDetailRow(
                            'Route',
                            'Route ${vehicle.route}',
                            Icons.route,
                            Colors.purple,
                          ),
                          SizedBox(height: 16),

                          // Vehicle Line Section
                          _buildDetailRow(
                            'Vehicle Line',
                            vehicle.vehicle_line,
                            Icons.linear_scale,
                            Colors.teal,
                          ),
                          SizedBox(height: 16),

                          // LOT Section
                          _buildDetailRow(
                            'LOT Number',
                            vehicle.lot,
                            Icons.inventory_2,
                            Colors.amber,
                          ),

                          // Show additional fields if available from backend
                          if (vehicle.engine_no != null) ...[
                            SizedBox(height: 16),
                            _buildDetailRow(
                              'Engine Number',
                              vehicle.engine_no!,
                              Icons.engineering,
                              Colors.red,
                            ),
                          ],

                          if (vehicle.production_start_date != null) ...[
                            SizedBox(height: 16),
                            _buildDetailRow(
                              'Production Start Date',
                              vehicle.production_start_date!,
                              Icons.calendar_today,
                              Colors.pink,
                            ),
                          ],

                          if (vehicle.current_shop != null) ...[
                            SizedBox(height: 16),
                            _buildDetailRow(
                              'Current Shop',
                              vehicle.current_shop!,
                              Icons.factory,
                              Colors.brown,
                            ),
                          ],

                          if (vehicle.status != null) ...[
                            SizedBox(height: 16),
                            _buildDetailRow(
                              'Status',
                              vehicle.status == 0 ? 'In Progress' : 'Completed',
                              Icons.info,
                              vehicle.status == 0
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                          ],

                          // Add some padding at the bottom
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Footer - Static Close Button
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: Offset(0, -1),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mycolor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Close',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper method to build detail rows
  Widget _buildDetailRow(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
        centerTitle: false,
        title: _isSearching
            ? _buildSearchField()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.view != null ? 'Units at Line' : 'Scheduled Units',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_hasActiveFilters)
                    Text(
                      _buildFilterSubtitle(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.9),
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
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _hasActiveFilters
                  ? Colors.orange.withOpacity(0.9)
                  : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    size: 20,
                    color: _hasActiveFilters ? Colors.white : Colors.white,
                  ),
                  onPressed: _showFilterBottomSheet,
                ),
                if (_hasActiveFilters)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$_activeFiltersCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
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
                      // Active filters indicator banner
                      if (_hasActiveFilters)
                        Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.orange.shade100,
                                Colors.orange.shade50
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade600,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.filter_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Active Filters',
                                      style: TextStyle(
                                        color: Colors.orange.shade800,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      _buildFilterSubtitle(),
                                      style: TextStyle(
                                        color: Colors.orange.shade700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    selectedLine = 'All';
                                    selectedLot = 'All';
                                  });
                                },
                                icon: Icon(Icons.clear,
                                    size: 16, color: Colors.orange.shade600),
                                label: Text(
                                  'Clear',
                                  style: TextStyle(
                                    color: Colors.orange.shade600,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 8),
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
                                                      // Show unit details dialog
                                                      _showUnitDetailsDialog(
                                                          vehicle);
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
