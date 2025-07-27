import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/pages/QFL%204/QFL4_form.dart';
import 'package:isuze_pqcs/pages/QFL%204/qflview.dart';

class QFL4_View extends StatefulWidget {
  final dynamic vehicleId;
  final dynamic modelId;
  final dynamic vehicleVin;
  final dynamic vehicleName;

  const QFL4_View({super.key, required this.vehicleId, required this.modelId, required this.vehicleVin, required this.vehicleName});

  @override
  State<QFL4_View> createState() => _QFL4_ViewState();
}

class _QFL4_ViewState extends State<QFL4_View> {
  bool isLoading2 = false;
  Map<String, dynamic> user = {};
  List<dynamic> shops = [];
  List<dynamic> data = [];
  List<String> issues = [""];
  bool isLoading = true;
  String errorText = '';

  @override
  void initState() {
    super.initState();
    loadDataLists();
  }

// sheduledunits
  Future<void> loadUserAndShops() async {
    setState(() => isLoading = true);
    try {
      final userData = await getuserdata();
      user = jsonDecode(userData);
      final response = await fetchShops();

      if (response != null && response["data"]["shop"] != null) {
        shops = response["data"]["shop"];
      }
    } catch (e) {
      errorText = "Error loading shops: $e";
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<Map<String, dynamic>?> fetchShops() async {
    String url = Api.api_url + "home";
    return await httpget(url, user['data']['token'], context);
  }

  Future<Map<String, dynamic>?> fetchScheduledVehicles() async {
    String url = Api.api_url +
        "loadQfl4/${widget.vehicleId}"; // Replace with correct path

    return await httpget(url, user['data']['token'], context);
  }

  Future<void> loadDataLists() async {
    setState(() {
      isLoading = true;
      errorText = '';
    });

    try {
      final userData = await getuserdata();
      user = jsonDecode(userData);
    } catch (e) {
      setState(() {
        isLoading = false;
        errorText = "Failed to load user data: $e";
      });
      return;
    }

    try {
      // Parallel fetch
      final results = await Future.wait([
        fetchShops().catchError((e) {
          errorText += "Error loading shops: $e\n";
          return null;
        }),
        fetchScheduledVehicles().catchError((e) {
          errorText += "Error loading vehicles: $e\n";
          return null;
        }),
      ]);

      final shopResponse = results[0];
      final vehicleResponse = results[1];
      print(shopResponse);
      print(vehicleResponse);

      if (shopResponse != null && shopResponse["data"]["shop"] != null) {
        shops = shopResponse["data"]["shop"];
      } else {
        errorText += "Shop data missing.\n";
      }

      if (vehicleResponse != null && vehicleResponse["data"] != null) {
        data = vehicleResponse["data"];
      } else {
        errorText += "Vehicle data missing.\n";
      }
    } catch (e) {
      errorText += "Unexpected error: $e\n";
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: shops.isNotEmpty
          ? Container(
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => QFL4_form(
                        vehicleId: widget.vehicleId,
                        vehicleVin: widget.vehicleVin,
                        modelId: widget.modelId,
                        shops: shops,
                      ),
                    ),
                  ).then((value) {
                    if (value != null) {
                      loadDataLists();
                    }
                  });
                },
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  'Add Issue',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            )
          : null,
      appBar: AppBar(
        title: const Text(
          'QFL 4 - Quality Issues',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        elevation: 0,
        actions: [
          if (!isLoading)
            IconButton(
              onPressed: loadDataLists,
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh',
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
      body: isLoading
          ? _buildLoadingState()
          : errorText.isNotEmpty
              ? _buildErrorState(theme)
              : _buildContentState(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading quality issues...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
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
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorText.trim(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: loadDataLists,
              icon: const Icon(Icons.refresh_rounded),
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
    );
  }

  Widget _buildContentState() {
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        Expanded(
          child: QFLIssuesPage(
            issues: data.cast<Map<String, dynamic>>(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
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
                Icons.assignment_turned_in_outlined,
                size: 48,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Quality Issues Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Great! No quality issues have been reported for this vehicle yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            if (shops.isNotEmpty) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => QFL4_form(
                        vehicleId: widget.vehicleId,
                        modelId: widget.modelId,
                        shops: shops,
                        vehicleVin: widget.vehicleVin,
                      
                      ),
                    ),
                  ).then((value) {
                    if (value != null) {
                      loadDataLists();
                    }
                  });
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Report First Issue'),
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
          ],
        ),
      ),
    );
  }
}
