import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';

class ChecklistItemCard extends StatelessWidget {
  final Map<String, dynamic> checklistItem;
  final int? index;

  const ChecklistItemCard({
    Key? key,
    required this.checklistItem,
    this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isOK = checklistItem['answer'] == 'OK';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOK
              ? [Colors.green.shade50, Colors.green.shade100]
              : [Colors.red.shade50, Colors.red.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOK ? Colors.green.shade300 : Colors.red.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isOK
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Index number with gradient
            if (index != null)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isOK
                        ? [Colors.green.shade400, Colors.green.shade600]
                        : [Colors.red.shade400, Colors.red.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isOK ? Colors.green : Colors.red).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${(index ?? 0) + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

            if (index != null) const SizedBox(width: 16),

            // Question text
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    checklistItem['answer'] ?? 'Unknown Question',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Answer badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isOK
                      ? [Colors.green.shade400, Colors.green.shade600]
                      : [Colors.red.shade400, Colors.red.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (isOK ? Colors.green : Colors.red).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isOK ? Icons.check_circle : Icons.cancel,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    checklistItem['answer'] ?? 'N/A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//// LotIssueDialog.dart

class LotIssueDialogReceiving extends StatefulWidget {
  final lotId;
  final lotNumber;
  final user;
  const LotIssueDialogReceiving(
      {Key? key,
      required this.lotId,
      required this.user,
      required this.lotNumber})
      : super(key: key);

  @override
  State<LotIssueDialogReceiving> createState() =>
      _LotIssueDialogReceivingState();
}

class _LotIssueDialogReceivingState extends State<LotIssueDialogReceiving>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool hasIssue = false;
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
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
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

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Modern header with gradient
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [mycolor.withOpacity(0.8), mycolor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.report_problem,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Lot Issue Confirmation',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content area
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Is there any lot issue?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Modern choice chips
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => hasIssue = true),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: hasIssue
                                        ? LinearGradient(
                                            colors: [
                                              Colors.red.shade400,
                                              Colors.red.shade600
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                    color:
                                        hasIssue ? null : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: hasIssue
                                          ? Colors.red.shade600
                                          : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                    boxShadow: hasIssue
                                        ? [
                                            BoxShadow(
                                              color:
                                                  Colors.red.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.warning,
                                        color: hasIssue
                                            ? Colors.white
                                            : Colors.red.shade600,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Yes',
                                        style: TextStyle(
                                          color: hasIssue
                                              ? Colors.white
                                              : Colors.red.shade600,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => hasIssue = false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: !hasIssue
                                        ? LinearGradient(
                                            colors: [
                                              Colors.green.shade400,
                                              Colors.green.shade600
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                    color:
                                        !hasIssue ? null : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: !hasIssue
                                          ? Colors.green.shade600
                                          : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                    boxShadow: !hasIssue
                                        ? [
                                            BoxShadow(
                                              color:
                                                  Colors.green.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: !hasIssue
                                            ? Colors.white
                                            : Colors.green.shade600,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'No',
                                        style: TextStyle(
                                          color: !hasIssue
                                              ? Colors.white
                                              : Colors.green.shade600,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Issue details section
                        if (hasIssue) ...[
                          SizedBox(height: 20),
                          _buildStyledTextField(
                            controller: _issueDescriptionController,
                            label: 'Issue Description',
                            icon: FeatherIcons.fileText,
                            hint: 'Describe the issue in detail',
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

                          // Camera button
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: mycolor, width: 2),
                            ),
                            child: TextButton.icon(
                              onPressed: _pickImage,
                              icon: Icon(Icons.camera_alt, color: mycolor),
                              label: Text(
                                'Take Picture',
                                style: TextStyle(
                                  color: mycolor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),

                          // Image preview
                          if (_imageFile != null)
                            Container(
                              margin: const EdgeInsets.only(top: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _imageFile!,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                        ],

                        const SizedBox(height: 32),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.red.shade300, width: 2),
                                ),
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.red.shade600,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [mycolor.withOpacity(0.8), mycolor],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: mycolor.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () => _submitForm(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Submit',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => _imageFile = File(image.path));
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    // if (!_formKey.currentState!.validate()) return;

    final fields = {
      'any_lot_issue': hasIssue ? 'YES' : 'NO',
      'vehicle_receiving_id': widget.lotId.toString(), // ✅ fix
      'lot_number': hasIssue ? widget.lotNumber.toString() : null,
      'process_description':
          hasIssue ? _processDescriptionController.text.trim() : null,
      'part_number': hasIssue ? _partNoController.text.trim() : null,
      'issue_description':
          hasIssue ? _issueDescriptionController.text.trim() : null,
      'category': hasIssue ? _selectedIssueCategory ?? '' : null,
      'issue_type': hasIssue ? _selectedIssueType ?? '' : null,
      'reason_code': hasIssue ? _selectedReasonCode ?? '' : null,
      'classification': hasIssue ? _selectedDefectClassification ?? '' : null,
    };

    // Example dynamic files

    final files = _imageFile != null && hasIssue
        ? {
            'images': _imageFile!,
          }
        : {};

    print(fields);
    await submitMultipartForm(
      context: context,
      url: '${Api.api_url}pushToPlanning',
      fields: fields, // Now guaranteed strings
      files: files,
      token: widget.user,
    );

    Navigator.pop(context);
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
            maxLines: null,
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
}

/// LotIssueDialog.dart

class LotIssueDialogFinishRacking extends StatefulWidget {
  final lotId;
  final lotNumber;
  final user;
  const LotIssueDialogFinishRacking(
      {Key? key,
      required this.lotId,
      required this.user,
      required this.lotNumber})
      : super(key: key);

  @override
  State<LotIssueDialogFinishRacking> createState() =>
      _LotIssueDialogFinishRackingState();
}

class _LotIssueDialogFinishRackingState
    extends State<LotIssueDialogFinishRacking>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool hasIssue = false;
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
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
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

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Modern header with gradient
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [mycolor.withOpacity(0.8), mycolor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.inventory_2,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Complete Racking',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content area
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Is there any lot issue?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Modern choice chips
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => hasIssue = true),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: hasIssue
                                        ? LinearGradient(
                                            colors: [
                                              Colors.red.shade400,
                                              Colors.red.shade600
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                    color:
                                        hasIssue ? null : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: hasIssue
                                          ? Colors.red.shade600
                                          : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                    boxShadow: hasIssue
                                        ? [
                                            BoxShadow(
                                              color:
                                                  Colors.red.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.warning,
                                        color: hasIssue
                                            ? Colors.white
                                            : Colors.red.shade600,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Yes',
                                        style: TextStyle(
                                          color: hasIssue
                                              ? Colors.white
                                              : Colors.red.shade600,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => hasIssue = false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: !hasIssue
                                        ? LinearGradient(
                                            colors: [
                                              Colors.green.shade400,
                                              Colors.green.shade600
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                    color:
                                        !hasIssue ? null : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: !hasIssue
                                          ? Colors.green.shade600
                                          : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                    boxShadow: !hasIssue
                                        ? [
                                            BoxShadow(
                                              color:
                                                  Colors.green.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: !hasIssue
                                            ? Colors.white
                                            : Colors.green.shade600,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'No',
                                        style: TextStyle(
                                          color: !hasIssue
                                              ? Colors.white
                                              : Colors.green.shade600,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Issue details section
                        if (hasIssue) ...[
                          SizedBox(height: 20),
                          _buildStyledTextField(
                            controller: _issueDescriptionController,
                            label: 'Issue Description',
                            icon: FeatherIcons.fileText,
                            hint: 'Describe the issue in detail',
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

                          // Camera button
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: mycolor, width: 2),
                            ),
                            child: TextButton.icon(
                              onPressed: _pickImage,
                              icon: Icon(Icons.camera_alt, color: mycolor),
                              label: Text(
                                'Take Picture',
                                style: TextStyle(
                                  color: mycolor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),

                          // Image preview
                          if (_imageFile != null)
                            Container(
                              margin: const EdgeInsets.only(top: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _imageFile!,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                        ],

                        const SizedBox(height: 32),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.red.shade300, width: 2),
                                ),
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.red.shade600,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [mycolor.withOpacity(0.8), mycolor],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: mycolor.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () => _submitForm(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Complete',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        color: Colors.grey.shade50,
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: mycolor),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(color: Colors.grey.shade600),
        ),
      ),
    );
  }

  Widget _buildModernDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        color: Colors.grey.shade50,
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: mycolor),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(color: Colors.grey.shade600),
        ),
        items: options
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: TextStyle(color: Colors.grey.shade800)),
                ))
            .toList(),
        onChanged: onChanged,
        dropdownColor: Colors.white,
      ),
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
            maxLines: null,
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
            menuMaxHeight: 600,
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
                _selectedIssueType = null;
                _issueTypeController.clear();
              });
            },
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
            menuMaxHeight: 600,
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
            menuMaxHeight: 600,
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
            menuMaxHeight: 200,
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
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => _imageFile = File(image.path));
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    // if (!_formKey.currentState!.validate()) return;

    final fields = {
      'any_lot_issue': hasIssue ? 'YES' : 'NO',
      'vehicle_receiving_id': widget.lotId.toString(), // ✅ fix
      'lot_number': hasIssue ? widget.lotNumber.toString() : null,
      'process_description':
          hasIssue ? _processDescriptionController.text.trim() : null,
      'part_number': hasIssue ? _partNoController.text.trim() : null,
      'issue_description':
          hasIssue ? _issueDescriptionController.text.trim() : null,
      'category': hasIssue ? _selectedIssueCategory ?? '' : null,
      'issue_type': hasIssue ? _selectedIssueType ?? '' : null,
      'reason_code': hasIssue ? _selectedReasonCode ?? '' : null,
      'classification': hasIssue ? _selectedDefectClassification ?? '' : null,
    };

    // Example dynamic files
    final files = _imageFile != null && hasIssue
        ? {
            'images': _imageFile!,
          }
        : {};

    await submitMultipartForm(
      context: context,
      url: '${Api.api_url}completeUnboxing',
      fields: fields, // Now guaranteed strings
      files: files,
      token: widget.user,
    );

    Navigator.pop(context);
  }
}
