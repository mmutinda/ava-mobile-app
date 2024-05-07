import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:isuze_pqcs/models/shops.dart';
import 'package:isuze_pqcs/pages/qc_inspection/scheduleUnits.dart';
import 'package:isuze_pqcs/widgets/menu_item.dart';
import 'package:isuze_pqcs/widgets/shops.dart';

import 'package:nb_utils/nb_utils.dart';

class Qc_Home extends StatefulWidget {
  const Qc_Home({super.key});

  @override
  State<Qc_Home> createState() => _Qc_HomeState();
}

List<shops> shop = []; // List to hold vehicles fetched from API
final List<Color> colors = [
  Colors.amber.shade900,
  Colors.indigo,
  Colors.teal,
];

class _Qc_HomeState extends State<Qc_Home> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  void fetchData() async {
    String apiResponse =
        '{"shops": [ {"id": 1, "name": "Best Auto Deals"},{"id": 2, "name": "Great Cars Emporium"}, {"id": 3, "name": "Top Notch Autos"}]}';
    // print(apiResponse);
    // Convert JSON string to Map
    Map<String, dynamic> responseJson = json.decode(apiResponse);
    // Extract list of vehicles from the response and convert them into Vehicle objects
    List<shops> fetchedShop = (responseJson['shops'] as List)
        .map((shopJson) => shops.fromJson(shopJson))
        .toList();
    print(fetchedShop);
    setState(() {
      shop = fetchedShop; // Update state with fetched vehicles
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: SpeedDial(
      //   animatedIcon: AnimatedIcons.menu_close,
      //   children: [
      //     SpeedDialChild(
      //       child: Icon(Icons.add),
      //       label: 'Add',
      //       onTap: () {
      //         // Add your action here
      //         print('Add button pressed');
      //       },
      //     ),
      //     SpeedDialChild(
      //       child: Icon(Icons.edit),
      //       label: 'Edit',
      //       onTap: () {
      //         // Add your action here
      //         print('Edit button pressed');
      //       },
      //     ),
      //     SpeedDialChild(
      //       child: Icon(Icons.delete),
      //       label: 'Delete',
      //       onTap: () {
      //         // Add your action here
      //         print('Delete button pressed');
      //       },
      //     ),
      //   ],
      // ),
      backgroundColor: Color.fromARGB(255, 168, 88, 32),
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text(
          "Qc Inspection",
          style: TextStyle(),
        ),
        actions: [
          _buildPopupMenuButton(),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(30), topLeft: Radius.circular(30)),
          color: Colors.grey.shade300,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                      child: MenuItem(
                          iconData: Icons.checklist,
                          name: "Scheduled Units",
                          onTap: () {
                            SCheduleUnits().launch(context,
                                pageRouteAnimation: PageRouteAnimation.Slide);
                          })),
                ],
              ),
            ),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "SHOPS",
                  style: TextStyle(color: Colors.grey, fontSize: 19),
                )),
            // Expanded(
            //     child: ListView.builder(
            //   itemCount: 12,
            //   itemBuilder: (context, index) {
            //     return MenuItem(name: "Shop No ${index + 1}", onTap: () {});
            //   },
            // ))
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      2, // You can adjust the number of columns here
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 3 /
                      2, // You can adjust the aspect ratio of each grid item
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  Color categoryColor = colors[index % colors.length];
                  return ShopItems(
                    dividerColor: categoryColor,
                    name: "Shop No ${index + 1}",
                    onTap: () {},
                    number: "${index + 2}",
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPopupMenuButton() {
    return PopupMenuButton<String>(
      itemBuilder: (BuildContext context) {
        return ['Profile', 'Logout'].map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Text(choice),
          );
        }).toList();
      },
      onSelected: (String choice) async {
        if (choice == 'Logout') {
          // ProgressDialog pr = ProgressDialog(context, isDismissible: true);
          // pr.style(message: "Logging you out...");
          // pr.show();
          // SharedPreferences prefs = await SharedPreferences.getInstance();
          // await prefs.clear().then((value) {
          //   pr.hide().whenComplete(() {
          //     Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          //       MaterialPageRoute(
          //         builder: (BuildContext context) {
          //           return const Login();
          //         },
          //       ),
          //       (_) => false,
          //     );
          //   });
          // });

          print('Logout selected');
        } else if (choice == 'Profile') {
          // Navigate to the user's profile screen or show profile details
          // Navigator.push(context, MaterialPageRoute(
          //   builder: (context) {
          //     return ProfileTab();
          //   },
          // ));
          print('Profile selected');
        }
      },
    );
  }
}
