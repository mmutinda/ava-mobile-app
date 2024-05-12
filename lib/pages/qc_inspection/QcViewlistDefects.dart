import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/pages/qc_inspection/correctDefect.dart';
import 'package:nb_utils/nb_utils.dart';

class QCDefectsPage extends StatefulWidget {
  final vehileId;

  const QCDefectsPage({super.key, required this.vehileId});
  @override
  _QCDefectsPageState createState() => _QCDefectsPageState();
}

class _QCDefectsPageState extends State<QCDefectsPage> {
  String term = '';
  List<dynamic> data = []; // Define your data list
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
    var url = "${Api.api_url}qdefects/${widget.vehileId}";
    // print(url);

    try {
      var response = await httpget(url, user['data']['token'], context);
      // log(jsonEncode(response));
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
        title: Text('Defects List'),
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
                        // shrinkWrap: false,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          Color categoryColor = colors[index % colors.length];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text("${index + 1}"),
                              ),
                              title: RichText(
                                text: TextSpan(
                                  text:
                                      '${data[index]['getqueries']['query_name']}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text:
                                          ' - (${data[index]['defect_name']})',
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ),
                              subtitle: Text(
                                '(${data[index]['qshops']['shop_name']})',
                                style: TextStyle(
                                  color: Colors.amber[900],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: categoryColor),
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(10))),
                                  child: TextButton(
                                    onPressed: () {
                                      showInDialog(context,
                                              builder: (context) =>
                                                  CorrectDefect(
                                                      vehicle_id: data[index]
                                                          ['id']),
                                              dialogAnimation:
                                                  DialogAnimation.SCALE)
                                          .then((value) {
                                        fetchData();
                                        setState(() {});
                                      });
                                    },
                                    child: Text(
                                      "CORRECT",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )),
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
