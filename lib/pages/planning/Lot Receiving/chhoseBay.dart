import 'package:flutter/material.dart';
import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:isuze_pqcs/pages/planning/Lot%20Receiving/BoxingLot.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class ChooseComponentBay extends StatefulWidget {
  // final String vehicle_id;
  // final String route_id;
  // final String job_no;

  // const ChooseComponentBay({
  //   super.key,
  //   required this.vehicle_id,
  //   required this.route_id,
  //   required this.job_no,
  // });

  @override
  State<ChooseComponentBay> createState() => _ChooseComponentBayState();
}

class _ChooseComponentBayState extends State<ChooseComponentBay> {
  late TextEditingController inputController;

  final List<String> bays = ['BAY 1', 'BAY 2'];
  final List<String> routes = ['Route 1', 'Route 2', 'Route 3'];

  String? selectedBay;
  String? selectedRoute;

  @override
  void initState() {
    super.initState();
    // inputController = TextEditingController(text: widget.job_no);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(color: Color.fromARGB(255, 192, 85, 3)),
            child: Text(
              "CHOOSE COMPONENT",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20),

          /// Dropdown for Bay
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Choose Bay',
                border: OutlineInputBorder(),
              ),
              value: selectedBay,
              items: bays
                  .map((bay) => DropdownMenuItem(value: bay, child: Text(bay)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedBay = value!;
                });
              },
            ),
          ),

          SizedBox(height: 12),

          /// Dropdown for Route
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Choose Route',
                border: OutlineInputBorder(),
              ),
              value: selectedRoute,
              items: routes
                  .map((route) =>
                      DropdownMenuItem(value: route, child: Text(route)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedRoute = value!;
                });
              },
            ),
          ),

          SizedBox(height: 12),

          /// Job No Input

          Spacer(),

          /// Submit Button
          ElevatedButton(
            onPressed: () async {
              if (selectedBay != null && selectedRoute != null) {
                showConfirmDialogCustom(
                  context,
                  title: "Do you want to Send this?",
                  primaryColor: Colors.amber[900],
                  onAccept: (_) async {
                    final ProgressDialog progressDialog =
                        ProgressDialog(context);
                    progressDialog.style(
                      message: 'Pushing...',
                      child: CircularProgressIndicator(),
                    );
                    await progressDialog.show();

                    await Future.delayed(Duration(seconds: 1)); // Mock delay

                    await progressDialog.hide();
                    awesomeTopSnackbar(
                      context,
                      "Pushed to next shop successfully",
                      iconWithDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(),
                        color: Colors.white,
                      ),
                      icon: Icon(
                        Icons.done,
                        color: Colors.green[900],
                      ),
                    );
                    Navigator.pop(context);
                    // Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => boxingLot()),
                      // Keeps only the first route (Home screen) in the stack
                    );
                  },
                );
              } else {
                awesomeTopSnackbar(
                  context,
                  "Please select Bay and Route",
                  iconWithDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(),
                    color: Colors.white,
                  ),
                  icon: Icon(Icons.close, color: Colors.red),
                  backgroundColor: Colors.red[900],
                );
              }
            },
            child: Text("SEND"),
          ),
        ],
      ),
    );
  }
}
