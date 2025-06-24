import 'package:flutter/material.dart';
import 'package:isuze_pqcs/pages/Receiving/display_vehicles.dart';
import 'package:isuze_pqcs/pages/planning/EOL/EOLScreen.dart';
import 'package:isuze_pqcs/pages/planning/PlanningUnits.dart';
import 'package:isuze_pqcs/pages/planning/Unboxing/chooseBay.dart';
import 'package:isuze_pqcs/pages/planning/Unboxing/display_UnboxingLots.dart';
import 'package:isuze_pqcs/pages/planning/scheduleUnits.dart';
import 'package:nb_utils/nb_utils.dart';

class PlanningHome extends StatefulWidget {
  const PlanningHome({super.key});

  @override
  State<PlanningHome> createState() => _PlanningHomeState();
}

class _PlanningHomeState extends State<PlanningHome> {
  // int selectedIndex = 2;

  final List<String> options = [
    'Scheduled Lots',
    'Unboxing',
    'Schedule to Assembly',
    'Show Weekly/\nMonthly Plan',
    'Show Units at\nLogistics',
    'Show Units at Line',
    'Show Units at\nrework',
    'Show Units at EOL',
    'Show Units at GCP',
  ];
  final List<Color> colors = [
    Colors.amber.shade900,
    Colors.indigo,
    Colors.teal,
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planning'),
      ),
      body: ListView.builder(
        itemCount: options.length,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            color: Colors.white,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Icon(
                Icons.label,
                color: colors[index % colors.length], // Dynamic color
              ),
              title: Text(
                options[index],
                style: const TextStyle(
                  fontSize: 16,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                if (index == 0) {
                  print(index);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DisplayVehicles(
                              isPlanning: "Yes",
                            )),
                  );
                  // showEOLBottomSheet(context);
                  return;
                }
                if (index == 1) {
                  showInDialog(context,
                          builder: (context) => ChooseBayDialog(),
                          dialogAnimation: DialogAnimation.SCALE)
                      .then((value) {
                    print(value);
                    if (value != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => display_UnboxingLots(
                                  bayName: value,
                                )),
                      );
                    }
                  });
                  // print(index);
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => DisplayVehicles(
                  //             isUnboxing: "Yes",
                  //           )),
                  // );
                  // showEOLBottomSheet(context);
                  return;
                }
                if (index == 2) {
                  print(index);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SCheduleUnits()),
                  );
                  // showEOLBottomSheet(context);
                  return;
                }
                if (index == 5) {
                  // Handle special case for "Show Received Lots"
                  // showInDialog(context,
                  //         builder: (context) => EOLScreenCategory(),
                  //         dialogAnimation: DialogAnimation.SCALE)
                  //     .then((value) {});

                  return;
                }
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) => PlaningUnits(
                //             option: index.toString(),
                //           )),
                // );
              },
            ),
          );
        },
      ),
    );
  }
}
