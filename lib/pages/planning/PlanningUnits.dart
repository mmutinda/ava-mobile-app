import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/models/qc_inpection.dart' as Veh;
// import 'package:isuze_pqcs/pages/qc_inspection/chooseComponent.dart';

class PlaningUnits extends StatefulWidget {
  final option;

  const PlaningUnits({super.key, required this.option});
  @override
  _PlaningUnitsState createState() => _PlaningUnitsState();
}

class _PlaningUnitsState extends State<PlaningUnits> {
  final List<Color> colors = [
    Colors.amber.shade900,
    Colors.indigo,
    Colors.teal,
  ];
  List<Veh.Vehicle> vehicles = []; // List to hold vehicles fetched from API
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
      String getLoadingMessage(String option) {
        switch (option) {
          case '0':
            return "Loading scheduled lots";
          case '01':
            return "Loading Unboxing...";
          case '011':
            return "Loading Schedule to Assembly...";
          case '1':
            return "Loading Weekly/\nMonthly Plan...";
          case '2':
            return "Loading Units at\nLogistics...";
          case '3':
            return "Loading Units at Line...";
          case '4':
            return "Loading Units at\nrework...";
          case '5':
            return "Loading Units at EOL...";
          case '6':
            return "Loading Units at GCP...";
          default:
            return "Loading...";
        }
      }

// Use this inside a function or lifecycle method
      EasyLoading.show(
        status: getLoadingMessage(widget.option),
        maskType: EasyLoadingMaskType.black,
      );
    }

    setState(() {
      isLoading = shouldShowLoading;
      message = '';
    });

    final url = "${Api.api_url}sheduledunits";
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
        final List<Veh.Vehicle> fetchedVehicles = (response['data'] as List)
            .map((vehicleData) => Veh.Vehicle.fromJson(vehicleData))
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
    String getScreenTitle(String option) {
      switch (option) {
        case '0':
          return "Scheduled Lots";
        case '01':
          return "Unboxing";
        case '011':
          return "Schedule to Assembly";
        case '1':
          return "Weekly/Monthly Plan";
        case '2':
          return "Units at Logistics";
        case '3':
          return "Units at Line";
        case '4':
          return "Units at rework";
        case '5':
          return "Units at EOL";
        case '6':
          return "Units at GCP";

        default:
          return "Dashboard";
      }
    }

    // print(widget.option);
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
        title: _isSearching
            ? _buildSearchField()
            : Text(getScreenTitle(widget.option)),
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
                    var vin = vehicles[index].vin;
                    var model = vehicles[index].model;
                    if (vehicles[index].cabin_cockpit_moved == '1') {
                    } else if (vehicles[index].chasis_moved == '1') {}
                    if (searchText.isNotEmpty &&
                        !(vin
                                .toLowerCase()
                                .contains(searchText.toLowerCase()) ||
                            model
                                .toLowerCase()
                                .contains(searchText.toLowerCase()))) {
                      return Container(); // Return an empty container if not matching
                    }
                    return null;
                  },
                ),
    );
  }
}
