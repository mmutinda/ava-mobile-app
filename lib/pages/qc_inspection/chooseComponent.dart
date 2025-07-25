import 'dart:convert';

import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:nb_utils/nb_utils.dart';
// import 'package:nb_utils/nb_utils.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
// import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class ChooseComponent extends StatefulWidget {
  final vehicle_id;
  final route_id;
  final job_no;

  const ChooseComponent(
      {super.key,
      required this.vehicle_id,
      required this.route_id,
      required this.job_no});

  @override
  State<ChooseComponent> createState() => _ChooseComponentState();
}

class _ChooseComponentState extends State<ChooseComponent> {
  String? selectedComponent;
  late TextEditingController inputController;
  final List<String> data = [
    // 'Cabin/Cockpit',
    // 'Chassis',
  ];
  final List<String> data2 = [
    // 'Cabin/Cockpit',
    // 'Chassis',
  ];
  final List<String> data3 = [
    // 'Cabin/Cockpit',
    // 'Chassis',
  ];
  var user = {};
  var alldata = {};
  var components = {};
  String ComponentId = '';
  String message = '';
  @override
  void initState() {
    inputController = TextEditingController(text: widget.job_no);
    super.initState();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      fetchComponent();
    });
  }

  Future fetchComponent() async {
    setState(() {
      message = '';
    });

    try {
      String unitsurl =
          Api.api_url + "getcomponent/${widget.route_id}/${widget.vehicle_id}";
      print(unitsurl);
      var responsedata =
          await httpget(unitsurl, "${user['data']['token']}", context);

      if (responsedata["success"]) {
        responsedata["data"]['routes'].forEach((var route) {
          print(route['routing_part']);
          setState(() {
            data.add(route['routing_part']);
            data2.add(route['id'].toString());
            data3.add(route['route_number'].toString());
            // data2.add(route['id'].toString());
          });
        });
        // setState(() {
        //   alldata = responsedata["data"]['routes'];
        // });
      } else {
        setState(() {
          message = 'Network Problem';
        });
      }
    } catch (error) {
      // Handle errors
      print('Error fetching units: $error');
      setState(() {
        message = 'Network Problem';
      });
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(20),
      //   boxShadow: [
      //     BoxShadow(
      //       color: mycolor.withOpacity(0.1),
      //       blurRadius: 20,
      //       offset: Offset(0, 8),
      //       spreadRadius: 2,
      //     ),
      //   ],
      // ),
      child: data.isEmpty
          ? Container(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomLoader(),
                    // CircularProgressIndicator(
                    //   valueColor: AlwaysStoppedAnimation<Color>(mycolor),
                    //   strokeWidth: 3,
                    // ),
                    SizedBox(height: 16),
                    Text(
                      'Loading components...',
                      style: TextStyle(
                        color: mycolor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : message.isNotEmpty
              ? Container(
                  height: 200,
                  child: ErrorMessageWidget(
                    errorMessage: message,
                    onRetry: () {
                      fetchComponent().then((value) {
                        setState(() {
                          message = '';
                        });
                      });
                    },
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with gradient
                    Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [mycolor, mycolor.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            "CHOOSE COMPONENT",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content area
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Component selection cards
                          ...data.map((component) {
                            final componentName = component;
                            final componentNameId =
                                data2[data.indexOf(component)];
                            final route_number = data3[data.indexOf(component)];
                            final isSelected = ComponentId == componentNameId;

                            return Container(
                              margin: EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    ComponentId = componentNameId;
                                    components = {
                                      'id': componentNameId,
                                      'route_number': route_number
                                    };
                                    selectedComponent = ComponentId;
                                  });
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 200),
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? mycolor.withOpacity(0.1)
                                        : Colors.grey[50],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? mycolor
                                          : Colors.grey[300]!,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: mycolor.withOpacity(0.2),
                                              blurRadius: 8,
                                              offset: Offset(0, 4),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? mycolor
                                                : Colors.grey[400]!,
                                            width: 2,
                                          ),
                                          color: isSelected
                                              ? mycolor
                                              : Colors.transparent,
                                        ),
                                        child: isSelected
                                            ? Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 16,
                                              )
                                            : null,
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              componentName,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: isSelected
                                                    ? mycolor
                                                    : Colors.black87,
                                              ),
                                            ),
                                            if (route_number.isNotEmpty) ...[
                                              SizedBox(height: 4),
                                              Text(
                                                'Route: $route_number',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: mycolor,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'SELECTED',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),

                          SizedBox(height: 24),

                          // Action button
                          Container(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (selectedComponent != null) {
                                  showConfirmDialogCustom(
                                    primaryColor: mycolor,
                                    context,
                                    title: "Do you want to Push this?",
                                    onAccept: (val) async {
                                      final ProgressDialog progressDialog =
                                          ProgressDialog(context);
                                      progressDialog.style(
                                        message: 'Pushing...',
                                        child: CustomLoader(),
                                        progressWidget:
                                            CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  mycolor),
                                        ),
                                      );
                                      await progressDialog.show();

                                      try {
                                        String url =
                                            Api.api_url + "moveunitfromstore";
                                        var payload = {
                                          "id": widget.vehicle_id,
                                          "route_id": widget.route_id,
                                          "component": components,
                                          "job_no": inputController.text,
                                        };
                                        print(payload);
                                        log(jsonEncode(payload));
                                        print(url);
                                        var response = await httppostwithtoken(
                                            url,
                                            user['data']['token'],
                                            payload,
                                            context);
                                        print(response);
                                        if (response['success']) {
                                          await progressDialog.hide();

                                          awesomeTopSnackbar(
                                            context,
                                            "${response['msg']}",
                                            iconWithDecoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(),
                                                color: Colors.white),
                                            icon: Icon(
                                              Icons.done,
                                              color: Colors.green[900],
                                            ),
                                          );
                                          Navigator.pop(context);
                                        } else {
                                          await progressDialog.hide();

                                          awesomeTopSnackbar(
                                              context, "${response['msg']}",
                                              iconWithDecoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(),
                                                  color: Colors.white),
                                              icon: Icon(
                                                Icons.close,
                                                color: Colors.red,
                                              ),
                                              backgroundColor: Colors.red[900]);
                                        }
                                        return response;
                                      } catch (e) {
                                        await progressDialog.hide();
                                        print("error : $e");
                                      } finally {
                                        await progressDialog.hide();
                                      }

                                      Navigator.pop(context);
                                    },
                                  );
                                } else {
                                  awesomeTopSnackbar(
                                      context, "Please select component.",
                                      iconWithDecoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(),
                                          color: Colors.white),
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                      backgroundColor: Colors.red[900]);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mycolor,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 8,
                                shadowColor: mycolor.withOpacity(0.3),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.push_pin, size: 20),
                                  SizedBox(width: 12),
                                  Text(
                                    "PUSH COMPONENT",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
