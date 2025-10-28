
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isuze_pqcs/pages/planning/Lot%20Receiving/FinishConfirmationScreen%20.dart';
import 'package:isuze_pqcs/pages/planning/Lot%20Receiving/chooseComponent.dart';
import 'package:isuze_pqcs/pages/planning/widget.dart';
import 'package:nb_utils/nb_utils.dart';

class UnboxingScreen extends StatefulWidget {
  @override
  _UnboxingScreenState createState() => _UnboxingScreenState();
}

class _UnboxingScreenState extends State<UnboxingScreen> {
  final List<String> chassisList = [
    'BZF20272019A',
    'BZF20272020A',
    'BZF20272021A',
    'BZF20272022A',
    'BZF20272023A',
    'BZF20272024A',
  ];

  String selectedValue = 'NO';
  Map<String, dynamic>? issueData;

  void _showIssueDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => IssueDialog(),
    );

    if (result != null) {
      setState(() {
        issueData = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color mycolor = Colors.blue; // Replace with your desired theme color

    return Scaffold(
      appBar: AppBar(
        title: Text("Unboxing", style: GoogleFonts.poppins()),
        actions: [Icon(Icons.more_vert)],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoText("Lot no:", "BZF-29"),
            _buildInfoText("Lot Quantity:", "12"),
            SizedBox(height: 20),
            Text("Chassis Details",
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: chassisList.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    color: Colors.white,
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                      leading: Icon(Icons.qr_code, color: Colors.grey[700]),
                      title: Text(chassisList[index],
                          style: GoogleFonts.poppins()),
                      trailing: ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.check_circle_outline),
                        label: Text("Rack Unit"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[300],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Text(
                    "Any Lot Issue?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: mycolor,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                ChoiceChip(
                  label: Text('YES'),
                  selected: selectedValue == 'YES',
                  selectedColor: Colors.red,
                  onSelected: (selected) {
                    setState(() {
                      selectedValue = 'YES';
                    });
                    _showIssueDialog();
                  },
                  labelStyle: TextStyle(
                    color: selectedValue == 'YES' ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
                ChoiceChip(
                  label: Text('NO'),
                  selected: selectedValue == 'NO',
                  selectedColor: Colors.green,
                  onSelected: (selected) {
                    setState(() {
                      selectedValue = 'NO';
                      issueData = null; // Clear data when user says NO
                    });
                  },
                  labelStyle: TextStyle(
                    color: selectedValue == 'NO' ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (issueData != null) ...[
              SizedBox(height: 20),
              Text("Issue Summary",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              Text("Part No: ${issueData!['partNo']}"),
              Text("Category: ${issueData!['category']}"),
              Text("Classification: ${issueData!['classification']}"),
              if (issueData!['image'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Image.file(issueData!['image'], height: 100),
                ),
            ],
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  toast("Proceeding to Finish screen...");

                  // ChooseComponent(
                  //   vehicle_id: 1,
                  //   job_no: 1,
                  //   route_id: 1,
                  // );
                  FinishConfirmationScreen().launch(context);
                  showInDialog(context,
                          builder: (context) => ChooseComponentReceivingLot(
                                vehicle_id: '1',
                                job_no: '1',
                                route_id: '4',
                              ),
                          dialogAnimation: DialogAnimation.SCALE)
                      .then((value) {
                    // fetchData();
                    // setState(() {});
                  });
                },
                child: Text("Finish Racking / Schedule",
                    style: GoogleFonts.poppins(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mycolor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoText(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.poppins(color: Colors.black, fontSize: 16),
          children: [
            TextSpan(
                text: "$title ", style: TextStyle(fontWeight: FontWeight.w500)),
            TextSpan(
                text: value, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
