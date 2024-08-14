import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/models/qc_inpection.dart';
import 'package:isuze_pqcs/pages/QCA_home.dart/record.dart';
import 'package:nb_utils/nb_utils.dart';

class CheckList extends StatefulWidget {
  final gcaType;
  final stepId;
  final vehicle_id;
  final CategoryId;
  final query_group_name;
  const CheckList(
      {super.key,
      this.gcaType,
      this.stepId,
      this.vehicle_id,
      this.CategoryId,
      required this.query_group_name});
  @override
  _CheckListState createState() => _CheckListState();
}

class _CheckListState extends State<CheckList> {
  final List<Color> colors = [
    Colors.amber.shade900,
    Colors.indigo,
    Colors.teal,
  ];
  List<AuditsHome> vehicles = []; // List to hold vehicles fetched from API
  var user = {};
  var dataQueries;
  var dataAudit;
  bool isLoading = false;
  String message = '';
  var data;

  @override
  void initState() {
    super.initState();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      fetchData();
    });
    // fetchData(); // Fetch data when the page is initialized
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    var url =
        "${Api.api_url}loadgcaquery/${widget.stepId}/${widget.CategoryId}/${widget.vehicle_id}/${widget.gcaType}";
    print(url);

    try {
      var response = await httpget(url, user['data']['token'], context);

      // print(response['data']);
      if (response == null) {
        print("No Internet");
        // Handle no internet scenario
        return;
      }

      if (response['success'] && response['data'] != null) {
        setState(() {
          data = response['data'];
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

  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // print(widget.query_group_name);
    return Scaffold(
      body: data == null
          ? Center(
              child: Container(
                width: double.infinity,
                child: FacebookLikeShimmer(),
              ),
            )
          : message.isNotEmpty
              ? ErrorMessageWidget(
                  errorMessage: message,
                  onRetry: () {
                    fetchData();
                  },
                ) // Show message for success or failure
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          // ignore: unused_local_variable
                          Color categoryColor = colors[index % colors.length];
                          var get = data[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.all(0),
                                    leading: CircleAvatar(
                                        child: Text(
                                      "${index + 1}",
                                    )),
                                    title: Text(
                                      "${get['defect_name']}",
                                      style: TextStyle(
                                          color: mycolor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "${get['defect_condition'] ?? 'No Defect Condition'}"),
                                        Text("${get['phenomenon'] ?? ''}"),
                                      ],
                                    ),
                                    trailing: get['gca_answer'].length == 0
                                        ? Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: categoryColor),
                                                borderRadius: BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(10))),
                                            child: TextButton(
                                              onPressed: () {
                                                showInDialog(context,
                                                        builder: (context) =>
                                                            RecordAnswer(
                                                              gcaType: widget
                                                                  .gcaType,
                                                              query_group_name:
                                                                  widget
                                                                      .query_group_name,
                                                              CategoryId: widget
                                                                  .CategoryId,
                                                              stepId:
                                                                  widget.stepId,
                                                              vehicle_id: widget
                                                                  .vehicle_id,
                                                            ),
                                                        dialogAnimation:
                                                            DialogAnimation
                                                                .SCALE)
                                                    .then((value) {
                                                  fetchData();
                                                  setState(() {});
                                                });
                                              },
                                              child: Text(
                                                "Record",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ))
                                        : Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: categoryColor),
                                                borderRadius: BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(10))),
                                            child: TextButton(
                                              onPressed: () {},
                                              child: Text(
                                                "Audited",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )),
                                  )
                                ],
                              ),
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
