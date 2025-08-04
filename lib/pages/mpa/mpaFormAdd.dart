import 'dart:convert';
import 'package:http/http.dart' as http;
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

class Item {
  final category;
  final resp;
  final query_name;
  final rating;

  final comment;

  Item({
    required this.category,
    required this.query_name,
    required this.rating,
    required this.resp,
    required this.comment,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      category: json['category'],
      query_name: json['query_name'],
      rating: json['rating'],
      resp: json['resp'],
      comment: json['comment'],
    );
  }
}

class AuditChecklistPageAdd extends StatefulWidget {
  final id;

  const AuditChecklistPageAdd({super.key, required this.id});
  // final List<AuditChecklistItem> previouslyAnsweredItems;

  // const AuditChecklistPageAdd(
  //     {super.key, required this.previouslyAnsweredItems});

  @override
  State<AuditChecklistPageAdd> createState() => _AuditChecklistPageAddState();
}

class _AuditChecklistPageAddState extends State<AuditChecklistPageAdd> {
  List<AuditChecklistItem> auditItems = [];
  bool isLoadingAuditItems = true;
  String auditItemsError = '';

  String? selectedResp = "Prodn";
  String? selectedGroup = "Man";

  List<AuditChecklistItem> get filteredItems {
    return auditItems.where((item) {
      final matchResp = selectedResp == null || item.resp == selectedResp;
      final matchGroup = selectedGroup == null || item.group == selectedGroup;
      final notAlreadyFilled = !isItemPreviouslyAnswered(item);
      return matchResp && matchGroup && notAlreadyFilled;
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
  bool isItemPreviouslyAnswered(AuditChecklistItem item) {
    return items.any((prev) =>
        prev.category == item.group &&
        prev.resp == item.resp &&
        prev.query_name == item.description &&
        prev.rating != null);
  }

  // Get previous data for an audit item
  Item? getPreviousItemData(AuditChecklistItem item) {
    try {
      return items.firstWhere((prev) =>
          prev.category == item.group &&
          prev.resp == item.resp &&
          prev.query_name == item.description);
    } catch (e) {
      return null;
    }
  }

  // Check if there are new items that need to be saved
  bool hasNewDataToSave() {
    // Get all items that currently have ratings (answered items)
    final currentAnsweredItems =
        auditItems.where((item) => item.rating != null).toList();

    if (currentAnsweredItems.isEmpty) {
      return false; // No new data if nothing is answered
    }

    // Check if any answered item is different from previous data or is completely new
    for (var item in currentAnsweredItems) {
      final previousData = getPreviousItemData(item);

      if (previousData == null) {
        // This is a completely new item
        return true;
      }

      // Check if rating or comment has changed from previous data
      if (item.rating != previousData.rating ||
          (item.comment ?? '') != (previousData.comment ?? '')) {
        return true;
      }
    }

    return false; // All answered items are identical to previous data
  }

  // Pre-populate audit items with previous data
  void populateAuditItemsWithPreviousData() {
    // ignore: unused_local_variable
    int populatedCount = 0;
    for (var auditItem in auditItems) {
      final previousData = getPreviousItemData(auditItem);
      if (previousData != null) {
        auditItem.rating = previousData.rating;
        auditItem.comment = previousData.comment;
        populatedCount++;
      }
    }
  }

  Future<void> loadAuditItems() async {
    setState(() {
      isLoadingAuditItems = true;
      auditItemsError = '';
    });

    try {
      final response = await fetchAuditItems();
      print(response);
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

        // Populate audit items with previous data if available
        if (items.isNotEmpty) {
          populateAuditItemsWithPreviousData();
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

  final SingleValueDropDownController _shopController =
      SingleValueDropDownController();

  Widget buildShopDropdown() {
    return DropDownTextField(
      controller: _shopController,
      enableSearch: true,
      clearOption: false,
      dropDownIconProperty: IconProperty(color: Colors.blue, size: 28),
      textFieldDecoration: InputDecoration(
        labelText: 'Select Shop/Station',
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey.shade100,
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
      initializeFormData();
    }).catchError((error) {
      print(error);
    });
  }

  List<Item> items = [];

  Future<void> initializeFormData() async {
    print(
        'Fetching previous data from: ${Api.api_url}load-mpa-items/${widget.id}');
    setState(() => isLoading = true);

    try {
      // Load Shops and Audit Items
      await Future.wait([
        loadShops(),
        loadAuditItems(),
      ]);

      // Load Previous Data using the same API as details page
      final response = await http.get(
        headers: {
          'Authorization': 'Bearer ${user['data']['token']}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        Uri.parse('${Api.api_url}load-mpa-items/${widget.id}'),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception(
              'Request timeout. Please check your internet connection.');
        },
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);

          if (data == null) {
            throw Exception('Received null response from server');
          }

          if (!data.containsKey('data')) {
            throw Exception('Invalid response format: missing data field');
          }

          final dynamic recordData = data['data'];

          if (recordData == null) {
            print('No previous MPA record data found for this ID');
            // This is not necessarily an error - could be a new record
            items = [];
          } else if (recordData is List) {
            try {
              // Parse items from the response array
              items = [];
              for (var itemJson in recordData) {
                try {
                  final item = Item(
                    category: itemJson['mpa_setting']['category'],
                    query_name: itemJson['mpa_setting']['query_name'],
                    rating: itemJson['rating'],
                    resp: itemJson['mpa_setting']['responsible'],
                    comment: itemJson['comment'],
                  );
                  items.add(item);
                } catch (e) {
                  print('Warning: Failed to parse item: $e');
                  continue;
                }
              }
              print('Successfully loaded ${items.length} previous items');
            } catch (e) {
              print('Warning: Failed to parse record data: $e');
              // Don't throw here - this might be a new record without previous data
              items = [];
            }
          } else {
            print(
                'Invalid response format: data is not a list, received: ${recordData.runtimeType}');
            items = [];
          }
        } catch (e) {
          print('Error parsing response: $e');
          // Don't throw here - this might be a new record
          items = [];
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception(
            'Access denied. You don\'t have permission to view this data.');
      } else if (response.statusCode == 404) {
        print('No previous MPA record found for this ID - starting fresh');
        items = []; // This is fine - new record
      } else if (response.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception(
            'Unexpected response: ${response.statusCode} - ${response.reasonPhrase}');
      }

      // Populate audit items with previous data after both are loaded
      populateAuditItemsWithPreviousData();
    } catch (e) {
      errorText = "Error during initialization: $e";
      print("❌ Error during initialization: $e");
    } finally {
      setState(() => isLoading = false);
    }
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
            const Text("Audit Checklist - Edit",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )),
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
          decoration: BoxDecoration(),
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
        decoration: BoxDecoration(),
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
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
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
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
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
              elevation: 8,
              shadowColor: mycolor.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Container(
                decoration: BoxDecoration(
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
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: mycolor.withOpacity(0.3)),
                                  ),
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    value: selectedGroup,
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
                                        setState(() => selectedGroup = value),
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
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    final alreadyFilled = isItemPreviouslyAnswered(item);

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      child: Card(
                        elevation: 2,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Row with title and badge
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "${index + 1}. ${item.description}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ),
                                    if (alreadyFilled)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: Colors.green.shade400),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.green.withOpacity(0.2),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          "Already Filled",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green.shade700,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                /// Rating chips
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 8,
                                  children: List.generate(4, (value) {
                                    final isSelected = item.rating == value;
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: ChoiceChip(
                                        label: Text(
                                          getRatingLabel(value),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.grey.shade700,
                                          ),
                                        ),
                                        selected: isSelected,
                                        selectedColor: getRatingColor(value),
                                        backgroundColor: Colors.grey.shade100,
                                        elevation: isSelected ? 4 : 2,
                                        pressElevation: 6,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          side: BorderSide(
                                            color: isSelected
                                                ? getRatingColor(value)
                                                : Colors.grey.shade300,
                                          ),
                                        ),
                                        onSelected: alreadyFilled
                                            ? null
                                            : (_) {
                                                setState(() {
                                                  item.rating = value;
                                                });
                                              },
                                      ),
                                    );
                                  }),
                                ),

                                const SizedBox(height: 16),

                                /// Comment field
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextFormField(
                                    initialValue: item.comment,
                                    enabled: !alreadyFilled,
                                    decoration: InputDecoration(
                                      hintText: 'Add comment (optional)',
                                      hintStyle: TextStyle(
                                          color: Colors.grey.shade500),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                    ),
                                    onChanged: (val) {
                                      item.comment = val;
                                    },
                                    maxLines: 2,
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
                ? CustomLoader()
                : SafeArea(
                    child: Container(
                      margin: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
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
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          backgroundColor: mycolor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                        icon: Icon(Icons.send_rounded, size: 20),
                        label: Text(
                          "Submit Audit Checklist",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        onPressed: () {
                          final answered = auditItems
                              .where((item) => item.rating != null)
                              .toList();

                          if (answered.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Please answer at least one checklist item before submitting."),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (!hasNewDataToSave()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "No new data to save. All answered items are identical to previously submitted data."),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          _showDocumentDialog();
                        },
                      ),
                    ),
                  )
      ],
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.search_off_rounded,
                    size: 48,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No Items Found',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'No audit checklist items found for the selected filters.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
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

  void _showDocumentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              content: SingleChildScrollView(
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  // margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📄Confirm to Add',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(120, 50),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    backgroundColor: Colors.grey.shade300,
                                    foregroundColor: Colors.black,
                                  ),
                                  child: const Text("Cancel"),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    Navigator.pop(
                                        context); // ✅ Close the dialog first

                                    // ✅ Wait for dialog to close, then call submission outside using Future
                                    Future.delayed(Duration.zero, () {
                                      submitChecklistData(); // Call function in parent or parent context
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(120, 50),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    backgroundColor: mycolor,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text("Confirm"),
                                ),
                              ),
                            ],
                          ),
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
    print("=====");
    setState(() {
      isLoading2 = true;
    });

    // Build payload array from only new or changed items
    final newOrChangedItems = auditItems
        .where((item) {
          // Only include items that have ratings AND are new or changed
          if (item.rating == null) return false;

          final previousData = getPreviousItemData(item);

          // If no previous data exists, it's a new item
          if (previousData == null) return true;

          // If rating or comment has changed, include it
          if (item.rating != previousData.rating ||
              (item.comment ?? '') != (previousData.comment ?? '')) {
            return true;
          }

          // Otherwise, skip it (no changes)
          return false;
        })
        .map((item) => {
              'mpa_setting_id': item.sn,
              'rating': item.rating,
              'comment': item.comment ?? '',
            })
        .toList();

    print(
        '📤 Submitting ${newOrChangedItems.length} new/changed items out of ${auditItems.where((item) => item.rating != null).length} total answered items');
    for (var item in newOrChangedItems) {
      print('   • Item ID ${item['mpa_setting_id']}: Rating ${item['rating']}');
    }

    var payload = {
      "mpa_id": widget.id,
      "items": newOrChangedItems,
    };
    print(payload);
    try {
      String url = Api.api_url + "mpaadd";
      final response = await httppostwithtoken(
        url,
        "${user['data']['token']}",
        payload,
        context,
      );

      if (!mounted) return;

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
          MaterialPageRoute(builder: (context) => QFLThreeList()),
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
