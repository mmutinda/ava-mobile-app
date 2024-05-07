import 'dart:convert';

import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch data when the page is initialized
  }

  // Method to fetch data from API
  void fetchData() async {
    String apiResponse =
        '{"vehicles": [   {"model": "Jeep", "vin": "NOP012", "lot": "424344", "job": "Job404142", "unitRemaining": 19, "color": "Teal", "year": 2023, "mileage": 22000},   {"model": "Audi", "vin": "PQR678", "lot": "181920", "job": "Job161718", "unitRemaining": 12, "color": "Gray", "year": 2022, "mileage": 27000},{"model": "Honda", "vin": "DEF456", "lot": "5678", "job": "Job456", "unitRemaining": 15, "color": "Blue", "year": 2021, "mileage": 30000}, {"model": "Toyota", "vin": "ABC123", "lot": "1234", "job": "Job123", "unitRemaining": 10, "color": "Red", "year": 2022, "mileage": 25000},{"model": "Toyota", "vin": "ABC123", "lot": "1234", "job": "Job123", "unitRemaining": 10}, {"model": "Honda", "vin": "DEF456", "lot": "5678", "job": "Job456", "unitRemaining": 15}]}';

    // Convert JSON string to Map
    Map<String, dynamic> responseJson = json.decode(apiResponse);
    // Extract list of vehicles from the response and convert them into Vehicle objects
    List<Vehicle> fetchedVehicles = (responseJson['vehicles'] as List)
        .map((vehicleJson) => Vehicle.fromJson(vehicleJson))
        .toList();
    setState(() {
      vehicles = fetchedVehicles; // Update state with fetched vehicles
    });
  }

  TextEditingController searchController = TextEditingController();
  String searchText = '';
  bool _isSearching = false;
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
      body: ListView.builder(
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          Color categoryColor = colors[index % colors.length];
          var vin = vehicles[index].vin;
          var model = vehicles[index].model;
          if (searchText.isNotEmpty &&
              !(vin.toLowerCase().contains(searchText.toLowerCase()) ||
                  model.toLowerCase().contains(searchText.toLowerCase()))) {
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
                  title: Text(
                    vehicles[index].model,
                    style: TextStyle(
                        color: Colors.amber[900], fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('VIN: ${vehicles[index].vin}'),
                      Text('lOT: ${vehicles[index].lot}'),
                      Text('Unit Remaining: ${vehicles[index].unitRemaining}'),
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
                          borderRadius:
                              BorderRadius.only(topRight: Radius.circular(10))),
                      child: TextButton(
                        onPressed: () {
                          showInDialog(context,
                              builder: (context) => ChooseComponent(),
                              dialogAnimation:
                                  DialogAnimation.SLIDE_TOP_BOTTOM);
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VehicleDetailsPage(vehicle: vehicles[index]),
                      ),
                    );
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
