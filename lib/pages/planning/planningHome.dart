import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:isuze_pqcs/pages/Receiving/display_vehicles.dart';
import 'package:isuze_pqcs/pages/planning/Unboxing/chooseBay.dart';
import 'package:isuze_pqcs/pages/planning/Unboxing/display_UnboxingLots.dart';
import 'package:isuze_pqcs/pages/planning/scheduleUnits.dart';
import 'package:nb_utils/nb_utils.dart';

class PlanningHome extends StatefulWidget {
  const PlanningHome({super.key});

  @override
  State<PlanningHome> createState() => _PlanningHomeState();
}

class _PlanningHomeState extends State<PlanningHome>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> options = [
    {
      'title': 'Scheduled Lots',
      'subtitle': 'View and manage scheduled production lots',
      'icon': FeatherIcons.calendar,
      'color': Colors.blue,
      'gradient': [Colors.blue.shade400, Colors.blue.shade600],
    },
    {
      'title': 'Unboxing',
      'subtitle': 'Manage unboxing operations and bay assignments',
      'icon': FeatherIcons.package,
      'color': Colors.orange,
      'gradient': [Colors.orange.shade400, Colors.orange.shade600],
    },
    {
      'title': 'Schedule to Assembly',
      'subtitle': 'Schedule units for assembly line production',
      'icon': FeatherIcons.settings,
      'color': Colors.green,
      'gradient': [Colors.green.shade400, Colors.green.shade600],
    },
    {
      'title': 'Weekly/Monthly Plan',
      'subtitle': 'View comprehensive planning schedules',
      'icon': FeatherIcons.barChart2,
      'color': Colors.purple,
      'gradient': [Colors.purple.shade400, Colors.purple.shade600],
    },
    {
      'title': 'Units at Logistics',
      'subtitle': 'Track units in logistics department',
      'icon': FeatherIcons.truck,
      'color': Colors.cyan,
      'gradient': [Colors.cyan.shade400, Colors.cyan.shade600],
    },
    {
      'title': 'Units at Line',
      'subtitle': 'Monitor units on production line',
      'icon': FeatherIcons.activity,
      'color': Colors.indigo,
      'gradient': [Colors.indigo.shade400, Colors.indigo.shade600],
    },
    {
      'title': 'Units at Rework',
      'subtitle': 'Manage units requiring rework',
      'icon': FeatherIcons.refreshCw,
      'color': Colors.amber,
      'gradient': [Colors.amber.shade400, Colors.amber.shade600],
    },
    {
      'title': 'Units at EOL',
      'subtitle': 'End-of-line inspection status',
      'icon': FeatherIcons.checkCircle,
      'color': Colors.teal,
      'gradient': [Colors.teal.shade400, Colors.teal.shade600],
    },
    {
      'title': 'Units at GCP',
      'subtitle': 'Good Control Point monitoring',
      'icon': FeatherIcons.shield,
      'color': Colors.red,
      'gradient': [Colors.red.shade400, Colors.red.shade600],
    },
  ];

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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
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
                FeatherIcons.calendar,
                color: Colors.white,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Planning',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  FeatherIcons.moreVertical,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: () {
                // Add more options functionality
              },
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
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
              // Header Card
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
                  border:
                      Border.all(color: theme.primaryColor.withOpacity(0.2)),
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
                        FeatherIcons.clipboard,
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
                            "Production Planning",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: theme.primaryColor,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Manage schedules, units & operations",
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.green.withOpacity(0.3)),
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
                            "Active",
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
              ),
              // Options List
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final option = options[index];
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
                            ((index * 0.1) + 0.3).clamp(0.0, 1.0),
                            curve: Curves.easeOutBack,
                          ),
                        ));

                        return SlideTransition(
                          position: slideAnimation,
                          child: _buildPlanningCard(context, option, index),
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

  Widget _buildPlanningCard(
      BuildContext context, Map<String, dynamic> option, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (option['color'] as Color).withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _handleOptionTap(context, index),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (option['color'] as Color).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: option['gradient'] as List<Color>,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (option['color'] as Color).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    option['icon'] as IconData,
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
                        option['title'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        option['subtitle'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (option['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    FeatherIcons.chevronRight,
                    color: option['color'] as Color,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleOptionTap(BuildContext context, int index) {
    if (index == 0) {
      print(index);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DisplayVehicles(
                  isPlanning: "Yes",
                )),
      );
      return;
    }
    if (index == 1) {
      showInDialog(context,
              builder: (context) => ChooseBayDialog(),
              dialogAnimation: DialogAnimation.SCALE)
          .then((value) {
        print(value);
        if (value != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => display_UnboxingLots(
                      bayName: value,
                    )),
          );
        }
      });
      return;
    }
    if (index == 2) {
      print(index);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SCheduleUnits()),
      );
      return;
    }
    toasty(
      context,
      "Under Development",
      bgColor: Colors.red.shade100,
      textColor: Colors.red.shade900,
    );
  }
}
