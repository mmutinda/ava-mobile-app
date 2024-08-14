import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';

class Notes extends StatefulWidget {
  // final String vinNo;
  // final String modelName;
  final gcaType;
  final stepId;
  // final Map<String, dynamic> data;

  Notes({
    // required this.vinNo,
    // required this.modelName,
    required this.gcaType,
    required this.stepId,
    // required this.data,
  });

  @override
  _NotesState createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  bool isLoading = false;
  String message = '';
  var user = {};
  var data;
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
    var url = "${Api.api_url}loadZoneItems/${widget.stepId}/${widget.gcaType}";
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
        // List<dynamic> responseData = response['data'];
        setState(() {
          isLoading = false;
          data = response['data'];
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
      body: SingleChildScrollView(
        child: data == null
            ? Center(
                child: Container(
                  width: double.infinity,
                  child: SizedBox(
                    height: 200,
                    child: FacebookLikeShimmer(),
                  ),
                ),
              )
            : message.isNotEmpty
                ? ErrorMessageWidget(
                    errorMessage: message,
                    onRetry: () {
                      fetchData();
                    },
                  ) // Show message for success or failure
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: widget.gcaType == 'CV'
                        ? _buildCvContent()
                        : _buildLcvContent(),
                  ),
      ),
    );
  }

  Widget _buildCvContent() {
    return Card(
      child: Column(
        children: [
          if (widget.stepId == '4') _buildTable(),
          if (['5', '6', '7', '8', '9'].contains(widget.stepId))
            HtmlWidget(
              data['note'] ?? '',
            )
        ],
      ),
    );
  }

  Widget _buildLcvContent() {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text('Note'),
          ),
          if (['4', '5', '6', '7', '8', '9'].contains(widget.stepId))
            HtmlWidget(
              data['note'],
            )
        ],
      ),
    );
  }

  Widget _buildTable() {
    final zoneItems = data['zoneitems'] as List<dynamic>?;
    if (zoneItems == null) return Container();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Zone')),
          DataColumn(label: Text('Definition')),
          DataColumn(label: Text('Applicable Portion')),
        ],
        rows: zoneItems.map((item) {
          final isEven = zoneItems.indexOf(item) % 2 == 0;
          return DataRow(
            cells: [
              DataCell(Text(item['zone'] ?? '')),
              DataCell(Text(item['defination'] ?? '')),
              DataCell(Text(item['applicable_portion'] ?? '')),
            ],
            color: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  return Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.08);
                }
                return isEven ? mycolor.withOpacity(0.1) : null;
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
