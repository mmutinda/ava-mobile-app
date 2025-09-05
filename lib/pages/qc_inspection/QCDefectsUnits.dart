import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/models/qc_inpection.dart';
import 'package:isuze_pqcs/pages/qc_inspection/QcViewlistDefects.dart';
import 'package:nb_utils/nb_utils.dart';

class QCDefectsUnit extends StatefulWidget {
  @override
  _QCDefectsUnitState createState() => _QCDefectsUnitState();
}

class _QCDefectsUnitState extends State<QCDefectsUnit> {
  final List<Color> colors = [
    Colors.amber.shade900,
    Colors.indigo,
    Colors.teal,
  ];
  List<Vehicle> vehicles = [];
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
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    var url = "${Api.api_url}unitswithdefects";

    try {
      var response = await httpget(url, user['data']['token'], context);
      log(jsonEncode(response));
      if (response == null) {
        print("No Internet");
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
      print('Error fetching data: $e');
    }
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
        title: _isSearching ? _buildSearchField() : Text('Units With Defects'),
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
                )
              : ListView.builder(
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    Color categoryColor = colors[index % colors.length];
                    var vin = vehicles[index].vin;
                    var model = vehicles[index].model;
                    // ignore: unused_local_variable
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
                      return Container();
                    }
                    return Column(
                      children: [
                        SizedBox(height: 5),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: boxDecorations(
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
                                  onPressed: () {
                                    QCDefectsPage(vehileId: vehicles[index].id)
                                        .launch(context,
                                            pageRouteAnimation:
                                                PageRouteAnimation.Slide);
                                  },
                                  child: Text(
                                    "CORRECT",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )),
                            onTap: () {},
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

BoxDecoration boxDecorations(
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
