import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/models/shops.dart';
import 'package:isuze_pqcs/pages/qc_inspection/scanning.dart';
import 'package:isuze_pqcs/widgets/shops.dart';

import 'package:nb_utils/nb_utils.dart';

class Qc_Home extends StatefulWidget {
  const Qc_Home({super.key});

  @override
  State<Qc_Home> createState() => _Qc_HomeState();
}

List<shops> shop = []; // List to hold vehicles fetched from API
final List<Color> colors = [
  Colors.amber.shade900,
  Colors.indigo,
  Colors.teal,
];

class _Qc_HomeState extends State<Qc_Home> {
  var user = {};
  bool isLoading = false;
  String message = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      fetchData();
    });
    fetchData();
  }

  Future<void> fetchData() async {
    print("started");
    setState(() {
      isLoading = true;
    });
    var url = "${Api.api_url}home";
    print(url);

    try {
      var response = await httpget(url, user['data']['token'], context);
      // log(jsonEncode(response['data']['shop']));
      response['data']['shop'].forEach((shop) {
        print(shop['unitmovement'].length);
      });
      if (response == null) {
        print("No Internet");
        // Handle no internet scenario
        return;
      }

      if (response['success'] && response['data'] != null) {
        List<dynamic> responseData = response['data']['shop'];
        // print(response['data']['shop']['unitmovement']);
        List<shops> fetchedVehicles = responseData.map((vehicleData) {
          return shops.fromJson(vehicleData);
        }).toList();

        setState(() {
          shop = fetchedVehicles;
          isLoading = false;
          message = '';
        });
      } else {
        // Handle other scenarios
        setState(() {
          isLoading = false;
          message = '${response['msg']}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        message = 'Network Problem';
      });
      // message = '${"Network Problem"}';
      print('$e');
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: SpeedDial(
      //   animatedIcon: AnimatedIcons.menu_close,
      //   children: [
      //     SpeedDialChild(
      //       child: Icon(Icons.add),
      //       label: 'Add',
      //       onTap: () {
      //         // Add your action here
      //         print('Add button pressed');
      //       },
      //     ),
      //     SpeedDialChild(
      //       child: Icon(Icons.edit),
      //       label: 'Edit',
      //       onTap: () {
      //         // Add your action here
      //         print('Edit button pressed');
      //       },
      //     ),
      //     SpeedDialChild(
      //       child: Icon(Icons.delete),
      //       label: 'Delete',
      //       onTap: () {
      //         // Add your action here
      //         print('Delete button pressed');
      //       },
      //     ),
      //   ],
      // ),

      appBar: AppBar(
        title: Text(
          "Shops",
          style: TextStyle(),
        ),
      ),
      body: Container(
          child: isLoading
              ? Expanded(
                  child: Container(
                    width: double.infinity,
                    child: FacebookLikeShimmer2(),
                  ),
                )
              : message.isNotEmpty
                  ? ErrorMessageWidget(
                      errorMessage: message,
                      onRetry: () {
                        fetchData();
                      },
                    ) // Show message for success or failure
                  : Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              2, // You can adjust the number of columns here
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                          childAspectRatio: 3 /
                              2, // You can adjust the aspect ratio of each grid item
                        ),
                        itemCount: shop.length,
                        itemBuilder: (context, index) {
                          Color categoryColor = colors[index % colors.length];
                          return ShopItems(
                            dividerColor: categoryColor,
                            name: "${shop[index].name}",
                            onTap: () {
                              Scanning(
                                shopId: "${shop[index].id}",
                                shopName: "${shop[index].name}",
                              ).launch(context,
                                  pageRouteAnimation: PageRouteAnimation.Slide);
                            },
                            number: "${shop[index].number}",
                          );
                        },
                      ),
                    )),
    );
  }
}
