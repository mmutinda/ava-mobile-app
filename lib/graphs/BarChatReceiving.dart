// import 'dart:convert';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:pqcs/common/api.dart';
// import 'package:pqcs/common/functions.dart';
// import 'package:pqcs/dashboard/loader.dart';

// class BarChatReceiving extends StatefulWidget {
//   @override
//   _BarChatReceivingState createState() => _BarChatReceivingState();
// }

// class _BarChatReceivingState extends State<BarChatReceiving> {
//   bool _isLoading = true;
//   List<List<double>> _data = [];
//   var _labels;
//   String _errorMessage = '';
//   var user = {};

//   @override
//   void initState() {
//     super.initState();
//     getuserdata().then((value) {
//       setState(() {
//         user = jsonDecode(value);
//       });
//       _fetchData();
//     });
//   }

//   Future<void> _fetchData() async {
//     setState(() {
//       _isLoading = true; // Show loading when refreshing
//     });

//     try {
//       String url = "${Api.api_url}getDashboard";
//       final response = await httpget(url, user["token"], context);

//       if (response['status'] == true) {
//         final data = response['data']['data'];
//         final labels = response['data']['labels'];

//         setState(() {
//           try {
//             _data = (data as List<dynamic>)
//                 .map<List<double>>((item) => (item as List<dynamic>)
//                     .map<double>((value) => value.toDouble())
//                     .toList())
//                 .toList();
//             _labels = (labels as List<dynamic>)
//                 .map((label) => label.toString())
//                 .toList();
//           } catch (e) {
//             print("Error parsing data: $e");
//           }
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _errorMessage = 'Failed to fetch data.';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       print(e);
//       setState(() {
//         _errorMessage = 'Error: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         if (_isLoading)
//           Center(
//             child: AnimatedGraphLoader(
//               maxY: 20,
//               barCount: 8,
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               animationDuration: const Duration(milliseconds: 800),
//             ),
//           )
//         else if (_errorMessage.isNotEmpty)
//           Center(child: Text(_errorMessage))
//         else
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: BarChart(
//               BarChartData(
//                 barTouchData: _barTouchData,
//                 titlesData: _titlesData,
//                 borderData: _borderData,
//                 barGroups: _barGroups,
//                 gridData: const FlGridData(show: false),
//                 alignment: BarChartAlignment.spaceAround,
//                 maxY: 20,
//               ),
//             ),
//           ),
//         Positioned(
//           top: 8,
//           right: 8,
//           child: IconButton(
//             icon: Icon(Icons.refresh, color: Colors.blue.shade900),
//             onPressed: _fetchData,
//           ),
//         ),
//       ],
//     );
//   }

//   BarTouchData get _barTouchData => BarTouchData(
//         enabled: false,
//         touchTooltipData: BarTouchTooltipData(
//           getTooltipColor: (group) => Colors.transparent,
//           tooltipPadding: EdgeInsets.zero,
//           tooltipMargin: 8,
//           getTooltipItem: (
//             BarChartGroupData group,
//             int groupIndex,
//             BarChartRodData rod,
//             int rodIndex,
//           ) {
//             return BarTooltipItem(
//               rod.toY.round().toString(),
//               const TextStyle(
//                 color: Colors.cyan,
//                 fontWeight: FontWeight.bold,
//               ),
//             );
//           },
//         ),
//       );

//   Widget _getTitles(double value, TitleMeta meta) {
//     final style = TextStyle(
//       color: Colors.blue.shade900,
//       fontWeight: FontWeight.bold,
//       fontSize: 14,
//     );
//     String text = '';
//     if (value.toInt() >= 0 && value.toInt() < _labels.length) {
//       text = _labels[value.toInt()];
//     }
//     return SideTitleWidget(
//       axisSide: meta.axisSide,
//       space: 4,
//       child: Text(text, style: style),
//     );
//   }

//   FlTitlesData get _titlesData => FlTitlesData(
//         show: true,
//         bottomTitles: AxisTitles(
//           sideTitles: SideTitles(
//             showTitles: true,
//             reservedSize: 30,
//             getTitlesWidget: _getTitles,
//           ),
//         ),
//         leftTitles: const AxisTitles(
//           sideTitles: SideTitles(showTitles: false),
//         ),
//         topTitles: const AxisTitles(
//           sideTitles: SideTitles(showTitles: false),
//         ),
//         rightTitles: const AxisTitles(
//           sideTitles: SideTitles(showTitles: false),
//         ),
//       );

//   FlBorderData get _borderData => FlBorderData(
//         show: false,
//       );

//   LinearGradient get _barsGradient => LinearGradient(
//         colors: [
//           Colors.blue.shade900,
//           Colors.cyan,
//         ],
//         begin: Alignment.bottomCenter,
//         end: Alignment.topCenter,
//       );

//   LinearGradient get _secondBarGradient => LinearGradient(
//         colors: [
//           Colors.red.shade900,
//           Colors.orange,
//         ],
//         begin: Alignment.bottomCenter,
//         end: Alignment.topCenter,
//       );

//   List<BarChartGroupData> get _barGroups {
//     return _data
//         .asMap()
//         .entries
//         .map((entry) => BarChartGroupData(
//               x: entry.key,
//               barRods: [
//                 BarChartRodData(
//                   toY: entry.value[0],
//                   gradient: _barsGradient,
//                 ),
//                 BarChartRodData(
//                   toY: entry.value[1],
//                   gradient: _secondBarGradient,
//                 ),
//               ],
//               showingTooltipIndicators: [0, 1],
//             ))
//         .toList();
//   }
// }
// import 'dart:convert';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:pqcs/common/api.dart';
// import 'package:pqcs/common/functions.dart';
// import 'package:pqcs/dashboard/loader.dart';

// class BarChatReceiving extends StatefulWidget {
//   @override
//   _BarChatReceivingState createState() => _BarChatReceivingState();
// }

// class _BarChatReceivingState extends State<BarChatReceiving> {
//   bool _isLoading = true;
//   List<List<double>> _data = [];
//   List<String> _labels = [];
//   String _errorMessage = '';
//   var user = {};

//   @override
//   void initState() {
//     super.initState();
//     getuserdata().then((value) {
//       setState(() {
//         user = jsonDecode(value);
//       });
//       _fetchData();
//     });
//   }

//   Future<void> _fetchData() async {
//     setState(() {
//       _isLoading = true; // Show loading when refreshing
//     });

//     try {
//       String url = "${Api.api_url}getDashboard";
//       final response = await httpget(url, user["token"], context);

//       if (response['status']) {
//         final data = response['data']['data'];
//         final labels = response['data']['labels'];

//         setState(() {
//           try {
//             _data = (data as List<dynamic>)
//                 .map<List<double>>((item) => (item as List<dynamic>)
//                     .map<double>((value) => value.toDouble())
//                     .toList())
//                 .toList();
//             _labels = (labels as List<dynamic>)
//                 .map((label) => label.toString())
//                 .toList();

//             // Save data to SharedPreferences
//             _saveToSharedPreferences(data, labels);
//           } catch (e) {
//             print("Error parsing data: $e");
//           }
//           _isLoading = false;
//         });
//       } else {
//         await _loadFromSharedPreferences();
//         setState(() {
//           _errorMessage = 'Failed to fetch data.';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       print(e);
//       await _loadFromSharedPreferences();
//       setState(() {
//         _errorMessage = 'Error: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _saveToSharedPreferences(dynamic data, dynamic labels) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('barChartData', jsonEncode(data));
//     await prefs.setString('barChartLabels', jsonEncode(labels));
//   }

//   Future<void> _loadFromSharedPreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     final cachedData = prefs.getString('barChartData');
//     final cachedLabels = prefs.getString('barChartLabels');

//     if (cachedData != null && cachedLabels != null) {
//       setState(() {
//         _data = (jsonDecode(cachedData) as List<dynamic>)
//             .map<List<double>>((item) => (item as List<dynamic>)
//                 .map<double>((value) => value.toDouble())
//                 .toList())
//             .toList();
//         _labels = (jsonDecode(cachedLabels) as List<dynamic>)
//             .map((label) => label.toString())
//             .toList();
//       });
//     } else {
//       setState(() {
//         _errorMessage = 'No cached data available.';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         if (_isLoading)
//           Center(
//             child: AnimatedGraphLoader(
//               maxY: 20,
//               barCount: 8,
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               animationDuration: const Duration(milliseconds: 800),
//             ),
//           )
//         else if (_errorMessage.isNotEmpty)
//           Center(child: Text(_errorMessage))
//         else
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: BarChart(
//               BarChartData(
//                 barTouchData: _barTouchData,
//                 titlesData: _titlesData,
//                 borderData: _borderData,
//                 barGroups: _barGroups,
//                 gridData: const FlGridData(show: false),
//                 alignment: BarChartAlignment.spaceAround,
//                 maxY: 20,
//               ),
//             ),
//           ),
//         Positioned(
//           top: 8,
//           right: 8,
//           child: IconButton(
//             icon: Icon(Icons.refresh, color: Colors.blue.shade900),
//             onPressed: _fetchData,
//           ),
//         ),
//       ],
//     );
//   }

//   BarTouchData get _barTouchData => BarTouchData(
//         enabled: false,
//         touchTooltipData: BarTouchTooltipData(
//           getTooltipColor: (group) => Colors.transparent,
//           tooltipPadding: EdgeInsets.zero,
//           tooltipMargin: 8,
//           getTooltipItem: (
//             BarChartGroupData group,
//             int groupIndex,
//             BarChartRodData rod,
//             int rodIndex,
//           ) {
//             return BarTooltipItem(
//               rod.toY.round().toString(),
//               const TextStyle(
//                 color: Colors.cyan,
//                 fontWeight: FontWeight.bold,
//               ),
//             );
//           },
//         ),
//       );

//   Widget _getTitles(double value, TitleMeta meta) {
//     final style = TextStyle(
//       color: Colors.blue.shade900,
//       fontWeight: FontWeight.bold,
//       fontSize: 14,
//     );
//     String text = '';
//     if (value.toInt() >= 0 && value.toInt() < _labels.length) {
//       text = _labels[value.toInt()];
//     }
//     return SideTitleWidget(
//       axisSide: meta.axisSide,
//       space: 4,
//       child: Text(text, style: style),
//     );
//   }

//   FlTitlesData get _titlesData => FlTitlesData(
//         show: true,
//         bottomTitles: AxisTitles(
//           sideTitles: SideTitles(
//             showTitles: true,
//             reservedSize: 30,
//             getTitlesWidget: _getTitles,
//           ),
//         ),
//         leftTitles: const AxisTitles(
//           sideTitles: SideTitles(showTitles: false),
//         ),
//         topTitles: const AxisTitles(
//           sideTitles: SideTitles(showTitles: false),
//         ),
//         rightTitles: const AxisTitles(
//           sideTitles: SideTitles(showTitles: false),
//         ),
//       );

//   FlBorderData get _borderData => FlBorderData(
//         show: false,
//       );

//   LinearGradient get _barsGradient => LinearGradient(
//         colors: [
//           Colors.blue.shade900,
//           Colors.cyan,
//         ],
//         begin: Alignment.bottomCenter,
//         end: Alignment.topCenter,
//       );

//   LinearGradient get _secondBarGradient => LinearGradient(
//         colors: [
//           Colors.red.shade900,
//           Colors.orange,
//         ],
//         begin: Alignment.bottomCenter,
//         end: Alignment.topCenter,
//       );

//   List<BarChartGroupData> get _barGroups {
//     return _data
//         .asMap()
//         .entries
//         .map((entry) => BarChartGroupData(
//               x: entry.key,
//               barRods: [
//                 BarChartRodData(
//                   toY: entry.value[0],
//                   gradient: _barsGradient,
//                 ),
//                 BarChartRodData(
//                   toY: entry.value[1],
//                   gradient: _secondBarGradient,
//                 ),
//               ],
//               showingTooltipIndicators: [0, 1],
//             ))
//         .toList();
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/graphs/loader.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BarChatReceiving extends StatefulWidget {
  @override
  _BarChatReceivingState createState() => _BarChatReceivingState();
}

class _BarChatReceivingState extends State<BarChatReceiving> {
  bool _isLoading = true;
  List<List<double>> _data = [];
  List<String> _labels = [];
  String _errorMessage = '';
  Timer? _timeoutTimer;
  var user = {};

  @override
  void initState() {
    super.initState();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      _loadCachedData();
      _fetchDataInBackground();
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('barChartData');
    final cachedLabels = prefs.getString('barChartLabels');

    if (cachedData != null && cachedLabels != null) {
      setState(() {
        _data = (jsonDecode(cachedData) as List<dynamic>)
            .map<List<double>>((item) => (item as List<dynamic>)
                .map<double>((value) => value.toDouble())
                .toList())
            .toList();
        _labels = (jsonDecode(cachedLabels) as List<dynamic>)
            .map((label) => label.toString())
            .toList();
        _isLoading =
            false; // Stop showing the loader if cached data is available
      });
    } else {
      setState(() {
        _isLoading = true; // Show loader if no cached data exists
      });
    }
  }

  Future<void> _fetchDataInBackground() async {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(Duration(minutes: 10), () {
      if (_isLoading) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Loading took too long. Please try again later.';
        });
      }
    });

    try {
      String url = "${Api.api_url}getDashboard";
      final response = await httpget(url, user["token"], context);

      if (response['status'] == true) {
        final data = response['data']['data'];
        final labels = response['data']['labels'];

        setState(() {
          _data = (data as List<dynamic>)
              .map<List<double>>((item) => (item as List<dynamic>)
                  .map<double>((value) => value.toDouble())
                  .toList())
              .toList();
          _labels = (labels as List<dynamic>)
              .map((label) => label.toString())
              .toList();
          _isLoading = false;
        });

        // Save new data to SharedPreferences
        await _saveToSharedPreferences(data, labels);
      } else {
        if (_data.isEmpty || _labels.isEmpty) {
          setState(() {
            _errorMessage = 'No data available. Please check your network.';
          });
        }
      }
    } catch (e) {
      print(e);
      if (_data.isEmpty || _labels.isEmpty) {
        setState(() {
          _errorMessage = 'No data available. Please check your network.';
        });
      }
    } finally {
      _timeoutTimer?.cancel();
    }
  }

  Future<void> _saveToSharedPreferences(dynamic data, dynamic labels) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('barChartData', jsonEncode(data));
    await prefs.setString('barChartLabels', jsonEncode(labels));
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    await _fetchDataInBackground();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isLoading)
          Center(
            child: AnimatedGraphLoader(
              maxY: 20,
              barCount: 8,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              animationDuration: const Duration(milliseconds: 800),
            ),
          )
        else if (_errorMessage.isNotEmpty)
          Center(child: Text(_errorMessage))
        else if (_data.isEmpty || _labels.isEmpty)
          Center(
            child: Text(
              'No data available.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: BarChart(
              BarChartData(
                barTouchData: _barTouchData,
                titlesData: _titlesData,
                borderData: _borderData,
                barGroups: _barGroups,
                gridData: const FlGridData(show: false),
                alignment: BarChartAlignment.spaceAround,
                maxY: 20,
              ),
            ),
          ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: Icon(Icons.refresh, color: Colors.blue.shade900),
            onPressed: _onRefresh,
          ),
        ),
      ],
    );
  }

  BarTouchData get _barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.round().toString(),
              const TextStyle(
                color: Colors.cyan,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );

  Widget _getTitles(double value, TitleMeta meta) {
    final style = TextStyle(
      color: Colors.blue.shade900,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text = '';
    if (value.toInt() >= 0 && value.toInt() < _labels.length) {
      text = _labels[value.toInt()];
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: style),
    );
  }

  FlTitlesData get _titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: _getTitles,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get _borderData => FlBorderData(
        show: false,
      );

  LinearGradient get _barsGradient => LinearGradient(
        colors: [
          Colors.blue.shade900,
          Colors.cyan,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  LinearGradient get _secondBarGradient => LinearGradient(
        colors: [
          Colors.red.shade900,
          Colors.orange,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  List<BarChartGroupData> get _barGroups {
    return _data
        .asMap()
        .entries
        .map((entry) => BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value[0],
                  gradient: _barsGradient,
                ),
                BarChartRodData(
                  toY: entry.value[1],
                  gradient: _secondBarGradient,
                ),
              ],
              showingTooltipIndicators: [0, 1],
            ))
        .toList();
  }
}
