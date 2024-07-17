import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/models/qc_inpection.dart';
import 'package:isuze_pqcs/pages/qc_inspection/chooseComponent.dart';
import 'package:nb_utils/nb_utils.dart';

class SCheduleUnits extends StatefulWidget {
  @override
  _SCheduleUnitsState createState() => _SCheduleUnitsState();
}

class _SCheduleUnitsState extends State<SCheduleUnits> {
  final List<Color> colors = [
    Colors.amber.shade900,
    Colors.indigo,
    Colors.teal,
  ];
  List<Vehicle> vehicles = []; // List to hold vehicles fetched from API
  var user = {};
  bool isLoading = false;
  String message = '';
  @override
  void initState() {
    super.initState();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      fetchData();
    });
    // fetchData(); // Fetch data when the page is initialized
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      message = '';
    });
    var url = "${Api.api_url}sheduledunits";

    try {
      var response = await httpget(url, user['data']['token'], context);
      log(jsonEncode(response));
      if (response == null) {
        print("No Internet");
        // Handle no internet scenario
        return;
      }

      if (response['success'] && response['data'] != null) {
        List<dynamic> responseData = response['data'];

        List<Vehicle> fetchedVehicles = responseData.map((vehicleData) {
          return Vehicle.fromJson(vehicleData);
        }).toList();

        setState(() {
          vehicles = fetchedVehicles;
          isLoading = false;
          message = '';
        });
      } else {
        // Handle other scenarios
        setState(() {
          isLoading = false;
          message = '${response['msg']}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        message = 'Network Problem';
      });
      // message = '${"Network Problem"}';
      print('Error fetching data: $e');
    }
  }

  Future<void> fetchData2() async {
    var url = "${Api.api_url}sheduledunits";

    try {
      var response = await httpget(url, user['data']['token'], context);
      log(jsonEncode(response));
      if (response == null) {
        // Handle no internet scenario
        return;
      }

      if (response['success'] && response['data'] != null) {
        List<dynamic> responseData = response['data'];

        List<Vehicle> fetchedVehicles = responseData.map((vehicleData) {
          return Vehicle.fromJson(vehicleData);
        }).toList();

        setState(() {
          vehicles = fetchedVehicles;
        });
      } else {
        // Handle other scenarios
      }
    } catch (e) {
      // message = '${"Network Problem"}';
      print('Error fetching data: $e');
    }
  }

  TextEditingController searchController = TextEditingController();
  String searchText = '';
  bool _isSearching = false;
  @override
  Widget build(BuildContext context) {
    // print(user['data']['token']);
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
            hintText: 'search...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: _isSearching ? _buildSearchField() : Text('Schedule Units'),
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
      body: isLoading
          ? Center(
              child: Container(
                width: double.infinity,
                child: FacebookLikeShimmer(),
              ),
            )
          : message.isNotEmpty
              ? ErrorMessageWidget(
                  errorMessage: message,
                  onRetry: () {
                    fetchData();
                  },
                ) // Show message for success or failure
              : ListView.builder(
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    Color categoryColor = colors[index % colors.length];
                    var vin = vehicles[index].vin;
                    var model = vehicles[index].model;
                    var UnitRemaining = 'All';
                    if (vehicles[index].cabin_cockpit_moved == '1') {
                      UnitRemaining = 'Chassis';
                    } else if (vehicles[index].chasis_moved == '1') {
                      UnitRemaining = 'Cabin Or Cockpit';
                    }

                    if (searchText.isNotEmpty &&
                        !(vin
                                .toLowerCase()
                                .contains(searchText.toLowerCase()) ||
                            model
                                .toLowerCase()
                                .contains(searchText.toLowerCase()))) {
                      return Container(); // Return an empty container if not matching
                    }
                    return Column(
                      children: [
                        SizedBox(height: 5),
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
                              backgroundColor: Color.fromARGB(255, 168, 88, 32),
                              foregroundColor: Colors.white,
                              child: Text("${index + 1}"),
                            ),
                            title: Text(
                              vehicles[index].model,
                              style: TextStyle(
                                  color: Colors.amber[900],
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('VIN: ${vehicles[index].vin}'),
                                Row(
                                  children: [
                                    Text('lOT: ${vehicles[index].lot}'),
                                    width(),
                                    Text('JOB: ${vehicles[index].job}'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text('UNIT REMAINING:'),
                                    SizedBox(width: 5),
                                    Text(
                                      '${UnitRemaining}',
                                      style: TextStyle(
                                        color: Colors.amber[900],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // trailing: CircleAvatar(
                            //   radius: 15,
                            //   backgroundColor:
                            //       categoryColor, // Use the category color here
                            // child: Icon(
                            //   Icons.arrow_forward_ios,
                            //   size: 10,
                            //   color: Colors.white,
                            // ),
                            // ),
                            trailing: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(color: categoryColor),
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(10))),
                                child: TextButton(
                                  onPressed: () {
                                    showInDialog(context,
                                            builder: (context) =>
                                                ChooseComponent(
                                                  vehicle_id:
                                                      vehicles[index].id,
                                                  job_no: vehicles[index].job,
                                                  route_id:
                                                      vehicles[index].route,
                                                ),
                                            dialogAnimation:
                                                DialogAnimation.SCALE)
                                        .then((value) {
                                      fetchData2();
                                      setState(() {});
                                    });
                                  },
                                  child: Text(
                                    "SELECT",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )),
                            onTap: () {
                              // Navigate to vehicle details page passing the selected vehicle
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    );
                  },
                ),
    );
  }
}

class VehicleDetailsPage extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleDetailsPage({Key? key, required this.vehicle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Model: ${vehicle.model}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'VIN: ${vehicle.vin}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Lot: ${vehicle.lot}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Job: ${vehicle.job}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Units Remaining: ${vehicle.unitRemaining}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

BoxDecoration boxDecoration(
    {double radius = 2,
    Color color = Colors.transparent,
    Color? bgColor,
    var showShadow = false}) {
  return BoxDecoration(
    color: bgColor,
    boxShadow: showShadow
        ? defaultBoxShadow(shadowColor: shadowColorGlobal)
        : [const BoxShadow(color: Colors.transparent)],
    border: Border.all(color: color),
    borderRadius: BorderRadius.all(Radius.circular(radius)),
  );
}
