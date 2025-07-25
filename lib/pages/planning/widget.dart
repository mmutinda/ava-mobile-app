// ignore_for_file: unused_import

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isuze_pqcs/models/qc_inpection.dart';
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

class _IssueDialogState extends State<IssueDialog>
    with SingleTickerProviderStateMixin {
  final _partNoController = TextEditingController();
  final _categoryController = TextEditingController();
  final _classificationController = TextEditingController();
  File? _imageFile;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _partNoController.dispose();
    _categoryController.dispose();
    _classificationController.dispose();
    super.dispose();
  }

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
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Section
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColor.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                FeatherIcons.alertTriangle,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Issue Details',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content Section
                      Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStyledTextField(
                              controller: _partNoController,
                              label: 'Part Number',
                              icon: FeatherIcons.hash,
                              hint: 'Enter part number',
                            ),
                            SizedBox(height: 20),
                            _buildStyledTextField(
                              controller: _categoryController,
                              label: 'Issue Category',
                              icon: FeatherIcons.tag,
                              hint: 'Enter issue category',
                            ),
                            SizedBox(height: 20),
                            _buildStyledTextField(
                              controller: _classificationController,
                              label: 'Defect Classification',
                              icon: FeatherIcons.list,
                              hint: 'Enter defect classification',
                            ),
                            SizedBox(height: 24),
                            _buildImageSection(),
                          ],
                        ),
                      ),

                      // Action Buttons
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                label: 'Cancel',
                                icon: FeatherIcons.x,
                                color: Colors.grey,
                                onPressed: () => Navigator.pop(context),
                                isPrimary: false,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildActionButton(
                                label: 'Submit',
                                icon: FeatherIcons.check,
                                color: Theme.of(context).primaryColor,
                                onPressed: _submitIssue,
                                isPrimary: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(FeatherIcons.camera, size: 16, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                'Capture Image',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _captureImage,
          child: Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              border: Border.all(
                color: _imageFile != null
                    ? Theme.of(context).primaryColor.withOpacity(0.3)
                    : Colors.grey.shade300,
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(15),
              color: _imageFile != null
                  ? Theme.of(context).primaryColor.withOpacity(0.05)
                  : Colors.grey.shade50,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: _imageFile == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          FeatherIcons.camera,
                          size: 32,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Tap to capture image",
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Add a photo of the issue",
                        style: GoogleFonts.poppins(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.file(
                          _imageFile!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            FeatherIcons.edit2,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: isPrimary
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.8)],
              )
            : null,
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: isPrimary ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: isPrimary
                ? null
                : BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isPrimary ? Colors.white : color,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: isPrimary ? Colors.white : color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitIssue() {
    if (_partNoController.text.trim().isEmpty ||
        _categoryController.text.trim().isEmpty ||
        _classificationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(FeatherIcons.alertCircle, color: Colors.white),
              SizedBox(width: 8),
              Text('Please fill in all required fields'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    Navigator.pop(context, {
      'partNo': _partNoController.text.trim(),
      'category': _categoryController.text.trim(),
      'classification': _classificationController.text.trim(),
      'image': _imageFile,
    });
  }
}
