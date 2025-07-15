import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/pages/claimforms/NearMissForm.dart';
import 'package:url_launcher/url_launcher.dart';

class NearMiss {
  final int id;
  final String department;
  final String pfNumber;
  final String date;
  final String location;
  final String levelOfRisk;
  final String category;
  final String description;
  final List<String>? files;
  final CreatedBy createdBy;

  NearMiss({
    required this.id,
    required this.department,
    required this.pfNumber,
    required this.date,
    required this.location,
    required this.levelOfRisk,
    required this.category,
    required this.description,
    this.files,
    required this.createdBy,
  });

  factory NearMiss.fromJson(Map<String, dynamic> json) {
    return NearMiss(
      id: json['id'],
      department: json['department'],
      pfNumber: json['pf_number'],
      date: json['date'],
      location: json['location'],
      levelOfRisk: json['level_of_risk'],
      category: json['category_of_near_miss'],
      description: json['description'],
      files: json['file'] != null ? List<String>.from(json['file']) : null,
      createdBy: CreatedBy.fromJson(json['created_by']),
    );
  }
}

class CreatedBy {
  final String name;
  final String email;

  CreatedBy({required this.name, required this.email});

  factory CreatedBy.fromJson(Map<String, dynamic> json) {
    return CreatedBy(
      name: json['name'],
      email: json['email'],
    );
  }
}

class NearMissListPage extends StatefulWidget {
  const NearMissListPage({super.key});

  @override
  State<NearMissListPage> createState() => _NearMissListPageState();
}

class _NearMissListPageState extends State<NearMissListPage> {
  late Future<List<NearMiss>> futureRecords;
  var user = {};
  List<NearMiss> _allRecords = [];
  List<NearMiss> _filteredRecords = [];
  @override
  void initState() {
    super.initState();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      futureRecords = fetchNearMissRecords();
      futureRecords.then((records) {
        setState(() {
          _allRecords = records;
          _filteredRecords = records; // Initially no filter, show all
        });
      });
    });
  }

  Future<List<NearMiss>> fetchNearMissRecords() async {
    print("object");
    final response = await http.get(
      headers: {
        'Authorization': 'Bearer ${user['data']['token']}',
        'Accept': 'application/json',
      },
      Uri.parse('${Api.api_url}loadnearmiss'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> records = data['data'];
      return records.map((json) => NearMiss.fromJson(json)).toList();
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
      print(selectedDate);
      setState(() {
        _selectedDate = selectedDate;
        _filteredRecords = _allRecords.where((record) {
          // Parse record.date string back to DateTime
          print(record.date);
          DateTime recordDate = DateFormat('yyyy-MM-dd').parse(record.date);
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NearMissFormPage(),
            ),
          ).then((result) {
            // Reload all records again on add
            futureRecords = fetchNearMissRecords();
            futureRecords.then((records) {
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
        title: const Text('Near Miss Records'),
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
                                    record.department,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: mycolor,
                                    ),
                                  ),
                                  Text(
                                    record.levelOfRisk,
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
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            NearMissDetailPage(record: record),
                                      ),
                                    );
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
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      // body: Container(
      //   child: FutureBuilder<List<NearMiss>>(
      //     future: futureRecords,
      //     builder: (context, snapshot) {
      //       if (snapshot.connectionState == ConnectionState.waiting) {
      //         return Center(
      //           child: CustomLoader(),
      //         );
      //       } else if (snapshot.hasError) {
      //         return ErrorMessageWidget(
      //           errorMessage: "${snapshot.error}",
      //           onRetry: () {
      //             setState(() {
      //               futureRecords = fetchNearMissRecords();
      //             });
      //           },
      //         );
      //       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      //         return const Center(
      //           child: Text(
      //             'No records found.',
      //             style: TextStyle(fontSize: 18, color: Colors.black54),
      //           ),
      //         );
      //       }

      //       final records = snapshot.data!;
      //       return ListView.builder(
      //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      //         itemCount: records.length,
      //         itemBuilder: (context, index) {
      //           final record = records[index];
      //           return Card(
      //             elevation: 1,
      //             color: Colors.white,
      //             // shadowColor: Colors.blue.shade100,
      //             shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(15),
      //             ),
      //             margin: const EdgeInsets.symmetric(vertical: 8),
      //             child: ListTile(
      //               contentPadding: const EdgeInsets.symmetric(
      //                   horizontal: 20, vertical: 12),
      //               leading: CircleAvatar(
      //                 backgroundColor: Colors.grey.shade200,
      //                 child: Text("${index + 1}"),
      //               ),
      //               title: Text(
      //                 record.department,
      //                 style: TextStyle(
      //                     fontWeight: FontWeight.bold,
      //                     fontSize: 16,
      //                     color: mycolor),
      //               ),
      //               subtitle: Padding(
      //                 padding: const EdgeInsets.only(top: 4),
      //                 child: Text.rich(
      //                   TextSpan(
      //                     children: [
      //                       const TextSpan(
      //                           text: 'Date: ',
      //                           style: TextStyle(fontWeight: FontWeight.w500)),
      //                       TextSpan(text: '${record.date}\n'),
      //                       const TextSpan(
      //                           text: 'Risk: ',
      //                           style: TextStyle(fontWeight: FontWeight.w500)),
      //                       TextSpan(text: record.levelOfRisk),
      //                     ],
      //                   ),
      //                 ),
      //               ),
      //               trailing:
      //                   const Icon(Icons.arrow_forward_ios_rounded, size: 18),
      //               onTap: () {
      //                 Navigator.push(
      //                   context,
      //                   MaterialPageRoute(
      //                     builder: (_) => NearMissDetailPage(record: record),
      //                   ),
      //                 );
      //               },
      //             ),
      //           );
      //         },
      //       );
      //     },
      //   ),
      // ),
    );
  }
}

class NearMissDetailPage extends StatelessWidget {
  final NearMiss record;

  const NearMissDetailPage({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details - ${record.department}'),
        // backgroundColor: Colors.blue.shade700,
        // foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        // decoration: const BoxDecoration(
        //   gradient: LinearGradient(
        //     colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter,
        //   ),
        // ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: Colors.white,
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            // shadowColor: Colors.blueAccent.shade100,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                children: [
                  _buildDetailTile(Icons.calendar_today, 'Date', record.date),
                  _buildDetailTile(
                      Icons.location_on, 'Location', record.location),
                  _buildDetailTile(
                      Icons.shield, 'Risk Level', record.levelOfRisk),
                  _buildDetailTile(Icons.category, 'Category', record.category),
                  _buildDetailTile(
                      Icons.description, 'Description', record.description),
                  const SizedBox(height: 10),
                  _buildDetailTile(Icons.person, 'Reported by',
                      '${record.createdBy.name} (${record.createdBy.email})'),
                  const SizedBox(height: 20),
                  if (record.files != null && record.files!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📎 Attachments',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        ...record.files!.map(
                          (file) => InkWell(
                            onTap: () async {
                              final url = Uri.parse('${Api.files}$file');

                              if (await canLaunchUrl(url)) {
                                await launchUrl(
                                  url,
                                  mode: LaunchMode
                                      .externalApplication, // opens in the browser
                                );
                              } else {
                                // Optional: Handle error
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Could not launch URL')),
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.attach_file,
                                      size: 18, color: mycolor),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      file.split('/').last,
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: mycolor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$title:',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
