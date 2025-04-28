import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader2.dart';
import 'package:isuze_pqcs/pages/Receiving/Dispatch_take_photos.dart';

import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class DisplayVehiclesDispatch extends StatefulWidget {
  @override
  State<DisplayVehiclesDispatch> createState() =>
      _DisplayVehiclesDispatchState();
}

class _DisplayVehiclesDispatchState extends State<DisplayVehiclesDispatch> {
  var user = {};
  var vehicles = [];
  var loadingText = '';
  TextEditingController searchController = TextEditingController();
  String searchText = '';
  bool isLoading = false;
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
            : Text(
                "Received Vehicles",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
        elevation: 0,
        actions: [
          IconButton(
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
        ],
      ),
      body: RefreshIndicator(
        color: app_colorPrimary,
        onRefresh: () {
          return Future.delayed(
            const Duration(seconds: 1),
            () {
              setState(() {});
              // showing snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Page Refreshed'),
                ),
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
                                loadingText = 'No vehicles Found';
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
                          var halModel = vehicle["product"]["hal_model"];
                          var chasisNo = vehicles[index]["product"]['sku'];
                          var regNo = vehicles[index]["product"]["name"];
                          Color categoryColor = colors[index % colors.length];

                          if (searchText.isNotEmpty) {
                            bool chasisContainsSearchText = chasisNo
                                .toLowerCase()
                                .contains(searchText.toLowerCase());
                            bool regContainsSearchText = regNo
                                .toLowerCase()
                                .contains(searchText.toLowerCase());

                            if (!chasisContainsSearchText &&
                                !regContainsSearchText) {
                              return Container();
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.all(10),
                            child: InkWell(
                              onTap: () async {},
                              child: Card(
                                color: Colors.white,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(5),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 10, 0, 10),
                                  child: Row(
                                    children: [
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
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                '${vehicles[index]["product"]?["name"] ?? ''}'),
                                            Text(
                                              "${vehicles[index]["product"]['sku']}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text('H${halModel["name"]}'),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(
                                            top: 10, bottom: 5, right: 5),
                                        alignment: Alignment.center,
                                        child: GestureDetector(
                                          onTap: () async {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      Dispatch_take_photos(
                                                    id: vehicles[index]['id'],
                                                    title: vehicles[index]
                                                        ["product"]["name"],
                                                    sku: vehicles[index]
                                                        ["product"]['sku'],
                                                  ),
                                                )).then((value) {
                                              fetchVehicles();
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: categoryColor),
                                                borderRadius: BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(10))),
                                            child: Text(
                                              "SELECT",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          // child: Icon(Icons.forward),
                                          // child: Icon(Icons.forward),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ),
    );
  }

  Future fetchVehicles() async {
    String url = "${Api.api_url}fetchVehiclesUnphotographed";
    setState(() {
      loadingText = '';
      isLoading = vehicles.isEmpty ? true : false;
    });
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
    var responsedata = await httpget(url, user["token"], context);
    if (responsedata != null) {
      pr.hide();
      var mockResponseData = {
        "status": "success",
        "vehicles": [
          {
            "id": 1,
            "created_at": "2025-04-22T10:20:30Z",
            "product": {
              "id": 101,
              "name": "Toyota Hilux - T987XYZ",
              "sku": "CHS123456",
              "hal_model": {"id": 11, "name": "Hilux 2023"}
            }
          },
          {
            "id": 2,
            "created_at": "2025-04-20T12:15:00Z",
            "product": {
              "id": 102,
              "name": "Isuzu D-Max - T321ABC",
              "sku": "CHS789012",
              "hal_model": {"id": 12, "name": "D-Max V-Cross"}
            }
          },
          {
            "id": 3,
            "created_at": "2025-04-21T08:45:10Z",
            "product": {
              "id": 103,
              "name": "Ford Ranger - T654JKL",
              "sku": "CHS345678",
              "hal_model": {"id": 13, "name": "Ranger FX4"}
            }
          }
        ]
      };

      setState(() {
        isLoading = false;
        // vehicles = responsedata["vehicles"] ?? [];
        vehicles = (mockResponseData["vehicles"] as List<dynamic>) ?? [];
      });
    } else {
      pr.hide().whenComplete(() {
        setState(() {
          isLoading = false;
          loadingText = responsedata["message"];
        });
        // ScaffoldMessenger.of(context)
        //     .showSnackBar(snackBar(responsedata["message"], Colors.red[500]));
      });
    }
    Future.delayed(const Duration(seconds: dismissseconds), () {
      if (pr.isShowing()) {
        pr.hide();
        setState(() {
          isLoading = false;
          loadingText = internetmessage;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(snackBar(internetmessage, snackred));
      }
    });
  }
}
