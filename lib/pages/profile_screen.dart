import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/pages/login/login.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

// ignore: must_be_immutable
class ProfileScreen extends StatefulWidget {
  PageController? pageController;
  int? currentIndex;

  ProfileScreen({this.pageController, this.currentIndex});

  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  FocusNode nameNode = FocusNode();
  TextEditingController nameController = TextEditingController(text: "Name");
  bool edit = false;
  // List<ProfileModel> profileActivityItems = getActivityItems();

  var user = {};
  void initState() {
    nameController = TextEditingController();
    super.initState();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
    });
  }

  void dispose() {
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:
            Text('Profile', style: boldTextStyle(size: 24, color: textWhite)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.all(16),
        controller: ScrollController(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: CircleAvatar(
                    radius: 40,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              edit = !edit;
                              FocusScope.of(context).requestFocus(nameNode);
                              nameController = TextEditingController();
                              setState(() {});
                            },
                            child: Text(
                              "${user['data']['name']}",
                              // style: primaryTextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                      // SizedBox(height: 8),
                      Text(
                        "Usename : ${user['data']['username']}",
                        // style: TextStyle(color: Colors.white60),
                      ),
                      SizedBox(height: 8),
                      Container(
                        // height: 28,
                        // width: 90,
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.amber.shade700,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: GestureDetector(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            children: [
                              Icon(
                                Icons.email,
                                color: Colors.black,
                                size: 18,
                              ),
                              Text(
                                '${user['data']['email']}',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            // SizedBox(height: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 32),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                      color: mycolor, borderRadius: BorderRadius.circular(20)),
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      showConfirmDialog(
                        context,
                        'Do you want to logout from the PQCS System?',
                        onAccept: (context) async {
                          ProgressDialog pr =
                              ProgressDialog(context, isDismissible: true);
                          pr.style(message: "Logging you out...");
                          pr.show();
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.clear().then((value) {
                            pr.hide().whenComplete(() {
                              Navigator.of(context, rootNavigator: true)
                                  .pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return const Login();
                                  },
                                ),
                                (_) => false,
                              );
                            });
                          });
                        },
                      );
                    },
                    label: Text('LogOut', style: TextStyle(color: textWhite)),
                    icon: Icon(
                      Icons.logout,
                      color: textWhite,
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            )
          ],
        ),
      ),
    );
  }
}
