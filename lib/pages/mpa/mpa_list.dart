import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/pages/mpa/mpa_deatils.dart';
import 'package:isuze_pqcs/pages/mpa/mpaForm.dart';
import 'package:nb_utils/nb_utils.dart';

class QflT {
  final int id;
  final String project_model_Variant;
  final String audit_department;
  final String period;
  final String station_number;
  final String audit_line;

  final String date;

  QflT({
    required this.id,
    required this.project_model_Variant,
    required this.audit_department,
    required this.period,
    required this.station_number,
    required this.audit_line,
    required this.date,
  });

  factory QflT.fromJson(Map<String, dynamic> json) {
    return QflT(
      id: json['id'],
      project_model_Variant: json['project_model_variant'].toString(),
      audit_department: json['audit_department'].toString(),
      period: json['period'].toString(),
      station_number: json['station_number'].toString(),
      audit_line: json['audit_line'].toString(),
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
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasError = false;
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });

      final userData = await getuserdata();
      setState(() {
        user = jsonDecode(userData);
      });

      final records = await fetchNearMissRecords();
      setState(() {
        _allRecords = records;
        _filteredRecords = records; // Initially no filter, show all
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<List<QflT>> fetchNearMissRecords() async {
    try {
      final response = await http.get(
        headers: {
          'Authorization': 'Bearer ${user['data']['token']}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        Uri.parse('${Api.api_url}load-mpa'),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception(
              'Request timeout. Please check your internet connection.');
        },
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);

          // Check if the response has the expected structure
          if (data == null) {
            throw Exception('Received null response from server');
          }

          if (!data.containsKey('data')) {
            throw Exception('Invalid response format: missing data field');
          }

          final dynamic recordsData = data['data'];

          if (recordsData == null) {
            // Return empty list if no data instead of throwing error
            return [];
          }

          if (recordsData is! List) {
            throw Exception('Invalid response format: data is not a list');
          }

          final List<dynamic> records = recordsData;

          // Parse each record with error handling
          List<QflT> parsedRecords = [];
          for (int i = 0; i < records.length; i++) {
            try {
              final record = QflT.fromJson(records[i]);
              parsedRecords.add(record);
            } catch (e) {
              print('Warning: Failed to parse record at index $i: $e');
              // Continue parsing other records instead of failing completely
              continue;
            }
          }

          return parsedRecords;
        } catch (e) {
          throw Exception('Failed to parse response data: $e');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception(
            'Access denied. You don\'t have permission to view this data.');
      } else if (response.statusCode == 404) {
        throw Exception('MPA records endpoint not found.');
      } else if (response.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        throw Exception(
            'Client error (${response.statusCode}). Please check your request.');
      } else if (response.statusCode >= 500) {
        throw Exception(
            'Server error (${response.statusCode}). Please try again later.');
      } else {
        throw Exception(
            'Unexpected response: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } on http.ClientException {
      throw Exception('Network error: Please check your internet connection.');
    } on FormatException {
      throw Exception('Invalid response format from server.');
    } on Exception {
      // Re-throw our custom exceptions
      rethrow;
    } catch (e) {
      throw Exception('Unexpected error: $e');
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
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: mycolor.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          onPressed: () {
            AuditChecklistPage()
                .launch(context, pageRouteAnimation: PageRouteAnimation.Slide)
                .then((result) {
              // Reload all records again on add
              _loadData();
            });
          },
          backgroundColor: mycolor,
          child: const Icon(Icons.add),
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: mycolor,
        foregroundColor: Colors.white,
        title: const Text(
          'MPA Records',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                mycolor,
                mycolor.withOpacity(0.8),
              ],
            ),
          ),
        ),
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
      body: _isLoading
          ? Center(child: CustomLoader())
          : _hasError
              ? _buildErrorState()
              : _filteredRecords.isEmpty
                  ? _buildEmptyState()
                  : _buildRecordsList(),
    );
  }

  Widget _buildErrorState() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shadowColor: Colors.red.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.red.withOpacity(0.02),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.shade100,
                                Colors.red.shade50,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: Colors.red.shade600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Unable to Load Data',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage ?? 'An unexpected error occurred',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [mycolor, mycolor.withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: mycolor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _loadData,
                            icon: Icon(Icons.refresh_rounded, size: 18),
                            label: Text(
                              'Try Again',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No records found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedDate != null
                ? 'Try selecting a different date'
                : 'No QFL3 records available',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      itemCount: _filteredRecords.length,
      itemBuilder: (context, index) {
        final record = _filteredRecords[index];
        _filteredRecords.sort((a, b) {
          DateTime dateA = DateFormat('dd MMM yyyy, hh:mm a').parse(a.date);
          DateTime dateB = DateFormat('dd MMM yyyy, hh:mm a').parse(b.date);
          return dateB.compareTo(dateA);
        });
        return _buildDocumentCard(context, record, index);
      },
    );
  }

  Widget _buildDocumentCard(BuildContext context, QflT record, int index) {
    final theme = Theme.of(context);
    Color scoreColor = mycolor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scoreColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: scoreColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Header with gradient background
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    scoreColor.withOpacity(0.1),
                    scoreColor.withOpacity(0.05),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: scoreColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.station_number,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Audit Line: ${record.audit_line}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Department and Period
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoChip(
                          Icons.business_outlined,
                          record.audit_department,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoChip(
                          Icons.access_time_outlined,
                          record.project_model_Variant,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Date
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoChip(
                          Icons.calendar_today_outlined,
                          "Created Date",
                          Colors.teal,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoChip(
                          Icons.calendar_today_outlined,
                          record.date,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // View button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        QFLThreeDetails(
                          id: record.id,
                          audit_line: record.audit_department,
                          project_model_Variant: record.project_model_Variant,
                        ).launch(context,
                            pageRouteAnimation: PageRouteAnimation.Slide);
                      },
                      icon: const Icon(Icons.visibility_outlined, size: 16),
                      label: const Text(
                        'View Details',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color.withOpacity(0.8),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
