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

  const TorqueEntryPage({super.key, required this.id});

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
  List<TorqueItem> torqueEntries = [];

  bool isLoadingOperations = false;
  bool isLoadingPrev = false;
  bool isLoading2 = false;
  var user = {};

  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

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
      final url = "${Api.api_url}loadTcmJointByShop/$stationId";
      final token = user['data']['token'];

      final response = await httpget(url, token, context);

      if (response['success'] == true) {
        final data = response['data'];
        if (data != null && data is List && data.isNotEmpty) {
          setState(() {
            operationList = data;
          });
        } else {
          setState(() {
            operationList = [];
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "No operations found for the selected station.",
                textAlign: TextAlign.center,
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
          selectedStation = null; // Optional: reset if required
        }
      } else if (response == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "No operations found for the selected station.",
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Operation not found. Please try again.",
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error fetching operations: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error loading operations."),
          backgroundColor: Colors.red,
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
          "${Api.api_url}loadFilledTcm/$selectedStation/${widget.id}/$operationId";
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
              torqueItem.controller.text = entry['reading_value'].toString();
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
      "operation_id": selectedOperation,
      "torque_values": newTorqueValues,
    };

    setState(() {
      isLoading2 = true;
    });

    try {
      final url = Api.api_url + "recordQfl3Readings";
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
              elevation: 4,
              // shadowColor: entry.isExisting
              //     ? Colors.grey.shade300
              //     : Colors.amber.shade200,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: entry.isExisting
                        ? [Colors.grey.shade50, Colors.grey.shade100]
                        : [Colors.white, Colors.white.withOpacity(0.5)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color:
                              entry.isExisting ? Colors.grey.shade400 : mycolor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: entry.isExisting
                                  ? Colors.grey.shade300
                                  : mycolor.withOpacity(0.3),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          entry.isExisting ? Icons.lock : Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 16),
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
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: entry.isExisting
                                  ? Colors.grey.shade100
                                  : Colors.amber.shade50,
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
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.shade200,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.white, size: 20),
                            onPressed: () => removeTorqueEntry(index),
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.shade200,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
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
                            Row(
                              children: [
                                // Station Dropdown
                                Expanded(
                                  child: DropdownButtonFormField2<String>(
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      labelText: 'Select Station',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    value: selectedStation,
                                    items: stationList.map((station) {
                                      return DropdownMenuItem<String>(
                                        value: station['id'].toString(),
                                        child: Text(station['shop_name']),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedStation = value;
                                      });
                                      fetchOperations(value!);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Operation Dropdown
                                Expanded(
                                  child: DropdownButtonFormField2<String>(
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      labelText: 'Select Operation',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    value: selectedOperation,
                                    items: operationList
                                        .map<DropdownMenuItem<String>>((op) {
                                      return DropdownMenuItem<String>(
                                        value: op['id'].toString(),
                                        child: Text(op['part_name_joint_id']
                                            .toString()),
                                      );
                                    }).toList(),
                                    onChanged: isLoadingOperations ||
                                            operationList.isEmpty
                                        ? null
                                        : (value) {
                                            setState(() {
                                              selectedOperation = value;
                                            });
                                            fetchInitialEntry(value!);
                                          },
                                    disabledHint: Text(
                                      isLoadingOperations
                                          ? "Loading..."
                                          : "Select a station first",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            buildTorqueEntryList(),
                            const SizedBox(height: 10),
                            isLoading2
                                ? CustomLoader()
                                : Row(
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: selectedOperation != null &&
                                                selectedOperation!.isNotEmpty &&
                                                selectedStation != null
                                            ? addTorqueEntry
                                            : null,
                                        icon: const Icon(Icons.add),
                                        label: const Text('Add Entry'),
                                      ),
                                      const SizedBox(width: 20),
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
}

class TorqueItem {
  final TextEditingController controller = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final bool isExisting;

  TorqueItem({this.isExisting = false});
}
