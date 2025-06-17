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

class ChooseComponentReceivingLot extends StatefulWidget {
  final vehicle_id;
  final route_id;
  final job_no;

  const ChooseComponentReceivingLot(
      {super.key,
      required this.vehicle_id,
      required this.route_id,
      required this.job_no});

  @override
  State<ChooseComponentReceivingLot> createState() =>
      _ChooseComponentReceivingLotState();
}

class _ChooseComponentReceivingLotState
    extends State<ChooseComponentReceivingLot> {
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
    // TODO: implement initState
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
      height: 350,
      width: double.infinity,
      child: data.isEmpty
          ? CustomLoader()
          : message.isNotEmpty
              ? ErrorMessageWidget(
                  errorMessage: message,
                  onRetry: () {
                    fetchComponent().then((value) {
                      setState(() {
                        message = '';
                      });
                    });
                  },
                )
              : Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 192, 85, 3),
                      ),
                      child: Text(
                        "CHOOSE COMPONENT",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 20),
                    Column(
                      children: data.map((component) {
                        final componentName = component;
                        final componentNameId = data2[data.indexOf(
                            component)]; // Get the corresponding value from data2
                        final route_number = data3[data.indexOf(
                            component)]; // Get the corresponding value from data2

                        return Column(
                          children: [
                            RadioListTile(
                              groupValue: ComponentId,
                              value: componentNameId,
                              title: Text(
                                '$componentName',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onChanged: (String? value) {
                                setState(() {
                                  ComponentId = value!;
                                  components = {
                                    'id': componentNameId,
                                    'route_number': route_number
                                  };
                                  selectedComponent = ComponentId;
                                });
                                print(components);
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Divider(),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    gap(),
                    TextFormField(
                      maxLines: null,
                      enabled: [4, 5].contains(int.tryParse(widget.route_id)),
                      controller: inputController,
                      decoration: InputDecoration(
                        labelText: 'Job No',
                        isDense: true,
                        hintText: 'Job No',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: mycolor.withOpacity(0.06),
                      ),
                    ),
                    Spacer(),
                    AppButton(
                      text: "Push TO Assembly",
                      onTap: () async {
                        if (selectedComponent != null) {
                          // Navigator.pop(context);
                          showConfirmDialogCustom(
                            primaryColor: Colors.amber[900],
                            context,
                            title: "Do you want to Push this?",
                            // dialogType: DialogType.CONFIRMATION,
                            onAccept: (val) async {
                              final ProgressDialog progressDialog =
                                  ProgressDialog(context);
                              progressDialog.style(
                                message: 'Pushing...',
                                child: CustomLoader(),
                                progressWidget: CircularProgressIndicator(),
                              );
                              await progressDialog.show();

                              try {
                                String url = Api.api_url + "moveunitfromstore";
                                var payload = {
                                  "id": widget.vehicle_id,
                                  "route_id": widget.route_id,
                                  "component": components,
                                  "job_no": inputController.text,
                                };
                                print(payload);
                                log(jsonEncode(payload));
                                print(url);
                                var response = await httppostwithtoken(url,
                                    user['data']['token'], payload, context);
                                print(response);
                                if (response['success']) {
                                  await progressDialog.hide();

                                  awesomeTopSnackbar(
                                    context,
                                    "${response['msg']}",
                                    iconWithDecoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(),
                                        color: Colors.white),
                                    icon: Icon(
                                      Icons.done,
                                      color: Colors.green[900],
                                    ),
                                  );
                                  Navigator.pop(context);
                                  // print(response);
                                  print(response);
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
                                  // print(response);

                                  print(response);
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
                              context, "'Please select component.')",
                              iconWithDecoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(),
                                  color: Colors.white),
                              icon: Icon(
                                Icons.close,
                                color: Colors.red,
                              ),
                              backgroundColor: Colors.red[900]);
                        }
                      },
                    ),
                  ],
                ),
    );
  }
}
