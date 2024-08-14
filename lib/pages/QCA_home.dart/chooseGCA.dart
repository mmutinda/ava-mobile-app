import 'dart:convert';

import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/pages/QCA_home.dart/audit_screen.dart';
import 'package:nb_utils/nb_utils.dart';
// import 'package:nb_utils/nb_utils.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
// import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class ChooseGCA extends StatefulWidget {
  final sku;

  const ChooseGCA({
    super.key,
    required this.sku,
  });

  @override
  State<ChooseGCA> createState() => _ChooseGCAState();
}

class _ChooseGCAState extends State<ChooseGCA> {
  String? selectedComponent;
  late TextEditingController inputController;
  final List<String> data = [
    'CV',
    'LCV',
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
  bool isLoading = false;
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
    return Container(
      height: 300,
      width: double.infinity,
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 192, 85, 3),
            ),
            child: Text(
              "CHOOSE GCA TYPE",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),
          Text("${widget.sku}"),
          Column(
            children: data.map((component) {
              final componentName = component;

              return Column(
                children: [
                  RadioListTile(
                    groupValue: ComponentId,
                    value: componentName,
                    title: Text(
                      '$componentName',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onChanged: (String? value) {
                      setState(() {
                        ComponentId = value!;
                      });
                      print(ComponentId);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Divider(),
                  ),
                ],
              );
            }).toList(),
          ),
          gap(),
          isLoading
              ? Center(
                  child: SizedBox(
                    height: 50,
                    child: CustomLoader(),
                  ),
                )
              : AppButton(
                  text: "SUBMIT",
                  onTap: () async {
                    // ignore: unnecessary_null_comparison
                    if (ComponentId != null) {
                      // Navigator.pop(context);
                      setState(() {
                        isLoading = true;
                      });
                      final ProgressDialog progressDialog =
                          ProgressDialog(context);
                      progressDialog.style(
                        message: 'loading...',
                        child: CustomLoader(),
                        progressWidget: CircularProgressIndicator(),
                      );
                      await progressDialog.show();

                      try {
                        String url = Api.api_url +
                            "validategcaunit/${widget.sku}/$ComponentId";
                        print(url);
                        var response =
                            await httpget(url, user['data']['token'], context);
                        print(response);
                        if (response['success']) {
                          await progressDialog.hide();
                          setState(() {
                            isLoading = false;
                          });
                          Navigator.pop(context);
                          AuditScreen(
                            modelName: response['data']['chasis'],
                            vinNo: response['data']['model'],
                            vehicleId: response['data']['vehicle_id'],
                            gca_type: ComponentId,
                          ).launch(context,
                              pageRouteAnimation: PageRouteAnimation.Fade);
                          // Navigator.push(context, MaterialPageRoute(builder: (context) {
                          //   return
                          // },))

                          print(response);
                          // print(response);
                        } else {
                          await progressDialog.hide();
                          setState(() {
                            isLoading = false;
                          });
                          awesomeTopSnackbar(context, "${response['msg']}",
                              iconWithDecoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
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
                        setState(() {
                          isLoading = false;
                        });
                        await progressDialog.hide();
                        print("error : $e");
                      } finally {
                        await progressDialog.hide();
                        setState(() {
                          isLoading = false;
                        });
                      }

                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please select a component.'),
                        ),
                      );
                    }
                  },
                ),
        ],
      ),
    );
  }
}
