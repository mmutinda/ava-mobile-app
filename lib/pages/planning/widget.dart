// ignore_for_file: unused_import

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isuze_pqcs/models/qc_inpection.dart';
// ignore: unused_import
import 'package:isuze_pqcs/pages/planning/EOL/EOLScreen.dart';
import 'package:isuze_pqcs/pages/planning/Lot%20Receiving/BoxingLot.dart';
import 'package:isuze_pqcs/pages/planning/Lot%20Receiving/chhoseBay.dart';
import 'package:isuze_pqcs/pages/qc_inspection/chooseComponent.dart';
import 'package:nb_utils/nb_utils.dart';

class ListCard extends StatelessWidget {
  final Vehicle vehicle;
  final int index;
  final Color categoryColor;
  final int caseIndex;
  final VoidCallback? onRefresh;

  const ListCard({
    super.key,
    required this.vehicle,
    required this.index,
    required this.categoryColor,
    required this.caseIndex,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    String unitRemaining = 'All';
    if (vehicle.cabin_cockpit_moved == '1') {
      unitRemaining = 'Chassis';
    } else if (vehicle.chasis_moved == '1') {
      unitRemaining = 'Cabin Or Cockpit';
    }

    return Column(
      children: [
        const SizedBox(height: 5),
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6)
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 168, 88, 32),
                  foregroundColor: Colors.white,
                  child: Text("${index + 1}"),
                ),
                title: Text(
                  caseIndex == 0
                      ? "Lot No${index + 1}"
                      : caseIndex == 1
                          ? "Plan  ${index + 1}"
                          : caseIndex == 2
                              ? "Bay  ${index + 1}"
                              : caseIndex == 3
                                  ? "Unit  ${index + 1}"
                                  : caseIndex == 4
                                      ? "Rework  ${index + 1}"
                                      : caseIndex == 5
                                          ? "Unit  ${index + 1}"
                                          : caseIndex == 6
                                              ? "Unit  ${index + 1}"
                                              : "Plan  ${index + 1}",
                  style: TextStyle(
                    color: Colors.amber[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (caseIndex == 3) Text('VIN: ${vehicle.vin}'),
                    if (caseIndex == 3) // Example: conditionally show LOT/JOB
                      Row(
                        children: [
                          Text('LOT: ${vehicle.lot}'),
                          const SizedBox(width: 8),
                          Text('JOB: ${vehicle.job}'),
                        ],
                      ),
                    if (caseIndex == 3)
                      Row(
                        children: [
                          const Text('UNIT REMAINING:'),
                          const SizedBox(width: 5),
                          Text(
                            unitRemaining,
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
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      switch (caseIndex) {
                        case 0:
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChooseComponentBay()),
                          );
                          break;
                        case 1:
                          toasty(context, "Under Development");
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => AnotherScreen()),
                          // );
                          break;
                        case 2:
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => boxingLot()),
                            // Keeps only the first route (Home screen) in the stack
                          );
                          break;
                        case 5:
                          break;
                        default:
                          toasty(context, "Under Development");
                          break;
                      }
                    },
                    child: Text(
                      caseIndex == 0
                          ? "SCHEDULE"
                          : caseIndex == 2
                              ? "View Details"
                              : "OTHER",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),

            // Badge (customer name)
            // if (vehicle.customer_name != null &&
            //     vehicle.customer_name!.isNotEmpty)
            //   Positioned(
            //     right: 10,
            //     top: 0,
            //     child: Container(
            //       padding:
            //           const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            //       decoration: BoxDecoration(
            //         color: Colors.amber[900],
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //       child: Text(
            //         vehicle.customer_name!,
            //         style: const TextStyle(
            //           color: Colors.white,
            //           fontSize: 12,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //     ),
            //   ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class IssueDialog extends StatefulWidget {
  @override
  _IssueDialogState createState() => _IssueDialogState();
}

class _IssueDialogState extends State<IssueDialog> {
  final _partNoController = TextEditingController();
  final _categoryController = TextEditingController();
  final _classificationController = TextEditingController();
  File? _imageFile;

  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Issue Details',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(_partNoController, 'Part No'),
              SizedBox(height: 12),
              _buildTextField(_categoryController, 'Issue Category'),
              SizedBox(height: 12),
              _buildTextField(
                  _classificationController, 'Defect Classification'),
              SizedBox(height: 16),
              GestureDetector(
                onTap: _captureImage,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                    image: _imageFile != null
                        ? DecorationImage(
                            image: FileImage(_imageFile!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Colors.grey.shade100,
                  ),
                  child: _imageFile == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt,
                                  size: 40, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                "Tap to capture image",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel", style: TextStyle(color: Colors.grey[700])),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context, {
              'partNo': _partNoController.text.trim(),
              'category': _categoryController.text.trim(),
              'classification': _classificationController.text.trim(),
              'image': _imageFile,
            });
          },
          icon: Icon(Icons.send),
          label: Text("Submit"),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Theme.of(context).primaryColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[800]),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
