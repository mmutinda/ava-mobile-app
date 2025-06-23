import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/pages/Receiving/QcList.dart';
import 'package:isuze_pqcs/pages/Receiving/form_receiving.dart';
import 'package:isuze_pqcs/pages/planning/scheduleUnits.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class DisplayVehicles extends StatefulWidget {
  final isPlanning;

  const DisplayVehicles({super.key, this.isPlanning = false});
  @override
  State<DisplayVehicles> createState() => _DisplayVehiclesState();
}

class _DisplayVehiclesState extends State<DisplayVehicles> {
  var user = {};
  var vehicles = [];
  // var vehicles;
  var loadingText = '';
  bool isLoading = false;
  String selectedBay = 'Bay 1'; // Default to Bay 1
  String selectedRoute = 'Route 1';
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
              loadingText = 'No Lots available at the moment';
            });
          }
        },
      );
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
            : widget.isPlanning == 'Yes'
                ? Text("Scheduled Lots")
                : Text('Received Lots'),
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
                            // Sort vehicles by delivery_date in descending order
                            vehicles.sort((a, b) {
                              // Assuming delivery_date is in a format that can be directly compared as strings
                              return b['created_at'].compareTo(a['created_at']);
                            });
                            var vehicle = vehicles[index];
                            var vin_no = vehicle["vin_no"];
                            var engine_no = vehicles[index]["engine_no"];
                            var client = vehicles[index]["customer"]["name"];
                            Color categoryColor = colors[index % colors.length];
                            // Check if the title contains the search text
                            // if (searchText.isNotEmpty &&
                            //     !(chasisNo
                            //         .toLowerCase()
                            //         .contains(searchText.toLowerCase()))||) {
                            //   return Container();
                            // }
                            if (searchText.isNotEmpty &&
                                !(vin_no
                                        .toLowerCase()
                                        .contains(searchText.toLowerCase()) ||
                                    engine_no
                                        .toLowerCase()
                                        .contains(searchText.toLowerCase()) ||
                                    client
                                        .toLowerCase()
                                        .contains(searchText.toLowerCase()))) {
                              return Container(); // Return an empty container if not matching
                            }
                            return Column(
                              children: [
                                SizedBox(height: 5),
                                Stack(children: [
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
                                        backgroundColor:
                                            Color.fromARGB(255, 168, 88, 32),
                                        foregroundColor: Colors.white,
                                        child: Text("${index + 1}"),
                                      ),
                                      title: Text(
                                        vehicles[index]['model']?['model_name'],
                                        style: TextStyle(
                                            color: Colors.amber[900],
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Text('Insprcted 0 out of 10'),
                                          // Text('VIN: ${vehicles[index].vin}'),
                                          Row(
                                            children: [
                                              Text(
                                                  'lOT Number: ${vehicles[index]['lot_number']}'),
                                              width(),
                                              // if (vehicles[index]['job_no'] !=
                                              //     null)
                                              Text(
                                                  'lOT Quantity: ${vehicles[index]['lot_qty'] ?? 'N/A'}'),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: categoryColor),
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(10))),
                                        child: TextButton(
                                          onPressed: () {
                                            if (widget.isPlanning == 'Yes') {
                                              String? selectedBay = 'Bay 1';
                                              String? selectedRoute = 'Route 1';

                                              // ID maps
                                              final bayIds = {
                                                'Bay 1': 'Bay 1',
                                                'Bay 2': 'Bay 2',
                                                'Bay 3': 'Bay 3'
                                              };
                                              final routeIds = {
                                                'Route 1': '1',
                                                'Route 2': '2',
                                                'Route 3': '3'
                                              };

                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return StatefulBuilder(
                                                    builder: (BuildContext
                                                            context,
                                                        StateSetter setState) {
                                                      return AlertDialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        title: const Text(
                                                          'Choose Bay and Route',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        content: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            DropdownButtonFormField<
                                                                String>(
                                                              value:
                                                                  selectedBay,
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {
                                                                  selectedBay =
                                                                      value!;
                                                                });
                                                              },
                                                              items: [
                                                                'Bay 1',
                                                                'Bay 2',
                                                                'Bay 3'
                                                              ].map<
                                                                  DropdownMenuItem<
                                                                      String>>((String
                                                                  value) {
                                                                return DropdownMenuItem<
                                                                    String>(
                                                                  value: value,
                                                                  child: Text(
                                                                      value),
                                                                );
                                                              }).toList(),
                                                              decoration:
                                                                  InputDecoration(
                                                                labelText:
                                                                    'Select Bay',
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12),
                                                                ),
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            12,
                                                                        vertical:
                                                                            10),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 15),
                                                            DropdownButtonFormField<
                                                                String>(
                                                              value:
                                                                  selectedRoute,
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {
                                                                  selectedRoute =
                                                                      value!;
                                                                });
                                                              },
                                                              items: [
                                                                'Route 1',
                                                                'Route 2',
                                                                'Route 3'
                                                              ].map<
                                                                  DropdownMenuItem<
                                                                      String>>((String
                                                                  value) {
                                                                return DropdownMenuItem<
                                                                    String>(
                                                                  value: value,
                                                                  child: Text(
                                                                      value),
                                                                );
                                                              }).toList(),
                                                              decoration:
                                                                  InputDecoration(
                                                                labelText:
                                                                    'Select Route',
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12),
                                                                ),
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            12,
                                                                        vertical:
                                                                            10),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 20),
                                                            SizedBox(
                                                              width: double
                                                                  .infinity,
                                                              child:
                                                                  ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          14),
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12),
                                                                  ),
                                                                ),
                                                                onPressed:
                                                                    () async {
                                                                  final fields =
                                                                      {
                                                                    'vehicle_receiving_id':
                                                                        vehicles[index]
                                                                            [
                                                                            'id'],
                                                                    'vehicle_bay':
                                                                        bayIds[
                                                                            selectedBay],
                                                                    'vehicle_route':
                                                                        routeIds[
                                                                            selectedRoute],
                                                                  };
                                                                  // print(fields);

                                                                  await submitForm(
                                                                    context:
                                                                        context,
                                                                    url:
                                                                        '${Api.api_url}pushBay',
                                                                    fields:
                                                                        fields,
                                                                    token: user[
                                                                            'data']
                                                                        [
                                                                        'token'],
                                                                  );
                                                                  print(fields);
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: Text(
                                                                  'PUSH TO ${selectedBay!}',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                            } else {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => QClist(
                                                    Id: vehicles[index]['id'],
                                                    LotNo: vehicles[index]
                                                        ['lot_number'],
                                                  ),
                                                ),
                                              ).then((value) {
                                                fetchVehicles();
                                              });
                                            }
                                          },
                                          child: Text(
                                            "SELECT",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => QClist(
                                                      Id: vehicles[index]['id'],
                                                      LotNo: vehicles[index]
                                                          ['lot_number'],
                                                    ))).then((value) {
                                          fetchVehicles();
                                        });
                                      },
                                    ),
                                  ),

                                  // 🔷 Badge (top-right)
                                  Positioned(
                                    right: 10,
                                    top: 0,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color:
                                            vehicles[index]['customer'] != null
                                                ? Colors.amber[900]
                                                : null,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        vehicles[index]['customer']?['name'] ??
                                            '',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                                SizedBox(height: 10),
                              ],
                            );
                          },
                        ),
                      )),
      ),
      floatingActionButton: widget.isPlanning == 'Yes'
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return ReceivingForm();
                  },
                )).then(
                  (value) {
                    fetchVehicles().then(
                      (value) {
                        if (vehicles.isEmpty) {
                          print(value);
                          setState(() {
                            loadingText = 'No Lots available at the moment';
                          });
                        }
                      },
                    );
                  },
                );
              },
              child: Icon(Icons.add),
            ),
    );
  }

  Future fetchVehicles() async {
    setState(() {
      loadingText = '';
      isLoading = vehicles.isEmpty ? true : false;
    });
    String url = widget.isPlanning == 'Yes'
        ? "${Api.api_url}loadSheduledLot"
        : "${Api.api_url}loadVehicleReceivingLots";
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
    // print(responsedata);
    if (responsedata != null) {
      pr.hide();

      setState(() {
        isLoading = false;
        vehicles = (responsedata["data"] as List<dynamic>) ?? [];
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
