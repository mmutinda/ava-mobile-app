// import 'dart:convert';

// import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
// import 'package:flutter/material.dart';
// import 'package:isuze_pqcs/common/api.dart';
// import 'package:isuze_pqcs/common/constants.dart';
// import 'package:isuze_pqcs/common/functions.dart';
// import 'package:isuze_pqcs/common/loader.dart';
// import 'package:isuze_pqcs/common/widgets.dart';
// import 'package:nb_utils/nb_utils.dart';
// // import 'package:nb_utils/nb_utils.dart';
// import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
// // import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

// class ChooseComponent extends StatefulWidget {
//   final vehicle_id;
//   final route_id;
//   final job_no;

//   const ChooseComponent(
//       {super.key,
//       required this.vehicle_id,
//       required this.route_id,
//       required this.job_no});

//   @override
//   State<ChooseComponent> createState() => _ChooseComponentState();
// }

// class _ChooseComponentState extends State<ChooseComponent> {
//   String? selectedComponent;
//   late TextEditingController inputController;
//   final List<String> data = [
//     // 'Cabin/Cockpit',
//     // 'Chassis',
//   ];
//   final List<String> data2 = [
//     // 'Cabin/Cockpit',
//     // 'Chassis',
//   ];
//   final List<String> data3 = [
//     // 'Cabin/Cockpit',
//     // 'Chassis',
//   ];
//   var user = {};
//   var alldata = {};
//   var components = {};
//   String ComponentId = '';
//   String message = '';
//   bool isLoading = false;

//   // Lines data
//   List<Map<String, dynamic>> lines = [];
//   String? selectedLineId;
//   String? selectedLineName;
//   @override
//   void initState() {
//     inputController = TextEditingController(text: widget.job_no);
//     super.initState();
//     getuserdata().then((value) {
//       setState(() {
//         user = jsonDecode(value);
//       });
//       fetchComponent();
//     });
//   }

//   Future fetchComponent() async {
//     setState(() {
//       message = '';
//       isLoading = true;
//     });

//     try {
//       String unitsurl =
//           Api.api_url + "getcomponent/${widget.route_id}/${widget.vehicle_id}";
//       print(unitsurl);
//       var responsedata =
//           await httpget(unitsurl, "${user['data']['token']}", context);

//       if (responsedata != null && responsedata["success"] == true) {
//         // Clear existing data before adding new ones
//         setState(() {
//           data.clear();
//           data2.clear();
//           data3.clear();
//         });

//         if (responsedata["data"] != null &&
//             responsedata["data"]['routes'] != null) {
//           responsedata["data"]['routes'].forEach((var route) {
//             print(route['routing_part']);
//             setState(() {
//               data.add(route['routing_part'] ?? 'Unknown Component');
//               data2.add(route['id']?.toString() ?? '');
//               data3.add(route['route_number']?.toString() ?? '');
//             });
//           });

//           // Parse lines data
//           if (responsedata["data"]['lines'] != null) {
//             setState(() {
//               lines.clear();
//               lines.addAll(List<Map<String, dynamic>>.from(
//                   responsedata["data"]['lines']));
//             });
//           }

//           // Check if no components were found
//           if (data.isEmpty) {
//             setState(() {
//               message = 'No components available for this route';
//               isLoading = false;
//             });
//           } else {
//             setState(() {
//               isLoading = false;
//             });
//           }
//         } else {
//           setState(() {
//             message = 'Invalid response format from server';
//             isLoading = false;
//           });
//         }
//       } else {
//         setState(() {
//           message = responsedata?["message"] ??
//               responsedata?["msg"] ??
//               'Failed to load components. Please try again.';
//           isLoading = false;
//         });
//       }
//     } catch (error) {
//       // Handle different types of errors
//       print('Error fetching components: $error');
//       String errorMessage = 'Network error occurred';

//       if (error.toString().contains('SocketException') ||
//           error.toString().contains('TimeoutException')) {
//         errorMessage =
//             'Network connection failed. Check your internet connection.';
//       } else if (error.toString().contains('FormatException')) {
//         errorMessage = 'Invalid server response format';
//       } else if (error.toString().contains('Unauthorized') ||
//           error.toString().contains('401')) {
//         errorMessage = 'Session expired. Please login again.';
//       } else if (error.toString().contains('404')) {
//         errorMessage = 'Service not found. Please try again later.';
//       } else if (error.toString().contains('500')) {
//         errorMessage = 'Server error. Please try again later.';
//       }

//       setState(() {
//         message = errorMessage;
//         isLoading = false;
//       });

//       // Show error toast for immediate feedback
//       awesomeTopSnackbar(
//         context,
//         errorMessage,
//         iconWithDecoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(),
//             color: Colors.white),
//         icon: Icon(
//           Icons.error_outline,
//           color: Colors.red,
//         ),
//         backgroundColor: Colors.red[900],
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       // decoration: BoxDecoration(
//       //   color: Colors.white,
//       //   borderRadius: BorderRadius.circular(20),
//       //   boxShadow: [
//       //     BoxShadow(
//       //       color: mycolor.withOpacity(0.1),
//       //       blurRadius: 20,
//       //       offset: Offset(0, 8),
//       //       spreadRadius: 2,
//       //     ),
//       //   ],
//       // ),
//       child: isLoading
//           ? Container(
//               height: 250,
//               child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CustomLoader(),
//                     // CircularProgressIndicator(
//                     //   valueColor: AlwaysStoppedAnimation<Color>(mycolor),
//                     //   strokeWidth: 3,
//                     // ),
//                     SizedBox(height: 16),
//                     Text(
//                       'Loading components...',
//                       style: TextStyle(
//                         color: mycolor,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           : message.isNotEmpty
//               ? Container(
//                   constraints: BoxConstraints(
//                     minHeight: 200,
//                     maxHeight: 400,
//                   ),
//                   child: ErrorMessageWidget(
//                     errorMessage: message,
//                     onRetry: () {
//                       fetchComponent();
//                     },
//                   ),
//                 )
//               : Container(
//                   constraints: BoxConstraints(
//                     maxHeight: MediaQuery.of(context).size.height * 0.8,
//                   ),
//                   child: Column(mainAxisSize: MainAxisSize.min, children: [
//                     // Header with gradient
//                     Container(
//                       alignment: Alignment.center,
//                       width: double.infinity,
//                       padding:
//                           EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [mycolor, mycolor.withOpacity(0.8)],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(20),
//                           topRight: Radius.circular(20),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.settings,
//                             color: Colors.white,
//                             size: 24,
//                           ),
//                           SizedBox(width: 12),
//                           Text(
//                             "CHOOSE COMPONENT",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 18,
//                               letterSpacing: 1.2,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     // Content area - make scrollable
//                     DropdownButtonFormField<String>(
//                       value: selectedLineId,
//                       decoration: InputDecoration(
//                         labelText: 'Select Production Line',
//                         labelStyle: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87,
//                         ),
//                         filled: true,
//                         fillColor: Colors.grey[50],
//                         contentPadding:
//                             EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(
//                             color: Colors.grey.shade300,
//                             width: 1,
//                           ),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(
//                             color: mycolor,
//                             width: 2,
//                           ),
//                         ),
//                       ),
//                       icon: Icon(Icons.keyboard_arrow_down, color: mycolor),
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.black87,
//                       ),
//                       items: lines.map((line) {
//                         return DropdownMenuItem<String>(
//                           value: line['id'].toString(),
//                           child: Row(
//                             children: [
//                               Container(
//                                 width: 8,
//                                 height: 8,
//                                 margin: EdgeInsets.only(right: 12),
//                                 decoration: BoxDecoration(
//                                   color: line['status'] == 'Active'
//                                       ? Colors.green
//                                       : Colors.grey,
//                                   shape: BoxShape.circle,
//                                 ),
//                               ),
//                               Text(
//                                 line['name'] ?? 'Unknown Line',
//                                 style: TextStyle(
//                                     fontSize: 14, fontWeight: FontWeight.w500),
//                               ),
//                             ],
//                           ),
//                         );
//                       }).toList(),
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           selectedLineId = newValue;
//                           selectedLineName = lines.firstWhere(
//                             (line) => line['id'].toString() == newValue,
//                             orElse: () => {'name': 'Unknown'},
//                           )['name'];
//                         });
//                       },
//                     ),

//                     Flexible(
//                       child: Container(
//                         child: Container(
//                           padding: EdgeInsets.all(20),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               // Component selection cards
//                               ...data.map((component) {
//                                 final componentName = component;
//                                 final componentNameId =
//                                     data2[data.indexOf(component)];
//                                 final route_number =
//                                     data3[data.indexOf(component)];
//                                 final isSelected =
//                                     ComponentId == componentNameId;

//                                 return Container(
//                                   margin: EdgeInsets.only(bottom: 12),
//                                   child: InkWell(
//                                     onTap: () {
//                                       setState(() {
//                                         ComponentId = componentNameId;
//                                         components = {
//                                           'id': componentNameId,
//                                           'route_number': route_number
//                                         };
//                                         selectedComponent = ComponentId;
//                                       });
//                                     },
//                                     borderRadius: BorderRadius.circular(16),
//                                     child: AnimatedContainer(
//                                       duration: Duration(milliseconds: 200),
//                                       padding: EdgeInsets.all(16),
//                                       decoration: BoxDecoration(
//                                         color: isSelected
//                                             ? Colors.grey[50]
//                                             : Colors.grey[50],
//                                         borderRadius: BorderRadius.circular(16),
//                                         border: Border.all(
//                                           color: isSelected
//                                               ? mycolor
//                                               : Colors.grey[300]!,
//                                           width: isSelected ? 2 : 1,
//                                         ),
//                                       ),
//                                       child: Row(
//                                         children: [
//                                           Container(
//                                             width: 24,
//                                             height: 24,
//                                             decoration: BoxDecoration(
//                                               shape: BoxShape.circle,
//                                               border: Border.all(
//                                                 color: isSelected
//                                                     ? mycolor
//                                                     : Colors.grey[400]!,
//                                                 width: 2,
//                                               ),
//                                               color: isSelected
//                                                   ? mycolor
//                                                   : Colors.transparent,
//                                             ),
//                                             child: isSelected
//                                                 ? Icon(
//                                                     Icons.check,
//                                                     color: Colors.white,
//                                                     size: 16,
//                                                   )
//                                                 : null,
//                                           ),
//                                           SizedBox(width: 16),
//                                           Expanded(
//                                             child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   componentName,
//                                                   style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     fontSize: 16,
//                                                     color: isSelected
//                                                         ? mycolor
//                                                         : Colors.black87,
//                                                   ),
//                                                 ),
//                                                 if (route_number
//                                                     .isNotEmpty) ...[
//                                                   SizedBox(height: 4),
//                                                   Text(
//                                                     'Route: $route_number',
//                                                     style: TextStyle(
//                                                       fontSize: 12,
//                                                       color: Colors.grey[600],
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ],
//                                             ),
//                                           ),
//                                           if (isSelected)
//                                             Container(
//                                               padding: EdgeInsets.symmetric(
//                                                 horizontal: 8,
//                                                 vertical: 4,
//                                               ),
//                                               decoration: BoxDecoration(
//                                                 color: mycolor,
//                                                 borderRadius:
//                                                     BorderRadius.circular(8),
//                                               ),
//                                               child: Text(
//                                                 'SELECTED',
//                                                 style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 10,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                             ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               }).toList(),

//                               // Lines dropdown section

//                               SizedBox(height: 24),

//                               // Action button
//                               Container(
//                                 width: double.infinity,
//                                 child: ElevatedButton(
//                                   onPressed: () async {
//                                     if (selectedComponent != null &&
//                                         selectedLineId != null) {
//                                       showConfirmDialogCustom(
//                                         primaryColor: mycolor,
//                                         context,
//                                         title: "Do you want to Push this?",
//                                         onAccept: (val) async {
//                                           final ProgressDialog progressDialog =
//                                               ProgressDialog(context);
//                                           progressDialog.style(
//                                             message: 'Pushing...',
//                                             child: CustomLoader(),
//                                             progressWidget:
//                                                 CircularProgressIndicator(
//                                               valueColor:
//                                                   AlwaysStoppedAnimation<Color>(
//                                                       mycolor),
//                                             ),
//                                           );
//                                           await progressDialog.show();

//                                           try {
//                                             String url = Api.api_url +
//                                                 "moveunitfromstore";
//                                             var payload = {
//                                               "id": widget.vehicle_id,
//                                               "route_id": widget.route_id,
//                                               "component": components,
//                                               // "job_no": inputController.text,[]
//                                               "line_name": selectedLineName,
//                                             };
//                                             print(payload);
//                                             log(jsonEncode(payload));
//                                             print(url);
//                                             var response =
//                                                 await httppostwithtoken(
//                                                     url,
//                                                     user['data']['token'],
//                                                     payload,
//                                                     context);
//                                             print(response);

//                                             await progressDialog.hide();

//                                             if (response != null &&
//                                                 response['success'] == true) {
//                                               awesomeTopSnackbar(
//                                                 context,
//                                                 "${response['msg'] ?? 'Component pushed successfully!'}",
//                                                 iconWithDecoration:
//                                                     BoxDecoration(
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(20),
//                                                         border: Border.all(),
//                                                         color: Colors.white),
//                                                 icon: Icon(
//                                                   Icons.done,
//                                                   color: Colors.green[900],
//                                                 ),
//                                               );
//                                               Navigator.pop(context);
//                                             } else {
//                                               String errorMsg = response?[
//                                                       'msg'] ??
//                                                   response?['message'] ??
//                                                   'Failed to push component. Please try again.';
//                                               awesomeTopSnackbar(
//                                                   context, errorMsg,
//                                                   iconWithDecoration:
//                                                       BoxDecoration(
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(20),
//                                                           border: Border.all(),
//                                                           color: Colors.white),
//                                                   icon: Icon(
//                                                     Icons.close,
//                                                     color: Colors.red,
//                                                   ),
//                                                   backgroundColor:
//                                                       Colors.red[900]);
//                                             }
//                                             return response;
//                                           } catch (e) {
//                                             await progressDialog.hide();
//                                             print("error : $e");

//                                             String errorMessage =
//                                                 'An error occurred while pushing component';

//                                             if (e.toString().contains(
//                                                     'SocketException') ||
//                                                 e.toString().contains(
//                                                     'TimeoutException')) {
//                                               errorMessage =
//                                                   'Network connection failed. Check your internet connection.';
//                                             } else if (e
//                                                     .toString()
//                                                     .contains('Unauthorized') ||
//                                                 e.toString().contains('401')) {
//                                               errorMessage =
//                                                   'Session expired. Please login again.';
//                                             } else if (e
//                                                 .toString()
//                                                 .contains('404')) {
//                                               errorMessage =
//                                                   'Service not found. Please try again later.';
//                                             } else if (e
//                                                 .toString()
//                                                 .contains('500')) {
//                                               errorMessage =
//                                                   'Server error. Please try again later.';
//                                             }

//                                             awesomeTopSnackbar(
//                                                 context, errorMessage,
//                                                 iconWithDecoration:
//                                                     BoxDecoration(
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(20),
//                                                         border: Border.all(),
//                                                         color: Colors.white),
//                                                 icon: Icon(
//                                                   Icons.error_outline,
//                                                   color: Colors.red,
//                                                 ),
//                                                 backgroundColor:
//                                                     Colors.red[900]);
//                                           }

//                                           Navigator.pop(context);
//                                         },
//                                       );
//                                     } else {
//                                       String missingSelection = '';
//                                       if (selectedComponent == null &&
//                                           selectedLineId == null) {
//                                         missingSelection =
//                                             'Please select both component and production line.';
//                                       } else if (selectedComponent == null) {
//                                         missingSelection =
//                                             'Please select a component.';
//                                       } else {
//                                         missingSelection =
//                                             'Please select a production line.';
//                                       }

//                                       awesomeTopSnackbar(
//                                           context, missingSelection,
//                                           iconWithDecoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(20),
//                                               border: Border.all(),
//                                               color: Colors.white),
//                                           icon: Icon(
//                                             Icons.close,
//                                             color: Colors.red,
//                                           ),
//                                           backgroundColor: Colors.red[900]);
//                                     }
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: mycolor,
//                                     foregroundColor: Colors.white,
//                                     padding: EdgeInsets.symmetric(vertical: 16),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(16),
//                                     ),
//                                     elevation: 8,
//                                     shadowColor: mycolor.withOpacity(0.3),
//                                   ),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Icon(Icons.push_pin, size: 20),
//                                       SizedBox(width: 12),
//                                       Text(
//                                         "PUSH COMPONENT",
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 16,
//                                           letterSpacing: 0.5,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     )
//                   ]),
//                 ),
//     );
//   }
// }
import 'dart:convert';

import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class ChooseComponent extends StatefulWidget {
  final String vehicle_id;
  final String route_id;
  final String vehicle_line;

  const ChooseComponent({
    super.key,
    required this.vehicle_id,
    required this.route_id,
    required this.vehicle_line,
  });

  @override
  State<ChooseComponent> createState() => _ChooseComponentState();
}

class _ChooseComponentState extends State<ChooseComponent> {
  String? selectedComponentId;
  late TextEditingController inputController;

  var user = {};
  var selectedComponent = {};
  String message = '';
  bool isLoading = false;

  List<Map<String, dynamic>> components = [];
  List<Map<String, dynamic>> lines = [];

  String? selectedLineId;
  String? selectedLineName;

  @override
  void initState() {
    super.initState();
    inputController = TextEditingController(text: widget.vehicle_line);

    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      fetchComponent();
    });
  }

  Future<void> fetchComponent() async {
    setState(() {
      message = '';
      isLoading = true;
    });

    try {
      final String url =
          '${Api.api_url}getcomponent/${widget.route_id}/${widget.vehicle_id}';
      final response = await httpget(url, user['data']['token'], context);

      if (response != null && response['success'] == true) {
        final routes = response['data']?['routes'] ?? [];
        final linesData = response['data']?['lines'] ?? [];

        setState(() {
          components = List<Map<String, dynamic>>.from(routes);
          lines = List<Map<String, dynamic>>.from(linesData);
          isLoading = false;

          if (components.isEmpty) {
            message = 'No components available for this route';
          }
        });
      } else {
        setState(() {
          message = response?["message"] ??
              response?["msg"] ??
              'Failed to load components';
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching components: $e");
      setState(() {
        message = _getErrorMessage(e.toString());
        isLoading = false;
      });

      awesomeTopSnackbar(
        context,
        message,
        iconWithDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(),
          color: Colors.white,
        ),
        icon: Icon(Icons.error_outline, color: Colors.red),
        backgroundColor: Colors.red[900],
      );
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('SocketException') ||
        error.contains('TimeoutException')) {
      return 'Network connection failed. Check your internet connection.';
    } else if (error.contains('Unauthorized') || error.contains('401')) {
      return 'Session expired. Please login again.';
    } else if (error.contains('404')) {
      return 'Service not found. Please try again later.';
    } else if (error.contains('500')) {
      return 'Server error. Please try again later.';
    } else if (error.contains('FormatException')) {
      return 'Invalid server response format.';
    } else {
      return 'Unexpected error occurred. Please try again.';
    }
  }

  void _submit() async {
    if (selectedComponentId != null &&
        (selectedLineId != null || widget.vehicle_line.isNotEmpty)) {
      // If vehicle_line is not empty, use it as selectedLineName
      if (widget.vehicle_line.isNotEmpty) {
        selectedLineName = widget.vehicle_line;
      }
      showConfirmDialogCustom(
        primaryColor: mycolor,
        context,
        title: "Do you want to Push this?",
        onAccept: (val) async {
          final progressDialog = ProgressDialog(context);
          progressDialog.style(
            message: 'Pushing...',
            child: CustomLoader(),
            progressWidget: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(mycolor),
            ),
          );

          await progressDialog.show();

          try {
            final url = '${Api.api_url}moveunitfromstore';
            final payload = {
              "id": widget.vehicle_id,
              "route_id": widget.route_id,
              "component": selectedComponent,
              "line_name": selectedLineName,
            };

            final response = await httppostwithtoken(
                url, user['data']['token'], payload, context);

            await progressDialog.hide();

            if (response != null && response['success'] == true) {
              awesomeTopSnackbar(
                context,
                response['msg'] ?? 'Component pushed successfully!',
                iconWithDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(),
                  color: Colors.white,
                ),
                icon: Icon(Icons.done, color: Colors.green[900]),
              );
              Navigator.pop(context);
            } else {
              final errorMsg = response?['msg'] ??
                  response?['message'] ??
                  'Failed to push component.';
              awesomeTopSnackbar(
                context,
                errorMsg,
                iconWithDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(),
                  color: Colors.white,
                ),
                icon: Icon(Icons.close, color: Colors.red),
                backgroundColor: Colors.red[900],
              );
            }
          } catch (e) {
            await progressDialog.hide();
            awesomeTopSnackbar(
              context,
              _getErrorMessage(e.toString()),
              iconWithDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(),
                color: Colors.white,
              ),
              icon: Icon(Icons.error_outline, color: Colors.red),
              backgroundColor: Colors.red[900],
            );
          }
        },
      );
    } else {
      final error = selectedComponentId == null
          ? (selectedLineId == null
              ? 'Please select both component and production line.'
              : 'Please select a component.')
          : 'Please select a production line.';

      awesomeTopSnackbar(
        context,
        error,
        iconWithDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(),
          color: Colors.white,
        ),
        icon: Icon(Icons.close, color: Colors.red),
        backgroundColor: Colors.red[900],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.vehicle_line.isNotEmpty);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: mycolor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient
            Container(
              alignment: Alignment.center,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [mycolor, mycolor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 24), // Balance the close button
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.settings, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      const Text(
                        "CHOOSE COMPONENT",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          // letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Content area
            Flexible(
              child: isLoading
                  ? Container(
                      height: 250,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomLoader(),
                            const SizedBox(height: 16),
                            Text(
                              'Loading components...',
                              style: TextStyle(
                                color: mycolor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : message.isNotEmpty
                      ? Container(
                          constraints: const BoxConstraints(
                            minHeight: 200,
                            maxHeight: 400,
                          ),
                          child: ErrorMessageWidget(
                            errorMessage: message,
                            onRetry: fetchComponent,
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (lines.isNotEmpty) ...[
                                _buildLineDropdown(),
                                const SizedBox(height: 20),
                              ],
                              const Text(
                                'Select Component',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                              const SizedBox(height: 12),
                              ...components
                                  .map((component) =>
                                      _buildComponentCard(component))
                                  .toList(),
                            ],
                          ),
                        ),
            ),
            // Footer with action button
            Container(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mycolor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: mycolor.withOpacity(0.3),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.push_pin, size: 20),
                      SizedBox(width: 12),
                      Text(
                        "PUSH COMPONENT",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineDropdown() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Production Line',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedLineId,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: 'Choose a production line...',
            filled: true,
            fillColor: widget.vehicle_line.isNotEmpty
                ? Colors.grey[200]
                : Colors.grey[50],
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: mycolor, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          icon: Icon(Icons.keyboard_arrow_down,
              color: widget.vehicle_line.isNotEmpty ? Colors.grey : mycolor),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: widget.vehicle_line.isNotEmpty
                ? Colors.grey[600]
                : Colors.black87,
          ),
          items: widget.vehicle_line.isNotEmpty
              ? null
              : lines.map((line) {
                  return DropdownMenuItem<String>(
                    value: line['id'].toString(),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: line['status'] == 'Active'
                                  ? Colors.green
                                  : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              line['name'] ?? 'Unknown Line',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color:
                                    Colors.black, // <- set to black       here
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          onChanged: widget.vehicle_line.isNotEmpty
              ? null
              : (String? value) {
                  setState(() {
                    selectedLineId = value;
                    selectedLineName = lines.firstWhere(
                        (line) => line['id'].toString() == value)['name'];
                  });
                },
          disabledHint: widget.vehicle_line.isNotEmpty
              ? Text(
                  widget.vehicle_line,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildComponentCard(Map<String, dynamic> component) {
    final componentName = component['routing_part'] ?? 'Unknown';
    final componentId = component['id']?.toString();
    final routeNumber = component['route_number']?.toString() ?? '';
    final isSelected = selectedComponentId == componentId;

    return InkWell(
      onTap: () {
        setState(() {
          selectedComponentId = componentId;
          selectedComponent = {"id": componentId, "route_number": routeNumber};
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? mycolor.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? mycolor : Colors.grey.shade300,
              width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? mycolor : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? mycolor : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    componentName,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? mycolor : Colors.black87),
                  ),
                  if (routeNumber.isNotEmpty)
                    Text('Route: $routeNumber',
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey[600])),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: mycolor, borderRadius: BorderRadius.circular(6)),
                child: const Text('SELECTED',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
