// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader2.dart';
import 'package:isuze_pqcs/pages/Receiving/vehicle_questions_template.dart';
import 'package:isuze_pqcs/pages/qc_inspection/jobcard_questions_template.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class VehicleReceivingConversion extends StatefulWidget {
  final int vehicleId;
  final String vehicleName;
  final type;
  final isStripingDone;

  const VehicleReceivingConversion({
    Key? key, // Add Key? here
    required this.vehicleId,
    required this.vehicleName,
    required this.type,
    this.isStripingDone,
  }) : super(key: key);

  @override
  State<VehicleReceivingConversion> createState() =>
      _VehicleReceivingConversionState();
}

class _VehicleReceivingConversionState extends State<VehicleReceivingConversion>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  var user = {};
  var data;
  var textLoading = 'No categories found';
  bool isLoading2 = false;
  var textLoading2 = '';
  List categories = [];
  final List<Color> colors = [
    // Colors.tealAccent.shade700,
    Colors.indigo,
    Colors.teal,
  ];
  TextEditingController notes = TextEditingController();
  TextEditingController collectedBy = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);

    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      fetchCategories(widget.vehicleId);
      fetchEntry(widget.vehicleId); // Fetch entry initially
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.index == 1) {
      fetchEntry(widget.vehicleId);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _handleTabChange();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(

      appBar: AppBar(
        title: Text(
          widget.vehicleName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: tab1(), // Define your tab 1 content
      // Define your entry form tab content
    );
  }

  Column tab1() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: categories.isEmpty
                ? Center(child: CustomLoader())
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      var category = categories[index];
                      List<dynamic> question = category["question"];
                      Color categoryColor = colors[index % colors.length];
                      return GestureDetector(
                        onTap: () async {
                          if (question[0]["questionitems_count"] == 0) {
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   snackBar("No questions available", snackblack),
                            // );
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.error,
                              animType: AnimType.rightSlide,
                              title: 'No questions available!',
                              btnOkColor: mycolor,
                              btnOkOnPress: () {},
                            )..show();
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VehicleQuestionsTemplate(
                                        strippingDone: widget.isStripingDone,
                                        vehicleId: widget.vehicleId,
                                        categoryItemId: category["id"],
                                        categoryName:
                                            category["query_item_name"],
                                      )
                              ),
                            ).then(
                                (value) => fetchCategories(widget.vehicleId));
                            // final result = await Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) => widget.isStripingDone !=
                            //               null
                            //           ? JobCardQuestionsTemplate(
                            //               strippingDone: widget.isStripingDone,
                            //               vehicleId: widget.vehicleId,
                            //               categoryItemId: category["id"],
                            //               categoryName:
                            //                   category["query_item_name"],
                            //             )
                            //           : VehicleQuestionsTemplate(
                            //               strippingDone: widget.isStripingDone,
                            //               vehicleId: widget.vehicleId,
                            //               categoryItemId: category["id"],
                            //               categoryName:
                            //                   category["query_item_name"],
                            //             ),
                            //     )).then((value) {
                            //   fetchCategories(widget.vehicleId);
                            // });
                            // if (result != null) {
                            //   fetchCategories(widget.vehicleId);
                            // }
                          }
                        },
                        child: Card(
                          color: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(
                              top: 10,
                            ),
                            // decoration: boxDecoration(
                            //     radius: 10,
                            //     showShadow: true,
                            //     bgColor: Colors.white),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    CircleAvatar(
                                      backgroundColor: categoryColor,
                                      foregroundColor: Colors.white,
                                      radius: 20,
                                      child: Text(
                                        "${index + 1}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            category["query_item_name"],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                              '${category["answers_count"]} out ${question.isEmpty ? 0 : question[0]["questionitems_count"]} Answered'),
                                        ],
                                      ),
                                    ),
                                    CircleAvatar(
                                      radius: 15,
                                      backgroundColor:
                                          categoryColor, // Use the category color here
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        size: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
        categories.isEmpty
            ? Container()
            : Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(),
                          foregroundColor: textWhite),
                      onPressed: () async {
                        await saveData(categories);
                      },
                      child: const Text('Save Data')),
                ),
              )
      ],
    );
  }

  Future fetchCategories(id) async {
    ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, showLogs: true, isDismissible: true);
    pr.style(message: 'Fetching categories...');
    // pr.show();
    // String url = widget.isStriping == true
    //     ? "${Api.api_url}${Api.endpoint_route_categories}/Stripping/$id"
    //     : "${Api.api_url}${Api.endpoint_route_categories}/Receiving New Vehicle/$id";
    // String url = "${Api.api_url}ApiLoadStrippingCat/$id";
    String url =
        "https://hal.hanspaulerp.net/api/fetchRoutingCategory/Receiving New Vehicle/1274";

    print(url);

    // var responsedata = await httpget(url, user["token"], context);

    var responsedata = await httpget(url, Api.usr, context);

    if (responsedata != null) {
      if (responsedata["category"] != null) {
        pr.hide().whenComplete(() {
          setState(() {
            categories = responsedata["category"]["routingitems"];
            // categories = responsedata["category"];
          });
        });
      } else {
        pr.hide().whenComplete(() {
          awesomeTopSnackbar(context, "${responsedata["message"]}",
              iconWithDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(),
                color: Colors.white,
              ),
              backgroundColor: Colors.red[900]);
        });
      }
    }
    // Dismiss the progress dialog after a few seconds
    Future.delayed(const Duration(seconds: dismissseconds), () {
      if (pr.isShowing()) {
        pr.hide();

        awesomeTopSnackbar(context, "${internetmessage}",
            iconWithDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(),
              color: Colors.white,
            ),
            backgroundColor: Colors.red[900]);
      }
    });
  }

  Future saveData(categories) async {
    var validate = true;
    for (var i = 0; i < categories.length; i++) {
      var category = categories[i];

      List<dynamic> question = category["question"];
      if ((category["answers_count"] != question[0]["questionitems_count"]) &&
          (question[0]["questionitems_count"] != 0)) {
        setState(() {
          validate = false;
        });

        break;
      }
    }
    if (validate == true) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Finalize Routing',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.blueGrey,
              ),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            content: IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.type == "stripped")
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: collectedBy,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                          labelText: 'Collected By',
                          labelStyle: const TextStyle(color: Colors.blueGrey),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: Colors.grey[400]!,
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: Colors.grey[400]!,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18.0,
                            horizontal: 15.0,
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextFormField(
                      controller: notes,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        labelText: 'Remark',
                        labelStyle: const TextStyle(color: Colors.blueGrey),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: Colors.grey[400]!,
                            width: 1.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: Colors.grey[400]!,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18.0,
                          horizontal: 15.0,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: ElevatedButton(
                      onPressed: () {
                        ProgressDialog pr = ProgressDialog(context,
                            type: ProgressDialogType.normal,
                            isDismissible: false,
                            showLogs: true);
                        pr.style(
                          message: 'Finalizing routing...',
                          borderRadius: 12,
                          backgroundColor: Colors.white,
                          progressWidget: const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  Center(child: CircularProgressIndicator())),
                          elevation: 10.0,
                          insetAnimCurve: Curves.easeInOut,
                        );

                        pr.show();
                        finalizeRouting(widget.vehicleId).then((res) {
                          pr
                              .hide()
                              .then((value) => awesomeTopSnackbar(
                                  context, "${res["message"]}",
                                  iconWithDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(),
                                    color: Colors.white,
                                  ),
                                  backgroundColor: Colors.green[900]))
                              .then((value) {
                            Navigator.of(context).pop();
                          });
                        });

                        Future.delayed(const Duration(seconds: dismissseconds),
                            () {
                          if (pr.isShowing()) {
                            pr.hide();
                            ScaffoldMessenger.of(context).showSnackBar(
                                snackBar(internetmessage, snackred));
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        // padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 5,
                        shadowColor: Colors.blue[300],
                      ),
                      child: const Text(
                        'Complete routing',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ).then((value) {
        Navigator.of(context).pop(true);
      });
    } else {
      awesomeTopSnackbar(context, "Please Answer All Categories Above",
          iconWithDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(),
            color: Colors.white,
          ),
          backgroundColor: Colors.red[900]);
    }
  }

  Future fetchEntry(id) async {
    setState(() {
      textLoading2 = '';
      isLoading2 = true;
    });
    ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, showLogs: true, isDismissible: true);
    pr.style(message: 'Fetching categories...');
    // pr.show();
    // String url = widget.type == 'stripping'
    //     ? "${Api.api_url}apiFetchStrippingForm/$id"
    //     : "${Api.api_url}apiFetchEntryForm/$id";
    String url = "${Api.api_url}apiFetchStrippedForm/$id";

    print(url);
    var responsedata = await httpget(url, user["token"], context);
    // print(responsedata);
    if (responsedata != null) {
      setState(() {
        textLoading2 = '';
        isLoading2 = false;
      });
      if (responsedata != null) {
        pr.hide().whenComplete(() {
          setState(() {
            data = responsedata["data"];
          });
          if (responsedata["data"].isEmpty) {
            setState(() {
              textLoading2 = 'No Data';
            });
          }
        });
      } else {
        pr.hide().whenComplete(() {
          setState(() {
            textLoading2 = "${responsedata["message"]}";
            isLoading2 = false;
          });
          showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.error(
              message: "${responsedata["message"]}",
            ),
          );
        });
      }
    } else {
      setState(() {
        textLoading2 = 'Something Wrong';
        isLoading2 = false;
      });
    }
    // Dismiss the progress dialog after a few seconds
    Future.delayed(const Duration(seconds: dismissseconds), () {
      if (pr.isShowing()) {
        pr.hide();

        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.error(
            message: "${internetmessage}",
          ),
        );
      }
    });
  }

  Future finalizeRouting(vehicleId) async {
    // String url = widget.type == 'stripping'
    //     ? "${Api.api_url}apiCompleteStripping"
    //     : "${Api.api_url}${Api.endpoint_finalize_routing}";
    var payload = {
      "type": "receive",
      "user": user["user"]["id"],
      "vehicle_id": vehicleId,
      "notes": notes.text
    };

    String url = "${Api.api_url}finalizeRouting";

    print(payload);
    print(url);

    var response =
        await httppostwithtoken(url, user["token"], payload, context);
    print(response);
    return response;
  }
}
