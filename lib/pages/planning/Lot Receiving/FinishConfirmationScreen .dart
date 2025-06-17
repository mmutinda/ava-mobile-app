import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FinishConfirmationScreen extends StatelessWidget {
  final List<Map<String, String>> rackList = [
    {'chassis': 'BZF20272019A', 'rack': 'FC'},
    {'chassis': 'BZF20272020A', 'rack': 'FA0'},
    {'chassis': 'BZF20272021A', 'rack': 'FA0'},
    {'chassis': 'BZF20272022A', 'rack': 'FA0'},
    {'chassis': 'BZF20272023A', 'rack': 'FA0'},
    {'chassis': 'BZF20272024A', 'rack': 'FC'},
  ];

  Color getRackColor(String rack) {
    switch (rack) {
      case 'FA0':
        return Colors.lightGreen.shade200;
      case 'FC':
        return Colors.blue.shade200;
      default:
        return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Racked Units", style: GoogleFonts.poppins()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Racked Units Summary",
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: rackList.length,
                itemBuilder: (context, index) {
                  final item = rackList[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item['chassis']!,
                            style: GoogleFonts.poppins(fontSize: 16)),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: getRackColor(item['rack']!),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item['rack']!,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close),
                label: Text("Close", style: GoogleFonts.poppins(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade100,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
