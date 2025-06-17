import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/pages/planning/EOL/EOLlist.dart';

class EOLScreenCategory extends StatelessWidget {
  const EOLScreenCategory({super.key});

  final List<Map<String, dynamic>> stations = const [
    {
      "name": "Brake Test",
      "count": 5,
      "icon": Icons.directions_car,
      "index": 1,
    },
    {
      "name": "Wheel Alignment",
      "count": 7,
      "icon": Icons.tune,
      "index": 2,
    },
    {"name": "Shower Test", "count": 12, "icon": Icons.water_damage},
    {"name": "Road Test", "count": 5, "icon": Icons.directions_car},
    {"name": "AC Refilling", "count": 10, "icon": Icons.ac_unit},
    {"name": "QC", "count": 25, "icon": Icons.verified},
    {"name": "Paint Rec", "count": 30, "icon": Icons.format_paint},
    {"name": "QFL4", "count": null, "icon": Icons.label},
    {"name": "Sale Station", "count": null, "icon": Icons.storefront},
  ];

  @override
  Widget build(BuildContext context) {
    final double sheetHeight = MediaQuery.of(context).size.height * 0.75;

    return Container(
      height: sheetHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
          ),
          const Text(
            'EOL Stations',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: stations.length,
              itemBuilder: (context, index) {
                final station = stations[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 1,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    onTap: () {
                      if (station["index"] == 1) {
                        // Handle case where count is null
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BrakeTestList(
                                    EOLType: 'BT',
                                  )),
                        );
                        return;
                      }
                      if (station["index"] == 2) {
                        // Handle case where count is null
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BrakeTestList(
                                    EOLType: 'WA',
                                  )),
                        );
                        return;
                      }
                      // Handle tap action
                      // You can navigate to a detailed screen or perform any action
                      print('Tapped on ${stations}');
                    },
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: Icon(station["icon"], color: mycolor),
                    ),
                    title: Text(
                      station["name"],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: station["count"] != null
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: mycolor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              station["count"].toString(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        : const SizedBox(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
