import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/constants.dart';

class ChooseEOLOperationsPage extends StatefulWidget {
  const ChooseEOLOperationsPage({Key? key}) : super(key: key);

  @override
  State<ChooseEOLOperationsPage> createState() =>
      _ChooseEOLOperationsPageState();
}

class _ChooseEOLOperationsPageState extends State<ChooseEOLOperationsPage> {
  // ✅ Simulated API data
  final List<Map<String, dynamic>> operations = [
    {"name": "Brake Test", "selected": false},
    {"name": "Wheel Alignment", "selected": false},
    {"name": "Shower Test", "selected": false},
    {"name": "Road Test", "selected": false},
    {"name": "AC", "selected": false},
    {"name": "QC", "selected": false},
  ];

  // ✅ Custom theme colors
  final Color startEolColor = mycolor;
  final Color checkboxActiveColor = mycolor;
  final Color checkboxBorderColor = Colors.grey.shade600;

  void toggleOperation(int index) {
    setState(() {
      operations[index]['selected'] = !operations[index]['selected'];
    });
  }

  void startEol() {
    final selectedOps = operations
        .where((op) => op['selected'] == true)
        .map((op) => op['name'])
        .toList();
    if (selectedOps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select at least one operation.",
          ),
        ),
      );
      return;
    }

    // ✅ Handle actual EOL start logic here
    print("Selected EOL Operations: $selectedOps");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose EOL Operations"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "The engineer chooses the operations to be carried out on the unit, i.e., check the EOL operations.",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 15,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // ✅ Decorated List
            Expanded(
              child: ListView.separated(
                itemCount: operations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final op = operations[index];
                  final isSelected = op['selected'] as bool;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: isSelected
                            ? checkboxActiveColor
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          op['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => toggleOperation(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? checkboxActiveColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected
                                    ? checkboxActiveColor
                                    : checkboxBorderColor,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 18,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Styled START EOL Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: startEolColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: startEol,
                child: const Text(
                  "START EOL",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
