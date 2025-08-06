import 'dart:convert';
import 'dart:developer';

import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/pages/assembly/assembly_stations.dart';
import 'package:isuze_pqcs/pages/planning/offlining/ChooseEOLOperationsPage.dart';

// Simulated data model
class Issue {
  final String title;
  final String status;
  final String shop;
  final String? description;
  final String? imageUrl;

  Issue({
    required this.title,
    required this.status,
    required this.shop,
    this.description,
    this.imageUrl,
  });

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      title: json['getqueries']['query_name'].toString(),
      status: json['defect_name'] ?? "OPEN",
      shop: json['qshops']['shop_name'].toString(),
      description: json['getqueryanswer']['defect_description']?.toString(),
      imageUrl: json['getqueryanswer']['icon']?.toString(),
    );
  }
}

class OffliningBayPage extends StatefulWidget {
  final ShopId;
  final res;
  final shop_name;

  const OffliningBayPage(
      {super.key, required this.ShopId, this.res, this.shop_name});

  @override
  State<OffliningBayPage> createState() => _OffliningBayPageState();
}

class _OffliningBayPageState extends State<OffliningBayPage> {
  List<Issue> issues = [];
  bool isLoading = true;
  String errorMessage = '';

  // ✅ Example: Simulate API call
  // Future<void> fetchIssues() async {
  //   setState(() {
  //     isLoading = true;
  //     errorMessage = '';
  //   });

  //   try {
  //     await Future.delayed(const Duration(seconds: 2)); // simulate network
  //     // ✅ Replace this with your real API call:
  //     final response = [
  //       {"title": "Faulty cab mount bracket", "status": "OPEN"},
  //       {"title": "Faulty 1st cross member", "status": "OPEN"},
  //       {"title": "Scratch on bumper", "status": "OPEN"},
  //       {"title": "ECU flashing not done", "status": "OPEN"},
  //     ];

  //     final fetched = response.map((e) => Issue.fromJson(e)).toList();

  //     setState(() {
  //       issues = fetched;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       errorMessage = 'Failed to load issues.';
  //     });
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }
  bool isLoading2 = false;
  Future<void> fetchData() async {
    print("Fetching Data...");
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    var url =
        "${Api.api_url}qdefects/${widget.res['data']['vehicledata']['id']}";
    print(url);
    try {
      var response = await httpget(url, user['data']['token'], context);
      print(response);
      if (response != null && response['success'] && response['data'] != null) {
        List<dynamic> responseData = response['data'];

        final fetched = responseData.map((e) => Issue.fromJson(e)).toList();
        print(fetched);
        if (fetched.isNotEmpty) {
          setState(() {
            issues = fetched;
            isLoading = false;
          });
          // await DBHelper.insertShops(fetchedShops); // Update SQLite
        } else {
          setState(() {
            errorMessage = "No Issue Found";
            isLoading = false;
            // _isRefreshing == false;
          });
        }
        // EasyLoading.dismiss(); // Always dismiss loader
      } else {
        setState(() {
          errorMessage = response['msg'] ?? "Failed to fetch data";
          // _isRefreshing == false;
          isLoading = false;
        });
        // EasyLoading.dismiss(); // Always dismiss loader
      }
    } catch (e) {
      // EasyLoading.dismiss(); // Always dismiss loaders
      print("Error fetching data: $e");

      setState(() {
        errorMessage = "Network Problem";
        // _isRefreshing == false;
        isLoading = false;
      });
    }
  }

  var user = {};
  @override
  void initState() {
    super.initState();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      fetchData();
    });
    // fetchIssues();
  }

  // ✅ Your custom colors
  final Color openStatusColor = Colors.red.shade300;
  final Color toEolColor = Colors.green.shade200;
  final Color toGcpColor = Colors.red.shade300;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: mycolor,
        foregroundColor: Colors.white,
        title: const Text(
          "Offlining Bay",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                    Icons.engineering,
                    color: mycolor,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Quality Control Review",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Engineer goes through all issues raised and determines the next course of action.",
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

            // ✅ Main content area
            Expanded(
              child: isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: mycolor),
                          const SizedBox(height: 16),
                          const Text(
                            "Loading issues...",
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
                      : issues.isEmpty
                          ? Center(
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.green.shade400,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      "No Issues Found",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "All quality checks have passed successfully.",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: issues.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final issue = issues[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border:
                                        Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Title and Status Row
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    issue.title,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: mycolor
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Text(
                                                      issue.shop,
                                                      style: TextStyle(
                                                        color: mycolor,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 6,
                                                      horizontal: 12),
                                              decoration: BoxDecoration(
                                                color: openStatusColor,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                issue.status,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Description if available
                                        if (issue.description != null &&
                                            issue.description!.isNotEmpty) ...[
                                          const SizedBox(height: 12),
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              issue.description!,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ],

                                        // Image if available
                                        if (issue.imageUrl != null &&
                                            issue.imageUrl!.isNotEmpty &&
                                            issue.imageUrl != 'null') ...[
                                          const SizedBox(height: 12),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  "${Api.qc_image}${issue.imageUrl}",
                                              width: double.infinity,
                                              height: 160,
                                              fit: BoxFit.cover,
                                              memCacheWidth: 800,
                                              memCacheHeight: 600,
                                              maxWidthDiskCache: 800,
                                              maxHeightDiskCache: 600,
                                              fadeInDuration: const Duration(
                                                  milliseconds: 300),
                                              fadeOutDuration: const Duration(
                                                  milliseconds: 100),
                                              placeholder: (context, url) =>
                                                  Container(
                                                height: 160,
                                                color: Colors.grey.shade100,
                                                child: Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      CircularProgressIndicator(
                                                        color: mycolor,
                                                        strokeWidth: 2,
                                                      ),
                                                      const SizedBox(height: 8),
                                                      const Text(
                                                        'Loading image...',
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                height: 160,
                                                color: Colors.grey.shade100,
                                                child: const Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        color: Colors.grey,
                                                        size: 40,
                                                      ),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        'Image not available',
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
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

            const SizedBox(height: 20),

            isLoading2
                ? CustomLoader()
                : // ✅ Bottom action buttons
                Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: toEolColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => ChooseEOLOperationsPage(
                                            ModelId: widget.res['data']
                                                ['vehicledata']['model_id'],
                                            ShopId: widget.ShopId,
                                            VehicleId: widget.res['data']
                                                ['vehicledata']['id'],
                                          )),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.black87,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "TO EOL",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: toGcpColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.shade300),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
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
                                          Icon(Icons.warning,
                                              color: Colors.orange),
                                          SizedBox(width: 8),
                                          Text("Confirm Submission"),
                                        ],
                                      ),
                                      content: const Text(
                                        "Are you sure you want to submit this data to GCP?",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text(
                                            "Cancel",
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () async {
                                            Navigator.pop(
                                                context); // Close dialog first
                                            await saveData(); // Your API call
                                          },
                                          child: const Text("Confirm"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.send_rounded,
                                    color: Colors.black87,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "TO GCP",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> saveData() async {
    setState(() {
      isLoading2 = true;
    });

    String url = Api.api_url + "moveunitToGCP";

    var payload = {
      "shop_id": widget.ShopId,
      "next_shop_id": 18,
      "vehicle_id": widget.res['data']['vehicledata']['id'],
      "model_id": widget.res['data']['vehicledata']['model_id'],
    };

    try {
      print("Payload: $payload");

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
      debugPrint("❌ Error occurred during saveData: $e");
      setState(() {
        isLoading2 = false;
      });
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
