import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class GCADefectsPage extends StatefulWidget {
  const GCADefectsPage({
    super.key,
  });
  @override
  _GCADefectsPageState createState() => _GCADefectsPageState();
}

class _GCADefectsPageState extends State<GCADefectsPage> {
  String term = '';
  List<dynamic> data = [];
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
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    var url = "${Api.api_url}loadgcaasactions";

    try {
      var response = await httpget(url, user['data']['token'], context);
      log(jsonEncode(response));
      if (response == null) {
        print("No Internet");
        return;
      }

      if (response['success'] && response['data'] != null) {
        var responseData = response['data'];

        setState(() {
          data = responseData;
          isLoading = false;
          message = '';
        });
      } else {
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
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Qcos Action List'),
      ),
      body: Column(
        children: [
          isLoading
              ? Expanded(
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      child: FacebookLikeShimmer(),
                    ),
                  ),
                )
              : message.isNotEmpty
                  ? Expanded(
                      child: ErrorMessageWidget(
                        errorMessage: message,
                        onRetry: () {
                          fetchData();
                        },
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return Card(
                            child: ExpansionTile(
                          iconColor: mycolor,
                          collapsedShape: RoundedRectangleBorder(
                            side: BorderSide.none,
                          ),
                          shape: RoundedRectangleBorder(
                            side: BorderSide.none,
                          ),
                          leading: CircleAvatar(
                            child: Text("${index + 1}"),
                          ),
                          title: Text(
                            '${data[index]['vehicle']['vin_no']}',
                            style: TextStyle(
                                color: Colors.amber[900],
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Lot ${data[index]['vehicle']['lot_no']} Job ${data[index]['vehicle']['job_no']}'),
                              Text(
                                '${data[index]['shop']['shop_name']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {},
                            child: Text('Resolve'),
                          ),
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${data[index]['defect']}',
                                          style: TextStyle(
                                              color: Colors.amber[900],
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                          'Vehicle Type: ${data[index]['vehicle_type']}'),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                          'Shop: ${data[index]['shop']['shop_name']}'),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                          'Category: ${data[index]['audit_category']['name']}'),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                          'UPC/FNA/Sheet No: ${data[index]['gca_manual_reference']}'),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                          'Count: ${data[index]['defect_count']}'),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('Weight: ${data[index]['weight']}'),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                          'Responsible: ${data[index]['responsible_team_leader']}'),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ));
                      },
                    ))
        ],
      ),
    );
  }
}
