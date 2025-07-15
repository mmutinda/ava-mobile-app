import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/models/qc_inpection.dart';
import 'package:isuze_pqcs/pages/tms/TorqueEntryPage.dart';
import 'package:nb_utils/nb_utils.dart';

class TMSUnits extends StatefulWidget {
  @override
  _TMSUnitsState createState() => _TMSUnitsState();
}

class _TMSUnitsState extends State<TMSUnits> {
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
        status: "Loading QFL 3 units...",
        maskType: EasyLoadingMaskType.black,
      );
    }

    setState(() {
      isLoading = shouldShowLoading;
      message = '';
    });

    final url = "${Api.api_url}qfl3units";
    print(url);

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
        title: _isSearching ? _buildSearchField() : Text('QFL 3  Units'),
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
                          Card(
                            color: Colors.white,
                            child: ListTile(
                              contentPadding: EdgeInsets.all(0),
                              leading: CircleAvatar(
                                backgroundColor:
                                    Color.fromARGB(255, 168, 88, 32),
                                foregroundColor: Colors.white,
                                child: Text("${index + 1}"),
                              ),
                              title: Text(
                                vehicles[index].vin,
                                style: TextStyle(
                                    color: Colors.amber[900],
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text('VIN: ${vehicles[index].vin}'),
                                  Text(
                                    vehicles[index].model,
                                    style: TextStyle(
                                        // color: Colors.amber[900],
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                      '${vehicles[index].customer_name ?? ''}'),
                                ],
                              ),
                              trailing: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: categoryColor),
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(10))),
                                  child: TextButton(
                                    onPressed: () {
                                      TorqueEntryPage(
                                        id: vehicles[index].id,
                                      ).launch(context,
                                          pageRouteAnimation:
                                              PageRouteAnimation.Slide);
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
                        ]),
                        SizedBox(height: 10),
                      ],
                    );
                  },
                ),
    );
  }
}
