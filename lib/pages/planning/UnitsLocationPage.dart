import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/models/qc_inpection.dart';
import 'package:isuze_pqcs/models/units_location.dart';

class UnitsLocationPage extends StatefulWidget {
  final String locationId;
  final String locationName;
  final IconData locationIcon;
  final Color locationColor;

  const UnitsLocationPage({
    super.key,
    required this.locationId,
    required this.locationName,
    required this.locationIcon,
    required this.locationColor,
  });

  @override
  State<UnitsLocationPage> createState() => _UnitsLocationPageState();
}

class _UnitsLocationPageState extends State<UnitsLocationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<UnitsLocationResponse> unitResponses = [];
  List<Vehicle> vehicles = [];
  var user = {};
  bool isLoading = false;
  String message = '';

  TextEditingController searchController = TextEditingController();
  String searchText = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      fetchData();
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (isLoading) {
      EasyLoading.dismiss();
    }
    super.dispose();
  }

  Future<void> fetchData() async {
    final shouldShowLoading = unitResponses.isEmpty;

    if (shouldShowLoading) {
      EasyLoading.show(
        status: "Loading ${widget.locationName.toLowerCase()} units...",
        maskType: EasyLoadingMaskType.black,
      );
    }

    setState(() {
      isLoading = shouldShowLoading;
      message = '';
    });

    // API endpoint based on location ID
    final url = "${Api.api_url}unitsinshop/${widget.locationId}";
    // final url = "${Api.api_url}unitsinshop/4";
    print("Fetching from: $url");

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
        final List<UnitsLocationResponse> fetchedUnits =
            (response['data'] as List)
                .map((unitData) => UnitsLocationResponse.fromJson(unitData))
                .toList();

        // Convert to Vehicle objects for compatibility with existing UI
        final List<Vehicle> fetchedVehicles =
            fetchedUnits.map((unit) => unit.toVehicle()).toList();

        setState(() {
          unitResponses = fetchedUnits;
          vehicles = fetchedVehicles;
          isLoading = false;
          message = '';
        });

        if (vehicles.isEmpty) {
          setState(() {
            message = "No ${widget.locationName.toLowerCase()} units found.";
          });
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

  Widget _buildLocationCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.locationColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: mycolor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              widget.locationIcon,
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
                  "Units at ${widget.locationName}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    // color: widget.locationColor,s
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Track and monitor unit status",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  "Live",
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
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
                    // color: widget.locationColor,
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
    );
  }

  List<Vehicle> get filteredVehicles {
    if (searchText.isEmpty) return vehicles;

    return vehicles.where((vehicle) {
      return vehicle.vin.toLowerCase().contains(searchText.toLowerCase()) ||
          vehicle.model.toLowerCase().contains(searchText.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Sort vehicles by creation date (newest first)
    vehicles.sort((a, b) =>
        DateTime.parse(b.created_at).compareTo(DateTime.parse(a.created_at)));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: _isSearching
            ? _buildSearchField()
            : Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.locationIcon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Units at ${widget.locationName}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (vehicles.isNotEmpty)
                          Text(
                            '${filteredVehicles.length} units',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: Colors.white70,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
        actions: [
          IconButton(
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
          if (!_isSearching)
            IconButton(
              icon: Icon(Icons.refresh, size: 24),
              onPressed: fetchData,
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          child: isLoading
              ? Center(child: SizedBox.shrink())
              : message.isNotEmpty
                  ? ErrorMessageWidget(
                      errorMessage: message,
                      onRetry: () {
                        fetchData();
                      },
                    )
                  : Column(
                      children: [
                        // Location info card
                        _buildLocationCard(),

                        // Stats header
                        if (vehicles.isNotEmpty) _buildStatsHeader(),

                        SizedBox(height: 16),

                        // Units list
                        Expanded(
                          child: filteredVehicles.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: filteredVehicles.length,
                                  itemBuilder: (context, index) {
                                    final vehicle = filteredVehicles[index];
                                    final unitResponse =
                                        unitResponses.isNotEmpty &&
                                                index < unitResponses.length
                                            ? unitResponses[index]
                                            : null;
                                    return AnimatedBuilder(
                                      animation: _animationController,
                                      builder: (context, child) {
                                        final slideAnimation = Tween<Offset>(
                                          begin: Offset(1.0, 0.0),
                                          end: Offset.zero,
                                        ).animate(CurvedAnimation(
                                          parent: _animationController,
                                          curve: Interval(
                                            (index * 0.1).clamp(0.0, 1.0),
                                            ((index * 0.1) + 0.3)
                                                .clamp(0.0, 1.0),
                                            curve: Curves.easeOutBack,
                                          ),
                                        ));

                                        return SlideTransition(
                                          position: slideAnimation,
                                          child: _buildVehicleCard(
                                              vehicle, unitResponse, index),
                                        );
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.locationColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                widget.locationIcon,
                size: 48,
                color: widget.locationColor,
              ),
            ),
            SizedBox(height: 24),
            Text(
              searchText.isNotEmpty
                  ? 'No units found for "${searchText}"'
                  : 'No Units at ${widget.locationName}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 12),
            Text(
              searchText.isNotEmpty
                  ? 'Try adjusting your search terms'
                  : 'No units are currently at this location.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            if (searchText.isNotEmpty) ...[
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    searchController.clear();
                    searchText = '';
                  });
                },
                icon: Icon(Icons.clear),
                label: Text('Clear Search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.locationColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(
      Vehicle vehicle, UnitsLocationResponse? unitResponse, int index) {
    if (vehicle.cabin_cockpit_moved == '1') {
    } else if (vehicle.chasis_moved == '1') {}

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: mycolor.withOpacity(0.2),
            width: 1,
          ),
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
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: widget.locationColor.withOpacity(0.3),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.model,
                        style: TextStyle(
                          color: Colors.amber[900],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      // Enhanced VIN display
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: mycolor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: mycolor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
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
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                vehicle.vin,
                                style: TextStyle(
                                  color: mycolor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  fontFamily: 'monospace',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 6),
                          Text(
                            'LOT: ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            vehicle.lot,
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (vehicle.customer_name != null) ...[
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.business_outlined,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                vehicle.customer_name.toString(),
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      // Additional info from UnitsLocationResponse
                      if (unitResponse != null) ...[
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Position: ',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                unitResponse.currentPosition,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.route_outlined,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Route: ',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${unitResponse.routeNumber}',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
// aging information
            Row(
              children: [
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        unitResponse != null ? 'AT LOCATION' : 'CREATED',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        unitResponse != null
                            ? unitResponse.calculateAgeing()
                            : calculateAgeing(vehicle.created_at),
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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
