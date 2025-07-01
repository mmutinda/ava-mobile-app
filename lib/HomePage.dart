import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:isuze_pqcs/RunningShopsDashboardWidget.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/slider.dart';
import 'package:isuze_pqcs/pages/QFL%204/qfl4.dart';
import 'package:isuze_pqcs/pages/Receiving/display_vehicles.dart';
import 'package:isuze_pqcs/pages/action.dart';
import 'package:isuze_pqcs/pages/assembly/assembly_stations.dart';
import 'package:isuze_pqcs/pages/claimforms/FiveS.dart';
import 'package:isuze_pqcs/pages/claimforms/FiveSAuditPage%20.dart';
import 'package:isuze_pqcs/pages/claimforms/NearMissForm.dart';
import 'package:isuze_pqcs/pages/claimforms/claimHome.dart';
import 'package:isuze_pqcs/pages/claimforms/nearMiss.dart';
import 'package:isuze_pqcs/pages/defetects/QCDefectsUnits.dart';
import 'package:isuze_pqcs/pages/planning/planningHome.dart';

import 'package:isuze_pqcs/pages/profile_screen.dart';
import 'package:isuze_pqcs/pages/ShopsScrean.dart';
import 'package:isuze_pqcs/pages/planning/scheduleUnits.dart';
import 'package:isuze_pqcs/qflTest.dart';
import 'package:nb_utils/nb_utils.dart';

class HomeScrean extends StatefulWidget {
  @override
  _HomeScreanState createState() => _HomeScreanState();
}

class _HomeScreanState extends State<HomeScrean> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedPage = 0;
  Map<String, dynamic> user = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
        title: Text("Home", style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: theme.primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage("images/profile1.jpg"),
                  ),
                  Text("${user['data']?['name'] ?? ''}",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  Text("${user['data']?['email'] ?? ''}",
                      style: TextStyle(fontSize: 14, color: Colors.white70)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  singleDrawerItem(FeatherIcons.home, "Dashboard", 0, theme),
                  Divider(),
                  // Section label
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      "OPERATIONS",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: theme.primaryColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  singleDrawerItem(
                      FeatherIcons.truck, "Vehicle Receiving", 5, theme),

                  singleDrawerItem(FeatherIcons.calendar, "Planning", 1, theme),
                  singleDrawerItem(
                      FeatherIcons.calendar, "Assembly", 16, theme),

                  Divider(),
                  // Section label
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      "QUALITY",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: theme.primaryColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  singleDrawerItem(FeatherIcons.folder, "QFL 3", 2, theme),
                  singleDrawerItem(FeatherIcons.folderPlus, "QFL 4", 3, theme),
                  singleDrawerItem(
                      FeatherIcons.folderPlus, "QFL 5/6", 3, theme),
                  singleDrawerItem(FeatherIcons.folderPlus, "MPA", 3, theme),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      "Claims and Defets",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: theme.primaryColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  singleDrawerItem(
                      FeatherIcons.xCircle, "Quality Defects", 14, theme),
                  singleDrawerItem(
                      FeatherIcons.messageSquare, "Claims", 15, theme),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      "SAFETY",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: theme.primaryColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  singleDrawerItem(FeatherIcons.alertTriangle,
                      "Near Miss Report", 13, theme),
                  singleDrawerItem(
                      FeatherIcons.checkSquare, "5S Audit", 12, theme),

                  Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      "OTHERS",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: theme.primaryColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  singleDrawerItem(
                      FeatherIcons.helpCircle, "Information Desk", 13, theme),
                  // singleDrawerItem(FeatherIcons.user, "Profile", 11, theme),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          BeautySlider(items: sliderItems),
          SizedBox(height: 10),
          Expanded(child: RunningShopsDashboardWidget()),
        ],
      ),
    );
  }

  Widget singleDrawerItem(
      IconData iconData, String title, int position, ThemeData theme) {
    return ListTile(
        leading: Icon(
          iconData,
          color:
              _selectedPage == position ? theme.primaryColor : Colors.grey[700],
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight:
                _selectedPage == position ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        onTap: () {
          setState(() {
            _selectedPage = position;
          });
          // Navigate based on selected position
          switch (position) {
            case 0:
              _scaffoldKey.currentState!.openEndDrawer();
              break;
            case 1:
              // SCheduleUnits().launch(context,
              PlanningHome().launch(context,
                  pageRouteAnimation: PageRouteAnimation.Slide);
              break;
            case 2:
              AuditChecklistPage().launch(context,
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
          }
        });
  }
}
