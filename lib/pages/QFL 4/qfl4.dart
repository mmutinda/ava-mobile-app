// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:isuze_pqcs/common/api.dart';
// import 'package:isuze_pqcs/common/functions.dart';
// import 'package:isuze_pqcs/common/widgets.dart';
// import 'package:isuze_pqcs/models/qc_inpection.dart';
// import 'package:isuze_pqcs/pages/QFL%204/QFL4_form.dart';
// import 'package:isuze_pqcs/pages/QFL%204/QFL4_view.dart';
// import 'package:nb_utils/nb_utils.dart';

// class QFL4 extends StatefulWidget {
//   @override
//   _QFL4State createState() => _QFL4State();
// }

// class _QFL4State extends State<QFL4> {
//   final List<Color> colors = [
//     Colors.amber.shade900,
//     Colors.indigo,
//     Colors.teal,
//   ];
//   List<Vehicle> vehicles = []; // List to hold vehicles fetched from API
//   var user = {};
//   bool isLoading = false;
//   String message = '';

//   @override
//   void initState() {
//     super.initState();
//     getuserdata().then((value) {
//       setState(() {
//         user = jsonDecode(value);
//       });
//       fetchData();
//     });
//     // fetchData(); // Fetch data when the page is initialized
//   }

//   Future<void> fetchData() async {
//     final shouldShowLoading = vehicles.isEmpty;

//     if (shouldShowLoading) {
//       EasyLoading.show(
//         status: "Loading units...",
//         maskType: EasyLoadingMaskType.black,
//       );
//     }

//     setState(() {
//       isLoading = shouldShowLoading;
//       message = '';
//     });

//     final url = "${Api.api_url}sheduledunits";

//     try {
//       final response = await httpget(url, user['data']['token'], context);
//       print(response);

//       if (response == null) {
//         setState(() {
//           isLoading = false;
//           message = 'Something went wrong. Check your internet connection.';
//         });
//         EasyLoading.dismiss();
//         return;
//       }

//       if (response['success'] && response['data'] != null) {
//         final List<Vehicle> fetchedVehicles = (response['data'] as List)
//             .map((vehicleData) => Vehicle.fromJson(vehicleData))
//             .toList();

//         setState(() {
//           vehicles = fetchedVehicles;
//           isLoading = false;
//           message = '';
//         });
//         if (vehicles.isEmpty) {
//           setState(() {
//             message = "No scheduled units found.";
//           });
//           EasyLoading.dismiss();
//         }
//       } else {
//         setState(() {
//           isLoading = false;
//           message = response['msg'] ?? 'Unexpected error';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//         message = 'Network problem: $e';
//       });
//       print('Error fetching data: $e');
//     } finally {
//       EasyLoading.dismiss();
//     }
//   }

//   @override
//   void dispose() {
//     if (isLoading) {
//       EasyLoading.dismiss(); // Dismiss loading when navigating away
//     }
//     super.dispose();
//   }

//   TextEditingController searchController = TextEditingController();
//   String searchText = '';
//   bool _isSearching = false;
//   @override
//   Widget build(BuildContext context) {
//     vehicles.sort((a, b) =>
//         DateTime.parse(b.created_at).compareTo(DateTime.parse(a.created_at)));

//     Widget _buildSearchField() {
//       return TextField(
//         autofocus: true,
//         style: TextStyle(color: Colors.white),
//         cursorColor: Colors.white,
//         controller: searchController,
//         onChanged: (value) {
//           setState(() {
//             searchText = value;
//           });
//         },
//         decoration: InputDecoration(
//             hintText: 'search...',
//             border: InputBorder.none,
//             hintStyle: TextStyle(color: Colors.white)),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: _isSearching ? _buildSearchField() : Text('Units'),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: IconButton(
//               icon: Icon(_isSearching ? Icons.close : Icons.search),
//               onPressed: () {
//                 setState(() {
//                   _isSearching = !_isSearching;
//                   if (!_isSearching) {
//                     searchController.clear();
//                     searchText = '';
//                   }
//                 });
//               },
//             ),
//           ),
//         ],
//       ),
//       body: isLoading
//           ? Center(child: SizedBox.shrink()) // Keep an empty widget
//           : message.isNotEmpty
//               ? ErrorMessageWidget(
//                   errorMessage: message,
//                   onRetry: () {
//                     fetchData();
//                   },
//                 ) // Show message for success or failure
//               : ListView.builder(
//                   itemCount: vehicles.length,
//                   itemBuilder: (context, index) {
//                     Color categoryColor = colors[index % colors.length];
//                     var vin = vehicles[index].vin;
//                     var model = vehicles[index].model;
//                     if (searchText.isNotEmpty &&
//                         !(vin
//                                 .toLowerCase()
//                                 .contains(searchText.toLowerCase()) ||
//                             model
//                                 .toLowerCase()
//                                 .contains(searchText.toLowerCase()))) {
//                       return Container(); // Return an empty container if not matching
//                     }
//                     return Column(
//                       children: [
//                         SizedBox(height: 5),
//                         Stack(children: [
//                           Container(
//                             padding: EdgeInsets.all(12),
//                             decoration: boxDecoration(
//                               radius: 10,
//                               showShadow: true,
//                               bgColor: Colors.white,
//                             ),
//                             child: ListTile(
//                               contentPadding: EdgeInsets.all(0),
//                               leading: CircleAvatar(
//                                 backgroundColor:
//                                     Color.fromARGB(255, 168, 88, 32),
//                                 foregroundColor: Colors.white,
//                                 child: Text("${index + 1}"),
//                               ),
//                               title: Text(
//                                 vehicles[index].vin,
//                                 style: TextStyle(
//                                     color: Colors.amber[900],
//                                     fontWeight: FontWeight.bold),
//                               ),
//                               subtitle: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   // Text('VIN: ${vehicles[index].vin}'),
//                                   Text(
//                                     vehicles[index].model,
//                                     style: TextStyle(
//                                         // color: Colors.amber[900],
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                   Text(
//                                       '${vehicles[index].customer_name ?? ''}'),
//                                 ],
//                               ),
//                               trailing: Container(
//                                   decoration: BoxDecoration(
//                                       border: Border.all(color: categoryColor),
//                                       borderRadius: BorderRadius.only(
//                                           topRight: Radius.circular(10))),
//                                   child: TextButton(
//                                     onPressed: () {
//                                       // Navigator.push(
//                                       //   context,
//                                       //   MaterialPageRoute(
//                                       //     builder: (context) => QFL4_form(
//                                       //       vehicleId: vehicles[index].id,
//                                       //       modelId: vehicles[index].model_id,
//                                       //     ),
//                                       //   ),
//                                       // );
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) => QFL4_View(
//                                             vehicleId: vehicles[index].id,
//                                             modelId: vehicles[index].model_id,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                     child: Text(
//                                       "SELECT",
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   )),
//                               onTap: () {
//                                 // Navigate to vehicle details page passing the selected vehicle
//                                 // Navigator.push(
//                                 //   context,
//                                 //   MaterialPageRoute(
//                                 //     builder: (context) => QFL4_form(
//                                 //       vehicleId: vehicles[index].id,
//                                 //       modelId: vehicles[index].model_id,
//                                 //     ),
//                                 //   ),
//                                 // );
//                               },
//                             ),
//                           ),

//                           // 🔷 Badge (top-right)
//                         ]),
//                         SizedBox(height: 10),
//                       ],
//                     );
//                   },
//                 ),
//     );
//   }
// }

// BoxDecoration boxDecoration(
//     {double radius = 2,
//     Color color = Colors.transparent,
//     Color? bgColor,
//     var showShadow = false}) {
//   return BoxDecoration(
//     color: bgColor,
//     boxShadow: showShadow
//         ? defaultBoxShadow(shadowColor: shadowColorGlobal)
//         : [const BoxShadow(color: Colors.transparent)],
//     border: Border.all(color: color),
//     borderRadius: BorderRadius.all(Radius.circular(radius)),
//   );
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/models/qc_inpection.dart';
import 'package:isuze_pqcs/pages/QFL%204/QFL4_view.dart';
import 'package:isuze_pqcs/pages/tms/TorqueEntryPage.dart';
import 'package:nb_utils/nb_utils.dart';

class QFL4 extends StatefulWidget {
  @override
  _QFL4State createState() => _QFL4State();
}

class _QFL4State extends State<QFL4> with TickerProviderStateMixin {
  final List<Color> colors = [
    Colors.amber.shade900,
    Colors.indigo,
    Colors.teal,
    Colors.deepPurple,
    Colors.orange,
    Colors.green,
  ];

  final List<LinearGradient> gradients = [
    LinearGradient(
      colors: [Colors.amber.shade900, Colors.amber.shade700],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Colors.indigo, Colors.blue.shade400],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Colors.teal, Colors.cyan.shade400],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Colors.deepPurple, Colors.purple.shade400],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Colors.orange, Colors.deepOrange.shade400],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Colors.green, Colors.lightGreen.shade400],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<Vehicle> vehicles = []; // List to hold vehicles fetched from API
  var user = {};
  bool isLoading = false;
  String message = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

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
        _animationController.forward();
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
    _animationController.dispose();
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
        elevation: 0,
        backgroundColor: mycolor,
        title: _isSearching
            ? _buildSearchField()
            : Text(
                'QFL 4 Units',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: Icon(
                  _isSearching ? Icons.close : Icons.search,
                  color: Colors.white,
                ),
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
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: vehicles.length,
                      itemBuilder: (context, index) {
                        LinearGradient cardGradient =
                            gradients[index % gradients.length];
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
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          margin: EdgeInsets.only(bottom: 8),
                          child: Card(
                            color: Colors.white,
                            elevation: 2,
                            // shadowColor: mycolor.withOpacity(0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              decoration: BoxDecoration(),
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Compact avatar
                                    Container(
                                      width: 45,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        gradient: cardGradient,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                categoryColor.withOpacity(0.2),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          "${index + 1}",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    // Content area
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // VIN with badge
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: categoryColor
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              vehicles[index].vin,
                                              style: TextStyle(
                                                color: categoryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          // Model and customer in one row
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.directions_car,
                                                color: categoryColor,
                                                size: 16,
                                              ),
                                              SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  vehicles[index].model,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                    color: Colors.grey.shade800,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (vehicles[index]
                                                  .customer_name
                                                  ?.isNotEmpty ==
                                              true) ...[
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.person,
                                                  color: categoryColor,
                                                  size: 16,
                                                ),
                                                SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    vehicles[index]
                                                            .customer_name ??
                                                        '',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontSize: 12,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    // Compact select button
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: cardGradient,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                categoryColor.withOpacity(0.2),
                                            blurRadius: 3,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => QFL4_View(
                                                  vehicleName: vehicles[index].model,
                                                  vehicleVin: vehicles[index].vin,
                                                  vehicleId: vehicles[index].id,
                                                  modelId:
                                                      vehicles[index].model_id,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "SELECT",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                SizedBox(width: 4),
                                                Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: Colors.white,
                                                  size: 12,
                                                ),
                                              ],
                                            ),
                                          ),
                                          
                                        ),
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
    );
  }
}
