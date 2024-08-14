import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/pages/QCA_home.dart/QCAhome.dart';
import 'package:isuze_pqcs/pages/qc_inpection_home.dart';
import 'package:isuze_pqcs/widgets/menu_item.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

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
      backgroundColor: Color.fromARGB(255, 168, 88, 32),
      appBar: AppBar(
        toolbarHeight: 80,
        leading: Icon(Icons.home),
        title: Text("PQCS SYSTEM",
            style: boldTextStyle(size: 24, color: textWhite)),
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
                      onTap: () {
                        // QuickAlert.show(
                        //     confirmBtnColor: mycolor,
                        //     confirmBtnTextStyle:
                        //         TextStyle(fontWeight: FontWeight.bold),
                        //     context: context,
                        //     type: QuickAlertType.info,
                        //     title: 'Module Under Construction!!');
                        
                        QCAHome().launch(context,
                            pageRouteAnimation: PageRouteAnimation.Fade);
                      },
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
                      onTap: () {
                        QuickAlert.show(
                            confirmBtnColor: mycolor,
                            confirmBtnTextStyle:
                                TextStyle(fontWeight: FontWeight.bold),
                            context: context,
                            type: QuickAlertType.info,
                            title: 'Module Under Construction!!');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
