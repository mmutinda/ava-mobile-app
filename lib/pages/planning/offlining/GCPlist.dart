import 'package:flutter/material.dart';

class CarData {
  final String model;
  final String chassis;
  final String ageing;

  CarData({required this.model, required this.chassis, required this.ageing});

  factory CarData.fromJson(Map<String, dynamic> json) {
    return CarData(
      model: json['model'],
      chassis: json['chassis'],
      ageing: json['ageing'],
    );
  }
}

// Simulate API call
Future<List<CarData>> fetchCarData() async {
  await Future.delayed(const Duration(seconds: 2));
  return List.generate(10, (index) {
    return CarData(
      model: 'Model-TATA',
      chassis: 'BZF2027 2019A',
      ageing: index == 0
          ? '2w'
          : index == 1
              ? '7d'
              : index == 5
                  ? '35d'
                  : '5d',
    );
  });
}

class GCPCarListScreen extends StatefulWidget {
  const GCPCarListScreen({super.key});
  @override
  State<GCPCarListScreen> createState() => _GCPCarListScreenState();
}

class _GCPCarListScreenState extends State<GCPCarListScreen> {
  late Future<List<CarData>> futureCars;

  @override
  void initState() {
    super.initState();
    futureCars = fetchCarData();
  }

  Color _getAgeingColor(String ageing) {
    if (ageing.contains('w')) return Colors.orange.shade200;
    if (ageing.contains('d')) {
      int days = int.tryParse(ageing.replaceAll('d', '')) ?? 0;
      if (days > 30) return Colors.red.shade200;
      if (days > 7) return Colors.yellow.shade300;
      return Colors.green.shade200;
    }
    return Colors.grey.shade200;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GCP - Green Car Park'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: FutureBuilder<List<CarData>>(
          future: futureCars,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text("Error loading data"));
            }

            final carList = snapshot.data ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom:
                          BorderSide(width: 1.5, color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: const [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Model',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Chassis',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Ageing',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: ListView.separated(
                    itemCount: carList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final car = carList[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                car.model,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                car.chassis,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: _getAgeingColor(car.ageing),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  car.ageing,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
