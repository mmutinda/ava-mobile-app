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

class _IssueDialogState extends State<IssueDialog> {
  final _issueDescriptionController = TextEditingController();
  final _partNoController = TextEditingController();
  File? _imageFile;
  bool _isSubmitting = false; // Add loading state

  // Validation error messages
  String? _descriptionError;
  String? _partNoError;
  String? _categoryError;
  String? _typeError;
  String? _classificationError;
  String? _imageError;

  // Part number dropdown variables
  List<DropDownValueModel> _partNumbers = [];
  SingleValueDropDownController _partNumberController =
      SingleValueDropDownController();
  bool _isLoadingPartNumbers = false;

  // Issue Category dropdown variables
  List<DropDownValueModel> _issueCategoryModels = [];
  SingleValueDropDownController _issueCategoryController =
      SingleValueDropDownController();

  // Issue Type dropdown variables
  List<DropDownValueModel> _issueTypeModels = [];
  SingleValueDropDownController _issueTypeController =
      SingleValueDropDownController();

  // Defect Classification dropdown variables
  List<DropDownValueModel> _defectClassificationModels = [];
  SingleValueDropDownController _defectClassificationController =
      SingleValueDropDownController();

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

  // Update issue types based on selected category
  void _updateIssueTypes(String? selectedCategory) {
    if (selectedCategory != null) {
      final types = _issueCategoriesAndTypes[selectedCategory] ?? [];
      _issueTypeModels = types
          .map((type) => DropDownValueModel(name: type, value: type))
          .toList();
    } else {
      _issueTypeModels = [];
    }

    // Clear current selection
    _issueTypeController.clearDropDown();
    _selectedIssueType = null;
  }

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

    // Initialize dropdown models for Issue Categories
    _issueCategoryModels = _issueCategories
        .map((category) => DropDownValueModel(name: category, value: category))
        .toList();

    // Initialize dropdown models for Defect Classifications
    _defectClassificationModels = _defectClassifications
        .map((classification) =>
            DropDownValueModel(name: classification, value: classification))
        .toList();

    // Initialize with provided data
    _issueDescriptionController.text = widget.initialDescription ?? '';
    _partNoController.text = widget.initialPartNo ?? '';

    // Set initial dropdown values if provided
    if (widget.initialCategory != null) {
      _selectedIssueCategory = widget.initialCategory;
      _issueCategoryController.dropDownValue = DropDownValueModel(
          name: widget.initialCategory!, value: widget.initialCategory!);

      // Initialize issue types for the selected category
      _updateIssueTypes(widget.initialCategory);
    }

    if (widget.initialType != null) {
      _selectedIssueType = widget.initialType;
      _issueTypeController.dropDownValue = DropDownValueModel(
          name: widget.initialType!, value: widget.initialType!);
    }

    if (widget.initialClassification != null) {
      _selectedDefectClassification = widget.initialClassification;
      _defectClassificationController.dropDownValue = DropDownValueModel(
          name: widget.initialClassification!,
          value: widget.initialClassification!);
    }

    _imageFile = widget.initialImage;

    // Load part numbers from API
    _loadPartNumbers();
  }

  @override
  void dispose() {
    _partNoController.dispose();
    _issueDescriptionController.dispose();
    _partNumberController.dispose();
    _issueCategoryController.dispose();
    _issueTypeController.dispose();
    _defectClassificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Allow back button to work unless submitting
        return !_isSubmitting;
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar for bottom sheet
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_rounded,
                    color: mycolor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Report Issue',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.pop(context, null),
                    icon: Icon(
                      Icons.close,
                      color: _isSubmitting ? Colors.grey : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            // Content area - Scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSimpleTextField(
                      controller: _issueDescriptionController,
                      label: 'Issue Description',
                      hint: 'Describe the issue',
                      maxLines: 3,
                      prefixIcon: Icons.description,
                      errorText: _descriptionError,
                    ),
                    SizedBox(height: 16),
                    _buildPartNumberDropdown(),
                    SizedBox(height: 16),
                    _buildSearchableDropdown(
                      label: 'Issue Category',
                      controller: _issueCategoryController,
                      items: _issueCategoryModels,
                      prefixIcon: Icons.category,
                      errorText: _categoryError,
                      onChanged: (value) {
                        setState(() {
                          // Handle both DropDownValueModel and String (when cleared)
                          if (value is DropDownValueModel) {
                            _selectedIssueCategory = value.value;
                          } else {
                            _selectedIssueCategory = null;
                          }
                          _categoryError = null;
                          _updateIssueTypes(_selectedIssueCategory);
                        });
                      },
                    ),
                    if (_selectedIssueCategory != null) ...[
                      SizedBox(height: 16),
                      _buildSearchableDropdown(
                        label: 'Issue Type',
                        controller: _issueTypeController,
                        items: _issueTypeModels,
                        prefixIcon: Icons.label,
                        errorText: _typeError,
                        onChanged: (value) {
                          setState(() {
                            // Handle both DropDownValueModel and String (when cleared)
                            if (value is DropDownValueModel) {
                              _selectedIssueType = value.value;
                            } else {
                              _selectedIssueType = null;
                            }
                            _typeError = null;
                          });
                        },
                      ),
                    ],
                    SizedBox(height: 16),
                    _buildSearchableDropdown(
                      label: 'Classification',
                      controller: _defectClassificationController,
                      items: _defectClassificationModels,
                      prefixIcon: Icons.priority_high,
                      errorText: _classificationError,
                      onChanged: (value) {
                        setState(() {
                          // Handle both DropDownValueModel and String (when cleared)
                          if (value is DropDownValueModel) {
                            _selectedDefectClassification = value.value;
                          } else {
                            _selectedDefectClassification = null;
                          }
                          _classificationError = null;
                        });
                      },
                    ),

                    SizedBox(height: 16),

                    // Image section with consistent labeling
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Evidence Image',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 6),
                        // Camera button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _imageError != null ? Colors.red : mycolor,
                              width: _imageError != null ? 2 : 1,
                            ),
                            color: Colors.grey.shade50,
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
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        if (_imageError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 12),
                            child: Text(
                              _imageError!,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
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
                                // height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Fixed bottom action buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pop(context, null),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
                      onPressed:
                          _isSubmitting ? null : () => _submitForm(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSubmitting ? Colors.grey : mycolor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
            ),
          ],
        ),
      ),
    );
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
                  errorText: _partNoError,
                  errorMaxLines: 2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _partNoError != null
                          ? Colors.red
                          : Colors.grey.shade300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _partNoError != null
                          ? Colors.red
                          : Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _partNoError != null ? Colors.red : mycolor,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                searchDecoration: InputDecoration(
                  hintText: 'Search part numbers...',
                  // prefixIcon: Icon(Icons.search, color: mycolor),
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
                    // Handle both DropDownValueModel and String (when cleared)
                    if (value is DropDownValueModel) {
                      _partNoController.text = value.value ?? '';
                    } else {
                      _partNoController.text = '';
                    }
                    _partNoError = null;
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
    IconData? prefixIcon,
    String? errorText,
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
          onChanged: (value) {
            if (errorText != null) {
              setState(() {
                _descriptionError = null;
              });
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon:
                prefixIcon != null ? Icon(prefixIcon, color: mycolor) : null,
            errorText: errorText,
            errorMaxLines: 2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : mycolor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchableDropdown({
    required String label,
    required SingleValueDropDownController controller,
    required List<DropDownValueModel> items,
    required Function(dynamic) onChanged,
    IconData? prefixIcon,
    String? hintText,
    String? errorText,
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
        DropDownTextField(
          controller: controller,
          textFieldDecoration: InputDecoration(
            hintText: hintText ?? 'Search $label...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon:
                prefixIcon != null ? Icon(prefixIcon, color: mycolor) : null,
            errorText: errorText,
            errorMaxLines: 2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : mycolor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          searchDecoration: InputDecoration(
            hintText: hintText ?? 'Search $label...',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select $label';
            }
            return null;
          },
          dropDownItemCount: 5,
          dropDownList: items,
          onChanged: onChanged,
          enableSearch: true,
          searchShowCursor: true,
          searchAutofocus: false,
          clearOption: true,
          searchKeyboardType: TextInputType.text,
        ),
      ],
    );
  }

  Widget _buildSimpleDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    IconData? prefixIcon,
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
            prefixIcon:
                prefixIcon != null ? Icon(prefixIcon, color: mycolor) : null,
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
      setState(() {
        _imageFile = File(image.path);
        _imageError = null;
      });
    }
  }

  void _submitForm(BuildContext context) async {
    // Prevent multiple submissions
    if (_isSubmitting) return;

    // Clear previous errors
    setState(() {
      _descriptionError = null;
      _partNoError = null;
      _categoryError = null;
      _typeError = null;
      _classificationError = null;
      _imageError = null;
    });

    // Comprehensive validation
    bool hasError = false;

    if (_issueDescriptionController.text.trim().isEmpty) {
      setState(() => _descriptionError = 'Please enter issue description');
      hasError = true;
    }

    // if (_partNoController.text.trim().isEmpty) {
    //   setState(() => _partNoError = 'Please select a part number');
    //   hasError = true;
    // }

    // if (_selectedIssueCategory == null || _selectedIssueCategory!.isEmpty) {
    //   setState(() => _categoryError = 'Please select an issue category');
    //   hasError = true;
    // }

    // if (_selectedIssueType == null || _selectedIssueType!.isEmpty) {
    //   setState(() => _typeError = 'Please select an issue type');
    //   hasError = true;
    // }

    // if (_selectedDefectClassification == null ||
    //     _selectedDefectClassification!.isEmpty) {
    //   setState(() => _classificationError = 'Please select a classification');
    //   hasError = true;
    // }

    // if (_imageFile == null) {
    //   setState(() => _imageError = 'Please take a picture of the issue');
    //   hasError = true;
    // }

    // Stop if validation fails
    if (hasError) {
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
