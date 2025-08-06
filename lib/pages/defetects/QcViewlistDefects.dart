import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/pages/qc_inspection/correctDefect.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DefectsPage extends StatefulWidget {
  final vehileId;

  const DefectsPage({super.key, required this.vehileId});
  @override
  _DefectsPageState createState() => _DefectsPageState();
}

class _DefectsPageState extends State<DefectsPage> {
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
      isLoading = data.isEmpty ? true : false;
    });
    var url = "${Api.api_url}qdefects/${widget.vehileId}";
    print(url);

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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Defects List',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              fetchData();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          isLoading
              ? Expanded(
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomLoader(),
                          SizedBox(height: 16),
                          Text(
                            'Loading defects...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
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
                      child: ListView.separated(
                        padding: EdgeInsets.all(16),
                        itemCount: data.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return Card(
                            color: Colors.white,
                            elevation: 4,
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey[200]!,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: Colors.red[600],
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "${index + 1}",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          '${data[index]['getqueryanswer']['answer']} - ${data[index]['defect_name']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[800],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (data[index]['getqueryanswer']
                                                  ['defect_description'] !=
                                              null &&
                                          data[index]['getqueryanswer']
                                                  ['defect_description']
                                              .toString()
                                              .isNotEmpty)
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(12),
                                          margin: EdgeInsets.only(bottom: 12),
                                          decoration: BoxDecoration(
                                            // color: Colors.orange[50],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.orange[200]!,
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.description,
                                                    size: 16,
                                                    color: Colors.orange[700],
                                                  ),
                                                  SizedBox(width: 6),
                                                  Text(
                                                    'Description',
                                                    style: TextStyle(
                                                      color: Colors.orange[700],
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 6),
                                              Text(
                                                '${data[index]['getqueryanswer']['defect_description']}',
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          // color: Colors.blue[50],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.blue[200]!,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.store,
                                              size: 16,
                                              color: Colors.blue[700],
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                '${data[index]['qshops']['shop_name']}',
                                                style: TextStyle(
                                                  color: Colors.blue[700],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Image display section
                                      if (data[index]['getqueryanswer']
                                                  ['icon'] !=
                                              null &&
                                          data[index]['getqueryanswer']['icon']
                                              .toString()
                                              .isNotEmpty)
                                        Container(
                                          margin: EdgeInsets.only(top: 12),
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.grey[200]!,
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft: Radius.circular(8),
                                                    topRight:
                                                        Radius.circular(8),
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.image,
                                                      size: 16,
                                                      color: Colors.grey[600],
                                                    ),
                                                    SizedBox(width: 6),
                                                    Text(
                                                      'Defect Image',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              ClipRRect(
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(8),
                                                  bottomRight:
                                                      Radius.circular(8),
                                                ),
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      '${Api.qc_image}${data[index]['getqueryanswer']['icon']}',
                                                  width: double.infinity,
                                                  height: 200,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      Container(
                                                    height: 200,
                                                    width: double.infinity,
                                                    color: Colors.grey[100],
                                                    child: Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.grey[400],
                                                      ),
                                                    ),
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Container(
                                                    height: 100,
                                                    width: double.infinity,
                                                    color: Colors.grey[100],
                                                    child: Center(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.broken_image,
                                                            color: Colors
                                                                .grey[400],
                                                            size: 32,
                                                          ),
                                                          SizedBox(height: 4),
                                                          Text(
                                                            'Image not available',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .grey[500],
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 36,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            showInDialog(context,
                                                    builder: (context) =>
                                                        CorrectDefect(
                                                            vehicle_id:
                                                                data[index]
                                                                    ['id']),
                                                    dialogAnimation:
                                                        DialogAnimation.SCALE)
                                                .then((value) {
                                              fetchData();
                                              setState(() {});
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor: Colors.green,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text(
                                            "CORRECT",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
