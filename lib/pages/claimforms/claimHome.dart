import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/pages/claimforms/NearMissForm.dart';
import 'package:isuze_pqcs/pages/claimforms/RaiseClaim.dart';
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

class ClaimHome extends StatefulWidget {
  const ClaimHome({super.key});

  @override
  State<ClaimHome> createState() => _ClaimHomeState();
}

class _ClaimHomeState extends State<ClaimHome> {
  late Future<List<NearMiss>> futureRecords;
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

  Future<List<NearMiss>> fetchNearMissRecords() async {
    final response = await http.get(
      headers: {
        'Authorization': 'Bearer ${user['data']['token']}',
        'Accept': 'application/json',
      },
      Uri.parse('${Api.api_url}loadnearmiss'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> records = data['datas'];
      return records.map((json) => NearMiss.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load Near Miss records');
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
              builder: (_) => ClaimForm(),
            ),
          ).then((result) {
            setState(() {
              futureRecords = fetchNearMissRecords();
            });
          });
        },
        backgroundColor: mycolor,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(title: const Text('Claims Records')),
      body: Container(
        child: FutureBuilder<List<NearMiss>>(
          future: futureRecords,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CustomLoader(),
              );
            } else if (snapshot.hasError) {
              return ErrorMessageWidget(
                errorMessage: "Something went wrong. Please try again.",
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
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return Card(
                  elevation: 1,
                  // shadowColor: Colors.blue.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: const Icon(Icons.warning, color: Colors.white),
                    ),
                    title: Text(
                      record.department,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                                text: 'Date: ',
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            TextSpan(text: '${record.date}\n'),
                            const TextSpan(
                                text: 'Risk: ',
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            TextSpan(text: record.levelOfRisk),
                          ],
                        ),
                      ),
                    ),
                    trailing:
                        const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NearMissDetailPage(record: record),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
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
                              final url = '${Api.progress_image}$file';
                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(Uri.parse(url));
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.attach_file,
                                      size: 18, color: Colors.blue),
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
          Icon(icon, size: 22, color: Colors.blueAccent),
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
