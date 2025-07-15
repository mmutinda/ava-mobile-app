import 'dart:convert';
import 'dart:developer';

import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/pages/assembly/assembly_stations.dart';

class SummaryGCP extends StatefulWidget {
  final String model;
  final String chassis;
  final String ageing;
  final String unit_movement_id;

  const SummaryGCP({
    super.key,
    required this.model,
    required this.chassis,
    required this.ageing,
    required this.unit_movement_id,
  });

  @override
  State<SummaryGCP> createState() => _SummaryGCPState();
}

class _SummaryGCPState extends State<SummaryGCP> {
  Map<String, dynamic> user = {};
  bool isLoading2 = false;

  @override
  void initState() {
    super.initState();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("GCP - ${widget.chassis}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildSummaryRow("Model", widget.model),
                    const Divider(),
                    _buildSummaryRow("Chassis", widget.chassis),
                  ],
                ),
              ),
            ),
            const Spacer(),
            isLoading2
                ? CustomLoader()
                : // ✅ Bottom action buttons
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: mycolor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              backgroundColor: Colors.white,
                              title: Row(
                                children: const [
                                  Icon(Icons.warning, color: Colors.orange),
                                  SizedBox(width: 8),
                                  Text("Confirm Submission"),
                                ],
                              ),
                              content: const Text(
                                "Are you sure you want remove this from GCP?",
                                style: TextStyle(fontSize: 16),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await saveData();
                                  },
                                  child: const Text("Confirm"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text(
                        "Remove Unit from GCP",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(
            "$title:",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> saveData() async {
    setState(() {
      isLoading2 = true;
    });

    String url = Api.api_url + "completeGCP";

    var payload = {
      "unit_movement_id": widget.unit_movement_id,
    };

    try {
      log("Payload: $payload");

      var response = await httppostwithtoken(
        url,
        "${user['data']['token']}",
        payload,
        context,
      );

      log(jsonEncode(response));

      if (response == null || response['success'] == null) {
        throw Exception("Invalid response from server.");
      }

      if (response['success']) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AssemblyStations()),
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
          "${response["msg"] ?? "Failed to submit data."}",
          iconWithDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(),
            color: Colors.white,
          ),
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
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
      setState(() {
        isLoading2 = false;
      });
    }
  }
}
