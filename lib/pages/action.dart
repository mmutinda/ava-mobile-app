import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/pages/defetects/GCAListDefects%20copy.dart';
import 'package:isuze_pqcs/pages/defetects/TTMSListDefects.dart';
import 'package:isuze_pqcs/pages/defetects/QCDefectsUnits.dart';
import 'package:nb_utils/nb_utils.dart';

class ActionsTab extends StatefulWidget {
  @override
  _ActionsTabState createState() => _ActionsTabState();
}

class _ActionsTabState extends State<ActionsTab> {
  final List<Color> colors = [
    Colors.amber.shade900,
    Colors.indigo,
    Colors.teal,
  ];
  List vehicles = [
    'Quality Defects',
    'TTMS Action Plan',
    'GCA Action Plan',
  ];
  List vehicles2 = [
    'Defects Assigned From QC',
    'Tightening Torque Management Action Plan',
    'GCA Action Plan',
  ];
  var user = {};
  bool isLoading = false;
  String message = '';
  @override
  void initState() {
    super.initState();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
    });
    // fetchData(); // Fetch data when the page is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Defects',
            style: boldTextStyle(size: 24, color: Colors.white)),
      ),
      body: ListView.builder(
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          Color categoryColor = colors[index % colors.length];

          return Column(
            children: [
              SizedBox(height: 5),
              Container(
                padding: EdgeInsets.all(12),
                decoration: boxDecoration(
                  radius: 10,
                  showShadow: true,
                  bgColor: Colors.white,
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(0),
                  leading: CircleAvatar(
                    backgroundColor: Color.fromARGB(255, 168, 88, 32),
                    foregroundColor: Colors.white,
                    child: Text("${index + 1}"),
                  ),
                  title: Text(
                    '${vehicles[index]}',
                    style: TextStyle(
                        color: Colors.amber[900], fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${vehicles2[index]}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  trailing: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: categoryColor),
                          borderRadius:
                              BorderRadius.only(topRight: Radius.circular(10))),
                      child: TextButton(
                        onPressed: () {
                          if (vehicles[index] == 'Quality Defects') {
                            DefectsUnit().launch(context,
                                pageRouteAnimation: PageRouteAnimation.Slide);
                          } else if (vehicles[index] == 'TTMS Action Plan') {
                            TTMSDefectsPage().launch(context,
                                pageRouteAnimation: PageRouteAnimation.Slide);
                          } else {
                            GCADefectsPage().launch(context,
                                pageRouteAnimation: PageRouteAnimation.Slide);
                          }
                        },
                        child: Text(
                          "VIEW",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                  onTap: () {
                    // Navigate to vehicle details page passing the selected vehicle
                  },
                ),
              ),
              SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }
}

BoxDecoration boxDecoration(
    {double radius = 2,
    Color color = Colors.transparent,
    Color? bgColor,
    var showShadow = false}) {
  return BoxDecoration(
    color: bgColor,
    boxShadow: showShadow
        ? defaultBoxShadow(shadowColor: shadowColorGlobal)
        : [const BoxShadow(color: Colors.transparent)],
    border: Border.all(color: color),
    borderRadius: BorderRadius.all(Radius.circular(radius)),
  );
}
