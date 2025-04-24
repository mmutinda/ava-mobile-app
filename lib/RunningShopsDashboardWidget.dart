import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/models/shops.dart';
import 'package:isuze_pqcs/services/sqlite_db_helper.dart';
import 'package:isuze_pqcs/widgets/shops.dart';
import 'package:nb_utils/nb_utils.dart';

class RunningShopsDashboardWidget extends StatefulWidget {
  const RunningShopsDashboardWidget({super.key});

  @override
  State<RunningShopsDashboardWidget> createState() =>
      _RunningShopsDashboardWidgetState();
}

class _RunningShopsDashboardWidgetState
    extends State<RunningShopsDashboardWidget> {
  List<shops> runningShops = [];
  var user = {};
  bool isLoading = false;
  String message = '';
  final List<Color> colors = [
    Colors.amber.shade900,
    Colors.indigo,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      fetchShops();
    });
  }

  Future<void> fetchShops() async {
    // EasyLoading.show(status: "Loading Shops...");
    setState(() {
      isLoading = true;
      message = '';
    });
    try {
      final cachedShops = await DBHelper.getCachedShops();
      if (cachedShops.isNotEmpty) {
        filterRunningShops(cachedShops);
        setState(() {
          isLoading = false;
          message = '';
        });
      }

      final url = "${Api.api_url}home";
      final response = await httpget(url, user['data']['token'], context);

      if (response != null && response['success']) {
        List<shops> fetched = (response['data']['shop'] as List)
            .map((e) => shops.fromJson(e))
            .toList();

        await DBHelper.insertShops(fetched);
        filterRunningShops(fetched);
        setState(() {
          isLoading = false;
        });
      } else {
        message = response?['msg'] ?? 'Failed to load data';
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      message = "Network Error";
      print("Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
      EasyLoading.dismiss();
      setState(() {});
    }
  }

  void filterRunningShops(List<shops> allShops) {
    runningShops =
        allShops.where((s) => double.tryParse(s.number)! > 0).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (message.isNotEmpty) {
      // return Text(message, style: TextStyle(color: Colors.red));
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                message,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  fetchShops();
                },
              ),
            ],
          ),
        ],
      );
    }

    if (runningShops.isEmpty) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "No running shops",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  fetchShops();
                },
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              "Shops with Running Units",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                fetchShops();
              },
            ),
          ],
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            // shrinkWrap: true,
            // physics: NeverScrollableScrollPhysics(),
            itemCount: runningShops.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 3 / 2, // Grid item aspect ratio
            ),
            itemBuilder: (_, index) {
              final shop = runningShops[index];
              final color = colors[index % colors.length];
              return ShopItems(
                name: shop.name,
                number: shop.number,
                dividerColor: color,
                onTap: () {},
              );
            },
          ),
        ),
      ],
    );
  }
}
