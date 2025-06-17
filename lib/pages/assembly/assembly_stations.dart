import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/models/shops.dart';
import 'package:isuze_pqcs/pages/qc_inspection/scanning.dart';
import 'package:isuze_pqcs/services/sqlite_db_helper.dart';
import 'package:isuze_pqcs/widgets/shops.dart';

import 'package:nb_utils/nb_utils.dart';

class AssemblyStations extends StatefulWidget {
  const AssemblyStations({super.key});

  @override
  State<AssemblyStations> createState() => _AssemblyStationsState();
}

List<shops> shop = []; // List to hold vehicles fetched from API
final List<Color> colors = [
  Colors.amber.shade900,
  Colors.indigo,
  Colors.teal,
];

class _AssemblyStationsState extends State<AssemblyStations> {
  var user = {};
  bool isLoading = false;
  String message = '';

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
    // setState(() {
    //   isLoading = true;
    // });
    // Step 1: Load from SQLite first
    List<shops> cachedShops = await DBHelper.getCachedShops();
    EasyLoading.show(
      status: "Loading Shops...",
      maskType: EasyLoadingMaskType.black,
    );

    if (cachedShops.isNotEmpty) {
      setState(() {
        shop = cachedShops;
        message = '';
      });
      EasyLoading.dismiss(); // Always dismiss loader
    }

    var url = "${Api.api_url}home";
    print(url);
    try {
      var response = await httpget(url, user['data']['token'], context);

      if (response != null && response['success'] && response['data'] != null) {
        List<dynamic> responseData = response['data']['shop'];
        List<shops> fetchedShops = responseData.map((shopData) {
          return shops.fromJson(shopData);
        }).toList();

        if (fetchedShops.isNotEmpty) {
          setState(() {
            shop = fetchedShops;
            message = '';
          });
          await DBHelper.insertShops(fetchedShops); // Update SQLite
        } else {
          setState(() {
            message = "No Shops Found";
          });
        }
        EasyLoading.dismiss(); // Always dismiss loader
      } else {
        setState(() {
          message = response['msg'] ?? "Failed to fetch data";
        });
        EasyLoading.dismiss(); // Always dismiss loader
      }
    } catch (e) {
      EasyLoading.dismiss(); // Always dismiss loaders
      print("Error fetching data: $e");
      if (cachedShops.isEmpty) {
        setState(() {
          message = "Network Problem";
        });
      }
    }
  }

  @override
  void dispose() {
    if (isLoading) {
      EasyLoading.dismiss(); // Dismiss loading when navigating away
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print(shop);
    return Scaffold(
      appBar: AppBar(
        title:
            Text("All Stations", style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: isLoading
            ? Center(child: SizedBox.shrink()) // Keep an empty widget
            : message.isNotEmpty
                ? ErrorMessageWidget(
                    errorMessage: message,
                    onRetry: fetchData,
                  )
                : ListView.builder(
                    itemCount: shop.length,
                    itemBuilder: (context, index) {
                      Color categoryColor = colors[index % colors.length];
                      return StationsItems(
                        index: index + 1,
                        dividerColor: categoryColor,
                        name: shop[index].name,
                        onTap: () {
                          Scanning(
                            shopId: shop[index].id,
                            shopName: shop[index].name,
                          ).launch(
                            context,
                            pageRouteAnimation: PageRouteAnimation.Slide,
                          );
                        },
                        number: shop[index].number,
                      );
                    },
                  ),
      ),
    );
  }
}
