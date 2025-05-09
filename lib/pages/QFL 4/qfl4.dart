import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/models/qc_inpection.dart';
import 'package:isuze_pqcs/pages/QFL%204/QFL4_form.dart';
import 'package:isuze_pqcs/pages/qc_inspection/chooseComponent.dart';
import 'package:nb_utils/nb_utils.dart';

class QFL4 extends StatefulWidget {
  @override
  _QFL4State createState() => _QFL4State();
}

class _QFL4State extends State<QFL4> {
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
    final shouldShowLoading = vehicles.isEmpty;

    if (shouldShowLoading) {
      EasyLoading.show(
        status: "Loading units...",
        maskType: EasyLoadingMaskType.black,
      );
    }

    setState(() {
      isLoading = shouldShowLoading;
      message = '';
    });

    final url = "${Api.api_url}sheduledunits";

    try {
      final response = await httpget(url, user['data']['token'], context);

      if (response == null) {
        setState(() {
          isLoading = false;
          message = 'Something went wrong. Check your internet connection.';
        });
        EasyLoading.dismiss();
        return;
      }

      if (response['success'] && response['data'] != null) {
        final List<Vehicle> fetchedVehicles = (response['data'] as List)
            .map((vehicleData) => Vehicle.fromJson(vehicleData))
            .toList();

        setState(() {
          vehicles = fetchedVehicles;
          isLoading = false;
          message = '';
        });
        if (vehicles.isEmpty) {
          setState(() {
            message = "No scheduled units found.";
          });
          EasyLoading.dismiss();
        }
      } else {
        setState(() {
          isLoading = false;
          message = response['msg'] ?? 'Unexpected error';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        message = 'Network problem: $e';
      });
      print('Error fetching data: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  void dispose() {
    if (isLoading) {
      EasyLoading.dismiss(); // Dismiss loading when navigating away
    }
    super.dispose();
  }

  TextEditingController searchController = TextEditingController();
  String searchText = '';
  bool _isSearching = false;
  @override
  Widget build(BuildContext context) {
    vehicles.sort((a, b) =>
        DateTime.parse(b.created_at).compareTo(DateTime.parse(a.created_at)));

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
        title: _isSearching ? _buildSearchField() : Text('Units'),
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
          ? Center(child: SizedBox.shrink()) // Keep an empty widget
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
                                vehicles[index].model,
                                style: TextStyle(
                                    color: Colors.amber[900],
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('VIN: ${vehicles[index].vin}'),
                                  // Text('VIN: ${vehicles[index].vin}'),
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
                              trailing: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: categoryColor),
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(10))),
                                  child: TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      "SELECT",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )),
                              onTap: () {
                                // Navigate to vehicle details page passing the selected vehicle
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QFL4_form(),
                                  ),
                                );
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
                                color: vehicles[index].customer_name != null
                                    ? Colors.amber[900]
                                    : null,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "Section",
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
