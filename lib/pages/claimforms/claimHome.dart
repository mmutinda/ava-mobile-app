import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/pages/claimforms/RaiseClaim.dart';
import 'package:isuze_pqcs/pages/claimforms/claimView.dart';

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
      futureRecords = fetchRecords();
    });
  }

  Future<List<NearMiss>> fetchRecords() async {
    final response = await http.get(
      headers: {
        'Authorization': 'Bearer ${user['data']['token']}',
        'Accept': 'application/json',
      },
      Uri.parse('${Api.api_url}loadlaim'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> records = data['datas'];
      return records.map((json) => NearMiss.fromJson(json)).toList();
    } else {
      throw Exception('Failed to claim records');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ClaimForm(),
            ),
          ).then((result) {
            setState(() {
              futureRecords = fetchRecords();
            });
          });
        },
        backgroundColor: mycolor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('New Claim'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      appBar: AppBar(
        title: const Text('Claims Records'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey.shade50,
      body: FutureBuilder<List<NearMiss>>(
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
                  futureRecords = fetchRecords();
                });
              },
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No claims found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start by creating your first claim',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          final records = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: mycolor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.assignment_outlined,
                      color: mycolor,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    record.department,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              record.date,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.warning_amber_outlined,
                                size: 14, color: Colors.orange.shade600),
                            const SizedBox(width: 4),
                            Text(
                              record.levelOfRisk,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  trailing: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClaimViewPage(claim: record),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
