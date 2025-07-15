import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/pages/QFL%204/QFL4_form.dart';
import 'package:isuze_pqcs/pages/QFL%204/qflview.dart';

class QFL4_View extends StatefulWidget {
  final dynamic vehicleId;
  final dynamic modelId;

  const QFL4_View({super.key, required this.vehicleId, required this.modelId});

  @override
  State<QFL4_View> createState() => _QFL4_ViewState();
}

class _QFL4_ViewState extends State<QFL4_View> {
  bool isLoading2 = false;
  Map<String, dynamic> user = {};
  List<dynamic> shops = [];
  List<dynamic> data = [];
  List<String> issues = [""];
  bool isLoading = true;
  String errorText = '';

  @override
  void initState() {
    super.initState();
    loadDataLists();
  }

// sheduledunits
  Future<void> loadUserAndShops() async {
    setState(() => isLoading = true);
    try {
      final userData = await getuserdata();
      user = jsonDecode(userData);
      final response = await fetchShops();

      if (response != null && response["data"]["shop"] != null) {
        shops = response["data"]["shop"];
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

  Future<Map<String, dynamic>?> fetchScheduledVehicles() async {
    String url = Api.api_url +
        "loadQfl4/${widget.vehicleId}"; // Replace with correct path

    return await httpget(url, user['data']['token'], context);
  }

  Future<void> loadDataLists() async {
    setState(() {
      isLoading = true;
      errorText = '';
    });

    try {
      final userData = await getuserdata();
      user = jsonDecode(userData);
    } catch (e) {
      setState(() {
        isLoading = false;
        errorText = "Failed to load user data: $e";
      });
      return;
    }

    try {
      // Parallel fetch
      final results = await Future.wait([
        fetchShops().catchError((e) {
          errorText += "Error loading shops: $e\n";
          return null;
        }),
        fetchScheduledVehicles().catchError((e) {
          errorText += "Error loading vehicles: $e\n";
          return null;
        }),
      ]);

      final shopResponse = results[0];
      final vehicleResponse = results[1];
      print(shopResponse);
      print(vehicleResponse);

      if (shopResponse != null && shopResponse["data"]["shop"] != null) {
        shops = shopResponse["data"]["shop"];
      } else {
        errorText += "Shop data missing.\n";
      }

      if (vehicleResponse != null && vehicleResponse["data"] != null) {
        data = vehicleResponse["data"];
      } else {
        errorText += "Vehicle data missing.\n";
      }
    } catch (e) {
      errorText += "Unexpected error: $e\n";
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: shops.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    fullscreenDialog: true, // ✅ This works here
                    builder: (context) => QFL4_form(
                      vehicleId: widget.vehicleId,
                      modelId: widget.modelId,
                      shops: shops,
                    ),
                  ),
                ).then((value) {
                  if (value != null) {
                    loadDataLists();
                  }
                });
              },
              child: Icon(Icons.add),
            )
          : null,
      appBar: AppBar(
        title: const Text('QFL 4 View'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(5),
              child: errorText.isNotEmpty
                  ? ErrorMessageWidget(
                      errorMessage: errorText, onRetry: loadUserAndShops)
                  : QFLIssuesPage(
                      issues: data.cast<Map<String, dynamic>>(),
                    )),
    );
  }
}
