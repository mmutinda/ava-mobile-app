import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/pages/qfl3/qfl3_deatils.dart';
import 'package:isuze_pqcs/pages/qfl3/qflthreeForm.dart';
import 'package:isuze_pqcs/pages/qfl3/qflthreeFormAdd.dart';
import 'package:nb_utils/nb_utils.dart';

class QflT {
  final int id;
  final String project_model_Variant;
  final String audit_department;
  final String period;
  final String station_number;
  final String document_ref;
  final String date;

  QflT({
    required this.id,
    required this.project_model_Variant,
    required this.audit_department,
    required this.period,
    required this.station_number,
    required this.document_ref,
    required this.date,
  });

  factory QflT.fromJson(Map<String, dynamic> json) {
    return QflT(
      id: json['id'],
      project_model_Variant: json['project_model_Variant'],
      audit_department: json['audit_department'],
      period: json['period'],
      station_number: json['station_number'],
      document_ref: json['document_ref'],
      date: DateFormat('dd MMM yyyy, hh:mm a')
          .format(DateTime.parse(json['created_at'])),
    );
  }
}

class QFLThreeList extends StatefulWidget {
  const QFLThreeList({super.key});

  @override
  State<QFLThreeList> createState() => _QFLThreeListState();
}

class _QFLThreeListState extends State<QFLThreeList> {
  Future<List<QflT>>? futureRecords;
  var user = {};
  List<QflT> _allRecords = [];
  List<QflT> _filteredRecords = [];
  // @override
  // void initState() {
  //   super.initState();
  //   getuserdata().then((value) {
  //     setState(() {
  //       user = jsonDecode(value);
  //     });
  //     futureRecords = fetchNearMissRecords();
  //   });
  // }
  @override
  void initState() {
    super.initState();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      futureRecords = fetchNearMissRecords();
      futureRecords!.then((records) {
        setState(() {
          _allRecords = records;
          _filteredRecords = records; // Initially no filter, show all
        });
      });
    });
  }

  Future<List<QflT>> fetchNearMissRecords() async {
    final response = await http.get(
      headers: {
        'Authorization': 'Bearer ${user['data']['token']}',
        'Accept': 'application/json',
      },
      Uri.parse('${Api.api_url}loadQfl3'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> records = data['data'];
      return records.map((json) => QflT.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load Near Miss records');
    }
  }

  DateTime? _selectedDate;
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      _filterByDate(picked);
    }
  }

  void _clearFilter() {
    _filterByDate(null);
  }

  void _filterByDate(DateTime? selectedDate) {
    if (selectedDate == null) {
      setState(() {
        _selectedDate = null;
        _filteredRecords = _allRecords;
      });
    } else {
      setState(() {
        _selectedDate = selectedDate;
        _filteredRecords = _allRecords.where((record) {
          // Parse record.date string back to DateTime
          DateTime recordDate =
              DateFormat('dd MMM yyyy, hh:mm a').parse(record.date);
          return recordDate.year == selectedDate.year &&
              recordDate.month == selectedDate.month &&
              recordDate.day == selectedDate.day;
        }).toList();
      });
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
            // Reload all records again on add
            futureRecords = fetchNearMissRecords();
            futureRecords!.then((records) {
              setState(() {
                _allRecords = records;
                // Apply current filter if any
                if (_selectedDate != null) {
                  _filterByDate(_selectedDate);
                } else {
                  _filteredRecords = records;
                }
              });
            });
          });
          ;
        },
        backgroundColor: mycolor,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('MPA Records'),
        actions: [
          if (_selectedDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white70),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.filter_alt, size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('dd MMM yyyy').format(_selectedDate!),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: _clearFilter,
                        child: const Icon(Icons.close,
                            size: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Filter by date',
            onPressed: _pickDate,
          ),
        ],
      ),
      body: _allRecords.isEmpty
          ? Center(child: CustomLoader())
          : _filteredRecords.isEmpty
              ? const Center(
                  child: Text(
                    'No records found.',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                  itemCount: _filteredRecords.length,
                  itemBuilder: (context, index) {
                    final record = _filteredRecords[index];
                    return Card(
                      elevation: 3,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: mycolor,
                              foregroundColor: Colors.white,
                              radius: 20,
                              child: Text(
                                "${index + 1}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    record.project_model_Variant,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: mycolor,
                                    ),
                                  ),
                                  Text(
                                    record.station_number,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: mycolor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: 'Audit Department: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                        TextSpan(text: record.audit_department),
                                      ],
                                    ),
                                    style: const TextStyle(
                                        color: Colors.black87, fontSize: 13),
                                  ),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: 'Date: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                        TextSpan(text: '${record.date}\n'),
                                      ],
                                    ),
                                    style: const TextStyle(
                                        color: Colors.black87, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    QFLThreeDetails(
                                      id: record.id,
                                      audit_line: record.audit_department,
                                      project_model_Variant:
                                          record.project_model_Variant,
                                    ).launch(context,
                                        pageRouteAnimation:
                                            PageRouteAnimation.Slide);
                                  },
                                  icon: const Icon(Icons.visibility, size: 16),
                                  label: const Text('View',
                                      style: TextStyle(fontSize: 12)),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    backgroundColor: mycolor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    AuditChecklistPageAdd(id: record.id).launch(
                                      context,
                                      pageRouteAnimation:
                                          PageRouteAnimation.Slide,
                                    );
                                  },
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Add',
                                      style: TextStyle(fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    side: BorderSide(
                                        color: Colors.green.shade700),
                                    foregroundColor: Colors.green.shade700,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
