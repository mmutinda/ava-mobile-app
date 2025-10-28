import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/models/shops.dart';
import 'package:isuze_pqcs/pages/planning/EOL/EOLScreen.dart';
import 'package:isuze_pqcs/pages/qc_inspection/scanning%20copy.dart';
import 'package:isuze_pqcs/services/sqlite_db_helper.dart';
import 'package:isuze_pqcs/widgets/shops.dart';
import 'package:nb_utils/nb_utils.dart';

class RunningShopsDashboardWidget extends StatefulWidget {
  const RunningShopsDashboardWidget({super.key});

  @override
  State<RunningShopsDashboardWidget> createState() =>
      RunningShopsDashboardWidgetState();
}

class RunningShopsDashboardWidgetState
    extends State<RunningShopsDashboardWidget> {
  List<shops> runningShops = [];
  var user = {};
  bool isLoading = false;
  String message = '';
  DateTime? lastUpdated;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  final List<Color> colors = [
    Colors.amber.shade900,
    Colors.indigo,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      fetchShops();
    });
  }

  Future<void> fetchShops() async {
    // EasyLoading.show(status: "Loading Shops...");
    setState(() {
      isLoading = true;
      message = '';
    });

    // Validate user data and token
    if (user.isEmpty || user['data'] == null || user['data']['token'] == null) {
      print("Error: No valid user token available");
      setState(() {
        isLoading = false;
        message = 'Authentication error. Please login again.';
      });
      return;
    }

    try {
      // Always try to get cached data first
      final cachedShops = await DBHelper.getCachedShops();
      bool hasCachedData = cachedShops.isNotEmpty;

      if (hasCachedData) {
        filterRunningShops(cachedShops);
        setState(() {
          isLoading = false;
          message = '';
          lastUpdated = DateTime.now();
        });
      }

      // Try to fetch fresh data from API
      final url = "${Api.api_url}home";
      final token = user['data']['token'];
      print("API URL: $url");
      print("Token available: ${token != null ? 'Yes' : 'No'}");

      final response = await httpget(url, token, context);

      // Debug API response
      if (response == null) {
        _debugApiIssue(response, "NULL_RESPONSE");
      }

      if (response != null && response is Map && response['success'] == true) {
        // API success - update with fresh data
        List<shops> fetched = (response['data']['shop'] as List)
            .map((e) => shops.fromJson(e))
            .toList();

        await DBHelper.insertShops(fetched);
        filterRunningShops(fetched);
        _retryCount = 0; // Reset retry count on successful API call

        setState(() {
          isLoading = false;
          message = '';
          lastUpdated = DateTime.now();
        });
      } else {
        // API failed - analyze the response
        String failureReason = "Unknown error";
        if (response == null) {
          failureReason = "No response from server (null)";
        } else if (response is Map) {
          if (response['success'] == false) {
            failureReason =
                "API returned success=false: ${response['msg'] ?? 'No message'}";
          } else {
            failureReason = "API response missing success field: $response";
          }
        } else {
          failureReason = "Invalid response type: ${response.runtimeType}";
        }

        print("API Failure: $failureReason");

        if (hasCachedData) {
          // We have cached data, so don't show any error - just silently use cached data
          print("API failed but showing cached data - no error message");
          _retryCount = 0; // Reset retry count since we have data to show
          // The cached data was already loaded above, so we're good
        } else {
          // No cached data and API failed - try to retry
          if (_retryCount < _maxRetries) {
            print(
                "API failed, retrying... (${_retryCount + 1}/$_maxRetries) - Reason: $failureReason");
            _retryFetch();
            return; // Don't set error message yet, let retry handle it
          } else {
            // Max retries reached and no cached data
            setState(() {
              message = response is Map && response['msg'] != null
                  ? response['msg']
                  : 'Failed to load data after multiple attempts. Server issue: $failureReason';
              isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      print("Network Error: $e");
      print("Error type: ${e.runtimeType}");

      // Check if we have cached data to fall back on
      try {
        final cachedShops = await DBHelper.getCachedShops();
        if (cachedShops.isNotEmpty) {
          // We have cached data, use it and don't show any error
          filterRunningShops(cachedShops);
          setState(() {
            isLoading = false;
            message = ''; // Clear any error message
            lastUpdated = DateTime.now();
          });
          print("Network error but showing cached data - no error message");
          _retryCount = 0; // Reset retry count since we have data to show
        } else {
          // No cached data and network error - try to retry
          if (_retryCount < _maxRetries) {
            print(
                "Network error, retrying... (${_retryCount + 1}/$_maxRetries)");
            _retryFetch();
            return; // Don't set error message yet, let retry handle it
          } else {
            // Max retries reached and no cached data
            setState(() {
              isLoading = false;
              message =
                  "Network Error after multiple attempts. Please check your internet connection and try again.";
            });
          }
        }
      } catch (dbError) {
        // Even database access failed
        setState(() {
          isLoading = false;
          message = "System Error. Please restart the app.";
        });
        print("Database error: $dbError");
      }
    } finally {
      EasyLoading.dismiss();
      // Ensure loading is always false
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void filterRunningShops(List<shops> allShops) {
    runningShops =
        allShops.where((s) => double.tryParse(s.number)! > 0).toList();
  }

  // Public method to trigger refresh from parent widget
  void refreshData() {
    _retryCount = 0; // Reset retry count on manual refresh
    fetchShops();
  }

  // Debug method to analyze API issues
  void _debugApiIssue(dynamic response, String context) {
    print("=== API DEBUG ($context) ===");
    print("Response: $response");
    print("Response type: ${response.runtimeType}");
    print("User data available: ${user.isNotEmpty}");
    print("Token available: ${user['data']?['token'] != null}");
    if (user['data']?['token'] != null) {
      final token = user['data']['token'] as String;
      print("Token length: ${token.length}");
      print(
          "Token starts with: ${token.substring(0, token.length > 10 ? 10 : token.length)}...");
    }
    print("API URL: ${Api.api_url}home");
    print("========================");
  }

  // Retry with exponential backoff
  Future<void> _retryFetch() async {
    if (_retryCount < _maxRetries) {
      _retryCount++;
      final delay = Duration(seconds: _retryCount * 2); // 2s, 4s, 6s delays
      print(
          "Retrying API call in ${delay.inSeconds} seconds... (Attempt $_retryCount/$_maxRetries)");

      await Future.delayed(delay);
      if (mounted) {
        fetchShops();
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else {
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (message.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade300,
              ),
              SizedBox(height: 16),
              Text(
                "Oops! Something went wrong",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  _retryCount = 0; // Reset retry count on manual refresh
                  fetchShops();
                },
                icon: Icon(Icons.refresh),
                label: Text("Try Again"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              if (_retryCount > 0) ...[
                SizedBox(height: 12),
                Text(
                  "Retrying... (${_retryCount}/$_maxRetries)",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (runningShops.isEmpty) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "No running shops",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  fetchShops();
                },
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          "Shops with Running Units",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        if (isLoading) ...[
                          SizedBox(width: 8),
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (lastUpdated != null)
                    Text(
                      "Last updated: ${_formatTime(lastUpdated!)}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                fetchShops();
              },
            ),
          ],
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: runningShops.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              childAspectRatio: 1.2, // Increased aspect ratio for more height
            ),
            itemBuilder: (_, index) {
              final shop = runningShops[index];
              final color = colors[index % colors.length];
              return ShopItems(
                name: shop.name,
                number: shop.number,
                dividerColor: color,
                onTap: () {
                  if (shop.number == "0") {
                    toast("No running units in this shop");
                  } else {
                    if (shop.id == "17") {
                      EOLScreenCategory(
                        ShopId: shop.id,
                      ).launch(
                        context,
                        pageRouteAnimation: PageRouteAnimation.Slide,
                      );
                    } else {
                      Scanning(
                        shopId: shop.id,
                        shopName: shop.name,
                      ).launch(
                        context,
                        pageRouteAnimation: PageRouteAnimation.Slide,
                      );
                    }
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
