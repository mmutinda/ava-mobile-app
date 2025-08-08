import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/pages/claimforms/RaiseClaim.dart';

class ClaimHome extends StatefulWidget {
  const ClaimHome({super.key});

  @override
  State<ClaimHome> createState() => _ClaimHomeState();
}

class _ClaimHomeState extends State<ClaimHome> {
  var user = {};
  Future<List<dynamic>>? futureRecords;

  @override
  void initState() {
    super.initState();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
        futureRecords = fetchRecords();
      });
    });
  }

  fetchRecords() async {
    final response = await http.get(
      headers: {
        'Authorization': 'Bearer ${user['data']['token']}',
        'Accept': 'application/json',
      },
      Uri.parse('${Api.api_url}loadClaim/General_Calimaim'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final List<dynamic> records = data['data'];
        return records;
      } else {
        throw Exception(data['msg'] ?? 'Failed to load claims');
      }
    } else {
      throw Exception('Failed to claim records');
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
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
      ),
      backgroundColor: Colors.grey.shade50,
      body: FutureBuilder<List<dynamic>>(
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
                    record['lot_number'] ?? 'N/A',
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
                            Icon(Icons.inventory_2_outlined,
                                size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              record['part_number'] ?? 'N/A',
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
                            Icon(Icons.category_outlined,
                                size: 14, color: Colors.orange.shade600),
                            const SizedBox(width: 4),
                            Text(
                              record['category'] ?? 'N/A',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.class_outlined,
                                size: 14, color: Colors.blue.shade600),
                            const SizedBox(width: 4),
                            Text(
                              record['classification'] ?? 'N/A',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(record['created_at']),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
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
                    // TODO: Navigate to claim details when ClaimViewPage is available
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Claim details view coming soon!'),
                        backgroundColor: Colors.blue,
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
