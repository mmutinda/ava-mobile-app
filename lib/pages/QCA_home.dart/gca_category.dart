import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/models/qc_inpection.dart';
import 'package:isuze_pqcs/pages/QCA_home.dart/ReportPage.dart';
import 'package:nb_utils/nb_utils.dart';

class Gca_ReportCategory extends StatefulWidget {
  final stepId;
  final step_name;
  final gca_type;
  final vehicle_id;
  final vinNo;
  final modelName;
  const Gca_ReportCategory(
      {super.key,
      required this.stepId,
      required this.step_name,
      this.gca_type,
      this.vehicle_id,
      required this.vinNo,
      required this.modelName});

  @override
  _Gca_ReportCategoryState createState() => _Gca_ReportCategoryState();
}

class _Gca_ReportCategoryState extends State<Gca_ReportCategory> {
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
        "${Api.api_url}loadgcacategory/${widget.stepId}/${widget.gca_type}/${widget.vehicle_id}";
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
        List<dynamic> responseData = response['data'];
        setState(() {
          // vehicles = fetchdata;
          isLoading = false;
          data = responseData;
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
    // print(dataQueries);
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
        title: _isSearching ? _buildSearchField() : Text("Category"),
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
                          var querycategories = get['querycategories'];
                          // var categoryId=querycategories['id']
                          // print(categoryId)
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: mycolor.withOpacity(0.2),
                                  ),
                                  child: Text(
                                    "${get['query_group_name']}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17),
                                  ),
                                ),
                              ),
                              // Divider(),
                              if (querycategories != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(
                                      querycategories.length, (index) {
                                    var get2 = querycategories[index];
                                    var categoryanswer =
                                        get2['categoryanswer'].length;

                                    // print(get2['id']);
                                    return Card(
                                      child: ListTile(
                                        onTap: () {
                                          ReportPage(
                                            query_group_name:
                                                get['query_group_name'],
                                            categoryId: get2['id'],
                                            modelName: widget.modelName,
                                            vehicle_id: widget.vehicle_id,
                                            vinNo: widget.vinNo,
                                            stepId: widget.stepId,
                                            // modelName: vehicles[index].title,
                                            gcaType: widget.gca_type,
                                            // vinNo: widget.vehicleId,
                                          ).launch(context,
                                              pageRouteAnimation:
                                                  PageRouteAnimation.Fade);
                                        },
                                        leading: CircleAvatar(
                                          child: Text("${index + 1}"),
                                        ),
                                        title: Text(get2['name']),
                                        subtitle: categoryanswer == 0
                                            ? Text(
                                                "No item Answered",
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              )
                                            : categoryanswer == 1
                                                ? Text(
                                                    "$categoryanswer item  Answered",
                                                    style: TextStyle(
                                                        color: Colors.grey),
                                                  )
                                                : Text(
                                                    "$categoryanswer items  Answered",
                                                    style: TextStyle(
                                                        color: Colors.grey),
                                                  ),
                                      ),
                                    );
                                  }),
                                ),
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
