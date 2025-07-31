import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/pages/Receiving/QcList.dart';
import 'package:isuze_pqcs/pages/Receiving/form_receiving.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class DisplayVehicles extends StatefulWidget {
  final isPlanning;

  const DisplayVehicles({super.key, this.isPlanning = false});
  @override
  State<DisplayVehicles> createState() => _DisplayVehiclesState();
}

class _DisplayVehiclesState extends State<DisplayVehicles>
    with SingleTickerProviderStateMixin {
  var user = {};
  var vehicles = [];
  // var vehicles;
  var loadingText = '';
  bool isLoading = false;
  String selectedBay = 'Bay 1'; // Default to Bay 1
  String selectedRoute = 'Route 1';
  TextEditingController searchController = TextEditingController();
  String searchText = '';
  bool _isSearching = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Color> colors = [
    mycolor,
    // Colors.amber.shade900,
    // Colors.indigo,
    // Colors.teal,
  ];
  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
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
      if (mounted) {
        setState(() {
          user = jsonDecode(value);
        });
        fetchVehicles().then(
          (value) {
            if (mounted) {
              _animationController.forward();
            }
          },
        ).catchError((error) {
          print("Initial fetchVehicles error: $error");
          if (mounted) {
            _animationController.forward();
          }
        });
      }
    }).catchError((error) {
      print("Error getting user data: $error");
      if (mounted) {
        setState(() {
          loadingText = 'Failed to load user data. Please restart the app.';
        });
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    Widget _buildSearchField() {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(25),
        ),
        child: TextField(
          autofocus: true,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
          cursorColor: Colors.white,
          controller: searchController,
          onChanged: (value) {
            setState(() {
              searchText = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search chassis or registration...',
            border: InputBorder.none,
            hintStyle: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              FeatherIcons.search,
              color: Colors.white.withOpacity(0.8),
              size: 20,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.primaryColor,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primaryColor,
                theme.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
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
                      widget.isPlanning == 'Yes'
                          ? FeatherIcons.calendar
                          : FeatherIcons.truck,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    widget.isPlanning == 'Yes'
                        ? "Scheduled Lots"
                        : 'Received Lots',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _isSearching ? FeatherIcons.x : FeatherIcons.search,
                  color: Colors.white,
                  size: 20,
                ),
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
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header Stats Card
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primaryColor.withOpacity(0.1),
                    theme.primaryColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.1),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      FeatherIcons.package,
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
                          widget.isPlanning == 'Yes'
                              ? "Scheduled Vehicles"
                              : "Received Vehicles",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: theme.primaryColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Total: ${vehicles.length} lots",
                          style: GoogleFonts.poppins(
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
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(FeatherIcons.list, color: Colors.blue, size: 14),
                        SizedBox(width: 6),
                        Text(
                          "List",
                          style: GoogleFonts.poppins(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: RefreshIndicator(
                color: theme.primaryColor,
                backgroundColor: Colors.white,
                strokeWidth: 3,
                onRefresh: () async {
                  try {
                    await fetchVehicles();
                    // Only show success message if no error occurred
                    if (mounted && loadingText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(FeatherIcons.refreshCw,
                                  color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Data refreshed successfully!',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    // Error is already handled in fetchVehicles(), just log it
                    print("Refresh error: $e");
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(FeatherIcons.alertCircle,
                                  color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Refresh failed. Please try again.',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: isLoading
                      ? _buildLoadingWidget(theme)
                      : loadingText.isNotEmpty
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: _buildErrorWidget(theme),
                            )
                          : _buildVehiclesList(theme),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.isPlanning == 'Yes'
          ? null
          : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primaryColor,
                    theme.primaryColor.withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return ReceivingForm();
                    },
                  )).then(
                    (value) async {
                      try {
                        await fetchVehicles();
                        // Success is handled in fetchVehicles
                      } catch (e) {
                        // Error handling is already done in fetchVehicles
                        print("Navigation callback error: $e");
                      }
                    },
                  );
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Icon(
                  FeatherIcons.plus,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingWidget(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Loading vehicles...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme) {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FeatherIcons.alertCircle, color: Colors.red, size: 48),
          SizedBox(height: 16),
          Text(
            'No Data Available',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.red[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            loadingText,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.red[600],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                await fetchVehicles();
                // Success message is handled in fetchVehicles if successful
              } catch (e) {
                // Error handling is already done in fetchVehicles
                print("Retry button error: $e");
              }
            },
            icon: Icon(FeatherIcons.refreshCw, size: 18),
            label: Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesList(ThemeData theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          // Sort vehicles by delivery_date in descending order
          vehicles.sort((a, b) {
            // Assuming delivery_date is in a format that can be directly compared as strings
            return b['created_at'].compareTo(a['created_at']);
          });
          var vehicle = vehicles[index];
          var vin_no = vehicle["vin_no"];
          var engine_no = vehicles[index]["engine_no"];
          var client = vehicles[index]["customer"]["name"];
          Color categoryColor = colors[index % colors.length];

          if (searchText.isNotEmpty &&
              !(vin_no.toLowerCase().contains(searchText.toLowerCase()) ||
                  engine_no.toLowerCase().contains(searchText.toLowerCase()) ||
                  client.toLowerCase().contains(searchText.toLowerCase()))) {
            return Container(); // Return an empty container if not matching
          }

          return _buildVehicleCard(vehicle, index, categoryColor, theme);
        },
      ),
    );
  }

  Widget _buildVehicleCard(
      Map vehicle, int index, Color categoryColor, ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (widget.isPlanning == 'Yes') {
              _showBaySelectionDialog(vehicle, index);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QClist(
                    Id: vehicles[index]['id'],
                    LotNo: vehicles[index]['lot_number'],
                  ),
                ),
              ).then((value) async {
                try {
                  await fetchVehicles();
                } catch (e) {
                  print("Navigation return callback error: $e");
                }
              });
            }
          },
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            categoryColor,
                            categoryColor.withOpacity(0.8)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: categoryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        "${index + 1}",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicles[index]['model']?['model_name'] ??
                                'Unknown Model',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(FeatherIcons.hash,
                                  size: 14, color: Colors.grey[600]),
                              SizedBox(width: 6),
                              Text(
                                'LOT: ${vehicles[index]['lot_number']}',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: theme.primaryColor,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(FeatherIcons.layers,
                                  size: 14, color: Colors.grey[600]),
                              SizedBox(width: 6),
                              Text(
                                'QTY: ${vehicles[index]['lot_qty'] ?? 'N/A'}',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (vehicles[index]['customer'] != null)
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber[900],
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          vehicles[index]['customer']?['name'] ?? '',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [categoryColor, categoryColor.withOpacity(0.8)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: categoryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        if (widget.isPlanning == 'Yes') {
                          _showBaySelectionDialog(vehicle, index);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QClist(
                                Id: vehicles[index]['id'],
                                LotNo: vehicles[index]['lot_number'],
                              ),
                            ),
                          ).then((value) async {
                            try {
                              await fetchVehicles();
                            } catch (e) {
                              print("Button navigation callback error: $e");
                            }
                          });
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.isPlanning == 'Yes'
                                  ? FeatherIcons.send
                                  : FeatherIcons.eye,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              widget.isPlanning == 'Yes'
                                  ? "PUSH TO BAY"
                                  : "SELECT",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontSize: 14,
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
          ),
        ),
      ),
    );
  }

  void _showBaySelectionDialog(Map vehicle, int index) {
    String? selectedBay = 'Bay 1';
    String? selectedRoute = 'Route 1';

    // ID maps
    final bayIds = {
      'Bay 1': 'Bay 1',
      'Bay 2': 'Bay 2',
      'Bay 3': 'Bay 3',
      'Bay 4': 'Bay 4',
      'Bus Bay': 'Bus Bay',
    };
    final routeIds = {'Route 1': '1', 'Route 2': '2', 'Route 3': '3'};

    showDialog(
      context: context,
      builder: (BuildContext context) {
        ThemeData theme = Theme.of(context);
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.primaryColor,
                            theme.primaryColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              FeatherIcons.navigation,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Text(
                            'Choose Bay and Route',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildStyledDropdown(
                            value: selectedBay!,
                            items: [
                              'Bay 1',
                              'Bay 2',
                              'Bay 3',
                              'Bay 4',
                              'Bus Bay'
                            ],
                            label: 'Select Bay',
                            icon: FeatherIcons.mapPin,
                            onChanged: (value) {
                              setState(() {
                                selectedBay = value;
                              });
                            },
                          ),
                          SizedBox(height: 20),
                          _buildStyledDropdown(
                            value: selectedRoute!,
                            items: ['Route 1', 'Route 2', 'Route 3'],
                            label: 'Select Route',
                            icon: FeatherIcons.navigation,
                            onChanged: (value) {
                              setState(() {
                                selectedRoute = value;
                              });
                            },
                          ),
                          SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.primaryColor,
                                  theme.primaryColor.withOpacity(0.8),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.primaryColor.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () async {
                                  final fields = {
                                    'vehicle_receiving_id': vehicles[index]
                                        ['id'],
                                    'vehicle_bay': bayIds[selectedBay],
                                    'vehicle_route': routeIds[selectedRoute],
                                  };

                                  await submitForm(
                                    context: context,
                                    url: '${Api.api_url}pushBay',
                                    fields: fields,
                                    token: user['data']['token'],
                                  );
                                  print(fields);
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(FeatherIcons.send,
                                          color: Colors.white, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'PUSH TO $selectedBay',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
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
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStyledDropdown({
    required String value,
    required List<String> items,
    required String label,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            onChanged: onChanged,
            items: items.map<DropdownMenuItem<String>>((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              );
            }).toList(),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: Theme.of(context).primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Future fetchVehicles() async {
    // Initialize loading state
    setState(() {
      loadingText = '';
      isLoading = vehicles.isEmpty ? true : false;
    });

    ProgressDialog? pr;

    try {
      // Validate user data
      if (user.isEmpty ||
          user['data'] == null ||
          user['data']['token'] == null) {
        throw Exception(
            'User authentication data is missing. Please login again.');
      }

      // Construct URL
      String url = widget.isPlanning == 'Yes'
          ? "${Api.api_url}loadSheduledLot"
          : "${Api.api_url}loadVehicleReceivingLots";
      print("Fetching vehicles from URL: $url");

      // Initialize progress dialog
      pr = ProgressDialog(context,
          type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
      pr.style(
        message: 'Fetching vehicles...',
        borderRadius: 8,
        backgroundColor: Colors.white,
        progressWidget: const SizedBox(
            width: 20,
            height: 20,
            child: Center(child: CircularProgressIndicator())),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
      );

      // Set up timeout for the request (handled internally by httpget function)
      // Make API request
      var responsedata = await httpget(url, user['data']["token"], context);

      // Handle successful response
      if (responsedata != null) {
        // Hide progress dialog safely
        if (pr.isShowing()) {
          await pr.hide();
        }

        // Validate response structure
        if (responsedata is Map<String, dynamic>) {
          if (responsedata.containsKey("data")) {
            // Check if data is a list
            if (responsedata["data"] is List) {
              List<dynamic> vehicleData = responsedata["data"] as List<dynamic>;

              setState(() {
                isLoading = false;
                vehicles = vehicleData;
                loadingText = vehicleData.isEmpty
                    ? 'No vehicles available at the moment'
                    : '';
              });

              print("Successfully loaded ${vehicleData.length} vehicles");
            } else {
              throw Exception(
                  'Invalid data format: Expected list but received ${responsedata["data"].runtimeType}');
            }
          } else if (responsedata.containsKey("message")) {
            // Handle API error with message
            throw Exception(responsedata["message"].toString());
          } else {
            throw Exception(
                'Invalid response format: Missing data or message field');
          }
        } else {
          throw Exception(
              'Invalid response format: Expected Map but received ${responsedata.runtimeType}');
        }
      } else {
        // Handle null response
        throw Exception(
            'No response received from server. Please check your internet connection.');
      }
    } catch (e) {
      print("Error in fetchVehicles: $e");

      // Hide progress dialog safely if it exists
      if (pr != null && pr.isShowing()) {
        try {
          await pr.hide();
        } catch (hideError) {
          print("Error hiding progress dialog: $hideError");
        }
      }

      // Determine error message based on error type
      String errorMessage;
      if (e.toString().contains('SocketException') ||
          e.toString().contains('NetworkImageLoadException') ||
          e.toString().contains('Connection failed')) {
        errorMessage =
            'No internet connection. Please check your network and try again.';
      } else if (e.toString().contains('TimeoutException') ||
          e.toString().contains('timed out')) {
        errorMessage = 'Request timed out. Please try again.';
      } else if (e.toString().contains('FormatException') ||
          e.toString().contains('Invalid data format')) {
        errorMessage = 'Server returned invalid data. Please contact support.';
      } else if (e.toString().contains('authentication') ||
          e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        errorMessage = 'Authentication failed. Please login again.';
      } else if (e.toString().contains('403') ||
          e.toString().contains('Forbidden')) {
        errorMessage =
            'Access denied. You don\'t have permission to view this data.';
      } else if (e.toString().contains('404') ||
          e.toString().contains('Not Found')) {
        errorMessage = 'Service not found. Please contact support.';
      } else if (e.toString().contains('500') ||
          e.toString().contains('Server Error')) {
        errorMessage = 'Server error occurred. Please try again later.';
      } else {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }

      // Update UI with error state
      setState(() {
        isLoading = false;
        loadingText = errorMessage;
      });

      // Show error toast for network/auth errors
      if (e.toString().contains('internet') ||
          e.toString().contains('network') ||
          e.toString().contains('authentication')) {
        try {
          toasty(context, errorMessage,
              bgColor: Colors.red, textColor: Colors.white);
        } catch (toastError) {
          print("Error showing toast: $toastError");
        }
      }
    } finally {
      // Ensure loading state is always reset
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
