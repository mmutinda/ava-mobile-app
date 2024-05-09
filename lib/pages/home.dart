import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/pages/qc_inpection_home.dart';
import 'package:isuze_pqcs/widgets/menu_item.dart';
import 'package:nb_utils/nb_utils.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var user = {};
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // print(user['data']['token']);

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
        leading: Icon(Icons.home),
        title: Text(
          "PQCS",
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
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                      child: MenuItem(
                          iconData: Icons.checklist,
                          name: "Qc Inspection",
                          onTap: () {
                            Qc_Home().launch(context,
                                pageRouteAnimation: PageRouteAnimation.Fade);
                          })),
                  Expanded(
                    child: MenuItem(
                      name: "GCA",
                      onTap: () {},
                      iconData: Icons.book_outlined,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                      child: MenuItem(
                          iconData: Icons.star,
                          name: "Tightening Torque Management(TTMS)",
                          onTap: () {})),
                ],
              ),
            ),
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
