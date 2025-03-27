import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/models/shops.dart';
import 'package:isuze_pqcs/pages/qc_inspection/scanning.dart';
import 'package:isuze_pqcs/widgets/shops.dart';

import 'package:nb_utils/nb_utils.dart';

class ShopsScrean extends StatefulWidget {
  const ShopsScrean({super.key});

  @override
  State<ShopsScrean> createState() => _ShopsScreanState();
}

List<shops> shop = []; // List to hold vehicles fetched from API
final List<Color> colors = [
  Colors.amber.shade900,
  Colors.indigo,
  Colors.teal,
];

class _ShopsScreanState extends State<ShopsScrean> {
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
    setState(() {
      isLoading = true;
    });
    EasyLoading.show(
        status: "Loading Shops...", maskType: EasyLoadingMaskType.black);

    var url = "${Api.api_url}home";
    print("API URL: $url");

    try {
      var response = await httpget(url, user['data']['token'], context);

      if (response == null) {
        print("No Internet Connection");
        setState(() {
          isLoading = false;
          message = "No Internet Connection";
        });
        EasyLoading.dismiss();
        return;
      }

      if (response['success'] && response['data'] != null) {
        List<dynamic> responseData = response['data']['shop'];

        List<shops> fetchedShops = responseData.map((shopData) {
          return shops.fromJson(shopData);
        }).toList();

        setState(() {
          shop = fetchedShops;
          isLoading = false;
          message = '';
        });
        EasyLoading.dismiss();
      } else {
        setState(() {
          isLoading = false;

          message = response['msg'] ?? "Failed to fetch data";
        });
        EasyLoading.dismiss();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        message = "Network Problem";
      });
      EasyLoading.dismiss();
      print("Error fetching data: $e");
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shops"),
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
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Number of columns
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 3 / 2, // Grid item aspect ratio
                    ),
                    itemCount: shop.length,
                    itemBuilder: (context, index) {
                      Color categoryColor = colors[index % colors.length];
                      return ShopItems(
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
