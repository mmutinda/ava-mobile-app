import 'dart:convert';
import 'dart:developer';
import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/common/widgets.dart';

class TorqueEntryPage extends StatefulWidget {
  final id;

  final ModelId;

  const TorqueEntryPage({super.key, required this.id, required this.ModelId});

  @override
  _TorqueEntryPageState createState() => _TorqueEntryPageState();
}

class _TorqueEntryPageState extends State<TorqueEntryPage>
    with TickerProviderStateMixin {
  String? selectedStation;
  String? selectedOperation;

  // var stationList = [];
  var stationList = [];
  var operationList = [];
  List<dynamic> shops = [];
  bool isLoading = true;
  String errorText = '';
  String qfl3_id = '';
  List<TorqueItem> torqueEntries = [];

  bool isLoadingOperations = false;
  bool isLoadingPrev = false;
  bool isLoading2 = false;
  var user = {};

  late AnimationController _animationController;
  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    torqueEntries.add(TorqueItem());
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      LoadShops();
    });
    // Initial station list
  }

  Future<void> LoadShops() async {
    setState(() => isLoading = true);
    try {
      final response = await fetchShops();

      if (response != null && response["data"]["shop"] != null) {
        stationList = response["data"]["shop"];
        print(stationList);
        _animationController.forward();
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

  Future<void> fetchOperations(String stationId) async {
    setState(() {
      isLoadingOperations = true;
      selectedOperation = null;
      operationList = [];
      selectedOperation = null;
      torqueEntries = [TorqueItem()];
    });

    try {
      final url =
          "${Api.api_url}loadQfl3Checklist/${stationId}/${widget.ModelId}";
      print(url);
      final token = user['data']['token'];

      final response = await httpget(url, token, context);

      if (response != null && response['success'] == true) {
        final data = response['data'];
        if (data != null && data is List && data.isNotEmpty) {
          setState(() {
            operationList = data;
          });

          // Show success message with operation count
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "${data.length} operation${data.length == 1 ? '' : 's'} loaded successfully",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else {
          setState(() {
            operationList = [];
          });

          // Show no operations found message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "No operations found for the selected station.",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } else {
        setState(() {
          operationList = [];
        });

        // Show error message
        final errorMessage = response?['msg'] ?? "Failed to load operations";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => fetchOperations(stationId),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        operationList = [];
      });

      debugPrint("Error fetching operations: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Network error. Please check your connection.",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => fetchOperations(stationId),
          ),
        ),
      );
    } finally {
      setState(() {
        isLoadingOperations = false;
      });
    }
  }

  Future<void> fetchInitialEntry(String operationId) async {
    setState(() {
      isLoadingPrev = true;
      torqueEntries.clear();
    });

    try {
      final url =
          "${Api.api_url}loadQfl3/$selectedStation/${widget.id}/${widget.ModelId}/$operationId";

      final token = user['data']['token'];
      print(url);

      final response = await httpget(url, token, context);
      print(response);
      if (response['success'] == true) {
        final data = response['data'];

        if (data != null && data is List && data.isNotEmpty) {
          setState(() {
            torqueEntries = data.map<TorqueItem>((entry) {
              final torqueItem = TorqueItem(isExisting: true); // mark as old
              torqueItem.controller.text = entry['reading'].toString();
              qfl3_id = entry['qfl3_id'].toString();
              return torqueItem;
            }).toList();

            // Optionally add one new empty field
            torqueEntries.add(TorqueItem()); // New field
          });
        } else {
          // No previous entries, show default empty field
          setState(() {
            torqueEntries = [TorqueItem()];
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No previous torque entries found."),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        if (response['msg'] != "No record found.") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['msg']),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //     content: Text("Failed to load previous torque values."),
          //     backgroundColor: Colors.red,
          //   ),
          // );
        }
      }
    } catch (e) {
      debugPrint("Error fetching initial entries: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error loading previous torque values."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoadingPrev = false;
      });
    }
  }

  // Get selected operation details
  Map<String, dynamic>? get selectedOperationDetails {
    if (selectedOperation == null || operationList.isEmpty) return null;

    for (var operation in operationList) {
      if (operation['id'].toString() == selectedOperation) {
        return operation;
      }
    }
    return null;
  }

  // Get USL and LSL values
  String get upperLimit {
    final operation = selectedOperationDetails;
    if (operation != null && operation['usl'] != null) {
      return operation['usl'].toString();
    }
    return '';
  }

  String get lowerLimit {
    final operation = selectedOperationDetails;
    if (operation != null && operation['lsl'] != null) {
      return operation['lsl'].toString();
    }
    return '';
  }

  // Method to build numbered operation dropdown items with dividers
  List<DropdownMenuItem<String>> _buildOperationItems() {
    if (operationList.isEmpty) {
      return [];
    }

    List<DropdownMenuItem<String>> items = [];

    for (int i = 0; i < operationList.length; i++) {
      final operation = operationList[i];

      // Add the operation item with number
      items.add(
        DropdownMenuItem<String>(
          value: operation['id'].toString(),
          child: Container(
            constraints: const BoxConstraints(
              maxHeight: 80, // Limit maximum height per item
            ),
            // padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Number badge
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: mycolor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: mycolor.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: mycolor,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Operation name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        operation['part_name'].toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Add divider between items (except after the last item)
      if (i < operationList.length - 1) {
        items.add(
          DropdownMenuItem<String>(
            enabled: false,
            value: null,
            child: Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.grey.shade300,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }

    return items;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void addTorqueEntry() {
    setState(() {
      torqueEntries.add(TorqueItem());
    });
  }

  void removeTorqueEntry(int index) {
    setState(() {
      torqueEntries.removeAt(index);
    });
  }

  void submitData(newEntries) async {
// Validate only new entries
    final newTorqueValues = torqueEntries
        .where((entry) => !entry.isExisting) // filter only new entries
        .map((entry) => entry.controller.text.trim())
        .where((value) => value.isNotEmpty) // optional: remove empty values
        .toList();

    // ✅ Create payload for Laravel
    final payload = {
      "shop_id": selectedStation,
      "vehicle_id": widget.id,
      "model_id": widget.ModelId,
      "operation_id": selectedOperation,
      "torque_values": newTorqueValues,
    };

    setState(() {
      isLoading2 = true;
    });

    try {
      final url = Api.api_url + "SaveQfl3";
      final response = await httppostwithtoken(
        url,
        "${user['data']['token']}",
        payload,
        context,
      );

      setState(() {
        isLoading2 = false;
      });
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

        Navigator.pop(context);
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
      setState(() {
        isLoading2 = false;
      });
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
      // Remove or update this block if 'isLoading2' is not defined elsewhere
      // If you want to use a loading state, define 'isLoading2' as a bool in your state
      setState(() {
        isLoading2 = false;
      });
      setState(() {
        selectedOperation = null;
        torqueEntries = [TorqueItem()];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildTorqueEntryList() {
      // Check if required fields are not selected
      final bool isSelectionValid = selectedOperation != null &&
          selectedOperation!.isNotEmpty &&
          selectedStation != null;

      if (!isSelectionValid) {
        return Expanded(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // gradient: LinearGradient(
                //   begin: Alignment.topLeft,
                //   end: Alignment.bottomRight,
                //   colors: [mycolor, Colors.orange.shade50],
                // ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: mycolor.withOpacity(0.3), width: 2),
                // boxShadow: [
                //   BoxShadow(
                //     color: mycolor.withOpacity(0.2),
                //     blurRadius: 10,
                //     // offset: Offset(0, 5),
                //   ),
                // ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: mycolor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: mycolor,
                      size: 40,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Selection Required",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: mycolor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Please select both Station and Operation to continue.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.orange.shade700,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // If loading previous data
      if (isLoadingPrev) {
        return Expanded(child: CustomLoader());
      }

      // Initialize field if no previous data
      if (torqueEntries.isEmpty) {
        torqueEntries.add(TorqueItem());
      }

      return Expanded(
        child: ListView.builder(
          itemCount: torqueEntries.length,
          itemBuilder: (context, index) {
            final entry = torqueEntries[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: entry.isExisting ? Colors.grey.shade50 : Colors.white,
                  border: Border.all(
                    color: entry.isExisting
                        ? Colors.grey.shade300
                        : mycolor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Limits display row (if available)
                      if (upperLimit.isNotEmpty || lowerLimit.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (lowerLimit.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.blue.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.arrow_downward,
                                        size: 14,
                                        color: Colors.blue.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'LSL: ${lowerLimit} Nm',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (upperLimit.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.orange.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.arrow_upward,
                                        size: 14,
                                        color: Colors.orange.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'USL: ${upperLimit} Nm',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.orange.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                      // Main input row
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: entry.isExisting
                                  ? Colors.grey.shade400
                                  : mycolor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              entry.isExisting ? Icons.lock : Icons.edit,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: entry.isExisting
                                      ? Colors.grey.shade300
                                      : mycolor.withOpacity(0.3),
                                ),
                              ),
                              child: TextFormField(
                                controller: entry.controller,
                                keyboardType: TextInputType.number,
                                enabled: !entry.isExisting,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: entry.isExisting
                                      ? Colors.grey.shade600
                                      : mycolor,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Torque Value (Nm)',
                                  labelStyle: TextStyle(
                                    color: entry.isExisting
                                        ? Colors.grey.shade500
                                        : mycolor,
                                  ),
                                  helperStyle: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 11,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: entry.isExisting
                                      ? Colors.grey.shade100
                                      : Colors.grey.shade50,
                                  prefixIcon: Icon(
                                    Icons.speed,
                                    color: entry.isExisting
                                        ? Colors.grey.shade400
                                        : mycolor.withOpacity(0.7),
                                  ),
                                  suffixIcon: entry.isExisting
                                      ? Tooltip(
                                          message:
                                              'This is existing data and cannot be edited.',
                                          child: Icon(Icons.info_outline,
                                              color: Colors.grey.shade400),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (torqueEntries.length > 1 && !entry.isExisting)
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.delete,
                                    color: Colors.white, size: 16),
                                onPressed: () => removeTorqueEntry(index),
                              ),
                            ),
                        ],
                      ),
                      // Show Add Entry button only in the last field
                      if (index == torqueEntries.length - 1 &&
                          !entry.isExisting)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: ElevatedButton.icon(
                            onPressed: selectedOperation != null &&
                                    selectedOperation!.isNotEmpty &&
                                    selectedStation != null
                                ? addTorqueEntry
                                : null,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Entry'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: mycolor,
          title: Text(
            'Torque Entry',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  mycolor,
                  mycolor.withOpacity(0.8),
                ],
              ),
            ),
          ),
        ),
        body: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Colors.amber.shade200,
                        //     blurRadius: 10,
                        //     offset: Offset(0, 5),
                        //   ),
                        // ],
                      ),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.amber.shade900),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Loading form data...',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(5),
                child: errorText.isNotEmpty
                    ? ErrorMessageWidget(
                        errorMessage: errorText, onRetry: LoadShops)
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Station Dropdown
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
                              child: DropdownButtonFormField2<String>(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: 'Select Station',
                                  labelStyle: TextStyle(color: mycolor),
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: mycolor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.location_on_outlined,
                                      color: mycolor,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade200),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade200),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: mycolor, width: 2),
                                  ),
                                ),
                                value: selectedStation,
                                items: stationList.map((station) {
                                  return DropdownMenuItem<String>(
                                    value: station['id'].toString(),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: mycolor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              station['shop_name'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedStation = value;
                                    selectedOperation =
                                        null; // Reset operation selection
                                    operationList = []; // Clear operations
                                  });
                                  fetchOperations(value!);
                                },
                                hint: Text(
                                  "Choose a station",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight:
                                      MediaQuery.of(context).size.height *
                                          0.3, // Responsive height
                                  width: MediaQuery.of(context).size.width -
                                      48, // Full width minus padding
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  scrollbarTheme: ScrollbarThemeData(
                                    radius: const Radius.circular(40),
                                    thickness: MaterialStateProperty.all(4),
                                    thumbVisibility:
                                        MaterialStateProperty.all(true),
                                    thumbColor: MaterialStateProperty.all(
                                        mycolor.withOpacity(0.5)),
                                  ),
                                ),
                                iconStyleData: IconStyleData(
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: mycolor,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
                            // Operation Dropdown
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
                              child: DropdownButtonFormField2<String>(
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: 'Select Operation',
                                  labelStyle: TextStyle(
                                    color: isLoadingOperations
                                        ? Colors.grey[500]
                                        : mycolor,
                                  ),
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isLoadingOperations
                                          ? Colors.grey.withOpacity(0.1)
                                          : mycolor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: isLoadingOperations
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      mycolor),
                                            ),
                                          )
                                        : Icon(
                                            Icons.settings_outlined,
                                            color: operationList.isEmpty
                                                ? Colors.grey[400]
                                                : mycolor,
                                          ),
                                  ),
                                  filled: true,
                                  fillColor: isLoadingOperations
                                      ? Colors.grey.shade50
                                      : Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade200),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: operationList.isEmpty
                                          ? Colors.grey.shade300
                                          : Colors.grey.shade200,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: mycolor, width: 2),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade200),
                                  ),
                                ),
                                value: selectedOperation,
                                items: _buildOperationItems(),
                                onChanged:
                                    isLoadingOperations || operationList.isEmpty
                                        ? null
                                        : (value) {
                                            setState(() {
                                              selectedOperation = value;
                                            });
                                            fetchInitialEntry(value!);
                                          },
                                hint: Text(
                                  isLoadingOperations
                                      ? "Loading operations..."
                                      : operationList.isEmpty
                                          ? "No operations available"
                                          : "Choose an operation",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                disabledHint: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          isLoadingOperations
                                              ? "Loading operations..."
                                              : selectedStation == null
                                                  ? "Select a station first"
                                                  : "No operations found",
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight:
                                      MediaQuery.of(context).size.height *
                                          0.4, // Responsive height
                                  width: MediaQuery.of(context).size.width -
                                      48, // Full width minus padding
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  scrollbarTheme: ScrollbarThemeData(
                                    radius: const Radius.circular(40),
                                    thickness: MaterialStateProperty.all(4),
                                    thumbVisibility:
                                        MaterialStateProperty.all(true),
                                    thumbColor: MaterialStateProperty.all(
                                        mycolor.withOpacity(0.5)),
                                  ),
                                ),
                                iconStyleData: IconStyleData(
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: isLoadingOperations
                                        ? Colors.grey[400]
                                        : mycolor,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
                            buildTorqueEntryList(),
                            const SizedBox(height: 10),
                            isLoading2
                                ? CustomLoader()
                                : Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            _showConfirmDialog2(context);
                                          },
                                          icon: const Icon(Icons.rocket_launch),
                                          label: const Text('Complete'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: selectedOperation !=
                                                      null &&
                                                  selectedOperation!
                                                      .isNotEmpty &&
                                                  selectedStation != null
                                              ? () {
                                                  if (selectedOperation ==
                                                      null) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            "Please select an operation"),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                  final newEntries =
                                                      torqueEntries
                                                          .where((entry) =>
                                                              !entry.isExisting)
                                                          .toList();

                                                  if (newEntries.isEmpty) {
                                                    awesomeTopSnackbar(
                                                      context,
                                                      "No new torque entries to submit.",
                                                      iconWithDecoration:
                                                          BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        border: Border.all(),
                                                        color: Colors.white,
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                    );

                                                    return;
                                                  }
                                                  for (int i = 0;
                                                      i < newEntries.length;
                                                      i++) {
                                                    if (newEntries[i]
                                                        .controller
                                                        .text
                                                        .trim()
                                                        .isEmpty) {
                                                      awesomeTopSnackbar(
                                                        context,
                                                        "Torque value missing in new entry ${i + 1}",
                                                        iconWithDecoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                          border: Border.all(),
                                                          color: Colors.white,
                                                        ),
                                                        backgroundColor:
                                                            Colors.red,
                                                      );

                                                      return;
                                                    }
                                                  }
                                                  _showConfirmDialog(
                                                      context, newEntries);
                                                }
                                              : null,
                                          icon: const Icon(Icons.send),
                                          label: const Text('Submit'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: mycolor,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                          ],
                        ),
                      ),
              ));
  }

  void _showConfirmDialog2(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [mycolor, mycolor.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: mycolor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.warning_amber, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text(
                'Confirm',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        content: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to submit the torque data?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: mycolor, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Once submitted, the data cannot be edited.',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.cancel, color: Colors.red),
              label: const Text('Cancel',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w600)),
            ),
          ),
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade600],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.shade200,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                submitData2(context);
              },
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text(
                'Yes, Complete',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, newEntries) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [mycolor, mycolor.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: mycolor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.warning_amber, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text(
                'Confirm',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        content: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to submit the torque data?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: mycolor, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${newEntries.length} new entr${newEntries.length == 1 ? 'y' : 'ies'} will be submitted',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.cancel, color: Colors.red),
              label: const Text('Cancel',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w600)),
            ),
          ),
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade600],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.shade200,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                submitData(newEntries);
              },
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text(
                'Yes, Submit',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void submitData2(BuildContext context) async {
    // ✅ Create payload for Laravel
    final payload = {
      "qfl3_id": qfl3_id,
    };
    print(payload);
    print(torqueEntries);
    print(payload);
    setState(() {
      isLoading2 = true;
    });

    try {
      final url = Api.api_url + "completeQfl3";
      final response = await httppostwithtoken(
        url,
        "${user['data']['token']}",
        payload,
        context,
      );

      setState(() {
        isLoading2 = false;
      });
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

        Navigator.pop(context);
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
      setState(() {
        isLoading2 = false;
      });
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
      // Remove or update this block if 'isLoading2' is not defined elsewhere
      // If you want to use a loading state, define 'isLoading2' as a bool in your state
      setState(() {
        isLoading2 = false;
      });
      setState(() {
        selectedOperation = null;
        torqueEntries = [TorqueItem()];
      });
    }
  }
}

class TorqueItem {
  final TextEditingController controller = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final bool isExisting;

  TorqueItem({this.isExisting = false});
}
