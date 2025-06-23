import 'package:flutter/material.dart';
import 'package:isuze_pqcs/pages/planning/offlining/ChooseEOLOperationsPage.dart';
import 'package:isuze_pqcs/pages/planning/offlining/GCPlist.dart';

// Simulated data model
class Issue {
  final String title;
  final String status;

  Issue({required this.title, required this.status});

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      title: json['title'],
      status: json['status'],
    );
  }
}

class OffliningBayPage extends StatefulWidget {
  const OffliningBayPage({Key? key}) : super(key: key);

  @override
  State<OffliningBayPage> createState() => _OffliningBayPageState();
}

class _OffliningBayPageState extends State<OffliningBayPage> {
  List<Issue> issues = [];
  bool isLoading = true;
  String errorMessage = '';

  // ✅ Example: Simulate API call
  Future<void> fetchIssues() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      await Future.delayed(const Duration(seconds: 2)); // simulate network
      // ✅ Replace this with your real API call:
      final response = [
        {"title": "Faulty cab mount bracket", "status": "OPEN"},
        {"title": "Faulty 1st cross member", "status": "OPEN"},
        {"title": "Scratch on bumper", "status": "OPEN"},
        {"title": "ECU flashing not done", "status": "OPEN"},
      ];

      final fetched = response.map((e) => Issue.fromJson(e)).toList();

      setState(() {
        issues = fetched;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load issues.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchIssues();
  }

  // ✅ Your custom colors
  final Color openStatusColor = Colors.red.shade300;
  final Color toEolColor = Colors.green.shade200;
  final Color toGcpColor = Colors.red.shade300;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Offlining Bay"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Engineer goes through all issues raised and determines the next course of action.",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // ✅ Main content area
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                errorMessage,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: fetchIssues,
                                child: const Text("Retry"),
                              ),
                            ],
                          ),
                        )
                      : issues.isEmpty
                          ? const Center(
                              child: Text("No issues found."),
                            )
                          : ListView.separated(
                              itemCount: issues.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final issue = issues[index];
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 1,
                                  // color: Colors.white,
                                  child: ListTile(
                                    title: Text(
                                      issue.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: openStatusColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        issue.status,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
            ),

            const SizedBox(height: 20),

            // ✅ Bottom action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: toEolColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ChooseEOLOperationsPage()),
                      );
                    },
                    child: const Text(
                      "TO EOL",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: toGcpColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // TO GCP action
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const GCPCarListScreen()),
                      );
                    },
                    child: const Text(
                      "TO GCP",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
