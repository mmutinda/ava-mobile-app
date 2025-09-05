import 'dart:convert';
import 'dart:developer';
import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/confirmationDialog.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/pages/assembly/assembly_stations.dart';

class SubShop {
  final String id;
  final String name;
  bool selected; // ✅ Added field
  bool isPriorityOperation; // Only one operation can be priority operation
  SubShop({
    required this.id,
    required this.name,
    this.selected = false, // ✅ Default to false
    this.isPriorityOperation = false, // Default to false
  });
  factory SubShop.fromJson(Map<String, dynamic> json) {
    return SubShop(
      id: json['id'].toString(),
      name: json['name'] ?? "",
    );
  }
}

class ChooseEOLOperationsPage extends StatefulWidget {
  final VehicleId;
  final ShopId;
  final ModelId;

  const ChooseEOLOperationsPage(
      {Key? key,
      required this.VehicleId,
      required this.ShopId,
      required this.ModelId})
      : super(key: key);
  @override
  State<ChooseEOLOperationsPage> createState() =>
      _ChooseEOLOperationsPageState();
}

class _ChooseEOLOperationsPageState extends State<ChooseEOLOperationsPage> {
  List<SubShop> operations = [];
  bool isLoading = true;
  String errorMessage = '';
  final Color startEolColor = mycolor;
  final Color checkboxActiveColor = mycolor;
  final Color checkboxBorderColor = Colors.grey.shade600;
  var user = {};
  bool isLoading2 = false;
  @override
  void initState() {
    super.initState();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      fetchData();
    });
  }

  Future<void> fetchData() async {
    print("Fetching Data...");
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    var url = "${Api.api_url}loadSubstations/17";
    print(url);
    try {
      var response = await httpget(url, user['data']['token'], context);
      if (response != null && response['success'] && response['data'] != null) {
        List<dynamic> responseData = response['data'];
        final fetched = responseData.map((e) => SubShop.fromJson(e)).toList();
        if (fetched.isNotEmpty) {
          setState(() {
            operations = fetched;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = "No Issue Found";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = response['msg'] ?? "Failed to fetch data";
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        errorMessage = "Network Problem";
        isLoading = false;
      });
    }
  }

  void toggleOperation(int index) {
    setState(() {
      operations[index].selected = !operations[index].selected;

      // If operation is deselected, remove its priority status
      if (!operations[index].selected) {
        operations[index].isPriorityOperation = false;
      }
    });
  }

  void setPriorityOperation(int index) {
    setState(() {
      // First, remove priority from all operations
      for (int i = 0; i < operations.length; i++) {
        operations[i].isPriorityOperation = false;
      }

      // Set the selected operation as priority operation
      if (operations[index].selected) {
        operations[index].isPriorityOperation = true;
      }
    });
  }

  void startEol() {
    // ✅ Add your START EOL logic here
    List<SubShop> selectedOps = operations.where((op) => op.selected).toList();
    SubShop? priorityOp =
        operations.where((op) => op.isPriorityOperation).firstOrNull;

    print("Selected operations: ${selectedOps.map((e) => e.name).toList()}");
    if (priorityOp != null) {
      print("Priority operation: ${priorityOp.name}");
    }

    if (selectedOps.isEmpty) {
      awesomeTopSnackbar(
        context,
        "Please, Choose atleast one operation",
        iconWithDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(),
          color: Colors.white,
        ),
        backgroundColor: Colors.red,
      );
      return;
    }
    CustomConfirmDialog.show(
      context: context,
      title: 'Confirm Action',
      message: priorityOp != null
          ? 'Do you want to push to EOL with "${priorityOp.name}" as priority operation?'
          : 'Do you want to push to EOL with the selected operations?',
      onConfirm: () async {
        await saveData();
      },
    );
    // Proceed with selectedOps
  }

  Future<void> saveData() async {
    setState(() {
      isLoading2 = true;
    });

    try {
      print("isLoading2: $isLoading2");

      String url = Api.api_url + "moveunitToEOL";

      // ✅ Build selected operations list with priority operation first
      List<SubShop> selectedOps =
          operations.where((op) => op.selected).toList();

      // Find priority operation and put it first
      SubShop? priorityOp =
          selectedOps.where((op) => op.isPriorityOperation).firstOrNull;
      List<SubShop> orderedOps = [];

      if (priorityOp != null) {
        orderedOps.add(priorityOp);
        orderedOps.addAll(selectedOps.where((op) => !op.isPriorityOperation));
      } else {
        orderedOps = selectedOps;
      }

      var payload = {
        "shop_id": widget.ShopId,
        "next_shop_id": 17,
        "vehicle_id": widget.VehicleId,
        "model_id": widget.ModelId,
        "substations": orderedOps.map((e) => e.id).toList(),
        "current_station_id": priorityOp?.id,
      };

      print("$payload");

      var response = await httppostwithtoken(
        url,
        "${user['data']['token']}",
        payload,
        context,
      );

      log("Response: ${jsonEncode(response)}");

      if (response == null || response['success'] == null) {
        throw Exception("Invalid response received.");
      }

      if (response['success']) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AssemblyStations()),
          (route) => route.isFirst,
        );

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
      } else {
        awesomeTopSnackbar(
          context,
          "${response["msg"] ?? "Submission failed"}",
          iconWithDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(),
            color: Colors.white,
          ),
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      debugPrint("❌ saveData error: $e");
      setState(() {
        isLoading2 = false;
      });
      awesomeTopSnackbar(
        context,
        "An error occurred. Please check your connection or try again.",
        iconWithDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(),
          color: Colors.white,
        ),
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() {
        isLoading2 = false;
      });
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
          "Choose EOL Operations",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: mycolor),
                    const SizedBox(height: 16),
                    const Text(
                      "Loading operations...",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : errorMessage.isNotEmpty
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade400,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            errorMessage,
                            style: TextStyle(
                              color: Colors.red.shade600,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: mycolor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: fetchData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Retry",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      // Header info card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.settings_applications,
                              color: mycolor,
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "EOL Operations Selection",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Choose operations and optionally set one as priority.",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.separated(
                          itemCount: operations.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final op = operations[index];
                            final isSelected = op.selected;
                            return GestureDetector(
                              onTap: () => toggleOperation(index),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? mycolor
                                        : Colors.grey.shade200,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        // Custom checkbox
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? mycolor
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border: Border.all(
                                              color: isSelected
                                                  ? mycolor
                                                  : Colors.grey.shade400,
                                              width: 2,
                                            ),
                                          ),
                                          child: isSelected
                                              ? const Icon(
                                                  Icons.check,
                                                  size: 14,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        // Operation name
                                        Expanded(
                                          child: Text(
                                            op.name,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: isSelected
                                                  ? mycolor
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                        // Selection indicator
                                        if (isSelected)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: mycolor,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              "Selected",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    // Priority selection (only show if operation is selected)
                                    if (isSelected) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: mycolor.withOpacity(0.05),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: mycolor.withOpacity(0.2),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.priority_high,
                                              color: mycolor,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                "Set as Priority Operation to be start first",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: mycolor,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () =>
                                                  setPriorityOperation(index),
                                              child: Container(
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  color: op.isPriorityOperation
                                                      ? mycolor
                                                      : Colors.transparent,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: op
                                                            .isPriorityOperation
                                                        ? mycolor
                                                        : Colors.grey.shade400,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: op.isPriorityOperation
                                                    ? const Icon(
                                                        Icons.star,
                                                        size: 14,
                                                        color: Colors.white,
                                                      )
                                                    : null,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Selection counter with priority info
                      if (operations.any((op) => op.selected)) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            color: mycolor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: mycolor.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: mycolor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${operations.where((op) => op.selected).length} operation(s) selected",
                                    style: TextStyle(
                                      color: mycolor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              if (operations
                                  .any((op) => op.isPriorityOperation)) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: mycolor,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        "Priority: ${operations.where((op) => op.isPriorityOperation).first.name}",
                                        style: TextStyle(
                                          color: mycolor,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),
                      isLoading2
                          ? CustomLoader()
                          : Container(
                              width: double.infinity,
                              height: 48,
                              decoration: BoxDecoration(
                                color: startEolColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: startEolColor),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: startEol,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "START EOL",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
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
    );
  }
}
