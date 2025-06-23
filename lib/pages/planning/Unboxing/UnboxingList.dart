import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/pages/Receiving/widget.dart';
import 'package:isuze_pqcs/pages/planning/scheduleUnits.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class UnboxingList extends StatefulWidget {
  final Id;
  final LotNo;

  const UnboxingList({super.key, required this.Id, required this.LotNo});
  @override
  State<UnboxingList> createState() => _UnboxingListState();
}

class _UnboxingListState extends State<UnboxingList> {
  var user = {};
  var vehicles = [];
  // var vehicles;
  var loadingText = '';
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();
  String searchText = '';
  bool _isSearching = false;
  final List<Color> colors = [
    Colors.amber.shade900,
    Colors.indigo,
    Colors.teal,
  ];
  @override
  void initState() {
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      fetchVehicles().then(
        (value) {
          if (vehicles.isEmpty) {
            print(value);
            setState(() {
              loadingText = 'No vehicles available at the moment';
            });
          }
        },
      );
      ;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildSearchField() {
      return TextField(
        autofocus: true,
        style: TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        controller: searchController,
        onChanged: (value) {
          setState(() {
            searchText = value;
          });
        },
        decoration: InputDecoration(
            hintText: 'Chassis Number or RegNo...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? _buildSearchField()
            : Text('Units in Lot ${widget.LotNo}'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    searchController.clear();
                    searchText = '';
                  }
                });
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: mycolor,
        onRefresh: () {
          return Future.delayed(
            const Duration(seconds: 1),
            () {
              fetchVehicles().then(
                (value) {
                  toasty(context, "Refreshed",
                      bgColor: mycolor,
                      textColor: textWhite,
                      padding: EdgeInsets.all(12));
                },
              );
            },
          );
        },
        child: Column(
          children: [
            Expanded(
              child: SizedBox(
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : loadingText.isNotEmpty
                          ? ErrorMessageWidget(
                              errorMessage: loadingText,
                              onRetry: () {
                                fetchVehicles().then(
                                  (value) {
                                    if (vehicles.isEmpty) {
                                      setState(() {
                                        loadingText =
                                            'No vehicles available at the moment';
                                      });
                                    }
                                  },
                                );
                              },
                            )
                          : SizedBox(
                              child: ListView.builder(
                                itemCount: vehicles.length,
                                itemBuilder: (context, index) {
                                  var vehicle = vehicles[index];
                                  var chassis_number =
                                      vehicle["chassis_number"];
                                  var engine_no =
                                      vehicles[index]["engine_number"];

                                  Color categoryColor =
                                      colors[index % colors.length];

                                  if (searchText.isNotEmpty &&
                                      !(chassis_number.toLowerCase().contains(
                                              searchText.toLowerCase()) ||
                                          engine_no.toLowerCase().contains(
                                              searchText.toLowerCase()) ||
                                          engine_no.toLowerCase().contains(
                                              searchText.toLowerCase()))) {
                                    return Container(); // Return an empty container if not matching
                                  }
                                  return Column(
                                    children: [
                                      const SizedBox(height: 5),

                                      // 📦 Card with vehicle info
                                      Stack(
                                        children: [
                                          // 🔳 Main container with shadow and rounded corners
                                          Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: boxDecoration(
                                              radius: 10,
                                              showShadow: true,
                                              bgColor: Colors.white,
                                            ),
                                            child: ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              // 🔵 Leading: index circle
                                              leading: CircleAvatar(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 168, 88, 32),
                                                foregroundColor: Colors.white,
                                                child: Text("${index + 1}"),
                                              ),

                                              // 🏷️ Title: Chassis info
                                              title: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text('Chassis No'),
                                                  Text(
                                                    vehicles[index][
                                                            'chassis_number'] ??
                                                        '',
                                                    style: TextStyle(
                                                      color: Colors.amber[900],
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              // 📝 Subtitle: Engine info

                                              // 👉 Trailing: Action button
                                              trailing: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: categoryColor),
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(10),
                                                  ),
                                                ),
                                                child: TextButton(
                                                  onPressed: vehicles[index]
                                                              ['unit_racked'] ==
                                                          'YES'
                                                      ? null
                                                      : () {
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return StatefulBuilder(
                                                                builder: (BuildContext
                                                                        context,
                                                                    StateSetter
                                                                        setState) {
                                                                  return AlertDialog(
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20),
                                                                    ),
                                                                    title:
                                                                        const Text(
                                                                      'Confirmmation',
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    content:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        Text(
                                                                          'Are you sure you want to rack this unit?',
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            color:
                                                                                Colors.black87,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context); // Cancel
                                                                        },
                                                                        child:
                                                                            const Text(
                                                                          'Cancel',
                                                                          style:
                                                                              TextStyle(color: Colors.red),
                                                                        ),
                                                                      ),
                                                                      ElevatedButton(
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(12),
                                                                          ),
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal: 24,
                                                                              vertical: 14),
                                                                        ),
                                                                        onPressed:
                                                                            () async {
                                                                          final fields =
                                                                              {
                                                                            'vehicle_receiving_item_id':
                                                                                vehicles[index]['id'],
                                                                          };
                                                                          print(
                                                                              fields);
                                                                          await submitForm(
                                                                            context:
                                                                                context,
                                                                            url:
                                                                                '${Api.api_url}pushRack',
                                                                            fields:
                                                                                fields,
                                                                            token:
                                                                                user['data']['token'],
                                                                          );
                                                                          fetchVehicles();
                                                                        },
                                                                        child:
                                                                            Text(
                                                                          'CONFIRM & PUSH',
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                              );
                                                            },
                                                          );
                                                        },
                                                  child: Text(
                                                    vehicles[index][
                                                                'unit_racked'] ==
                                                            'YES'
                                                        ? "Racked"
                                                        : "Rack",
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 10),
                                    ],
                                  );
                                },
                              ),
                            )),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              child: Builder(builder: (context) {
                // Check if ALL vehicles are completed
                final allChecklistsDone = vehicles.isNotEmpty &&
                    vehicles.every((v) =>
                        v['unit_racked']?.toString().toLowerCase() == 'yes');

                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: allChecklistsDone ? mycolor : Colors.grey,
                    padding: const EdgeInsets.all(15),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: allChecklistsDone
                      ? () async {
                          final result = await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => LotIssueDialogFinishRacking(
                              lotId: widget.Id,
                              user: user['data']['token'],
                              lotNumber: widget.LotNo,
                            ),
                          );

                          if (result != null) {
                            // ✅ Do your push to planning with issue details
                            print("Push to Planning with: $result");
                          }
                        }
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              margin: const EdgeInsets.all(50),
                              padding: const EdgeInsets.all(10),
                              behavior: SnackBarBehavior.floating,
                              content: const Text(
                                  "Inspection incomplete for some vehicles."),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                  child: const Text("Finish Racking/schedule"),
                );
              }),
            ),
            SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Future fetchVehicles() async {
    setState(() {
      loadingText = '';
      isLoading = vehicles.isEmpty ? true : false;
    });
    String url = "${Api.api_url}loadUnboxingItems/${widget.Id}";
    print(url);
    ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
    pr.style(
      message: 'Fetching vehicles...',
      borderRadius: 8,
      backgroundColor: Colors.white,
      progressWidget: const SizedBox(
          width: 20,
          height: 20,
          child: Center(child: CircularProgressIndicator())),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
    );

    // pr.show();
    var responsedata = await httpget(url, user['data']["token"], context);
    print("responsedata: $responsedata");
    if (responsedata != null) {
      pr.hide();

      setState(() {
        isLoading = false;
        vehicles = (responsedata["data"]['items'] as List<dynamic>);
      });
    } else {
      pr.hide().whenComplete(() {
        setState(() {
          isLoading = false;
          loadingText = responsedata["message"].toString();
        });
        toasty(context, "${responsedata["message"]}",
            bgColor: Colors.red, textColor: textWhite);
      });
    }
    Future.delayed(const Duration(seconds: dismissseconds), () {
      if (pr.isShowing()) {
        pr.hide();
        setState(() {
          isLoading = false;
          loadingText = internetmessage;
        });
        // ScaffoldMessenger.of(context)
        //     .showSnackBar(snackBar(internetmessage, snackred));
      }
    });
  }
}
// for taking picture
