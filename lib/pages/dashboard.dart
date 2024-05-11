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
          icon: Icons.home,
          title: 'Home',
          navigatorkey: _tab1navigatorKey,
        ),
        PersistentTabItem(
          tab: ActionsTab(),
          icon: Icons.pending_actions_outlined,
          title: 'Actions',
          navigatorkey: _tab2navigatorKey,
        ),
        PersistentTabItem(
          tab: ProfileScreen(),
          icon: Icons.account_circle,
          title: 'Profile',
        ),
      ],
    );
  }
}
