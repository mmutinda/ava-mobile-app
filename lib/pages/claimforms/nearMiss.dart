import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
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
  bool _isLoading = true;
  String? _errorMessage;
  @override
  void initState() {
    super.initState();
    getuserdata().then((value) {
      if (mounted) {
        setState(() {
          user = jsonDecode(value);
        });
        futureRecords = fetchNearMissRecords();
        futureRecords.then((records) {
          if (mounted) {
            setState(() {
              _allRecords = records;
              _filteredRecords = records; // Initially no filter, show all
              _isLoading = false;
              _errorMessage = null;
            });
          }
        }).catchError((error) {
          print("Error loading near miss records: $error");
          if (mounted) {
            setState(() {
              _allRecords = [];
              _filteredRecords = [];
              _isLoading = false;
              _errorMessage = error.toString().replaceFirst('Exception: ', '');
            });
          }
        });
      }
    }).catchError((error) {
      print("Error getting user data: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load user data. Please restart the app.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  Future<List<NearMiss>> fetchNearMissRecords() async {
    try {
      print("Fetching Near Miss records...");

      // Validate user authentication
      if (user.isEmpty ||
          user['data'] == null ||
          user['data']['token'] == null) {
        throw Exception(
            'User authentication data is missing. Please login again.');
      }

      print("Making API request to: ${Api.api_url}loadnearmiss");

      final response = await http.get(
        Uri.parse('${Api.api_url}loadnearmiss'),
        headers: {
          'Authorization': 'Bearer ${user['data']['token']}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw Exception(
              'Request timed out. Please check your internet connection and try again.');
        },
      );

      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      // Handle different HTTP status codes
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);

          // Validate response structure
          if (data == null) {
            throw Exception('Received empty response from server');
          }

          if (!data.containsKey('data')) {
            // Check for error message in response
            if (data.containsKey('message')) {
              throw Exception(data['message'].toString());
            }
            throw Exception('Invalid response format: Missing data field');
          }

          final dynamic recordsData = data['data'];

          // Handle case where data might be null
          if (recordsData == null || recordsData.isEmpty) {
            print("No near miss records found");
            return [];
          }

          // Ensure data is a list
          if (recordsData is! List) {
            throw Exception(
                'Invalid data format: Expected list but received ${recordsData.runtimeType}');
          }

          final List<dynamic> records = recordsData;
          print("Successfully parsed ${records.length} records");

          // Parse each record with error handling
          List<NearMiss> nearMissRecords = [];
          for (int i = 0; i < records.length; i++) {
            try {
              final record = NearMiss.fromJson(records[i]);
              nearMissRecords.add(record);
            } catch (e) {
              print("Error parsing record at index $i: $e");
              // Continue with other records instead of failing completely
              continue;
            }
          }

          print(
              "Successfully processed ${nearMissRecords.length} near miss records");
          return nearMissRecords;
        } catch (e) {
          if (e.toString().contains('FormatException') ||
              e.toString().contains('format')) {
            throw Exception(
                'Server returned invalid data format. Please contact support.');
          }
          rethrow;
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception(
            'Access denied. You don\'t have permission to view near miss records.');
      } else if (response.statusCode == 404) {
        throw Exception('Near miss service not found. Please contact support.');
      } else if (response.statusCode == 500) {
        throw Exception('Server error occurred. Please try again later.');
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        // Try to extract error message from response
        try {
          final errorData = jsonDecode(response.body);
          if (errorData.containsKey('message')) {
            throw Exception(errorData['message'].toString());
          }
        } catch (_) {
          // If parsing fails, use generic message
        }
        throw Exception(
            'Client error (${response.statusCode}). Please check your request and try again.');
      } else if (response.statusCode >= 500) {
        throw Exception(
            'Server error (${response.statusCode}). Please try again later.');
      } else {
        throw Exception(
            'Unexpected response (${response.statusCode}). Please try again.');
      }
    } catch (e) {
      print("Error in fetchNearMissRecords: $e");

      // Handle specific error types
      String errorMessage;
      if (e.toString().contains('SocketException') ||
          e.toString().contains('NetworkException') ||
          e.toString().contains('Connection failed')) {
        errorMessage =
            'No internet connection. Please check your network and try again.';
      } else if (e.toString().contains('TimeoutException') ||
          e.toString().contains('timed out')) {
        errorMessage = 'Request timed out. Please try again.';
      } else if (e.toString().contains('FormatException') ||
          e.toString().contains('Invalid data format')) {
        errorMessage = 'Server returned invalid data. Please contact support.';
      } else if (e.toString().contains('authentication') ||
          e.toString().contains('login')) {
        errorMessage = 'Authentication failed. Please login again.';
      } else if (e.toString().contains('permission') ||
          e.toString().contains('Access denied')) {
        errorMessage =
            'Access denied. You don\'t have permission to view this data.';
      } else {
        // Clean up the error message
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        if (errorMessage.isEmpty) {
          errorMessage = 'An unexpected error occurred. Please try again.';
        }
      }

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: Duration(seconds: 5),
          ),
        );
      }

      // Re-throw the exception with clean message
      throw Exception(errorMessage);
    }
  }

  // Manual refresh method
  Future<void> _refreshRecords() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final records = await fetchNearMissRecords();

      if (mounted) {
        setState(() {
          _allRecords = records;
          // Apply current filter if any
          if (_selectedDate != null) {
            _filterByDate(_selectedDate);
          } else {
            _filteredRecords = records;
          }
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
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
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          foregroundColor: Colors.white,
          backgroundColor: theme.primaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NearMissFormPage(),
              ),
            ).then((result) async {
              // Reload all records again on add
              try {
                futureRecords = fetchNearMissRecords();
                final records = await futureRecords;
                if (mounted) {
                  setState(() {
                    _allRecords = records;
                    // Apply current filter if any
                    if (_selectedDate != null) {
                      _filterByDate(_selectedDate);
                    } else {
                      _filteredRecords = records;
                    }
                  });

                  // Show success message if new record was added
                  if (result == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Near miss record added successfully!',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                }
              } catch (e) {
                print("Error refreshing records: $e");
                // Error is already handled in fetchNearMissRecords
              }
            });
          },
          icon: const Icon(Icons.add_circle_outline, size: 20),
          label: const Text(
            'Report Issue',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text(
          'Near Miss Records',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        elevation: 0,
        actions: [
          if (_selectedDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.filter_alt, size: 14, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('dd MMM yyyy').format(_selectedDate!),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: _clearFilter,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
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
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  theme.primaryColor.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshRecords,
        color: theme.primaryColor,
        backgroundColor: Colors.white,
        strokeWidth: 3,
        displacement: 40.0,
        child: _isLoading
            ? _buildLoadingState()
            : _errorMessage != null
                ? _buildErrorState()
                : _filteredRecords.isEmpty
                    ? _buildEmptyState()
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              itemCount: _filteredRecords.length,
                              itemBuilder: (context, index) {
                                final record = _filteredRecords[index];
                                return _buildRecordCard(context, record, index);
                              },
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Loading near miss records...',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Pull down to refresh',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Unable to Load Records',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
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
                const SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: theme.primaryColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh,
                        size: 16,
                        color: theme.primaryColor,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Pull down to refresh',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _refreshRecords,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.search_off_rounded,
                    size: 48,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _selectedDate != null
                      ? 'No Records Found'
                      : 'No Near Miss Records',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _selectedDate != null
                      ? 'No near miss records found for the selected date.'
                      : 'No near miss incidents have been reported yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: theme.primaryColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh,
                        size: 16,
                        color: theme.primaryColor,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Pull down to refresh',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_selectedDate != null) ...[
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _clearFilter,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear Filter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, NearMiss record, int index) {
    final theme = Theme.of(context);
    final riskColor = mycolor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: riskColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: riskColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Header with risk level stripe
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    riskColor.withOpacity(0.1),
                    riskColor.withOpacity(0.05),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: riskColor,
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
                          record.department,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'PF: ${record.pfNumber}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // _buildRiskChip(record.levelOfRisk, riskColor),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRiskChip(record.levelOfRisk, riskColor),
                  // Location and Date
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoChip(
                          Icons.location_on_outlined,
                          record.location,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoChip(
                          Icons.calendar_today_outlined,
                          _formatDate(record.date),
                          Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Category
                  _buildInfoChip(
                    Icons.category_outlined,
                    record.category,
                    Colors.purple,
                  ),

                  const SizedBox(height: 16),

                  // View button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NearMissDetailPage(record: record),
                          ),
                        );
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

  Widget _buildRiskChip(String risk, Color color) {
    IconData riskIcon;
    switch (risk.toLowerCase()) {
      case 'high':
        riskIcon = Icons.priority_high;
        break;
      case 'medium':
        riskIcon = Icons.warning;
        break;
      case 'low':
        riskIcon = Icons.info;
        break;
      default:
        riskIcon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            riskIcon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            risk.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
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

  Color _getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateStr) {
    try {
      DateTime date = DateFormat('yyyy-MM-dd').parse(dateStr);
      DateTime now = DateTime.now();
      int difference = now.difference(date).inDays;

      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Yesterday';
      } else if (difference < 7) {
        return '${difference}d ago';
      } else {
        return DateFormat('MMM dd').format(date);
      }
    } catch (e) {
      return dateStr;
    }
  }
}

class NearMissDetailPage extends StatelessWidget {
  final NearMiss record;

  const NearMissDetailPage({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final riskColor = mycolor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Near Miss Details',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    mycolor,
                    mycolor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: mycolor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getRiskIcon(record.levelOfRisk),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.department,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${record.levelOfRisk.toUpperCase()} RISK INCIDENT',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: Colors.white.withOpacity(0.9),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'PF Number: ${record.pfNumber}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Incident Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDetailTile(
                    Icons.calendar_today_outlined,
                    'Date',
                    _formatDetailDate(record.date),
                    Colors.blue,
                  ),
                  _buildDetailTile(
                    Icons.location_on_outlined,
                    'Location',
                    record.location,
                    Colors.green,
                  ),
                  _buildDetailTile(
                    Icons.category_outlined,
                    'Category',
                    record.category,
                    Colors.purple,
                  ),
                  _buildDetailTile(
                    Icons.shield_outlined,
                    'Risk Level',
                    record.levelOfRisk,
                    riskColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Description Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: theme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      record.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Reporter Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_outlined,
                        color: theme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Reported By',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: theme.primaryColor,
                          radius: 20,
                          child: Text(
                            record.createdBy.name.isNotEmpty
                                ? record.createdBy.name[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record.createdBy.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                record.createdBy.email,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Attachments Card
            if (record.files != null && record.files!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.attach_file_rounded,
                          color: theme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Attachments',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${record.files!.length}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...record.files!.map(
                      (file) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () async {
                            final url = Uri.parse('${Api.files}$file');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Could not open file'),
                                ),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.insert_drive_file_outlined,
                                  size: 18,
                                  color: Colors.blue.shade600,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    file.split('/').last,
                                    style: TextStyle(
                                      color: Colors.blue.shade600,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.open_in_new,
                                  size: 16,
                                  color: Colors.blue.shade600,
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
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(
      IconData icon, String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRiskIcon(String risk) {
    switch (risk.toLowerCase()) {
      case 'high':
        return Icons.priority_high;
      case 'medium':
        return Icons.warning;
      case 'low':
        return Icons.info;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDetailDate(String dateStr) {
    try {
      DateTime date = DateFormat('yyyy-MM-dd').parse(dateStr);
      return DateFormat('EEEE, MMMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
