import 'package:flutter/material.dart';

void main() {
  runApp(const TorqueApp());
}

class TorqueApp extends StatelessWidget {
  const TorqueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TorqueTabPage(),
    );
  }
}

class TorqueTabPage extends StatefulWidget {
  const TorqueTabPage({super.key});

  @override
  State<TorqueTabPage> createState() => _TorqueTabPageState();
}

class _TorqueTabPageState extends State<TorqueTabPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> torqueEntries = [];

  final TextEditingController _operationController = TextEditingController();
  final TextEditingController _torqueValueController = TextEditingController();
  List<double> tempValues = [];

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  void _submitEntry() {
    final op = _operationController.text.trim();
    if (op.isEmpty || tempValues.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Please enter operation and at least one torque value."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      torqueEntries.add({
        'operation': op,
        'values': List.from(tempValues),
      });
      _operationController.clear();
      _torqueValueController.clear();
      tempValues.clear();
      _tabController.animateTo(1); // Switch to View tab
    });
  }

  void _addTorqueValue() {
    final val = double.tryParse(_torqueValueController.text.trim());
    if (val != null) {
      setState(() {
        tempValues.add(val);
        _torqueValueController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🔩 Torque Entry"),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.edit), text: "Enter"),
            Tab(icon: Icon(Icons.visibility), text: "View"),
          ],
        ),
        backgroundColor: Colors.indigo,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // === ENTER TAB ===
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _operationController,
                  decoration: const InputDecoration(
                    labelText: 'Operation Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _torqueValueController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Torque Value (Nm)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _addTorqueValue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                      ),
                      child: const Text("Add"),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: tempValues
                      .map((e) => Chip(
                            label: Text(e.toString()),
                            backgroundColor: Colors.indigo.shade100,
                          ))
                      .toList(),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submitEntry,
                    icon: const Icon(Icons.send),
                    label: const Text("Submit Entry"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                )
              ],
            ),
          ),

          // === VIEW TAB ===
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: torqueEntries.isEmpty
                ? const Center(
                    child: Text("No entries yet."),
                  )
                : ListView.builder(
                    itemCount: torqueEntries.length,
                    itemBuilder: (context, index) {
                      final entry = torqueEntries[index];
                      final operation = entry['operation'];
                      final values = entry['values'] as List<double>;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                operation,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const Divider(),
                              Wrap(
                                spacing: 10,
                                children: values
                                    .map(
                                      (val) => Chip(
                                        label: Text(
                                            "${val.toStringAsFixed(2)} Nm"),
                                        backgroundColor: Colors.indigo.shade200,
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
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
