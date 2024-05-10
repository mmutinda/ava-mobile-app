import 'package:flutter/material.dart';
import 'package:isuze_pqcs/pages/action.dart';
import 'package:isuze_pqcs/pages/home.dart';
import 'package:isuze_pqcs/pages/profile_screen.dart';

import '../widgets/bottom_persistent_nav.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _tab1navigatorKey = GlobalKey<NavigatorState>();

  final _tab2navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return PersistentBottomBarScaffold(
      items: [
        PersistentTabItem(
          tab: const Home(),
          icon: Icons.home_outlined,
          title: 'Home',
          navigatorkey: _tab1navigatorKey,
        ),
        PersistentTabItem(
          tab: ActionsTab(),
          icon: Icons.build_outlined,
          title: 'Action',
          navigatorkey: _tab2navigatorKey,
        ),
        PersistentTabItem(
          tab: ProfileScreen(),
          icon: Icons.person_2_outlined,
          title: 'Profile',
        ),
      ],
    );
  }
}
