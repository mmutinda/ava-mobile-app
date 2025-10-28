import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:intl/intl.dart';

class VehicleDetails extends StatefulWidget {
  final String vehicleId;

  const VehicleDetails({Key? key, required this.vehicleId}) : super(key: key);

  @override
  _VehicleDetailsState createState() => _VehicleDetailsState();
}

class _VehicleDetailsState extends State<VehicleDetails>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> movementHistory = [];
  List<dynamic> routingHistory = [];
  bool isLoadingMovement = true;
  bool isLoadingRouting = true;
  bool hasMovementError = false;
  bool hasRoutingError = false;
  String movementErrorMessage = '';
  String routingErrorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchMovementHistory();
    fetchRoutingHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';

    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return 'N/A';

    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString; // Return original if parsing fails
    }
  }

  String _calculateDuration(String? dateIn, String? dateOut) {
    if (dateIn == null ||
        dateOut == null ||
        dateIn.isEmpty ||
        dateOut.isEmpty) {
      return 'N/A';
    }

    try {
      DateTime inDate = DateTime.parse(dateIn);
      DateTime outDate = DateTime.parse(dateOut);
      Duration difference = outDate.difference(inDate);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ${difference.inHours % 24}h';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ${difference.inMinutes % 60}m';
      } else {
        return '${difference.inMinutes}m';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  Future<void> fetchMovementHistory() async {
    try {
      setState(() {
        isLoadingMovement = true;
        hasMovementError = false;
      });

      final userData = await getuserdata();
      final user = jsonDecode(userData);
      final token = user['data']?['token'] ?? '';

      if (token.isEmpty) {
        setState(() {
          hasMovementError = true;
          movementErrorMessage = 'Authentication token not found';
          isLoadingMovement = false;
        });
        return;
      }

      final url = '${Api.api_url}movementhistory/${widget.vehicleId}';
      final response = await httpget(url, token, context);

      if (response != null && response['success'] == true) {
        setState(() {
          movementHistory = response['data'] ?? [];
          isLoadingMovement = false;
        });
      } else {
        setState(() {
          hasMovementError = true;
          movementErrorMessage =
              response?['message'] ?? 'Failed to fetch movement history';
          isLoadingMovement = false;
        });
      }
    } catch (e) {
      setState(() {
        hasMovementError = true;
        movementErrorMessage = 'Error: ${e.toString()}';
        isLoadingMovement = false;
      });
    }
  }

  Future<void> fetchRoutingHistory() async {
    try {
      setState(() {
        isLoadingRouting = true;
        hasRoutingError = false;
      });

      final userData = await getuserdata();
      final user = jsonDecode(userData);
      final token = user['data']?['token'] ?? '';

      if (token.isEmpty) {
        setState(() {
          hasRoutingError = true;
          routingErrorMessage = 'Authentication token not found';
          isLoadingRouting = false;
        });
        return;
      }

      final url = '${Api.api_url}routinghistory/${widget.vehicleId}';
      final response = await httpget(url, token, context);

      if (response != null && response['success'] == true) {
        setState(() {
          routingHistory = response['data'] ?? [];
          isLoadingRouting = false;
        });
      } else {
        setState(() {
          hasRoutingError = true;
          routingErrorMessage =
              response?['message'] ?? 'Failed to fetch routing history';
          isLoadingRouting = false;
        });
      }
    } catch (e) {
      setState(() {
        hasRoutingError = true;
        routingErrorMessage = 'Error: ${e.toString()}';
        isLoadingRouting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                FeatherIcons.truck,
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
                    "Vehicle Details",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    widget.vehicleId,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(FeatherIcons.refreshCw, color: Colors.white),
            onPressed: () {
              fetchMovementHistory();
              fetchRoutingHistory();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          unselectedLabelStyle:
              TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          tabs: [
            Tab(
              icon: Icon(FeatherIcons.mapPin, size: 18),
              text: "Movement History",
            ),
            Tab(
              icon: Icon(FeatherIcons.navigation, size: 18),
              text: "Routing History",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMovementHistoryTab(),
          _buildRoutingHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildMovementHistoryTab() {
    if (isLoadingMovement) {
      return _buildLoadingWidget('Loading movement history...');
    }

    if (hasMovementError) {
      return _buildErrorWidget(
        'Movement History Error',
        movementErrorMessage,
        fetchMovementHistory,
      );
    }

    if (movementHistory.isEmpty) {
      return _buildEmptyWidget(
        'No Movement History',
        'There is no movement history available for this vehicle.',
        FeatherIcons.mapPin,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: movementHistory.length,
      itemBuilder: (context, index) {
        final movement = movementHistory[index];
        return _buildMovementCard(
            movement, index == movementHistory.length - 1);
      },
    );
  }

  Widget _buildRoutingHistoryTab() {
    if (isLoadingRouting) {
      return _buildLoadingWidget('Loading routing history...');
    }

    if (hasRoutingError) {
      return _buildErrorWidget(
        'Routing History Error',
        routingErrorMessage,
        fetchRoutingHistory,
      );
    }

    if (routingHistory.isEmpty) {
      return _buildEmptyWidget(
        'No Routing History',
        'There is no routing history available for this vehicle.',
        FeatherIcons.navigation,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: routingHistory.length,
      itemBuilder: (context, index) {
        final routing = routingHistory[index];
        return _buildRoutingCard(routing, index == routingHistory.length - 1);
      },
    );
  }

  Widget _buildLoadingWidget(String message) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String title, String message, VoidCallback onRetry) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                FeatherIcons.alertCircle,
                color: Colors.red,
                size: 32,
              ),
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(FeatherIcons.refreshCw),
              label: Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(String title, String message, IconData icon) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.grey,
                size: 32,
              ),
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovementCard(Map<String, dynamic> movement, bool isLast) {
    final theme = Theme.of(context);
    final shop = movement['shop'] as Map<String, dynamic>?;
    final user = movement['user'] as Map<String, dynamic>?;
    final shopColorCode = shop?['color_code']?.toString();

    // Parse shop color or use default
    Color shopColor = theme.primaryColor;
    if (shopColorCode != null && shopColorCode.isNotEmpty) {
      try {
        shopColor = Color(int.parse(shopColorCode.replaceFirst('#', '0xFF')));
      } catch (e) {
        shopColor = theme.primaryColor;
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: shopColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: shopColor.withOpacity(0.3),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 80,
                  color: Colors.grey.shade300,
                ),
            ],
          ),
          SizedBox(width: 16),
          // Card content
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: shopColor.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shop Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: shopColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          FeatherIcons.mapPin,
                          color: shopColor,
                          size: 16,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shop?['shop_name']?.toString() ?? 'Unknown Shop',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              'Shop #${shop?['shop_no']?.toString() ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: shopColor.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: shopColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: shopColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          movement['current_position']?.toString() ?? 'InShop',
                          style: TextStyle(
                            color: shopColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  // Time Information
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildTimeInfoItem(
                                'Date In',
                                _formatDate(
                                    movement['datetime_in']?.toString()),
                                FeatherIcons.logIn,
                                Colors.green,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildTimeInfoItem(
                                'Date Out',
                                _formatDate(
                                    movement['datetime_out']?.toString()),
                                FeatherIcons.logOut,
                                Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                FeatherIcons.clock,
                                size: 12,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Duration: ${_calculateDuration(movement['datetime_in']?.toString(), movement['datetime_out']?.toString())}',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12),

                  // Additional Information
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoChip(
                          'Done By',
                          movement['done_by']?.toString() ?? 'N/A',
                          FeatherIcons.user,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoChip(
                          'Route',
                          'Route ${movement['route_number']?.toString() ?? 'N/A'}',
                          FeatherIcons.navigation,
                        ),
                      ),
                    ],
                  ),

                  // User Information
                  if (user != null) ...[
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: shopColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: shopColor.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            FeatherIcons.user,
                            size: 14,
                            color: shopColor,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${user['name']?.toString() ?? 'Unknown'} (${user['username']?.toString() ?? 'N/A'})',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfoItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 12,
              color: color,
            ),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 12,
            color: Colors.grey[600],
          ),
          SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutingCard(Map<String, dynamic> routing, bool isLast) {
    final routingData = routing['routing'] as Map<String, dynamic>?;
    final shop = routing['shop'] as Map<String, dynamic>?;
    final doneby = routing['doneby'] as Map<String, dynamic>?;
    final getDefects = routing['get_defects'] as Map<String, dynamic>?;

    final answer = routing['answer']?.toString();
    final shopColorCode = shop?['color_code']?.toString();
    final hasDefect = getDefects != null;
    final isOK = answer == 'OK';

    // Parse shop color or use default
    Color shopColor = Theme.of(context).primaryColor;
    if (shopColorCode != null && shopColorCode.isNotEmpty) {
      try {
        shopColor = Color(int.parse(shopColorCode.replaceFirst('#', '0xFF')));
      } catch (e) {
        shopColor = Theme.of(context).primaryColor;
      }
    }

    // Determine status color based on answer
    Color statusColor = isOK ? Colors.green : Colors.red;
    IconData statusIcon =
        isOK ? FeatherIcons.checkCircle : FeatherIcons.xCircle;

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withOpacity(0.3),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 120,
                  color: Colors.grey.shade300,
                ),
            ],
          ),
          SizedBox(width: 16),
          // Card content
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Query Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          statusIcon,
                          color: statusColor,
                          size: 16,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              routingData?['query_name']?.toString() ??
                                  'Unknown Query',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: statusColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          answer ?? 'N/A',
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),
                  // Shop Information
                  if (shop != null) ...[
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: shopColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: shopColor.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: shopColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              FeatherIcons.mapPin,
                              color: shopColor,
                              size: 14,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  shop['shop_name']?.toString() ??
                                      'Unknown Shop',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                Text(
                                  'Shop #${shop['shop_no']?.toString() ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: shopColor.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                  ],

                  // Instruction & Parts Information
                  if (routingData != null) ...[
                    if (routingData['instruction'] != null &&
                        routingData['instruction'].toString().isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.blue.withOpacity(0.1)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              FeatherIcons.info,
                              size: 14,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Instructions',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    _stripHtmlTags(
                                        routingData['instruction'].toString()),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                    ],
                    if (routingData['parts_to_scan'] != null &&
                        routingData['parts_to_scan'].toString().isNotEmpty) ...[
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.purple.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FeatherIcons.package,
                              size: 12,
                              color: Colors.purple,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Parts: ${routingData['parts_to_scan']}',
                              style: TextStyle(
                                color: Colors.purple,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                    ],
                  ],

                  // Time Information
                  Row(
                    children: [
                      Expanded(
                        child: _buildRoutingInfoItem(
                          'Date/Time',
                          _formatDateTime(routing['created_at']?.toString()),
                          FeatherIcons.clock,
                        ),
                      ),
                      // Done By Information
                      if (doneby != null) ...[
                        Expanded(
                          child: _buildRoutingInfoItem(
                            'Done By',
                            doneby['name']?.toString() ?? 'Unknown',
                            FeatherIcons.userCheck,
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ],
                  ),

                  SizedBox(height: 8),

                  // Defect Description
                  if (routing['defect_description'] != null &&
                      routing['defect_description'].toString().isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.orange.withOpacity(0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            FeatherIcons.alertTriangle,
                            size: 14,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Defect Description',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  routing['defect_description'].toString(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                  ],

                  // Defect Details
                  if (hasDefect) ...[
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                FeatherIcons.alertCircle,
                                size: 14,
                                color: Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Defect Information',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDefectInfoItem(
                                  'Category',
                                  getDefects['defect_category']?.toString() ??
                                      'N/A',
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: _buildDefectInfoItem(
                                  'Repaired',
                                  getDefects['repaired']?.toString() ?? 'N/A',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDefectInfoItem(
                                  'Corrected By',
                                  getDefects['defect_corrected_by']
                                          ?.toString() ??
                                      'N/A',
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: _buildDefectInfoItem(
                                  'Status',
                                  getDefects['is_complete']?.toString() ??
                                      'N/A',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Image indicator
                  if (routing['icon'] != null &&
                      routing['icon'].toString().isNotEmpty) ...[
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            FeatherIcons.camera,
                            size: 12,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Image Attached',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutingInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 12,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 1),
              Text(
                value,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
      case 'arrived':
        return Colors.green;
      case 'in_transit':
      case 'in transit':
      case 'moving':
        return Colors.blue;
      case 'pending':
      case 'waiting':
        return Colors.orange;
      case 'delayed':
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _stripHtmlTags(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').trim();
  }

  Widget _buildDefectInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
