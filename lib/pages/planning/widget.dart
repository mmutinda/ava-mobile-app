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
  final _processDescriptionController = TextEditingController();
  final _partNoController = TextEditingController();
  final _issueDescriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _issueTypeController = TextEditingController();
  final _reasonCodeController = TextEditingController();
  final _classificationController = TextEditingController();
  File? _imageFile;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  String? _selectedReasonCode;
  String? _selectedIssueCategory;
  String? _selectedIssueType;
  String? _selectedDefectClassification;

  final List<String> _reasonCodes = [
    'WS-Wrong Shipment',
    'SS-Short Shipment',
    'NS-Not Supplied',
    'LL-Line Loss',
    'LD-Line Damage',
    'Related/Child Part',
    'ME-Manufacture Error',
    'Incomplete Process',
    'Jig Missing',
    'Robbed',
    'P/S Delay',
    'Faulty Machine',
    'Dent',
    'Scratches',
    'Debris',
    'Part Misaligned',
    'Dirt Marks',
    'Incomplete documentation',
    'Missing inspection mark',
  ];

  final List<String> _issueCategories = [
    'Process Issues',
    'Part Handling',
    'Paint Issues',
    'KDQR',
    'MMO',
  ];

  final Map<String, List<String>> _issueCategoriesAndTypes = {
    'Process Issues': [
      'LOOSE PART',
      'MISALIGNED PARTS',
      'EXCESS/LESS WORKING FLUIDS',
      'WRONG ROUTING',
      'POORLY FITTED PART',
      'MISSING INSPECTION MARKS',
      'MISSING DOCUMENTS',
      'INCOMPLETE PROCESS',
      'LESS PRESSURE',
      'TEMPORALY FITTED PART',
      'ABS LIGHT ON',
      'PART NOT FITTED',
      'ALTERNATIVE PART',
      'OVER TORQUE',
      'INCOMPLETE WELDS',
      'MISSING PART',
      'DAMAGED PART',
      'WARNING LIGHT',
      'WRONG PART FITTED',
      'LARGE GAPS',
      'WELD SPOTS',
      'WRONG DOCUMENTATION',
      'POROSITY',
      'UNDER TORQUE',
      'WELD UNDERCUTS',
      'POOR PUNCHING',
      'Jig Missing',
      'ROBBED',
      'FAULTY MACHINE',
    ],
    'Part Handling': [
      'SCRATCHES',
      'DENTS',
      'DIRT MARKS',
      'STRAY MARKS',
      'STAIN MARKS',
    ],
    'Paint Issues': [
      'DEBRIS',
      'OVERFLOW',
      'PINHOLES',
      'ORANGE PEELS',
      'COLOUR MISMATCH',
      'PAINT BLISS',
      'LESS PAINT',
      'PAINT BARE AREA',
      'PVC PEEL OFF',
      'PAINT OVERSPRAY',
      'DRY PAINT',
      'PAINT PEEL OFF',
      'POORLY PAINTED',
      'DAMAGED SEALER',
      'DAMAGED PVC',
      'PVC OVERSPRAY',
      'WET PAINT',
    ],
    'KDQR': [
      'PART QUALITY',
      'WS-WRONG SHIPMENT',
      'SS-SHORT SHIPMENT',
      'PROGRAMMING/SERVER',
      'FAULTY PART',
      'SCRATCHES',
      'DEBRIS',
      'ME-MANUFACTURER ERROR',
      'WRONG PART',
      'NS-NOT SUPPLIED',
    ],
    'MMO': [
      'LD-LINE DAMAGE',
      'LL-LINE LOSS',
      'RUST',
    ],
  };

  final List<String> _defectClassifications = [
    'A-Critical',
    'B- Major',
    'C-Minor',
    'D-Cosmetic',
  ];

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
    _processDescriptionController.dispose();
    _partNoController.dispose();
    _issueDescriptionController.dispose();
    _categoryController.dispose();
    _issueTypeController.dispose();
    _reasonCodeController.dispose();
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
                              controller: _issueDescriptionController,
                              label: 'Issue Description',
                              icon: FeatherIcons.fileText,
                              hint: 'Describe the issue in detail',
                              maxLines: 3,
                            ),
                            SizedBox(height: 20),
                            _buildStyledTextField(
                              controller: _processDescriptionController,
                              label: 'Process Description',
                              icon: FeatherIcons.clipboard,
                              hint: 'Enter process description',
                            ),
                            SizedBox(height: 20),
                            _buildStyledTextField(
                              controller: _partNoController,
                              label: 'Part Number',
                              icon: FeatherIcons.hash,
                              hint: 'Enter part number',
                            ),
                            SizedBox(height: 20),
                            _buildIssueCategoryDropdown(),
                            SizedBox(height: 20),
                            _buildIssueTypeDropdown(),
                            SizedBox(height: 20),
                            _buildReasonCodeDropdown(),
                            SizedBox(height: 20),
                            _buildDefectClassificationDropdown(),
                            
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
    int maxLines = 1,
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
            maxLines: maxLines,
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

  Widget _buildIssueCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(FeatherIcons.tag, size: 16, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                'Issue Category',
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
          child: DropdownButtonFormField<String>(
            value: _selectedIssueCategory,
            menuMaxHeight: 600, // Limit dropdown height for scrolling
            decoration: InputDecoration(
              hintText: 'Select issue category',
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
            items: _issueCategories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedIssueCategory = newValue;
                _categoryController.text = newValue ?? '';
                // Reset issue type when category changes
                _selectedIssueType = null;
                _issueTypeController.clear();
              });
            },
            validator: (value) =>
                value == null ? 'Please select an issue category' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildIssueTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(FeatherIcons.type, size: 16, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                'Issue Type',
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
          child: DropdownButtonFormField<String>(
            value: _selectedIssueType,
            menuMaxHeight: 600, // Limit dropdown height for scrolling
            decoration: InputDecoration(
              hintText: _selectedIssueCategory == null
                  ? 'Select category first'
                  : 'Select issue type',
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
              fillColor: _selectedIssueCategory == null
                  ? Colors.grey.shade200
                  : Colors.grey.shade50,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            items: _selectedIssueCategory == null
                ? []
                : _issueCategoriesAndTypes[_selectedIssueCategory]
                    ?.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(
                        type,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    );
                  }).toList(),
            onChanged: _selectedIssueCategory == null
                ? null
                : (String? newValue) {
                    setState(() {
                      _selectedIssueType = newValue;
                      _issueTypeController.text = newValue ?? '';
                    });
                  },
            validator: (value) =>
                value == null ? 'Please select an issue type' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildReasonCodeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(FeatherIcons.code, size: 16, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                'Reason Code',
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
          child: DropdownButtonFormField<String>(
            value: _selectedReasonCode,
            menuMaxHeight: 600, // Limit dropdown height for scrolling
            decoration: InputDecoration(
              hintText: 'Select reason code',
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
            items: _reasonCodes.map((String code) {
              return DropdownMenuItem<String>(
                value: code,
                child: Text(
                  code,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedReasonCode = newValue;
                _reasonCodeController.text = newValue ?? '';
              });
            },
            validator: (value) =>
                value == null ? 'Please select a reason code' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDefectClassificationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(FeatherIcons.list, size: 16, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                'Defect Classification',
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
          child: DropdownButtonFormField<String>(
            value: _selectedDefectClassification,
            menuMaxHeight: 200, // Limit dropdown height for scrolling
            decoration: InputDecoration(
              hintText: 'Select defect classification',
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
            items: _defectClassifications.map((String classification) {
              return DropdownMenuItem<String>(
                value: classification,
                child: Text(
                  classification,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedDefectClassification = newValue;
                _classificationController.text = newValue ?? '';
              });
            },
            validator: (value) =>
                value == null ? 'Please select a defect classification' : null,
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
    List<String> missingFields = [];

    if (_processDescriptionController.text.trim().isEmpty) {
      missingFields.add('Process Description');
    }
    if (_partNoController.text.trim().isEmpty) {
      missingFields.add('Part Number');
    }
    if (_issueDescriptionController.text.trim().isEmpty) {
      missingFields.add('Issue Description');
    }
    if (_selectedIssueCategory == null) {
      missingFields.add('Issue Category');
    }
    if (_selectedIssueType == null) {
      missingFields.add('Issue Type');
    }
    if (_selectedReasonCode == null) {
      missingFields.add('Reason Code');
    }
    if (_selectedDefectClassification == null) {
      missingFields.add('Defect Classification');
    }

    if (missingFields.isNotEmpty) {
      _showValidationErrorDialog(missingFields);
      return;
    }

    // Use the selected reason code directly
    String finalReasonCode = _selectedReasonCode!;

    Navigator.pop(context, {
      'processDescription': _processDescriptionController.text.trim(),
      'partNo': _partNoController.text.trim(),
      'issueDescription': _issueDescriptionController.text.trim(),
      'category': _selectedIssueCategory!,
      'issueType': _selectedIssueType!,
      'reasonCode': finalReasonCode,
      'classification': _selectedDefectClassification!,
      'image': _imageFile,
    });
  }

  void _showValidationErrorDialog(List<String> missingFields) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.red.shade500,
                        Colors.red.shade600,
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
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Validation Error',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Please fill in the following required fields:',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: missingFields.map((field) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    FeatherIcons.x,
                                    color: Colors.red.shade600,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      field,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Button
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.red.shade500,
                            Colors.red.shade600,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  FeatherIcons.check,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Got it',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
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
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
