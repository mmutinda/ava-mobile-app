import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';

class IssueDialog extends StatefulWidget {
  final String? initialDescription;
  final String? initialPartNo;
  final String? initialCategory;
  final String? initialType;
  final String? initialClassification;
  final File? initialImage;
  final String lotNo; // Add lot number parameter

  const IssueDialog({
    Key? key,
    this.initialDescription,
    this.initialPartNo,
    this.initialCategory,
    this.initialType,
    this.initialClassification,
    this.initialImage,
    required this.lotNo, // Add lot number parameter
  }) : super(key: key);

  @override
  State<IssueDialog> createState() => _IssueDialogState();
}

class _IssueDialogState extends State<IssueDialog>
    with SingleTickerProviderStateMixin {
  final _issueDescriptionController = TextEditingController();
  final _partNoController = TextEditingController();
  File? _imageFile;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isSubmitting = false; // Add loading state

  // Part number dropdown variables
  List<DropDownValueModel> _partNumbers = [];
  SingleValueDropDownController _partNumberController =
      SingleValueDropDownController();
  bool _isLoadingPartNumbers = false;

  String? _selectedIssueCategory;
  String? _selectedIssueType;
  String? _selectedDefectClassification;

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

  // API function to load part numbers
  Future<void> _loadPartNumbers() async {
    if (widget.lotNo.isEmpty) return;

    setState(() {
      _isLoadingPartNumbers = true;
    });

    try {
      // Get user data for token
      final userDataString = await getuserdata();
      final userData = jsonDecode(userDataString);
      final token = userData['data']?['token'] ?? '';

      final url = "${Api.api_url}loadPartNumber/${widget.lotNo}";
      print(url);
      final response = await httpget(url, token, context);

      if (response != null &&
          response['success'] == true &&
          response['data'] != null) {
        final List<dynamic> data = response['data'];
        setState(() {
          // Extract part numbers and remove duplicates
          final List<String> allPartNumbers =
              data.map((item) => item['part_no'].toString()).toList();
          final uniquePartNumbers = allPartNumbers.toSet().toList();

          // Convert to DropDownValueModel for dropdown_textfield package
          _partNumbers = uniquePartNumbers
              .map((partNumber) =>
                  DropDownValueModel(name: partNumber, value: partNumber))
              .toList();

          // Set initial selection if provided
          if (widget.initialPartNo != null &&
              uniquePartNumbers.contains(widget.initialPartNo)) {
            _partNumberController.dropDownValue = DropDownValueModel(
                name: widget.initialPartNo!, value: widget.initialPartNo!);
          }
        });
      }
    } catch (e) {
      print('Error loading part numbers: $e');
    } finally {
      setState(() {
        _isLoadingPartNumbers = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize with provided data
    _issueDescriptionController.text = widget.initialDescription ?? '';
    _partNoController.text = widget.initialPartNo ?? '';
    _selectedIssueCategory = widget.initialCategory;
    _selectedIssueType = widget.initialType;
    _selectedDefectClassification = widget.initialClassification;
    _imageFile = widget.initialImage;

    // Load part numbers from API
    _loadPartNumbers();

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
    _partNoController.dispose();
    _issueDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // Allow back button to work unless submitting
          return !_isSubmitting;
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 8,
              backgroundColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              content: SingleChildScrollView(
                child: Container(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Simple header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: mycolor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Report Issue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content area
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSimpleTextField(
                              controller: _issueDescriptionController,
                              label: 'Issue Description',
                              hint: 'Describe the issue',
                              maxLines: 3,
                            ),
                            SizedBox(height: 16),
                            _buildPartNumberDropdown(),
                            SizedBox(height: 16),
                            _buildSimpleDropdown(
                              label: 'Issue Category',
                              value: _selectedIssueCategory,
                              items: _issueCategories,
                              onChanged: (value) {
                                setState(() {
                                  _selectedIssueCategory = value;
                                  _selectedIssueType = null;
                                });
                              },
                            ),
                            if (_selectedIssueCategory != null) ...[
                              SizedBox(height: 16),
                              _buildSimpleDropdown(
                                label: 'Issue Type',
                                value: _selectedIssueType,
                                items: _issueCategoriesAndTypes[
                                        _selectedIssueCategory] ??
                                    [],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedIssueType = value;
                                  });
                                },
                              ),
                            ],
                            SizedBox(height: 16),
                            _buildSimpleDropdown(
                              label: 'Classification',
                              value: _selectedDefectClassification,
                              items: _defectClassifications,
                              onChanged: (value) {
                                setState(() {
                                  _selectedDefectClassification = value;
                                });
                              },
                            ),

                            SizedBox(height: 20),

                            // Camera button
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: mycolor),
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
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),

                            // Image preview
                            if (_imageFile != null)
                              Container(
                                margin: const EdgeInsets.only(top: 12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _imageFile!,
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 24),

                            // Action buttons
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: _isSubmitting
                                        ? null
                                        : () => Navigator.pop(context, null),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                            color: _isSubmitting
                                                ? Colors.grey.shade300
                                                : Colors.grey.shade400),
                                      ),
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: _isSubmitting
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _isSubmitting
                                        ? null
                                        : () => _submitForm(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          _isSubmitting ? Colors.grey : mycolor,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: _isSubmitting
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Submit',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
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
        ));
  }

  Widget _buildPartNumberDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Part Number',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 6),
        _isLoadingPartNumbers
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.grey.shade50,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(mycolor),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Loading part numbers...',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            : DropDownTextField(
                controller: _partNumberController,
                textFieldDecoration: InputDecoration(
                  hintText: 'Search part numbers...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: mycolor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: mycolor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                searchDecoration: InputDecoration(
                  hintText: 'Search part numbers...',
                  prefixIcon: Icon(Icons.search, color: mycolor),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a part number';
                  }
                  return null;
                },
                dropDownItemCount: 5, // Show max 5 items
                dropDownList: _partNumbers,
                onChanged: (value) {
                  setState(() {
                    // Update the controller for backwards compatibility
                    _partNoController.text = value?.value ?? '';
                  });
                },
                enableSearch: true,
                searchShowCursor: true,
                searchAutofocus:
                    false, // Disable auto-focus to prevent keyboard popup
                clearOption: true,
                searchKeyboardType: TextInputType.text,
              ),
      ],
    );
  }

  Widget _buildSimpleTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: mycolor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: 'Select $label',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: mycolor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
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

  void _submitForm(BuildContext context) async {
    // Prevent multiple submissions
    if (_isSubmitting) return;

    // Basic validation
    if (_issueDescriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter issue description'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Set loading state
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Simulate processing delay (you can remove this in production)
      await Future.delayed(Duration(milliseconds: 500));

      // Return claim data to indicate successful submission
      final claimData = {
        'description': _issueDescriptionController.text.trim(),
        'partNo': _partNoController.text.trim(),
        'category': _selectedIssueCategory,
        'type': _selectedIssueType,
        'classification': _selectedDefectClassification,
        'image': _imageFile,
      };

      Navigator.pop(context, claimData);
    } catch (e) {
      // Reset loading state on error
      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting claim. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
