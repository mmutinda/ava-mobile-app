import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:isuze_pqcs/RunningShopsDashboardWidget.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/slider.dart';
import 'package:isuze_pqcs/pages/QFL%204/qfl4.dart';
import 'package:isuze_pqcs/pages/QFL5/6/Qfl5/Qfl56Page.dart';
import 'package:isuze_pqcs/pages/Receiving/display_vehicles.dart';
import 'package:isuze_pqcs/pages/assembly/assembly_stations.dart';
import 'package:isuze_pqcs/pages/claimforms/FiveS.dart';
import 'package:isuze_pqcs/pages/claimforms/claimHome.dart';
import 'package:isuze_pqcs/pages/claimforms/nearMiss.dart';
import 'package:isuze_pqcs/pages/defetects/QCDefectsUnits.dart';
import 'package:isuze_pqcs/pages/help/help_page.dart';
import 'package:isuze_pqcs/pages/login/login.dart';
import 'package:isuze_pqcs/pages/planning/planningHome.dart';
import 'package:isuze_pqcs/pages/profile_screen.dart';
import 'package:isuze_pqcs/pages/mpa/mpa_list.dart';
import 'package:isuze_pqcs/pages/tms/TMS_listUnits.dart';
import 'package:isuze_pqcs/pages/dispatch/dispatch_home.dart';
import 'package:nb_utils/nb_utils.dart';

class HomeScrean extends StatefulWidget {
  @override
  _HomeScreanState createState() => _HomeScreanState();
}

class _HomeScreanState extends State<HomeScrean> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RunningShopsDashboardWidgetState> _dashboardKey =
      GlobalKey<RunningShopsDashboardWidgetState>();
  late AnimationController _shimmerController;
  int _selectedPage = 0;
  Map<String, dynamic> user = {};
  Timer? _refreshTimer;
  bool _isAutoRefreshEnabled = true;
  static const int _refreshIntervalSeconds =
      30; // Auto-refresh every 30 seconds

  // Vehicle counts from API
  Map<String, int> vehicleCounts = {
    'vehicle_receiving': 0,
    'planning': 0,
    'assembly': 0,
    'dispatch': 0,
  };
  bool _isLoadingVehicleCounts = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Load user data first so we have a valid token, then fetch counts and start auto-refresh
    _loadUserData().then((_) {
      _fetchVehicleCounts();
      _startAutoRefresh();
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _stopAutoRefresh();
    super.dispose();
  }

  void _startAutoRefresh() {
    if (_isAutoRefreshEnabled) {
      _refreshTimer = Timer.periodic(
        Duration(seconds: _refreshIntervalSeconds),
        (timer) {
          if (mounted) {
            _refreshDashboard();
          }
        },
      );
    }
  }

  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  // ignore: unused_element
  void _toggleAutoRefresh() {
    setState(() {
      _isAutoRefreshEnabled = !_isAutoRefreshEnabled;
    });

    if (_isAutoRefreshEnabled) {
      _startAutoRefresh();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.refresh, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text("Auto-refresh enabled"),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      _stopAutoRefresh();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.pause, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text("Auto-refresh disabled"),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _refreshDashboard() {
    // Trigger refresh on the dashboard widget
    if (_dashboardKey.currentState != null) {
      _dashboardKey.currentState!.refreshData();
    }
    // Also refresh vehicle counts
    // _fetchVehicleCounts();
  }

  Future<void> _fetchVehicleCounts() async {
    setState(() {
      _isLoadingVehicleCounts = true;
    });

    try {
      if (user.isEmpty ||
          user['data'] == null ||
          user['data']['token'] == null) {
        print("Error: No valid user token available for vehicle counts");
        setState(() {
          _isLoadingVehicleCounts = false;
        });
        return;
      }

      final url = "${Api.api_url}vehicle-counts";
      final token = user['data']['token'];
      print("Fetching vehicle counts from: $url");

      final response = await httpget(url, token, context);
      print("Vehicle counts response: $response");

      if (response != null && response is Map && response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        setState(() {
          vehicleCounts = {
            'vehicle_receiving': data['vehicle_receiving'] ?? 0,
            'planning': data['planning'] ?? 0,
            'assembly': data['assembly'] ?? 0,
            'dispatch': data['dispatch'] ?? 0,
          };
        });
        print("Vehicle counts updated: $vehicleCounts");
      } else {
        print(
            "Failed to fetch vehicle counts: ${response?['msg'] ?? 'Unknown error'}");
      }
    } catch (e) {
      print("Error fetching vehicle counts: $e");
    } finally {
      setState(() {
        _isLoadingVehicleCounts = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    final data = await getuserdata();
    setState(() {
      user = jsonDecode(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    // Responsive breakpoints
    final isSmallPhone = screenWidth < 360;
    final isPhone = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final isDesktop = screenWidth >= 900;

    // Adaptive sizes
    final titleFontSize = isSmallPhone ? 18.0 : (isPhone ? 22.0 : 26.0);
    final drawerHeaderHeight = isLandscape ? 180.0 : (isTablet ? 280.0 : 300.0);
    final avatarRadius = isSmallPhone ? 20.0 : (isLandscape ? 25.0 : 30.0);
    final quickActionColumns = isDesktop ? 4 : (isTablet ? 3 : 2);

    final List<Map<String, String>> sliderItems = [
      {
        'image': 'images/pic1.jpg',
        'title': 'Precision Engineering',
        'description': 'Ensuring Excellence in Every Component!',
      },
      {
        'image': 'images/pic2.jpg',
        'title': 'Quality Assurance',
        'description': 'Rigorous Testing for Peak Performance!',
      },
      {
        'image': 'images/pic3.jpg',
        'title': 'Safety Standards',
        'description': 'Built to Protect, Engineered for Reliability!',
      },
      {
        'image': 'images/pic4.jpg',
        'title': 'Final Inspection',
        'description': 'Perfection in Every Detail Before the Road!',
      },
    ];
    return Scaffold(
      key: _scaffoldKey,
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
            // Container(
            //   padding: EdgeInsets.all(8),
            //   decoration: BoxDecoration(
            //     color: Colors.white.withOpacity(0.2),
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Icon(
            //     FeatherIcons.home,
            //     color: Colors.white,
            //     size: 20,
            //   ),
            // ),
            // SizedBox(width: 12),
            Text(
              "Dashboard",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: titleFontSize,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
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
                  "Online",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(5, 0),
            ),
          ],
        ),
        child: Drawer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  constraints: BoxConstraints(
                    maxHeight: drawerHeaderHeight,
                  ),
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
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: isLandscape ? 15 : 30),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: avatarRadius,
                                  backgroundImage:
                                      AssetImage("images/profile1.jpg"),
                                ),
                              ),
                              SizedBox(
                                  width: isSmallPhone
                                      ? 12
                                      : (isLandscape ? 15 : 25)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "${user['data']?['name'] ?? 'Welcome User'}",
                                        style: TextStyle(
                                          fontSize: isLandscape ? 12 : 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "${user['data']?['email'] ?? 'user@company.com'}",
                                      style: TextStyle(
                                        fontSize: isLandscape ? 9 : 11,
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isLandscape ? 10 : 20),
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(FeatherIcons.zap,
                                    color: Colors.white, size: 12),
                                SizedBox(width: 4),
                                Text(
                                  "InfoPulse System",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: isLandscape ? 9 : 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      physics: BouncingScrollPhysics(),
                      children: <Widget>[
                        singleDrawerItem(
                            FeatherIcons.home, "Dashboard", 0, theme),
                        _buildSectionDivider("OPERATIONS", theme),
                        singleDrawerItemWithBadge(
                            FeatherIcons.truck,
                            "Vehicle Receiving",
                            5,
                            theme,
                            vehicleCounts['vehicle_receiving']?.toString() ??
                                "0",
                            isLoading: _isLoadingVehicleCounts),

                        singleDrawerItemWithBadge(
                            FeatherIcons.calendar,
                            "Planning",
                            1,
                            theme,
                            vehicleCounts['planning']?.toString() ?? "0",
                            isLoading: _isLoadingVehicleCounts),
                        singleDrawerItemWithBadge(
                            FeatherIcons.calendar,
                            "Assembly",
                            16,
                            theme,
                            vehicleCounts['assembly']?.toString() ?? "0",
                            isLoading: _isLoadingVehicleCounts),
                        singleDrawerItemWithBadge(
                            FeatherIcons.send,
                            "Dispatch",
                            17,
                            theme,
                            vehicleCounts['dispatch']?.toString() ?? "0",
                            isLoading: _isLoadingVehicleCounts),
                        _buildSectionDivider("QUALITY", theme),
                        singleDrawerItem(
                            FeatherIcons.folder, "QFL 3/TMS", 2, theme),
                        singleDrawerItem(
                            FeatherIcons.folderPlus, "QFL 4", 3, theme),
                        // singleDrawerItem(
                        //     FeatherIcons.folderPlus, "QFL 5/6", 56, theme),
                        singleDrawerItem(
                            FeatherIcons.folderPlus, "MPA", 33, theme),
                        _buildSectionDivider("Claims and Defects", theme),
                        singleDrawerItem(
                            FeatherIcons.xCircle, "Quality Defects", 14, theme),
                        singleDrawerItem(
                            FeatherIcons.messageSquare, "Claims", 15, theme),
                        _buildSectionDivider("SAFETY", theme),
                        singleDrawerItem(FeatherIcons.alertTriangle,
                            "Near Miss Report", 13, theme),
                        singleDrawerItem(
                            FeatherIcons.checkSquare, "5S Audit", 12, theme),
                        _buildSectionDivider("OTHERS", theme),
                        singleDrawerItem(
                            FeatherIcons.helpCircle, "Help", 133, theme),
                        _buildSectionDivider("ACCOUNT", theme),
                        singleDrawerItem(
                            FeatherIcons.user, "My Profile", 11, theme),
                        singleDrawerItem(
                            FeatherIcons.logOut, "Logout", 99, theme),
                        SizedBox(height: 20), // Add bottom padding for scroll
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
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
            child: isLandscape
                ? _buildLandscapeLayout(theme, sliderItems)
                : _buildPortraitLayout(theme, sliderItems),
          ),
          // Auto-refresh status indicator
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.3),
              blurRadius: 15,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: isLandscape
            ? FloatingActionButton(
                onPressed: () {
                  // Show quick actions bottom sheet
                  _showQuickActionsBottomSheet(context, theme);
                },
                backgroundColor: theme.primaryColor,
                elevation: 0,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    FeatherIcons.zap,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              )
            : FloatingActionButton(
                onPressed: () {
                  // Show quick actions bottom sheet
                  _showQuickActionsBottomSheet(context, theme);
                },
                backgroundColor: theme.primaryColor,
                elevation: 0,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    FeatherIcons.zap,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
      ),
    );
  }

  void _showQuickActionsBottomSheet(BuildContext context, ThemeData theme) {
    final screenWidth = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    // Responsive breakpoints
    final isPhone = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final isDesktop = screenWidth >= 900;
    final quickActionColumns = isDesktop ? 4 : (isTablet ? 3 : 2);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: isLandscape
            ? MediaQuery.of(context).size.height * 0.85
            : (MediaQuery.of(context).size.width >= 600
                ? MediaQuery.of(context).size.height * 0.7
                : MediaQuery.of(context).size.height * 0.6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      FeatherIcons.zap,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: quickActionColumns,
                  crossAxisSpacing: isPhone ? 12 : 16,
                  mainAxisSpacing: isPhone ? 12 : 16,
                  childAspectRatio: isDesktop
                      ? 1.0
                      : (isTablet ? 1.1 : (isLandscape ? 1.0 : 1.2)),
                  children: [
                    _buildQuickActionCard(
                      FeatherIcons.truck,
                      "Vehicle\nReceiving",
                      Colors.blue,
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DisplayVehicles())),
                    ),
                    _buildQuickActionCard(
                      FeatherIcons.send,
                      "Dispatch",
                      Colors.purple,
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DispatchHome())),
                    ),
                    _buildQuickActionCard(
                      FeatherIcons.calendar,
                      "Planning",
                      Colors.green,
                      () => PlanningHome().launch(context,
                          pageRouteAnimation: PageRouteAnimation.Slide),
                    ),
                    _buildQuickActionCard(
                      FeatherIcons.folder,
                      "QFL 3/TMS",
                      Colors.orange,
                      () => TMSUnits().launch(context,
                          pageRouteAnimation: PageRouteAnimation.Slide),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
      IconData icon, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(
                  MediaQuery.of(context).size.width < 600 ? 12 : 16),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: MediaQuery.of(context).size.width < 360
                    ? 20
                    : (MediaQuery.of(context).size.width < 600 ? 24 : 28),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.width < 600 ? 8 : 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width < 360
                    ? 12
                    : (MediaQuery.of(context).size.width < 600 ? 14 : 16),
                fontWeight: FontWeight.w600,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionDivider(String title, ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Column(
        children: [
          Divider(color: Colors.grey.shade300, thickness: 0.5, height: 6),
          SizedBox(height: 2),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 9,
                color: theme.primaryColor,
                letterSpacing: 0.8,
              ),
            ),
          ),
          SizedBox(height: 2),
        ],
      ),
    );
  }

  Widget singleDrawerItem(
      IconData iconData, String title, int position, ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: _selectedPage == position
            ? theme.primaryColor.withOpacity(0.1)
            : Colors.transparent,
      ),
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        minVerticalPadding: 0,
        leading: Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: _selectedPage == position
                ? theme.primaryColor
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            iconData,
            color: _selectedPage == position ? Colors.white : Colors.grey[600],
            size: 16,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight:
                _selectedPage == position ? FontWeight.w700 : FontWeight.w500,
            color: _selectedPage == position
                ? theme.primaryColor
                : Colors.grey[800],
            fontSize: 12,
          ),
        ),
        trailing: _selectedPage == position
            ? Icon(FeatherIcons.chevronRight,
                color: theme.primaryColor, size: 14)
            : null,
        onTap: () {
          setState(() {
            _selectedPage = position;
          });
          // Navigate based on selected position
          switch (position) {
            case 0:
              _scaffoldKey.currentState!.closeDrawer();
              break;
            case 1:
              PlanningHome().launch(context,
                  pageRouteAnimation: PageRouteAnimation.Slide);
              break;
            case 56:
              QFLPage().launch(context,
                  pageRouteAnimation: PageRouteAnimation.Slide);
              break;
            case 2:
              TMSUnits().launch(context,
                  pageRouteAnimation: PageRouteAnimation.Slide);
              break;
            case 33:
              QFLThreeList().launch(context,
                  pageRouteAnimation: PageRouteAnimation.Slide);
              break;
            case 3:
              QFL4().launch(context,
                  pageRouteAnimation: PageRouteAnimation.Slide);
              break;
            case 5:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DisplayVehicles()),
              );
              break;
            case 11:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileTab()),
              );
              break;
            case 12:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DocumentListPage()),
              );
              break;
            case 13:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NearMissListPage()),
              );
              break;
            case 14:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DefectsUnit()),
              );
              break;
            case 15:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClaimHome()),
              );
              break;
            case 16:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AssemblyStations()),
              );
              break;
            case 17:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DispatchHome()),
              );
              break;
            case 133:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpPage()),
              );
              break;
            case 99:
              _showLogoutDialog(context);
              break;
          }
        },
      ),
    );
  }

  Widget _buildShimmerBadge() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment(-1.0, 0.0),
              end: Alignment(1.0, 0.0),
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [
                0.0,
                _shimmerController.value,
                1.0,
              ],
            ),
          ),
          child: Container(
            width: 16,
            height: 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      },
    );
  }

  Widget singleDrawerItemWithBadge(IconData iconData, String title,
      int position, ThemeData theme, String badgeNumber,
      {bool isLoading = false}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: _selectedPage == position
            ? theme.primaryColor.withOpacity(0.1)
            : Colors.transparent,
      ),
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        minVerticalPadding: 0,
        leading: Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: _selectedPage == position
                ? theme.primaryColor
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            iconData,
            color: _selectedPage == position ? Colors.white : Colors.grey[600],
            size: 16,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight:
                _selectedPage == position ? FontWeight.w700 : FontWeight.w500,
            color: _selectedPage == position
                ? theme.primaryColor
                : Colors.grey[800],
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show shimmer while loading, or badge only if count > 0
            if (isLoading)
              _buildShimmerBadge()
            else if (badgeNumber != '0' && badgeNumber.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  badgeNumber,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (_selectedPage == position) ...[
              SizedBox(width: 8),
              Icon(FeatherIcons.chevronRight,
                  color: theme.primaryColor, size: 14),
            ],
          ],
        ),
        onTap: () {
          setState(() {
            _selectedPage = position;
          });
          // Navigate based on selected position
          switch (position) {
            case 0:
              _scaffoldKey.currentState!.closeDrawer();
              break;
            case 1:
              PlanningHome().launch(context,
                  pageRouteAnimation: PageRouteAnimation.Slide);
              break;
            case 56:
              QFLPage().launch(context,
                  pageRouteAnimation: PageRouteAnimation.Slide);
              break;
            case 2:
              TMSUnits().launch(context,
                  pageRouteAnimation: PageRouteAnimation.Slide);
              break;
            case 33:
              QFLThreeList().launch(context,
                  pageRouteAnimation: PageRouteAnimation.Slide);
              break;
            case 3:
              QFL4().launch(context,
                  pageRouteAnimation: PageRouteAnimation.Slide);
              break;
            case 5:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DisplayVehicles()),
              );
              break;
            case 11:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileTab()),
              );
              break;
            case 12:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DocumentListPage()),
              );
              break;
            case 13:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NearMissListPage()),
              );
              break;
            case 14:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DefectsUnit()),
              );
              break;
            case 15:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClaimHome()),
              );
              break;
            case 16:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AssemblyStations()),
              );
              break;
            case 17:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DispatchHome()),
              );
              break;
            case 133:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpPage()),
              );
              break;
            case 99:
              _showLogoutDialog(context);
              break;
          }
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.shade400, Colors.red.shade600],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(FeatherIcons.logOut, color: Colors.white, size: 20),
                ),
                SizedBox(width: 12),
                Text(
                  "Confirm Logout",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          content: Text(
            "Are you sure you want to logout from your account?",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade400, Colors.red.shade600],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _performLogout();
                },
                child: Text(
                  "Logout",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
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
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Logging you out...",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      // Clear user data
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Close loading dialog
      Navigator.pop(context);

      // Navigate to login page
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Login()),
        (_) => false,
      );
    } catch (e) {
      // Close loading dialog if still open
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error during logout. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Portrait layout - original vertical layout
  Widget _buildPortraitLayout(
      ThemeData theme, List<Map<String, String>> sliderItems) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalMargin =
        screenWidth < 360 ? 12.0 : (screenWidth < 600 ? 16.0 : 24.0);
    final sliderHeight =
        screenWidth < 360 ? 150.0 : (screenWidth < 600 ? 200.0 : 250.0);

    return Column(
      children: [
        // Image Slider
        Container(
          height: sliderHeight,
          margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BeautySlider(items: sliderItems),
          ),
        ),
        SizedBox(height: 16),
        // Dashboard Content
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              child: RunningShopsDashboardWidget(key: _dashboardKey),
            ),
          ),
        ),
      ],
    );
  }

  // Landscape layout - side by side layout
  Widget _buildLandscapeLayout(
      ThemeData theme, List<Map<String, String>> sliderItems) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final isDesktop = screenWidth >= 900;
    final horizontalPadding = isTablet ? 20.0 : (isDesktop ? 32.0 : 16.0);

    return Padding(
      padding: EdgeInsets.all(horizontalPadding),
      child: Row(
        children: [
          // Left side - Image Slider
          Expanded(
            flex: isDesktop ? 2 : 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BeautySlider(items: sliderItems),
              ),
            ),
          ),
          SizedBox(width: 16),
          // Right side - Dashboard Content
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: RunningShopsDashboardWidget(key: _dashboardKey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
