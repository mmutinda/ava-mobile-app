import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/pages/Receiving/ViewQcdata.dart';
import 'package:isuze_pqcs/pages/Receiving/receivingChecklist.dart';
import 'package:isuze_pqcs/pages/Receiving/widget.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class QClist extends StatefulWidget {
  final Id;
  final LotNo;

  const QClist({super.key, required this.Id, required this.LotNo});
  @override
  State<QClist> createState() => _QClistState();
}

class _QClistState extends State<QClist> with SingleTickerProviderStateMixin {
  var user = {};
  var vehicles = [];
  var loadingText = '';
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();
  String searchText = '';
  bool _isSearching = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      fetchVehicles().then(
        (value) {
          if (vehicles.isEmpty) {
            print(value);
            setState(() {
              loadingText = 'No Any Lot available at the moment';
            });
          }
          _animationController.forward();
        },
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildSearchField() {
      return TextField(
        autofocus: true,
        style: TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        controller: searchController,
        onChanged: (value) {
          setState(() {
            searchText = value;
          });
        },
        decoration: InputDecoration(
            hintText: 'Chassis Number or RegNo...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [mycolor, mycolor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        title: _isSearching
            ? _buildSearchField()
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.inventory_2, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Units in Lot ${widget.LotNo}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    searchController.clear();
                    searchText = '';
                  }
                });
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: mycolor,
        onRefresh: () {
          return Future.delayed(
            const Duration(seconds: 1),
            () {
              fetchVehicles().then(
                (value) {
                  toasty(context, "Refreshed",
                      bgColor: mycolor,
                      textColor: textWhite,
                      padding: EdgeInsets.all(12));
                },
              );
            },
          );
        },
        child: Column(
          children: [
            Expanded(
              child: SizedBox(
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : loadingText.isNotEmpty
                          ? ErrorMessageWidget(
                              errorMessage: loadingText,
                              onRetry: () {
                                fetchVehicles().then(
                                  (value) {
                                    if (vehicles.isEmpty) {
                                      setState(() {
                                        loadingText =
                                            'No Any Lot available at the moment';
                                      });
                                    }
                                  },
                                );
                              },
                            )
                          : SizedBox(
                              child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  itemCount: vehicles.length,
                                  itemBuilder: (context, index) {
                                    var vehicle = vehicles[index];
                                    var chassis_number =
                                        vehicle["chassis_number"];
                                    var engine_no =
                                        vehicles[index]["engine_number"];
                                    bool isCompleted =
                                        vehicle['receiving_checklist_done']
                                                ?.toString()
                                                .toLowerCase() ==
                                            '1';

                                    if (searchText.isNotEmpty &&
                                        !(chassis_number.toLowerCase().contains(
                                                searchText.toLowerCase()) ||
                                            engine_no.toLowerCase().contains(
                                                searchText.toLowerCase()))) {
                                      return const SizedBox.shrink();
                                    }

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white,
                                            Colors.grey.shade50
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.08),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          // Main content
                                          Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              children: [
                                                // Vehicle number with gradient
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: isCompleted
                                                          ? [
                                                              mycolor,
                                                              mycolor
                                                                  .withOpacity(
                                                                      0.8)
                                                            ]
                                                          : [
                                                              mycolor,
                                                              mycolor
                                                                  .withOpacity(
                                                                      0.8)
                                                            ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: (isCompleted
                                                                ? Colors.green
                                                                : mycolor)
                                                            .withOpacity(0.3),
                                                        blurRadius: 8,
                                                        offset:
                                                            const Offset(0, 4),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "${index + 1}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(width: 16),

                                                // Vehicle details
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'Chassis No',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.grey
                                                                  .shade600,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          const Spacer(),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: isCompleted
                                                                  ? Colors.green
                                                                      .shade100
                                                                  : Colors
                                                                      .orange
                                                                      .shade100,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                            ),
                                                            child: Text(
                                                              isCompleted
                                                                  ? 'Completed'
                                                                  : 'Pending',
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: isCompleted
                                                                    ? Colors
                                                                        .green
                                                                        .shade700
                                                                    : Colors
                                                                        .orange
                                                                        .shade700,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        chassis_number ?? '',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .blue.shade700,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        'Engine: ${engine_no ?? 'N/A'}',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors
                                                              .grey.shade600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                const SizedBox(width: 12),

                                                // Action button
                                                ElevatedButton(
                                                  onPressed: () {
                                                    if (isCompleted) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              QCView(
                                                            chasis:
                                                                chassis_number,
                                                            Id: vehicle['id'],
                                                          ),
                                                        ),
                                                      ).then((_) =>
                                                          fetchVehicles());
                                                    } else {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              QCChecklist(
                                                            id: vehicle['id'],
                                                            title:
                                                                chassis_number,
                                                            sku: chassis_number,
                                                          ),
                                                        ),
                                                      ).then((_) =>
                                                          fetchVehicles());
                                                    }
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.white,
                                                    side: BorderSide(
                                                      color: isCompleted
                                                          ? Colors.blue.shade600
                                                          : Colors
                                                              .orange.shade600,
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 20,
                                                        vertical: 12),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    isCompleted
                                                        ? "View"
                                                        : "Inspect",
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Tap overlay
                                          Positioned.fill(
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                onTap: () {
                                                  if (isCompleted) {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) => QCView(
                                                            chasis:
                                                                chassis_number,
                                                            Id: vehicle['id']),
                                                      ),
                                                    ).then(
                                                        (_) => fetchVehicles());
                                                  } else {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            QCChecklist(
                                                          id: vehicle['id'],
                                                          title: chassis_number,
                                                          sku: chassis_number,
                                                        ),
                                                      ),
                                                    ).then(
                                                        (_) => fetchVehicles());
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )),
            ),
            // Enhanced bottom button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Builder(builder: (context) {
                final allChecklistsDone = vehicles.isNotEmpty &&
                    vehicles.every((v) =>
                        v['receiving_checklist_done']
                            ?.toString()
                            .toLowerCase() ==
                        '1');

                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: allChecklistsDone
                          ? [mycolor.withOpacity(0.8), mycolor]
                          : [Colors.grey.shade300, Colors.grey.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: allChecklistsDone
                        ? [
                            BoxShadow(
                              color: mycolor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: allChecklistsDone
                        ? () async {
                            final result = await showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => LotIssueDialogReceiving(
                                lotId: widget.Id,
                                user: user['data']['token'],
                                lotNumber: widget.LotNo,
                              ),
                            );

                            if (result != null) {
                              print("Push to Planning with: $result");
                            }
                          }
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded,
                                        color: Colors.white),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        "Complete all vehicle inspections first",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.orange.shade600,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          allChecklistsDone ? Icons.rocket_launch : Icons.lock,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Push to Planning",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future fetchVehicles() async {
    setState(() {
      loadingText = '';
      isLoading = vehicles.isEmpty ? true : false;
    });
    String url = "${Api.api_url}loadVehicleReceivingLotItems/${widget.Id}";
    print(url);
    ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
    pr.style(
      message: 'Fetching vehicles...',
      borderRadius: 8,
      backgroundColor: Colors.white,
      progressWidget: const SizedBox(
          width: 20,
          height: 20,
          child: Center(child: CircularProgressIndicator())),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
    );

    // pr.show();
    var responsedata = await httpget(url, user['data']["token"], context);
    print("responsedata: $responsedata");
    if (responsedata != null) {
      pr.hide();

      setState(() {
        isLoading = false;
        vehicles = (responsedata["data"]['items'] as List<dynamic>);
      });
    } else {
      pr.hide().whenComplete(() {
        setState(() {
          isLoading = false;
          loadingText = responsedata["message"].toString();
        });
        toasty(context, "${responsedata["message"]}",
            bgColor: Colors.red, textColor: textWhite);
      });
    }
    Future.delayed(const Duration(seconds: dismissseconds), () {
      if (pr.isShowing()) {
        pr.hide();
        setState(() {
          isLoading = false;
          loadingText = internetmessage;
        });
        // ScaffoldMessenger.of(context)
        //     .showSnackBar(snackBar(internetmessage, snackred));
      }
    });
  }
}
// for taking picture

