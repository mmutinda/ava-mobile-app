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

  String? selectedResp = "Prodn";
  String? selectedGroup = "Man";

  List<AuditChecklistItem> get filteredItems {
    return auditItems.where((item) {
      final matchResp = selectedResp == null || item.resp == selectedResp;
      final matchGroup = selectedGroup == null || item.group == selectedGroup;
      return matchResp && matchGroup;
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

  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _auditDepartmentController =
      TextEditingController();
  final TextEditingController _auditSectionController = TextEditingController();
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

  String errorText = '';
  Map<String, dynamic> user = {};
  bool isLoading2 = false;
  List<dynamic> shops = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      loadShops();
      loadAuditItems();
    });
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
          final uniqueResps = auditItems.map((e) => e.resp).toSet().toList();
          final uniqueGroups = auditItems.map((e) => e.group).toSet().toList();

          if (uniqueResps.isNotEmpty && !uniqueResps.contains(selectedResp)) {
            selectedResp = uniqueResps.first;
          }
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text("Resp: ${selectedResp ?? 'All'}",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
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
    final uniqueResps = auditItems.map((e) => e.resp).toSet().toList();
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
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Responsibility",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700)),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.grey.shade50,
                                        Colors.white
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: mycolor.withOpacity(0.3)),
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
                                    value: selectedResp,
                                    hint: const Text("Select RESP"),
                                    icon: Icon(Icons.arrow_drop_down_rounded,
                                        color: mycolor),
                                    items: uniqueResps.map((resp) {
                                      return DropdownMenuItem<String>(
                                        value: resp,
                                        child: Text(resp,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500)),
                                      );
                                    }).toList(),
                                    onChanged: (value) =>
                                        setState(() => selectedResp = value),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Category Group",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700)),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.grey.shade50,
                                        Colors.white
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: mycolor.withOpacity(0.3)),
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
                                    onChanged: (value) => setState(
                                        () => selectedGroup = value ?? ''),
                                  ),
                                ),
                              ],
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
                                    "Question ${index + 1}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: mycolor,
                                    ),
                                  ),
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
                            child: const Icon(Icons.send_rounded,
                                color: Colors.white, size: 20),
                          ),
                          label: const Text(
                            "Submit Audit Checklist",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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
                                            "Please answer at least one checklist item before submitting.",
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
                            _showDocumentDialog();
                          },
                        ),
                      ),
                    ),
                  )
      ],
    );
  }

  void _showDocumentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 2,
              backgroundColor: Colors.white,
              child: Container(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Document Information',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800),
                                  ),
                                  Text(
                                    'Complete the form details',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        buildShopDropdown(),
                        _buildHeaderField(Icons.article,
                            'Project Model & Variant', _sectionController),
                        _buildHeaderField(Icons.person, 'Audit department',
                            _auditDepartmentController),
                        _buildHeaderField(Icons.person, 'Audit section/ Line',
                            _auditSectionController),
                        _buildHeaderField(Icons.schedule, 'Period/ Duration',
                            _periodDurationController),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(Icons.close_rounded,
                                      color: Colors.grey.shade700),
                                  label: Text("Cancel",
                                      style: TextStyle(
                                          color: Colors.grey.shade700)),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(120, 50),
                                    backgroundColor: Colors.grey.shade100,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [mycolor, mycolor.withOpacity(0.8)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     color: mycolor.withOpacity(0.3),
                                  //     blurRadius: 8,
                                  //     offset: Offset(0, 4),
                                  //   ),
                                  // ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    if (_sectionController.text
                                            .trim()
                                            .isEmpty ||
                                        _auditDepartmentController.text
                                            .trim()
                                            .isEmpty ||
                                        _auditSectionController.text
                                            .trim()
                                            .isEmpty ||
                                        _periodDurationController.text
                                            .trim()
                                            .isEmpty ||
                                        _shopController.dropDownValue == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              Icon(Icons.warning_amber_rounded,
                                                  color: Colors.white),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                    "Please fill in all fields before submitting.",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500)),
                                              ),
                                            ],
                                          ),
                                          backgroundColor: Colors.orange,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    Navigator.pop(context);
                                    Future.delayed(Duration.zero, () {
                                      submitChecklistData();
                                    });
                                  },
                                  icon: Icon(Icons.send_rounded,
                                      color: Colors.white),
                                  label: Text("Submit",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(120, 50),
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
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
      "project_model_variant": _sectionController.text,
      "audit_department": _auditDepartmentController.text,
      "audit_line": _auditSectionController.text,
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
