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

class _TorqueEntryPageState extends State<TorqueEntryPage> {
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
  @override
  void initState() {
    super.initState();
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
              "Failed to load operations. Please try again.",
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['msg'] ?? "Failed to load torque entries."),
            backgroundColor: Colors.red,
          ),
        );
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
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.warning, color: Colors.orange, size: 36),
                  SizedBox(height: 10),
                  Text(
                    "Please select a Station and Operation first.",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
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
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                        child: TextFormField(
                      controller: entry.controller,
                      keyboardType: TextInputType.number,
                      enabled: !entry.isExisting, // ✅ Disable if existing data
                      decoration: InputDecoration(
                        labelText: 'Torque Value (Nm)',
                        border: const OutlineInputBorder(),
                        // fillColor:
                        //     entry.isExisting ? Colors.grey.shade100 : null,
                        // filled: entry.isExisting,
                        suffixIcon: entry.isExisting
                            ? const Tooltip(
                                message:
                                    'This is existing data and cannot be edited.',
                                child: Icon(Icons.lock, color: Colors.grey),
                              )
                            : null,
                      ),
                    )),
                    const SizedBox(width: 10),
                    if (torqueEntries.length > 1 && !entry.isExisting)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removeTorqueEntry(index),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Torque Entry'),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
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

                            // isLoadingPrev
                            //     ? Expanded(child: CustomLoader())
                            //     : Expanded(
                            //         child: torqueEntries.isEmpty
                            //             ? Center(
                            //                 child: Text(
                            //                   "No previous data found. Please enter a new torque value.",
                            //                   style: TextStyle(
                            //                       fontSize: 16,
                            //                       color: Colors.grey[600]),
                            //                 ),
                            //               )
                            //             : ListView.builder(
                            //                 itemCount: torqueEntries.length,
                            //                 itemBuilder: (context, index) {
                            //                   final entry =
                            //                       torqueEntries[index];
                            //                   return Card(
                            //                     color: Colors.white,
                            //                     margin:
                            //                         const EdgeInsets.symmetric(
                            //                             vertical: 8),
                            //                     shape: RoundedRectangleBorder(
                            //                         borderRadius:
                            //                             BorderRadius.circular(
                            //                                 12)),
                            //                     elevation: 2,
                            //                     child: Padding(
                            //                       padding:
                            //                           const EdgeInsets.all(12),
                            //                       child: Column(
                            //                         children: [
                            //                           Row(
                            //                             children: [
                            //                               Expanded(
                            //                                 child:
                            //                                     TextFormField(
                            //                                   controller: entry
                            //                                       .controller,
                            //                                   keyboardType:
                            //                                       TextInputType
                            //                                           .number,
                            //                                   decoration:
                            //                                       const InputDecoration(
                            //                                     labelText:
                            //                                         'Torque Value (Nm)',
                            //                                     border:
                            //                                         OutlineInputBorder(),
                            //                                   ),
                            //                                 ),
                            //                               ),
                            //                               const SizedBox(
                            //                                   width: 10),
                            //                               if (torqueEntries
                            //                                       .length >
                            //                                   1)
                            //                                 IconButton(
                            //                                   icon: const Icon(
                            //                                       Icons.delete,
                            //                                       color: Colors
                            //                                           .red),
                            //                                   onPressed: () =>
                            //                                       removeTorqueEntry(
                            //                                           index),
                            //                                 ),
                            //                             ],
                            //                           ),
                            //                         ],
                            //                       ),
                            //                     ),
                            //                   );
                            //                 },
                            //               ),
                            //       ),
                            const SizedBox(height: 10),
                            isLoading2
                                ? CustomLoader()
                                : Row(
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: addTorqueEntry,
                                        icon: const Icon(Icons.add),
                                        label: const Text('Add Entry'),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            if (selectedOperation == null) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      "Please select an operation"),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }
                                            final newEntries = torqueEntries
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
                                                      BorderRadius.circular(20),
                                                  border: Border.all(),
                                                  color: Colors.white,
                                                ),
                                                backgroundColor: Colors.red,
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
                                                        BorderRadius.circular(
                                                            20),
                                                    border: Border.all(),
                                                    color: Colors.white,
                                                  ),
                                                  backgroundColor: Colors.red,
                                                );

                                                return;
                                              }
                                            }
                                            _showConfirmDialog(
                                                context, newEntries);
                                          },
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
      barrierDismissible: false, // Prevents closing by tapping outside
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Confirm Submission'),
          ],
        ),
        content: const Text(
          'Are you sure you want to submit the torque data?',
          style: TextStyle(fontSize: 16),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.cancel, color: Colors.red),
            label: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              submitData(newEntries); // Then call the function
            },
            icon: const Icon(Icons.check),
            label: const Text('Yes, Submit'),
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
