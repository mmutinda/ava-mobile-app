import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/pages/qfl3/qflthreeForm.dart';
import 'package:nb_utils/nb_utils.dart';

class QflT {
  final int id;
  final String project_model_Variant;
  final String audit_department;
  final String period;
  final String station_number;
  final String document_ref;
  final String revision;
  final String date;
  final List<Item> items;

  QflT({
    required this.id,
    required this.project_model_Variant,
    required this.audit_department,
    required this.period,
    required this.station_number,
    required this.document_ref,
    required this.revision,
    required this.date,
    required this.items,
  });

  factory QflT.fromJson(Map<String, dynamic> json) {
    return QflT(
      id: json['id'],
      project_model_Variant: json['project_model_Variant'],
      audit_department: json['audit_department'],
      period: json['period'],
      station_number: json['station_number'],
      document_ref: json['document_ref'],
      revision: json['revision'],
      date: DateFormat('dd MMM yyyy, hh:mm a')
          .format(DateTime.parse(json['created_at'])),
      items: (json['items'] as List)
          .map((itemJson) => Item.fromJson(itemJson))
          .toList(),
    );
  }
}

class Item {
  final qfl3_id;
  final category;
  final query_name;
  final rating;
  final resp;
  final comment;

  Item({
    required this.qfl3_id,
    required this.category,
    required this.query_name,
    required this.rating,
    required this.resp,
    required this.comment,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      qfl3_id: json['id'],
      category: json['category'],
      query_name: json['query_name'],
      rating: json['rating'],
      resp: json['resp'],
      comment: json['comment'],
    );
  }
}

class QFLThreeDetails extends StatefulWidget {
  final id;
  final project_model_Variant;
  final audit_line;

  const QFLThreeDetails(
      {super.key,
      required this.id,
      required this.project_model_Variant,
      required this.audit_line});

  @override
  State<QFLThreeDetails> createState() => _QFLThreeDetailsState();
}

class _QFLThreeDetailsState extends State<QFLThreeDetails> {
  Future<List<QflT>>? futureRecords;
  var user = {};
  @override
  void initState() {
    super.initState();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      futureRecords = fetchNearMissRecords();
    });
  }

  Future<List<QflT>> fetchNearMissRecords() async {
    final response = await http.get(
      headers: {
        'Authorization': 'Bearer ${user['data']['token']}',
        'Accept': 'application/json',
      },
      Uri.parse('${Api.api_url}editqfl3/${widget.id}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      // final List<dynamic> records = data['data'];
      // return records.map((json) => QflT.fromJson(json)).toList();
      // Since the response contains a single object, not a list:
      final Map<String, dynamic> record = data['data'];

      return [QflT.fromJson(record)]; // Wrap it in a list
    } else {
      throw Exception('Failed to load  records');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        onPressed: () {
          AuditChecklistPage()
              .launch(context, pageRouteAnimation: PageRouteAnimation.Slide)
              .then((result) {
            setState(() {
              futureRecords = fetchNearMissRecords();
            });
          });
          ;
        },
        backgroundColor: mycolor,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
          title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('QFL 3 Details',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text('Model: ${widget.project_model_Variant}',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)),
          Text('Audit Line: ${widget.audit_line}',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white)),
        ],
      )),
      body: Container(
        // decoration: const BoxDecoration(
        //   gradient: LinearGradient(
        //     begin: Alignment.topLeft,
        //     end: Alignment.bottomRight,
        //     colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
        //   ),
        // ),
        child: FutureBuilder<List<QflT>>(
          future: futureRecords,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CustomLoader(),
              );
            } else if (snapshot.hasError) {
              return ErrorMessageWidget(
                errorMessage: "${snapshot.error}",
                onRetry: () {
                  setState(() {
                    futureRecords = fetchNearMissRecords();
                  });
                },
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No records found.',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              );
            }

            final records = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoTile(
                          Icons.refresh,
                          'Revision',
                          records[0].revision,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoTile(Icons.description,
                            'Document Reference', records[0].document_ref),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoTile(Icons.folder_special,
                            'station_number', records[0].station_number),
                      ),
                      Expanded(
                        child: _buildInfoTile(
                            Icons.person, 'period', records[0].period),
                      ),
                    ],
                  ),

                  // Text('Items:',
                  //     style: GoogleFonts.poppins(
                  //         fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  ...records[0].items.map((item) => Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 1,
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: const Icon(Icons.inventory, color: mycolor),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(item.category,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: mycolor,
                                    )),
                              ),
                              Spacer(),
                              Expanded(
                                child: Text(item.resp,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: mycolor,
                                    )),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.query_name,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${item.comment ?? 'No comments'}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: mycolor,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 20),
                              Text('${item.rating}',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: mycolor, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
