import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class TTMSDefectsPage extends StatefulWidget {
  const TTMSDefectsPage({
    super.key,
  });
  @override
  _TTMSDefectsPageState createState() => _TTMSDefectsPageState();
}

class _TTMSDefectsPageState extends State<TTMSDefectsPage> {
  String term = '';
  List<dynamic> data = []; // Define your data list
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
    var url = "${Api.api_url}loadqcosactions";

    try {
      var response = await httpget(url, user['data']['token'], context);
      log(jsonEncode(response));
      if (response == null) {
        print("No Internet");
        // Handle no internet scenario
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
                    ) // Show message for success or failure
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
                              title: Text(
                                '${data[index]['date_open']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[900],
                                ),
                              ),
                              subtitle: Text(
                                '${data[index]['problem']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  // color: Colors.amber[900],
                                ),
                              ),
                              children: [
                                ListTile(
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Item: ${data[index]['item']}'),
                                      // Text(
                                      //     'Problem: ${data[index]['problem']}'),
                                      Text('Action: ${data[index]['action']}'),
                                      Text(
                                          'Responsible: ${data[index]['responsible']}'),
                                    ],
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: () {
                                       QuickAlert.show(
                            confirmBtnColor: mycolor,
                            confirmBtnTextStyle:
                                TextStyle(fontWeight: FontWeight.bold),
                            context: context,
                            type: QuickAlertType.info,
                            title: 'Module Under Construction!!');
                                    },
                                    child: Text('Resolve'),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
        ],
      ),
    );
  }
}
