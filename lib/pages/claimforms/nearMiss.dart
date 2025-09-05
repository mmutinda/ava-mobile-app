import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/pages/claimforms/NearMissForm.dart';
import 'package:isuze_pqcs/pages/claimforms/nearmisDetails.dart';

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
  Map<String, dynamic>? _bestPerformer;
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
              _calculateBestPerformer();
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
          // Apply current filters if any
          _applyFilters(
            date: _selectedDate,
            category: _selectedCategory,
            level: _selectedLevel,
            department: _selectedDepartment,
          );
          _isLoading = false;
          _errorMessage = null;
          _calculateBestPerformer();
          _calculateBestPerformer();
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
  String? _selectedCategory;
  String? _selectedLevel;
  String? _selectedDepartment;

  // Get unique values for filter dropdowns
  List<String> get _availableCategories {
    return _allRecords.map((record) => record.category).toSet().toList()
      ..sort();
  }

  List<String> get _availableLevels {
    return _allRecords.map((record) => record.levelOfRisk).toSet().toList()
      ..sort();
  }

  List<String> get _availableDepartments {
    return _allRecords.map((record) => record.department).toSet().toList()
      ..sort();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      _applyFilters(date: picked);
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  Widget _buildFilterBottomSheet() {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Records',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                if (_hasActiveFilters())
                  TextButton(
                    onPressed: () {
                      _clearFilter();
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: theme.primaryColor,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text('Clear All'),
                  ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade300),

          // Filter Sections
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterSection(
                    'Category',
                    _selectedCategory,
                    _availableCategories,
                    Icons.category_outlined,
                    (value) => _applyFilters(category: value),
                  ),
                  const SizedBox(height: 24),
                  _buildFilterSection(
                    'Risk Level',
                    _selectedLevel,
                    _availableLevels,
                    Icons.warning_amber_outlined,
                    (value) => _applyFilters(level: value),
                  ),
                  const SizedBox(height: 24),
                  _buildFilterSection(
                    'Department',
                    _selectedDepartment,
                    _availableDepartments,
                    Icons.apartment_outlined,
                    (value) => _applyFilters(department: value),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    String? selectedValue,
    List<String> options,
    IconData icon,
    Function(String?) onChanged,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: theme.primaryColor),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedValue,
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
              hintText: 'Select $title',
              hintStyle: TextStyle(color: Colors.grey.shade500),
            ),
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Text(
                  'All ${title}s',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              ...options.map((option) => DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  )),
            ],
            onChanged: (value) {
              onChanged(value);
              Navigator.pop(context);
            },
            dropdownColor: Colors.white,
            style: TextStyle(color: Colors.grey.shade800),
          ),
        ),
      ],
    );
  }

  bool _hasActiveFilters() {
    return _selectedDate != null ||
        _selectedCategory != null ||
        _selectedLevel != null ||
        _selectedDepartment != null;
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedDate != null) count++;
    if (_selectedCategory != null) count++;
    if (_selectedLevel != null) count++;
    if (_selectedDepartment != null) count++;
    return count;
  }

  Widget _buildFilterSummary() {
    final theme = Theme.of(context);
    List<Widget> filterChips = [];

    if (_selectedDate != null) {
      filterChips.add(_buildFilterChip(
        'Date: ${DateFormat('dd MMM yyyy').format(_selectedDate!)}',
        () => _applyFilters(date: null),
        Icons.calendar_today,
      ));
    }

    if (_selectedCategory != null) {
      filterChips.add(_buildFilterChip(
        'Category: $_selectedCategory',
        () => _applyFilters(category: null),
        Icons.category,
      ));
    }

    if (_selectedLevel != null) {
      filterChips.add(_buildFilterChip(
        'Level: $_selectedLevel',
        () => _applyFilters(level: null),
        Icons.warning,
      ));
    }

    if (_selectedDepartment != null) {
      filterChips.add(_buildFilterChip(
        'Dept: $_selectedDepartment',
        () => _applyFilters(department: null),
        Icons.business,
      ));
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      color: theme.primaryColor.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_alt,
                size: 16,
                color: theme.primaryColor,
              ),
              SizedBox(width: 6),
              Text(
                'Active Filters (${filterChips.length})',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: _clearFilter,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size(0, 0),
                ),
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filterChips,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove, IconData icon) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: theme.primaryColor),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: theme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.close,
                size: 10,
                color: theme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearFilter() {
    _applyFilters(date: null, category: null, level: null, department: null);
  }

  void _applyFilters({
    DateTime? date,
    String? category,
    String? level,
    String? department,
  }) {
    setState(() {
      _selectedDate = date;
      _selectedCategory = category;
      _selectedLevel = level;
      _selectedDepartment = department;

      _filteredRecords = _allRecords.where((record) {
        // Date filter
        if (_selectedDate != null) {
          try {
            DateTime recordDate = DateFormat('yyyy-MM-dd').parse(record.date);
            if (!(recordDate.year == _selectedDate!.year &&
                recordDate.month == _selectedDate!.month &&
                recordDate.day == _selectedDate!.day)) {
              return false;
            }
          } catch (e) {
            return false;
          }
        }

        // Category filter
        if (_selectedCategory != null && record.category != _selectedCategory) {
          return false;
        }

        // Level filter
        if (_selectedLevel != null && record.levelOfRisk != _selectedLevel) {
          return false;
        }

        // Department filter
        if (_selectedDepartment != null &&
            record.department != _selectedDepartment) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  // Calculate the best performer based on number of near miss reports for the previous month
  void _calculateBestPerformer() {
    if (_allRecords.isEmpty) {
      _bestPerformer = null;
      return;
    }

    // Get previous month date range
    DateTime now = DateTime.now();
    DateTime previousMonth = DateTime(now.year, now.month - 1, 1);
    DateTime startOfPreviousMonth = DateTime(previousMonth.year, previousMonth.month, 1);
    DateTime endOfPreviousMonth = DateTime(previousMonth.year, previousMonth.month + 1, 0);

    // Count reports by user for previous month only
    Map<String, Map<String, dynamic>> userCounts = {};

    for (var record in _allRecords) {
      try {
        // Parse the record date
        DateTime recordDate = DateFormat('yyyy-MM-dd').parse(record.date);
        
        // Check if record is from previous month
        if (recordDate.isAfter(startOfPreviousMonth.subtract(Duration(days: 1))) &&
            recordDate.isBefore(endOfPreviousMonth.add(Duration(days: 1)))) {
          
          String userId = record.createdBy.email;

          if (userCounts.containsKey(userId)) {
            userCounts[userId]!['count']++;
          } else {
            userCounts[userId] = {
              'count': 1,
              'name': record.createdBy.name,
              'email': record.createdBy.email,
            };
          }
        }
      } catch (e) {
        // Skip records with invalid dates
        print("Error parsing date for record ${record.id}: ${record.date}");
        continue;
      }
    }

    // Find the user with the most reports in previous month
    String? bestUserId;
    int maxCount = 0;

    userCounts.forEach((userId, userData) {
      if (userData['count'] > maxCount) {
        maxCount = userData['count'];
        bestUserId = userId;
      }
    });

    if (bestUserId != null && maxCount > 0) {
      _bestPerformer = userCounts[bestUserId];
    } else {
      _bestPerformer = null;
    }
  }

  // Build the best performer banner
  Widget _buildBestPerformerBanner() {
    if (_bestPerformer == null || _allRecords.isEmpty) {
      return SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor.withOpacity(0.1),
            theme.primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.emoji_events,
              color: Colors.amber.shade700,
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Near Miss Reporter - Previous Month',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.primaryColor.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  _bestPerformer!['name'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  '${_bestPerformer!['count']} reports last month',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  color: Colors.amber.shade700,
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  '#1',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
        child: FloatingActionButton(
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
                builder: (_) => NearMissFormPage(
                    pfNumber: user['data']['staff_no'] ?? '1'.toString()),
              ),
            ).then((result) async {
              // Reload all records again on add
              try {
                futureRecords = fetchNearMissRecords();
                final records = await futureRecords;
                if (mounted) {
                  setState(() {
                    _allRecords = records;
                    // Apply current filters if any
                    _applyFilters(
                      date: _selectedDate,
                      category: _selectedCategory,
                      level: _selectedLevel,
                      department: _selectedDepartment,
                    );
                    _calculateBestPerformer();
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
          child: Icon(Icons.add, size: 16),
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
          // Active filter chips
          if (_hasActiveFilters())
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.filter_alt, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '${_getActiveFilterCount()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: _clearFilter,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 10,
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
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter records',
            onPressed: _showFilterBottomSheet,
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
                          // Best performer banner
                          _buildBestPerformerBanner(),

                          // Filter summary
                          if (_hasActiveFilters()) _buildFilterSummary(),

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
                  _hasActiveFilters()
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
                  _hasActiveFilters()
                      ? 'No near miss records found matching the selected filters.'
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
                if (_hasActiveFilters()) ...[
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _clearFilter,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear Filters'),
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
      height: 200, // Fixed height to maintain consistency
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
                          record.category,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text('${record.description}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content with image on right side
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left side content
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row(
                          //   children: [
                          //     _buildRiskChip(record.levelOfRisk, riskColor),
                          //   ],
                          // ),
                          // const SizedBox(height: 8),

                          // Location and Date
                          Row(
                            children: [
                              Expanded(
                                  child: _buildRiskChip(
                                      record.department, riskColor)),
                              const SizedBox(width: 5),
                              Expanded(
                                child: _buildInfoChip(
                                  Icons.location_on_outlined,
                                  record.location,
                                  Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoChip(
                                  Icons.category_outlined,
                                  record.levelOfRisk,
                                  Colors.purple,
                                ),
                              ),
                              Expanded(
                                child: _buildInfoChip(
                                  Icons.calendar_today_outlined,
                                  _formatDate(record.date),
                                  Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // View button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        NearMissDetailPage(record: record),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.visibility_outlined,
                                  size: 14),
                              label: const Text(
                                'View Details',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
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

                    // Right side image
                    if (record.files != null && record.files!.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Container(
                        width: 80,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: "${Api.files}${record.files!.first}",
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade100,
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade100,
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
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
          Expanded(
            child: Text(
              risk.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
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

// 