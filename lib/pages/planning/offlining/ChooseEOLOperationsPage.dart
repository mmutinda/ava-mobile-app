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
  SubShop({
    required this.id,
    required this.name,
    this.selected = false, // ✅ Default to false
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
    });
  }

  void startEol() {
    // ✅ Add your START EOL logic here
    List<SubShop> selectedOps = operations.where((op) => op.selected).toList();
    print("Selected operations: ${selectedOps.map((e) => e.name).toList()}");
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
      message: 'Do you want to push to EOL',
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

      // ✅ Build selected operations list
      List<SubShop> selectedOps =
          operations.where((op) => op.selected).toList();

      var payload = {
        "shop_id": widget.ShopId,
        "next_shop_id": 17,
        "vehicle_id": widget.VehicleId,
        "model_id": widget.ModelId,
        "substations": selectedOps.map((e) => e.id).toList(),
      };

      print("Payload: $payload");

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
        padding: const EdgeInsets.all(16.0),
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
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.settings_applications,
                              color: mycolor,
                              size: 32,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "EOL Operations Selection",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "The engineer chooses the operations to be carried out on the unit, i.e., check the EOL operations.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.separated(
                          itemCount: operations.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final op = operations[index];
                            final isSelected = op.selected;
                            return GestureDetector(
                              onTap: () => toggleOperation(index),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  // color: isSelected
                                  //     ? mycolor.withOpacity(0.08)
                                  //     : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? mycolor
                                        : Colors.grey.shade200,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Custom checkbox
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? mycolor
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6),
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
                                              size: 16,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    // Operation name
                                    Expanded(
                                      child: Text(
                                        op.name,
                                        style: TextStyle(
                                          fontSize: 16,
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
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: mycolor,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          "Selected",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Selection counter
                      if (operations.any((op) => op.selected))
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(top: 16),
                          decoration: BoxDecoration(
                            color: mycolor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: mycolor.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: mycolor,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "${operations.where((op) => op.selected).length} operation(s) selected",
                                style: TextStyle(
                                  color: mycolor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),
                      isLoading2
                          ? CustomLoader()
                          : Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                color: startEolColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: startEolColor),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: startEol,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      "START EOL",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
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
