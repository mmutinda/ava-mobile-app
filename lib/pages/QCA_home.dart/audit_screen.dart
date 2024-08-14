import 'dart:convert';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/models/qc_inpection.dart';
import 'package:isuze_pqcs/pages/QCA_home.dart/gca_category.dart';
import 'package:nb_utils/nb_utils.dart';

class AuditScreen extends StatefulWidget {
  final vinNo;
  final modelName;
  final vehicleId;
  final gca_type;

  const AuditScreen(
      {super.key, this.vinNo, this.modelName, this.vehicleId, this.gca_type});
  @override
  _AuditScreenState createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
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
        "${Api.api_url}loadGcaSteps/${widget.gca_type}/${widget.vehicleId}";

    try {
      var response = await httpget(url, user['data']['token'], context);

      // print(response['data']);
      if (response == null) {
        print("No Internet");
        // Handle no internet scenario
        return;
      }

      if (response['success'] && response['data'] != null) {
        List<dynamic> responseData = response['data'];
        log(responseData);
        List<AuditsHome> fetchdata = responseData.map((vehicleData) {
          return AuditsHome.fromJson(vehicleData);
        }).toList();

        setState(() {
          vehicles = fetchdata;
          isLoading = false;
          // dataQueries = response['data']['queries'];
          // dataAudit = response['data']['auditdone'];
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
  String searchText = '';
  bool _isSearching = false;
  @override
  Widget build(BuildContext context) {
    // print(user['data']['token']);
    print(dataQueries);
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
            hintText: 'search...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: _isSearching
            ? _buildSearchField()
            : Column(
                children: [
                  Text('${widget.modelName}'),
                  Text('${widget.vinNo}'),
                ],
              ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                //   setState(() {
                //     _isSearching = !_isSearching;
                //     if (!_isSearching) {
                //       searchController.clear();
                //       searchText = '';
                //     }
                //   });
                fetchData();
              },
            ),
          ),
        ],
      ),
      body: isLoading
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
                        itemCount: vehicles.length,
                        itemBuilder: (context, index) {
                          // ignore: unused_local_variable
                          Color categoryColor = colors[index % colors.length];
                          var vin = vehicles[index].audit_time;
                          var model = vehicles[index].description;
                          var queries = vehicles[index].queries.length;

                          var auditdone = vehicles[index].auditdone.length;

                          // print(que);
                          if (searchText.isNotEmpty &&
                              !(vin
                                      .toLowerCase()
                                      .contains(searchText.toLowerCase()) ||
                                  model
                                      .toLowerCase()
                                      .contains(searchText.toLowerCase()))) {
                            return Container(); // Return an empty container if not matching
                          }
                          return Column(
                            children: [
                              SizedBox(height: 5),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: boxDecoration(
                                  radius: 10,
                                  showShadow: true,
                                  bgColor: Colors.white,
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(0),
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        Color.fromARGB(255, 168, 88, 32),
                                    foregroundColor: Colors.white,
                                    child: Text("${index + 1}"),
                                  ),
                                  title: Text(
                                    vehicles[index].title,
                                    style: TextStyle(
                                        color: Colors.amber[900],
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Audit time: ${vehicles[index].audit_time}'),
                                      HtmlWidget(
                                          '${vehicles[index].description}'),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: BubbleSpecialThree(
                                              text:
                                                  "$auditdone/$queries Defects",
                                              color: Colors.green,
                                              tail: true,
                                              isSender: false,
                                              textStyle: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          Spacer(),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: categoryColor),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  10))),
                                              child: TextButton(
                                                  onPressed: () {
                                                    Gca_ReportCategory(
                                                      modelName:
                                                          widget.modelName,
                                                      vinNo: widget.vinNo,
                                                      stepId:
                                                          vehicles[index].id,
                                                      step_name:
                                                          vehicles[index].title,
                                                      gca_type: widget.gca_type,
                                                      vehicle_id:
                                                          widget.vehicleId,
                                                    ).launch(context,
                                                        pageRouteAnimation:
                                                            PageRouteAnimation
                                                                .Fade);
                                                  },
                                                  child: Text("Audit")),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  onTap: () {
                                    // Navigate to vehicle details page passing the selected vehicle
                                  },
                                ),
                              ),
                              SizedBox(height: 10),
                            ],
                          );
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 168, 88, 32),
                              foregroundColor: Colors.white),
                          onPressed: () {},
                          child: Text("Complete Audit")),
                    )
                  ],
                ),
    );
  }
}

BoxDecoration boxDecoration(
    {double radius = 2,
    Color color = Colors.transparent,
    Color? bgColor,
    var showShadow = false}) {
  return BoxDecoration(
    color: bgColor,
    boxShadow: showShadow
        ? defaultBoxShadow(shadowColor: shadowColorGlobal)
        : [const BoxShadow(color: Colors.transparent)],
    border: Border.all(color: color),
    borderRadius: BorderRadius.all(Radius.circular(radius)),
  );
}
