import 'dart:convert';
import 'dart:developer';

import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/pages/mpa/mpa_list.dart';

class AuditChecklistItem {
  final String sn;
  final String group;
  final String resp;
  final String description;
  int? rating;
  String? comment;

  AuditChecklistItem({
    required this.sn,
    required this.group,
    required this.resp,
    required this.description,
    this.rating,
    this.comment,
  });

  factory AuditChecklistItem.fromJson(Map<String, dynamic> json) {
    return AuditChecklistItem(
      sn: json['id']?.toString() ?? '',
      group: json['category']?.toString() ?? '',
      resp: json['responsible']?.toString() ?? '',
      description: json['query_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sn': sn,
      'group': group,
      'resp': resp,
      'description': description,
      'rating': rating,
      'comment': comment,
    };
  }
}

class AuditChecklistPage extends StatefulWidget {
  const AuditChecklistPage({super.key});

  @override
  State<AuditChecklistPage> createState() => _AuditChecklistPageState();
}

class _AuditChecklistPageState extends State<AuditChecklistPage> {
  List<AuditChecklistItem> auditItems = [];
  bool isLoadingAuditItems = true;
  String auditItemsError = '';

  String? selectedGroup = "Man";

  List<AuditChecklistItem> get filteredItems {
    return auditItems.where((item) {
      final matchGroup = selectedGroup == null || item.group == selectedGroup;
      return matchGroup;
    }).toList();
  }

  Color getRatingColor(int value) {
    switch (value) {
      case 0:
        return Colors.redAccent;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      case 3:
        return Colors.grey;
      default:
        return Colors.transparent;
    }
  }

  String getRatingLabel(int value) {
    switch (value) {
      case 0:
        return "Non-Conforming";
      case 1:
        return "Needs Improvement";
      case 2:
        return "OK";
      case 3:
        return "N/A";
      default:
        return "";
    }
  }

  bool showFilters = false;

  // Helper method to calculate progress
  int get answeredCount {
    return auditItems.where((item) => item.rating != null).length;
  }

  int get totalCount {
    return auditItems.length;
  }

  double get progressPercentage {
    if (totalCount == 0) return 0.0;
    return answeredCount / totalCount;
  }

  // Predefined sections list
  final List<String> predefinedSections = [
    'TRAINING ACADEMY',
    'AVA DISPENSARY',
    'LOGISTICS BAY 1',
    'MAIN GATE AND PARKING',
    'MEN\'S CHANGING ROOM',
    'END OF LINE',
    'LOGISTICS BAY 3',
    'ADMIN OFFICE, CANTEEN & SURROUNDING AREA',
    'CONSUMABLES STORE & PAINT STORE',
    'TOOLS STORE',
    'OPERATIONS OFFICE',
    'SPRAY BOOTH 2, OVEN AND WETDECK',
    'CARPENTRY',
    'LADIES\' CHANGING ROOM',
    'MV TRAINING ROOM',
    'PAINTSHOP: PRECLEANING + UNDERBODY BOOTH 1',
    'MAINTENANCE, ENGINEERING, GENERATOR & COMPRESSOR AREA',
    'CONFERENCE ROOM',
    'LINE 3',
    'BODY CONVERSION AREA',
    'LOGISTICS BAY 2',
    'CAB TRIM LINE 2 AND BURNTWOOD',
    'CAB TRIM LINE 1 & BATTERY STORAGE',
    'COOLANT STORAGE AND SHOWER TEST AREA',
    'LINE 1',
    'LINE 2',
    'CAB TRIM LINE 3 & PILOT AREA',
    'BUS PROJECT AREA',
    'GAS STORAGE AREA',
    'BODYSHOP - JIGSHOP AND METAL LINE',
    'CHASSIS RIVET BAY 1, 2 & 3',
    'SPRAY BOOTH 4 AND SURROUNDING',
    'NEW LOGISTICS YARD',
    'TUKTUK ASSEMBLY',
    'JIG AND TROLLEY AREA',
    'CHASSIS AND TIPPER PAINTING AREA',
    'BODYSHOP - TIPPER',
    'OTHER',
  ];

  String? selectedSection;

  static const List<String> predefinedDepartments = [
    'Finance and Administration',
    'Innovation and Technology',
    'Human Resources',
    'Technical Service Department',
    'Business Development',
    'Production',
    'Quality',
  ];

  String? selectedDepartment;

  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _modelVariantController = TextEditingController();
  final TextEditingController _auditDepartmentController =
      TextEditingController();
  final TextEditingController _periodDurationController =
      TextEditingController();
  final SingleValueDropDownController _shopController =
      SingleValueDropDownController();
  Widget _buildHeaderField(
      IconData icon, String label, TextEditingController controller,
      {bool isDate = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // boxShadow: [
          //   BoxShadow(
          //     color: mycolor.withOpacity(0.1),
          //     blurRadius: 4,
          //     offset: Offset(0, 2),
          //   ),
          // ],
        ),
        child: TextField(
          controller: controller,
          readOnly: isDate,
          onTap: isDate
              ? () async {
                  final date = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    initialDate: DateTime.now(),
                  );
                  if (date != null) {
                    controller.text = date.toString().split(' ')[0];
                  }
                }
              : null,
          decoration: InputDecoration(
            labelText: label,
            // labelStyle: TextStyle(
            //   color: mycolor,
            //   fontWeight: FontWeight.w600,
            // ),
            prefixIcon: Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: mycolor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: mycolor, size: 20),
            ),
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
              borderSide: BorderSide(color: mycolor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: isDate
                ? Icon(Icons.calendar_today_rounded,
                    color: mycolor.withOpacity(0.7))
                : null,
          ),
        ),
      ),
    );
  }

  Widget buildShopDropdown() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: mycolor.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropDownTextField(
        controller: _shopController,
        enableSearch: true,
        clearOption: false,
        dropDownIconProperty: IconProperty(color: mycolor, size: 24),
        textFieldDecoration: InputDecoration(
          labelText: 'Select Shop/Station',
          // labelStyle: TextStyle(
          //   color: mycolor,
          //   fontWeight: FontWeight.w600,
          // ),
          prefixIcon: Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: mycolor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.business_rounded, color: mycolor, size: 20),
          ),
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
            borderSide: BorderSide(color: mycolor, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (val) => val == null || val.isEmpty ? "*Required" : null,
        dropDownList: shops
            .map((shop) => DropDownValueModel(
                  name: shop['shop_name'] ?? 'Unknown',
                  value: shop['id'],
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            // issues = [""];
          });
        },
      ),
    );
  }

  Widget _buildSectionDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        value: selectedSection,
        decoration: InputDecoration(
          labelText: 'Audit Section/Line',
          prefixIcon: Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: mycolor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.article, color: mycolor, size: 20),
          ),
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
            borderSide: BorderSide(color: mycolor, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: predefinedSections.map((String section) {
          return DropdownMenuItem<String>(
            value: section,
            child: Text(
              section,
              style: TextStyle(fontSize: 14),
            ),
          );
        }).toList(),
        onChanged: (String? value) {
          setState(() {
            selectedSection = value;
            _sectionController.text = value ?? '';
          });
        },
        validator: (value) =>
            value == null || value.isEmpty ? 'Please select a section' : null,
        isExpanded: true,
        icon: Icon(Icons.keyboard_arrow_down, color: mycolor),
        dropdownColor: Colors.white,
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 14,
        ),
        menuMaxHeight: 300,
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        value: selectedDepartment,
        decoration: InputDecoration(
          labelText: 'Audit Department',
          prefixIcon: Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: mycolor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.person, color: mycolor, size: 20),
          ),
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
            borderSide: BorderSide(color: mycolor, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: predefinedDepartments.map((String department) {
          return DropdownMenuItem<String>(
            value: department,
            child: Text(
              department,
              style: TextStyle(fontSize: 14),
            ),
          );
        }).toList(),
        onChanged: (String? value) {
          setState(() {
            selectedDepartment = value;
            _auditDepartmentController.text = value ?? '';
          });
        },
        validator: (value) => value == null || value.isEmpty
            ? 'Please select a department'
            : null,
        isExpanded: true,
        icon: Icon(Icons.keyboard_arrow_down, color: mycolor),
        dropdownColor: Colors.white,
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 14,
        ),
        menuMaxHeight: 300,
      ),
    );
  }

  String errorText = '';
  Map<String, dynamic> user = {};
  bool isLoading2 = false;
  List<dynamic> shops = [];
  bool isLoading = true;
  bool _documentInfoCompleted = false;

  @override
  void initState() {
    super.initState();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      _loadAllData();
    });
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      loadShops(),
      loadAuditItems(),
    ]);

    // Show document information dialog after all data is loaded
    if (!isLoadingAuditItems &&
        auditItemsError.isEmpty &&
        !isLoading &&
        !_documentInfoCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDocumentInformationDialog();
      });
    }
  }

  Future<void> loadAuditItems() async {
    setState(() {
      isLoadingAuditItems = true;
      auditItemsError = '';
    });

    try {
      final response = await fetchAuditItems();

      if (response != null && response["success"] == true) {
        final itemsData = response["data"] as List;
        auditItems =
            itemsData.map((item) => AuditChecklistItem.fromJson(item)).toList();

        // Update filter values based on fetched data
        if (auditItems.isNotEmpty) {
          final uniqueGroups = auditItems.map((e) => e.group).toSet().toList();

          if (uniqueGroups.isNotEmpty &&
              !uniqueGroups.contains(selectedGroup)) {
            selectedGroup = uniqueGroups.first;
          }
        }
      } else {
        auditItemsError = response?["message"] ?? "Failed to load audit items";
      }
    } catch (e) {
      auditItemsError = "Error loading audit items: $e";
      debugPrint("❌ Error loading audit items: $e");
    } finally {
      setState(() => isLoadingAuditItems = false);
    }
  }

  Future<Map<String, dynamic>?> fetchAuditItems() async {
    String url = Api.api_url + "load-mpa-settings";
    return await httpget(url, user['data']['token'], context);
  }

  Future<void> loadShops() async {
    setState(() => isLoading = true);
    try {
      final response = await fetchShops();

      if (response != null && response["data"]["shop"] != null) {
        shops = response["data"]["shop"];
      }
    } catch (e) {
      errorText = "Error loading shops: $e";
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<Map<String, dynamic>?> fetchShops() async {
    String url = Api.api_url + "home";
    return await httpget(url, user['data']['token'], context);
  }

  Future<void> _showDocumentInformationDialog() async {
    // Add a small delay to ensure everything is loaded
    await Future.delayed(Duration(milliseconds: 500));

    // Pre-fill some default values
    final now = DateTime.now();
    _periodDurationController.text =
        "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";

    if (!context.mounted) return;

    // Show document information dialog
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Don't allow dismissing the dialog
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Icon(Icons.description, color: mycolor),
                SizedBox(width: 8),
                Expanded(child: Text('Document Information')),
              ],
            ),
            content: Container(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildShopDropdown(),
                    _buildHeaderField(Icons.article, 'Project Model & Variant',
                        _modelVariantController),
                    _buildSectionDropdown(),
                    _buildDepartmentDropdown(),
                    // _buildHeaderField(Icons.schedule, 'Period/ Duration',
                    //     _periodDurationController,
                    //     isDate: true),
                  ],
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  // Validate the form
                  if (_validateDocumentForm()) {
                    Navigator.of(dialogContext).pop(true);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: mycolor),
                child: Text('Continue', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
      },
    );

    if (result == true) {
      setState(() {
        _documentInfoCompleted = true;
      });
      _showSuccessMessage();
    }
  }

  bool _validateDocumentForm() {
    List<String> missingFields = [];

    if (_sectionController.text.trim().isEmpty)
      missingFields.add('Project Model & Variant');
    if (selectedSection == null || selectedSection!.isEmpty)
      missingFields.add('Audit section/ Line');
    if (selectedDepartment == null || selectedDepartment!.isEmpty)
      missingFields.add('Audit department');

    if (_shopController.dropDownValue == null)
      missingFields.add('Shop/Station');

    if (missingFields.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                    'Please fill in all required fields:\n${missingFields.join('\n')}',
                    style: TextStyle(fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return false;
    }

    return true;
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
                'Document Information completed! You can now proceed with the audit checklist.'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDocumentInfoRequiredState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Center(
          child: Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: mycolor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.description, size: 48, color: mycolor),
                ),
                SizedBox(height: 20),
                Text(
                  'Document Information Required',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800]),
                ),
                SizedBox(height: 12),
                Text(
                  'Please complete the document information form to proceed with the audit checklist.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _showDocumentInformationDialog,
                  icon: Icon(Icons.description),
                  label: Text('Fill Document Information'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mycolor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text("Audit Checklist",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black26,
                      ),
                    ])),
            // Progress indicator

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text("Group: ${selectedGroup ?? 'All'}",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              // gradient: LinearGradient(
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              //   colors: [
              //     mycolor,
              //     mycolor.withOpacity(0.8),
              //     mycolor.withOpacity(0.9),
              //   ],
              // ),
              ),
        ),
        elevation: 8,
        shadowColor: mycolor.withOpacity(0.3),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                showFilters ? Icons.filter_alt_off : Icons.filter_alt,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                setState(() {
                  showFilters = !showFilters;
                });
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
            // gradient: LinearGradient(
            //   begin: Alignment.topCenter,
            //   end: Alignment.bottomCenter,
            //   colors: [
            //     mycolor.withOpacity(0.05),
            //     Colors.white,
            //     Colors.grey.shade50,
            //   ],
            // ),
            ),
        child: RefreshIndicator(
          displacement: 40,
          strokeWidth: 3,
          color: mycolor,
          backgroundColor: Colors.white,
          onRefresh: _refreshData,
          child: isLoading || isLoadingAuditItems
              ? _buildLoadingState()
              : errorText.isNotEmpty || auditItemsError.isNotEmpty
                  ? _buildErrorState()
                  : !_documentInfoCompleted
                      ? _buildDocumentInfoRequiredState()
                      : _buildMainContent(),
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    await Future.wait([
      loadShops(),
      loadAuditItems(),
    ]);

    // Show document information dialog after refresh if not completed
    if (!isLoadingAuditItems &&
        auditItemsError.isEmpty &&
        !isLoading &&
        !_documentInfoCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDocumentInformationDialog();
      });
    }
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(32),
            margin: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              // boxShadow: [
              //   BoxShadow(
              //     color: mycolor.withOpacity(0.1),
              //     blurRadius: 20,
              //     offset: Offset(0, 10),
              //   ),
              // ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    // gradient: LinearGradient(
                    //   colors: [
                    //     mycolor.withOpacity(0.1),
                    //     mycolor.withOpacity(0.05)
                    //   ],
                    // ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(mycolor),
                    strokeWidth: 4,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Loading Audit Checklist',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fetching audit items from server...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: mycolor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: mycolor.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_download,
                        size: 16,
                        color: mycolor,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Please wait',
                        style: TextStyle(
                          color: mycolor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildErrorState() {
    final displayError =
        auditItemsError.isNotEmpty ? auditItemsError : errorText;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.withOpacity(0.1),
                        Colors.red.withOpacity(0.05)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Failed to Load Data',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: Text(
                    displayError,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [mycolor, mycolor.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: mycolor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _refreshData,
                    icon:
                        const Icon(Icons.refresh_rounded, color: Colors.white),
                    label: const Text('Retry',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: mycolor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: mycolor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh,
                        size: 16,
                        color: mycolor,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Pull down to refresh',
                        style: TextStyle(
                          color: mycolor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildMainContent() {
    final uniqueGroups = auditItems.map((e) => e.group).toSet().toList();

    return Column(
      children: [
        // Filters
        AnimatedCrossFade(
          crossFadeState: showFilters
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: showFilters
              ? const Duration(milliseconds: 500)
              : const Duration(milliseconds: 0),
          firstChild: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Card(
              color: Colors.white,
              elevation: 2,
              // shadowColor: mycolor.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Container(
                decoration: BoxDecoration(
                  // gradient: LinearGradient(
                  //   begin: Alignment.topLeft,
                  //   end: Alignment.bottomRight,
                  //   colors: [
                  //     Colors.white,
                  //     mycolor.withOpacity(0.02),
                  //   ],
                  // ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.filter_list_rounded,
                              color: mycolor, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Filter Options",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Category Group",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.grey.shade50, Colors.white],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: mycolor.withOpacity(0.3)),
                              boxShadow: [
                                BoxShadow(
                                  color: mycolor.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              underline: const SizedBox(),
                              value: selectedGroup!.isNotEmpty
                                  ? selectedGroup
                                  : null,
                              hint: const Text("Select Group"),
                              icon: Icon(Icons.arrow_drop_down_rounded,
                                  color: mycolor),
                              items: uniqueGroups.map((group) {
                                return DropdownMenuItem<String>(
                                  value: group,
                                  child: Text(group,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                );
                              }).toList(),
                              onChanged: (value) =>
                                  setState(() => selectedGroup = value ?? ''),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          secondChild: const SizedBox.shrink(),
        ),

        // Progress Card
        if (auditItems.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: mycolor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.assignment_turned_in_outlined,
                              color: mycolor, size: 20),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Overall Progress',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            Text(
                              filteredItems.length == totalCount
                                  ? '$answeredCount of $totalCount questions completed'
                                  : '$answeredCount of $totalCount total questions answered',
                              style: TextStyle(
                                // fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Spacer(),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: progressPercentage == 1.0
                                ? Colors.green.withOpacity(0.1)
                                : mycolor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${(progressPercentage * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: progressPercentage == 1.0
                                  ? Colors.green
                                  : mycolor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progressPercentage,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: progressPercentage == 1.0
                                  ? [Colors.green, Colors.green.shade400]
                                  : [mycolor, mycolor.withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    if (answeredCount > 0) ...[
                      SizedBox(height: 8),
                      Text(
                        progressPercentage == 1.0
                            ? '🎉 All questions completed!'
                            : '${totalCount - answeredCount} questions remaining',
                        style: TextStyle(
                          fontSize: 12,
                          color: progressPercentage == 1.0
                              ? Colors.green
                              : Colors.grey.shade600,
                          fontWeight: progressPercentage == 1.0
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

        // Checklist
        Expanded(
          child: filteredItems.isEmpty
              ? Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 40),
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: mycolor.withOpacity(0.1),
                      //     blurRadius: 15,
                      //     offset: Offset(0, 8),
                      //   ),
                      // ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            // gradient: LinearGradient(
                            //   colors: [
                            //     mycolor.withOpacity(0.1),
                            //     mycolor.withOpacity(0.05)
                            //   ],
                            // ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(Icons.inbox_outlined,
                              size: 48, color: mycolor),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "No Items Found",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Try adjusting your filters to see audit items.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: mycolor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: mycolor.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.tune_rounded,
                                size: 16,
                                color: mycolor,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Use filters above',
                                style: TextStyle(
                                  color: mycolor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Card(
                        color: Colors.white,
                        elevation: 2,
                        // shadowColor: mycolor.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Container(
                          decoration: BoxDecoration(
                            // gradient: LinearGradient(
                            //   begin: Alignment.topLeft,
                            //   end: Alignment.bottomRight,
                            //   colors: [
                            //     Colors.white,
                            //     mycolor.withOpacity(0.02),
                            //   ],
                            // ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            mycolor.withOpacity(0.1),
                                            mycolor.withOpacity(0.05)
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        filteredItems.length == totalCount
                                            ? "Question ${index + 1} of $totalCount"
                                            : "Question ${index + 1} of ${filteredItems.length} filtered ($totalCount total)",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: mycolor,
                                        ),
                                      ),
                                    ),
                                    Spacer(),
                                    if (item.rating != null)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: Colors.green
                                                  .withOpacity(0.3)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.check_circle,
                                                color: Colors.green, size: 14),
                                            SizedBox(width: 4),
                                            Text(
                                              "Answered",
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  item.description,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                      height: 1.3),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List.generate(4, (value) {
                                    final isSelected = item.rating == value;
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: getRatingColor(value)
                                                      .withOpacity(0.3),
                                                  blurRadius: 6,
                                                  offset: Offset(0, 3),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: ChoiceChip(
                                        label: Text(
                                          getRatingLabel(value),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.grey.shade700,
                                          ),
                                        ),
                                        selected: isSelected,
                                        selectedColor: getRatingColor(value),
                                        backgroundColor: Colors.grey.shade100,
                                        onSelected: (_) {
                                          setState(() {
                                            item.rating = value;
                                          });
                                        },
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: mycolor.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextFormField(
                                    initialValue: item.comment,
                                    decoration: InputDecoration(
                                      hintText:
                                          'Add your comments here (optional)',
                                      hintStyle: TextStyle(
                                          color: Colors.grey.shade500),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: mycolor.withOpacity(0.3)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                            color: mycolor, width: 2),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                      prefixIcon: Icon(Icons.comment_outlined,
                                          color: mycolor.withOpacity(0.7)),
                                    ),
                                    onChanged: (val) {
                                      item.comment = val;
                                    },
                                    maxLines: 3,
                                    minLines: 1,
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
        // Submit Button
        filteredItems.isEmpty
            ? Container()
            : isLoading2
                ? Container(padding: EdgeInsets.all(20), child: CustomLoader())
                : Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: mycolor.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [mycolor, mycolor.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: mycolor.withOpacity(0.4),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              progressPercentage == 1.0
                                  ? Icons.check_circle_rounded
                                  : Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          label: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                progressPercentage == 1.0
                                    ? "Submit Complete Audit"
                                    : "Submit Partial Audit ($answeredCount/$totalCount)",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (progressPercentage < 1.0)
                                Text(
                                  "${totalCount - answeredCount} questions not answered",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                            ],
                          ),
                          onPressed: () {
                            final answered = auditItems
                                .where((item) => item.rating != null)
                                .toList();
                            if (answered.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.warning_amber_rounded,
                                          color: Colors.white),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                            "Please answer at least one question before submitting. Progress: $answeredCount/$totalCount completed.",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500)),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.orange,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                              return;
                            }

                            // Show confirmation dialog for partial submissions
                            if (progressPercentage < 1.0) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Row(
                                      children: [
                                        Icon(Icons.info_outline,
                                            color: mycolor),
                                        SizedBox(width: 8),
                                        Text('Partial Submission'),
                                      ],
                                    ),
                                    content: Text(
                                      'You have answered $answeredCount out of $totalCount questions (${(progressPercentage * 100).toInt()}% complete).\n\nDo you want to submit this partial audit?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          submitChecklistData();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: mycolor,
                                        ),
                                        child: Text('Submit Anyway',
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              submitChecklistData();
                            }
                          },
                        ),
                      ),
                    ),
                  )
      ],
    );
  }

  void submitChecklistData() async {
    // if (_sectionController.text.trim().isEmpty ||
    //     _auditDepartmentController.text.trim().isEmpty ||
    //     _auditSectionController.text.trim().isEmpty ||
    //     _periodDurationController.text.trim().isEmpty ||
    //     _shopController.dropDownValue == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text("Please fill in all fields before submitting."),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    //   return;
    // }

    setState(() {
      isLoading2 = true;
    });

    final answered = auditItems
        .where((item) => item.rating != null)
        .map((item) => {
              // 'category': item.group,
              // 'resp': item.resp,
              // 'query_name': item.description,
              'mpa_setting_id': item.sn,
              'rating': item.rating,
              'comment': item.comment ?? '',
            })
        .toList();

    final payload = {
      "project_model_variant": _modelVariantController.text,
      "audit_department": selectedDepartment ?? '',
      "audit_line": selectedSection ?? '',
      "station_number": _shopController.dropDownValue!.name.toString(),
      "period": _periodDurationController.text,
      // "document_ref": "AVA.QM.D.021",
      // "original_date": "19.03.2019",
      // "revision": "4",
      "items": answered,
    };
    print(payload);
    try {
      final url = Api.api_url + "store-mpa";
      final response = await httppostwithtoken(
        url,
        "${user['data']['token']}",
        payload,
        context,
      );

      if (!mounted) return;
      log(jsonEncode(response));
      if (response != null && response['success'] == true) {
        awesomeTopSnackbar(
          context,
          "${response["msg"]}",
          iconWithDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(),
            color: Colors.white,
          ),
          backgroundColor: Colors.green,
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (
            context,
          ) =>
                  QFLThreeList()),
          (route) => route.isFirst,
        );
      } else {
        awesomeTopSnackbar(
          context,
          "${response?["msg"] ?? "Failed to submit data."}",
          iconWithDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(),
            color: Colors.white,
          ),
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint("❌ Error during saveData: $e");
      awesomeTopSnackbar(
        context,
        "Something went wrong. Please try again.",
        iconWithDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(),
          color: Colors.white,
        ),
        backgroundColor: Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading2 = false;
        });
      }
    }
  }
}
