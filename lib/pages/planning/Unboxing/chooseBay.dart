import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/common/widgets.dart';

class ChooseBayDialog extends StatefulWidget {
  const ChooseBayDialog({
    super.key,
  });

  @override
  State<ChooseBayDialog> createState() => _ChooseBayDialogState();
}

class _ChooseBayDialogState extends State<ChooseBayDialog> {
  late TextEditingController inputController;
  var user = {};
  var data;

  String message = '';
  @override
  void initState() {
    super.initState();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      // fetchComponent();
      fetchBays();
    });
  }

  Future<void> fetchBays() async {
    final token = user['data']?['token'] ?? '';

    final result = await fetchData<List<dynamic>>(
      context: context,
      url: '${Api.api_url}loadBay',
      token: token,
      parser: (json) {
        if (json is List) {
          return json;
        }
        throw FormatException('Expected a list');
      },
    );

    if (result.success) {
      setState(() {
        data = result.data ?? [];
        message = data.isEmpty ? 'No Bay Available' : '';
      });
    } else {
      setState(() {
        message = result.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      width: double.infinity,
      child: data == null
          ? CustomLoader()
          : message.isNotEmpty
              ? ErrorMessageWidget(
                  errorMessage: message,
                  onRetry: () {
                    fetchBays().then((value) {
                      setState(() {
                        message = '';
                      });
                    });
                  },
                )
              : Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 192, 85, 3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // ✅ Decorated back/exit button
                          const Spacer(flex: 2),
                          const Text(
                            "CHOOSE BAY",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                // Close this dialog or navigate back
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          // extra space to keep title centered
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    // ✅ Wrap in Expanded to fill remaining space
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: data.map<Widget>((bay) {
                            final List<Color> colors = [
                              Colors.amber.shade900,
                              Colors.indigo,
                              Colors.teal,
                            ];
                            Color categoryColor =
                                colors[data.indexOf(bay) % colors.length];
                            var bayname = bay['name'];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 1,
                              color: Colors.white,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                leading: Icon(
                                  Icons.label,
                                  color: categoryColor,
                                ),
                                title: Text(
                                  bayname,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 16),
                                onTap: () {
                                  print("Selected Bay: $bayname");
                                  Navigator.pop(context, bayname);
                                  // Your logic here
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
