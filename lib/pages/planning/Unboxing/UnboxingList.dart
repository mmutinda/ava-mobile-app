import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/pages/Receiving/widget.dart';
import 'package:nb_utils/nb_utils.dart';

class UnboxingList extends StatefulWidget {
  final Id;
  final LotNo;

  const UnboxingList({super.key, required this.Id, required this.LotNo});
  @override
  State<UnboxingList> createState() => _UnboxingListState();
}

class _UnboxingListState extends State<UnboxingList>
    with SingleTickerProviderStateMixin {
  var user = {};
  var vehicles = [];
  // var vehicles;
  var loadingText = '';
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  String searchText = '';
  bool _isSearching = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  final List<Color> colors = [
    Colors.amber.shade900,
    Colors.indigo,
    Colors.teal,
  ];
  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      fetchVehicles().then(
        (value) {
          _animationController.forward();
        },
      );
    });

    // Start animation immediately to show loader
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildSearchField() {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(25),
        ),
        child: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          cursorColor: Colors.white,
          controller: searchController,
          onChanged: (value) {
            setState(() {
              searchText = value;
            });
          },
          decoration: const InputDecoration(
            hintText: 'Search by Chassis Number...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70, fontSize: 14),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            prefixIcon: Icon(Icons.search, color: Colors.white70),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          child: AppBar(
            elevation: 0,
            title: _isSearching
                ? _buildSearchField()
                : Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.inventory_2,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Unboxing Units',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'Lot ${widget.LotNo}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: Icon(
                    _isSearching ? Icons.close : Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                      if (!_isSearching) {
                        searchController.clear();
                        searchText = '';
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      color: mycolor,
      onRefresh: () async {
        await fetchVehicles();
        toasty(context, "Refreshed",
            bgColor: mycolor,
            textColor: textWhite,
            padding: const EdgeInsets.all(12));
      },
      child: Column(
        children: [
          // Stats header
          if (vehicles.isNotEmpty) _buildStatsHeader(),

          Expanded(
            child: Container(
              child: isLoading
                  ? _buildLoadingState()
                  : loadingText.isNotEmpty
                      ? _buildErrorState()
                      : _buildVehiclesList(),
            ),
          ),

          // Bottom action button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildActionButton(),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    final rackedCount = vehicles
        .where((v) => v['unit_racked']?.toString().toLowerCase() == 'yes')
        .length;
    final totalCount = vehicles.length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [mycolor.withOpacity(0.1), mycolor.withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: mycolor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: mycolor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.assignment_turned_in,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Racking Progress',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$rackedCount of $totalCount Units Racked',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: mycolor,
                  ),
                ),
              ],
            ),
          ),
          // Progress indicator
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  value: totalCount > 0 ? rackedCount / totalCount : 0,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    rackedCount == totalCount ? Colors.green : mycolor,
                  ),
                  strokeWidth: 3,
                ),
              ),
              Text(
                '${totalCount > 0 ? ((rackedCount / totalCount) * 100).round() : 0}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: mycolor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(mycolor),
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            'Loading units...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            loadingText.contains('No vehicles')
                ? Icons.inventory_2_outlined
                : Icons.error_outline,
            size: 64,
            color: loadingText.contains('No vehicles')
                ? Colors.grey.shade400
                : Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            loadingText.contains('No vehicles')
                ? 'No Units Available'
                : 'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loadingText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [mycolor.withOpacity(0.8), mycolor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                fetchVehicles();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Try Again',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesList() {
    // Filter vehicles based on search
    List filteredVehicles = vehicles.where((vehicle) {
      if (searchText.isEmpty) return true;

      var chassisNumber = vehicle["chassis_number"]?.toString() ?? '';
      var engineNumber = vehicle["engine_number"]?.toString() ?? '';

      return chassisNumber.toLowerCase().contains(searchText.toLowerCase()) ||
          engineNumber.toLowerCase().contains(searchText.toLowerCase());
    }).toList();

    if (filteredVehicles.isEmpty && searchText.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No units found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search terms',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      itemCount: filteredVehicles.length,
      itemBuilder: (context, index) {
        var vehicle = filteredVehicles[index];
        return ScaleTransition(
          scale: _slideAnimation,
          child: _buildVehicleCard(vehicle, index),
        );
      },
    );
  }

  Widget _buildVehicleCard(Map vehicle, int index) {
    Color categoryColor = colors[index % colors.length];
    var chassisNumber = vehicle['chassis_number'] ?? 'N/A';
    var engineNumber = vehicle['engine_number'] ?? 'N/A';
    var isRacked = vehicle['unit_racked']?.toString().toLowerCase() == '1';

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRacked ? Colors.green.shade300 : mycolor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isRacked ? null : () => _showRackingDialog(vehicle, index),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Status badge - smaller
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isRacked
                          ? [Colors.green.withOpacity(0.8), Colors.green]
                          : [mycolor.withOpacity(0.8), mycolor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: isRacked
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),

                const SizedBox(width: 12),

                // Unit details - compact
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status and chassis in one row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isRacked ? 'RACKED' : 'PENDING',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isRacked ? Colors.green : mycolor,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isRacked
                                  ? Colors.green.withOpacity(0.1)
                                  : mycolor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Unit ${index + 1}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isRacked ? Colors.green : mycolor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Chassis number - compact
                      Row(
                        children: [
                          Icon(
                            Icons.confirmation_number,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              chassisNumber,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Engine number - compact
                      Row(
                        children: [
                          Icon(
                            Icons.build,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              engineNumber,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Action button - compact
                if (!isRacked)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [categoryColor.withOpacity(0.8), categoryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'RACK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRackingDialog(Map vehicle, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter dialogSetState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: mycolor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.inventory_2,
                      color: mycolor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Confirm Racking',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Are you sure you want to rack this unit?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chassis: ${vehicle['chassis_number'] ?? 'N/A'}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Engine: ${vehicle['engine_number'] ?? 'N/A'}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mycolor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          dialogSetState(() {
                            isSubmitting = true;
                          });

                          try {
                            final fields = {
                              'vehicle_receiving_item_id': vehicle['id'],
                            };
                            print(fields);
                            await submitForm(
                              context: context,
                              url: '${Api.api_url}pushRack',
                              fields: fields,
                              token: user['data']['token'],
                            );

                            // Close dialog immediately after successful API call
                            // Navigator.of(context).pop();

                            // Show loading state and refresh data
                            setState(() {
                              isLoading = true;
                            });

                            await fetchVehicles();

                            // Show success message
                            toasty(context, "Unit racked successfully!",
                                bgColor: Colors.green, textColor: Colors.white);
                          } catch (e) {
                            toasty(context,
                                "Failed to rack unit. Please try again.",
                                bgColor: Colors.red, textColor: textWhite);
                            dialogSetState(() {
                              isSubmitting = false;
                            });
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'CONFIRM & RACK',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton() {
    // Check if ALL vehicles are completed
    final allChecklistsDone = vehicles.isNotEmpty &&
        vehicles
            .every((v) => v['unit_racked']?.toString().toLowerCase() == '1');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [mycolor.withOpacity(0.8), mycolor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: allChecklistsDone
              ? [
                  BoxShadow(
                    color: mycolor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap:
                // allChecklistsDone
                //     ?
                () async {
              final result = await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => LotIssueDialogFinishRacking(
                  lotId: widget.Id,
                  user: user['data']['token'],
                  lotNumber: widget.LotNo,
                ),
              );

              if (result != null) {
                print("Push to Planning with: $result");
              }
            },
            // : () {
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       SnackBar(
            //         margin: const EdgeInsets.all(50),
            //         padding: const EdgeInsets.all(10),
            //         behavior: SnackBarBehavior.floating,
            //         content:
            //             const Text("Racking incomplete for some units."),
            //         backgroundColor: Colors.red,
            //       ),
            //     );
            //   },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    // allChecklistsDone
                    //     ?
                    'FINISH RACKING & SCHEDULE',

                    // : 'RACKING INCOMPLETE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future fetchVehicles() async {
    setState(() {
      loadingText = '';
      isLoading = true;
    });

    String url = "${Api.api_url}loadUnboxingItems/${widget.Id}";
    print(url);

    try {
      var responsedata = await httpget(url, user['data']["token"], context);

      if (responsedata != null && responsedata["success"] == true) {
        setState(() {
          isLoading = false;
          vehicles = (responsedata["data"]['items'] as List<dynamic>);
          if (vehicles.isEmpty) {
            loadingText = 'No vehicles available at the moment';
          }
        });
      } else {
        setState(() {
          isLoading = false;
          loadingText =
              responsedata?["message"]?.toString() ?? 'Failed to load vehicles';
        });
        toasty(
            context, "${responsedata?["message"] ?? 'Failed to load vehicles'}",
            bgColor: Colors.red, textColor: textWhite);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        loadingText = 'Network error. Please check your connection.';
      });
      toasty(context, "Network error occurred",
          bgColor: Colors.red, textColor: textWhite);
    }
  }
}
// for taking picture
