import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader2.dart';
import 'package:isuze_pqcs/pages/Receiving/Jobsummary.dart';
// e.g. CustomLoader, ErrorMessageWidget

class ViewEntryFormPage extends StatefulWidget {
  final String VehicleId;

  const ViewEntryFormPage({super.key, required this.VehicleId});

  @override
  State<ViewEntryFormPage> createState() => _ViewEntryFormPageState();
}

class _ViewEntryFormPageState extends State<ViewEntryFormPage> {
  bool isLoading2 = true;
  String textLoading2 = '';
  var data1;
  String searchText = '';
  var user = {};
  @override
  void initState() {
    super.initState();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      fetchEntry(widget.VehicleId);
    });
  }

  Future<void> fetchEntry(String vehicleId) async {
    setState(() {
      isLoading2 = true;
      textLoading2 = '';
    });

    try {
      // Simulate a delay or fetch logic
      final url = "${Api.api_url}fetchScheduledUnits/$vehicleId";
      print(url);
      final response = await httpget(url, user['data']['token'], context);

      print(response);
      if (response == null) {
        setState(() {
          isLoading2 = false;
          textLoading2 =
              'Something went wrong. Check your internet connection.';
        });

        return;
      }

      if (response['success'] && response['data'] != null) {
        setState(() {
          data1 = response['data'];
          isLoading2 = false;
          textLoading2 = '';
        });

        if (data1.isEmpty) {
          setState(() {
            textLoading2 = "No Any data found.";
          });
        }
      } else {
        setState(() {
          isLoading2 = false;
          textLoading2 = response['msg'] ?? 'Unexpected error';
        });
      }
      // Replace with real API logic
    } catch (e) {
      setState(() {
        isLoading2 = false;
        textLoading2 = 'Failed to load data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: isLoading2
          ? const Center(child: CircularProgressIndicator())
          : textLoading2.isNotEmpty
              ? ErrorMessageWidget(
                  errorMessage: textLoading2,
                  onRetry: () => fetchEntry(widget.VehicleId),
                )
              : Column(
                  children: [
                    JobCardWidget(
                      deliveryDate: "${data1['created_at'] ?? 'N/A'}",
                      vin_no: "${data1['vin_no'] ?? 'N/A'}",
                      engine_no: "${data1['engine_no'] ?? 'N/A'}",
                      color: "${data1['color'] ?? 'N/A'}",
                      model: "${data1['model']['model_name'] ?? 'N/A'}",
                      clientName: "${data1['client']['name'] ?? 'N/A'}",
                      Lot_No: "${data1['lot_no'] ?? 'N/A'}",
                    ),
                    // Expanded(
                    //   child: ListView.builder(
                    //     itemCount: data1['answers'].length,
                    //     itemBuilder: (context, index) {
                    //       final itemData = data1['answers'][index];

                    //       return Card(
                    //         color: Colors.white,
                    //         elevation: 3,
                    //         margin: const EdgeInsets.symmetric(vertical: 8),
                    //         shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(10),
                    //         ),
                    //         child: Padding(
                    //           padding: const EdgeInsets.all(12.0),
                    //           child: Row(
                    //             crossAxisAlignment: CrossAxisAlignment.start,
                    //             children: [
                    //               Text(
                    //                 itemData['routing']['query_name'],
                    //                 style: const TextStyle(
                    //                   fontWeight: FontWeight.bold,
                    //                   fontSize: 16,
                    //                 ),
                    //               ),
                    //               const SizedBox(height: 10),
                    //               Text("${itemData['answer']}",
                    //                   style: TextStyle(fontSize: 14)),
                    //               const SizedBox(width: 10),
                    //               itemData['answer'] == 'OK'
                    //                   ? const Icon(Icons.check_circle,
                    //                       color: Colors.green)
                    //                   : const Icon(Icons.cancel,
                    //                       color: Colors.red),
                    //             ],
                    //           ),
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: data1['answers'].length,
                        itemBuilder: (context, index) {
                          final itemData = data1['answers'][index];
                          final queryName = itemData['routing']['query_name'];
                          final answer = itemData['answer'];
                          final isOk = answer == 'OK';

                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        queryName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            answer,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: isOk
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                          Icon(
                                            isOk
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            color: isOk
                                                ? Colors.green
                                                : Colors.red,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Badge at the top-right
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.indigo,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Answered',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
