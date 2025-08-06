import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:image_picker/image_picker.dart';

class ClaimForm extends StatefulWidget {
  @override
  State<ClaimForm> createState() => _ClaimFormState();
}

class _ClaimFormState extends State<ClaimForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FocusNode _vehicleFieldFocus = FocusNode();
  final FocusNode _partFieldFocus = FocusNode();

  late TextEditingController _lotNumberController;
  late SingleValueDropDownController _partDropdown;
  late TextEditingController _defectCodeController;
  late TextEditingController _descriptionController;

  List<dynamic> clients = [];
  List<dynamic> checklist = [];
  List<List<dynamic>> checklistData = [];
  Map<String, dynamic> user = {};
  String errorText = '';
  bool isLoading = true;
  bool _isLoadingModels = false;
  var selectedLotId;
  var modelId;

  FocusNode customerTextFieldFocusNode = FocusNode();
  FocusNode customerSearchFocusNode = FocusNode();
  FocusNode carModelTextFieldFocusNode = FocusNode();
  FocusNode carModelSearchFocusNode = FocusNode();
  FocusNode searchFocusNode = FocusNode();
  FocusNode textFieldFocusNode = FocusNode();
  String errorModel = '';
  late List<dynamic> partNOs = [];
  var LotId;

  // Image capture
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Dropdown selections
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
    _lotNumberController = TextEditingController();
    _partDropdown = SingleValueDropDownController();
    _defectCodeController = TextEditingController();
    _descriptionController = TextEditingController();

    getuserdata().then((value) {
      user = jsonDecode(value);
    });
  }

  @override
  void dispose() {
    _lotNumberController.dispose();
    _partDropdown.dispose();
    _defectCodeController.dispose();
    _descriptionController.dispose();
    _vehicleFieldFocus.dispose();
    _partFieldFocus.dispose();
    super.dispose();
  }

  void storeChecklist() {
    try {
      checklistData = checklist
          .where((item) => item['checked'] == 'OK' || item['checked'] == 'NOK')
          .map((item) => [item['id'], item['checked']])
          .toList();
    } catch (e) {
      print('Checklist error: $e');
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    storeChecklist();
    if (checklist.length != checklistData.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please complete all checklist items!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    _postData();
  }

  void _postData() async {
    final progress = ProgressDialog(context);
    progress.style(
      message: 'Submitting...',
      child: CustomLoader(),
      borderRadius: 8,
      backgroundColor: Colors.white,
      elevation: 10,
    );
    progress.show();

    try {
      String url = "${Api.api_url}postScheduledUnit";
      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer ${user['data']['token']}',
      });

      // Add form fields
      request.fields['lot_number'] = _lotNumberController.text.trim();
      request.fields['part_number'] = _partDropdown.dropDownValue?.value ?? '';
      request.fields['issue_description'] = _descriptionController.text.trim();
      request.fields['category'] = _selectedIssueCategory ?? '';
      request.fields['issue_type'] = _selectedIssueType ?? '';
      request.fields['reason_code'] = _selectedReasonCode ?? '';
      request.fields['classification'] =
          _selectedDefectClassification ?? '';

      // Add image if selected
      if (_imageFile != null) {
        var imageFile = await http.MultipartFile.fromPath(
          'images',
          _imageFile!.path,
        );
        request.files.add(imageFile);
      }

      var response = await request.send();
      var response2 = await http.Response.fromStream(response);
      var responseData = jsonDecode(response2.body);

      progress.hide();

      if (responseData['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Claim submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Failed to submit claim'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      progress.hide();
      print("Submission failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit claim. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: mycolor,
        foregroundColor: Colors.white,
        title: const Text(
          'New Claim',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modern Header with gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [mycolor.withOpacity(0.8), mycolor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: mycolor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.assignment_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create New Claim',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Fill in the details below to submit your claim',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Form Fields Container
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (errorModel.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red.shade600, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorModel,
                                style: TextStyle(
                                    color: Colors.red.shade600, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Lot Number Field
                    _buildModernTextField(
                      label: 'Lot Number',
                      icon: Icons.label_outline,
                      controller: _lotNumberController,
                      hint: 'Enter lot number',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "*Required";
                        }
                        return null;
                      },
                      suffixWidget: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [mycolor.withOpacity(0.8), mycolor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.search, color: Colors.white),
                          onPressed: () async {
                            final value = _lotNumberController.text.trim();
                            if (value.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please enter a Lot Number"),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            selectedLotId = value;
                            setState(() {
                              _isLoadingModels = true;
                              errorModel = '';
                            });

                            try {
                              final response = await fetchpartNO(selectedLotId);
                              print('FetchCarModel Response: $response');
                              if (response != null &&
                                  response['success'] == true) {
                                if (response['data'] != null &&
                                    response['data'] is List) {
                                  List<dynamic> rawData = response['data'];
                                  // Remove duplicates and null values
                                  Set<String> uniquePartNos = <String>{};
                                  for (var item in rawData) {
                                    if (item != null &&
                                        item.toString().isNotEmpty) {
                                      uniquePartNos.add(item.toString());
                                    }
                                  }
                                  partNOs = uniquePartNos.toList()..sort();

                                  if (partNOs.isEmpty) {
                                    errorModel =
                                        'No part numbers found for this lot.';
                                  }
                                } else {
                                  partNOs = [];
                                  errorModel = response['msg'] ??
                                      'No part numbers available.';
                                }
                              } else {
                                partNOs = [];
                                errorModel = response?['msg'] ??
                                    'Failed to load part numbers.';
                              }
                            } on TimeoutException {
                              errorModel = 'Fetching car models timed out.';
                              partNOs = [];
                            } on SocketException {
                              errorModel = 'No internet connection.';
                              partNOs = [];
                            } catch (e) {
                              errorModel = '$e';
                              partNOs = [];
                            } finally {
                              setState(() {
                                _isLoadingModels = false;
                                _partDropdown.clearDropDown();
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Part Number Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: mycolor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(Icons.inventory_2_outlined,
                                    size: 16, color: mycolor),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Part Number',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
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
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _isLoadingModels
                              ? Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : DropDownTextField(
                                  controller: _partDropdown,
                                  clearOption: false,
                                  dropDownIconProperty:
                                      IconProperty(color: mycolor, size: 30),
                                  textFieldFocusNode: textFieldFocusNode,
                                  textFieldDecoration: InputDecoration(
                                    hintText: 'Select part number',
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade200),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade200),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide:
                                          BorderSide(color: mycolor, width: 2),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                  searchFocusNode: searchFocusNode,
                                  dropDownItemCount: 5,
                                  enableSearch: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "*Required";
                                    } else {
                                      return null;
                                    }
                                  },
                                  dropDownList: partNOs.map((partNo) {
                                    return DropDownValueModel(
                                      name: partNo.toString(),
                                      value: partNo.toString(),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    modelId = val.value;
                                  },
                                ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Issue Category Dropdown
                    _buildModernDropdown(
                      label: 'Issue Category',
                      icon: Icons.category_outlined,
                      hint: 'Select issue category',
                      value: _selectedIssueCategory,
                      items: _issueCategories,
                      onChanged: (value) {
                        setState(() {
                          _selectedIssueCategory = value;
                          _selectedIssueType =
                              null; // Reset issue type when category changes
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Issue Type Dropdown (depends on category)
                    _buildModernDropdown(
                      label: 'Issue Type',
                      icon: Icons.list_alt_outlined,
                      hint: 'Select issue type',
                      value: _selectedIssueType,
                      items: _selectedIssueCategory != null
                          ? _issueCategoriesAndTypes[_selectedIssueCategory!] ??
                              []
                          : [],
                      onChanged: (value) {
                        setState(() {
                          _selectedIssueType = value;
                        });
                      },
                      enabled: _selectedIssueCategory != null,
                    ),
                    const SizedBox(height: 24),

                    // Reason Code Dropdown
                    _buildModernDropdown(
                      label: 'Reason Code',
                      icon: Icons.code_outlined,
                      hint: 'Select reason code',
                      value: _selectedReasonCode,
                      items: _reasonCodes,
                      onChanged: (value) {
                        setState(() {
                          _selectedReasonCode = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Defect Classification Dropdown
                    _buildModernDropdown(
                      label: 'Defect Classification',
                      icon: Icons.class_outlined,
                      hint: 'Select defect classification',
                      value: _selectedDefectClassification,
                      items: _defectClassifications,
                      onChanged: (value) {
                        setState(() {
                          _selectedDefectClassification = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Description Field (moved to end)
                    _buildModernTextField(
                      label: "Description",
                      icon: Icons.description_outlined,
                      controller: _descriptionController,
                      hint: 'Enter detailed description',
                      minLines: 2,
                      keyboardType: TextInputType.multiline,
                      validator: (value) =>
                          value == null || value.isEmpty ? '*Required' : null,
                    ),
                    const SizedBox(height: 24),

                    // Image Capture Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: mycolor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(Icons.camera_alt_outlined,
                                    size: 16, color: mycolor),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Defect Image',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: mycolor.withOpacity(0.3)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextButton.icon(
                            onPressed: _pickImage,
                            icon: Icon(Icons.camera_alt, color: mycolor),
                            label: Text(
                              _imageFile != null
                                  ? 'Change Picture'
                                  : 'Take Picture',
                              style: TextStyle(
                                color: mycolor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.grey.shade50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                              child: Stack(
                                children: [
                                  Image.file(
                                    _imageFile!,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.8),
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Colors.white, size: 20),
                                        onPressed: () {
                                          setState(() {
                                            _imageFile = null;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [mycolor.withOpacity(0.8), mycolor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: mycolor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Submit Claim',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future fetchpartNO(id) async {
    String url = Api.api_url + "loadPartNumbers/${id}";
    print(url);
    var responsedata = await httpget(url, user['data']['token'], context);
    print(responsedata);
    return responsedata;
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxHeight: 1000,
      maxWidth: 1000,
    );
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Widget _buildModernDropdown({
    required String label,
    required IconData icon,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: enabled
                      ? mycolor.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: enabled ? mycolor : Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: enabled ? Colors.grey[800] : Colors.grey[500],
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            hint: Text(
              hint,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: mycolor, width: 2),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            items: enabled
                ? items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList()
                : [],
            onChanged: enabled ? onChanged : null,
            isExpanded: true,
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: enabled ? mycolor : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    Widget? suffixWidget,
    int minLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: mycolor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 16, color: mycolor),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
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
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            minLines: minLines,
            maxLines: null,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.grey.shade50,
              suffixIcon: suffixWidget,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: mycolor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.shade400),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.shade400, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
