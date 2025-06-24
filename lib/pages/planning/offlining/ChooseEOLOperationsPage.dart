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
    var url = "${Api.api_url}loadSubstations/11";
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
    print(isLoading2);
    String url = Api.api_url + "moveunitToEOL";

    // ✅ Build the selected operations array
    List<SubShop> selectedOps = operations.where((op) => op.selected).toList();

    var payload = {
      "shop_id": widget.ShopId,
      "next_shop_id": 11,
      "vehicle_id": widget.VehicleId,
      "model_id": widget.ModelId,
      "substations": "${selectedOps.map((e) => e.id).toList()}", // ✅ Add here
    };

    print("Payload: $payload"); // Debug log

    var response = await httppostwithtoken(
      url,
      "${user['data']['token']}",
      payload,
      context,
    );

    setState(() {
      isLoading2 = false;
    });
    log(jsonEncode(response));
    if (response['success'] != null) {
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
          "${response["msg"]}",
          iconWithDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(),
            color: Colors.white,
          ),
          backgroundColor: Colors.red,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose EOL Operations"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : Column(
                    children: [
                      const Text(
                        "The engineer chooses the operations to be carried out on the unit, i.e., check the EOL operations.",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 15,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.separated(
                          itemCount: operations.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final op = operations[index];
                            final isSelected = op.selected;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: isSelected
                                      ? checkboxActiveColor
                                      : Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    op.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => toggleOperation(index),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? checkboxActiveColor
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isSelected
                                              ? checkboxActiveColor
                                              : checkboxBorderColor,
                                          width: 2,
                                        ),
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check,
                                              size: 18,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      isLoading2
                          ? CustomLoader()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: startEolColor,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: startEol,
                                child: const Text(
                                  "START EOL",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
      ),
    );
  }
}
