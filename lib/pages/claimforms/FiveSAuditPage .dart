import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';

class FiveSAuditPage extends StatefulWidget {
  @override
  _FiveSAuditPageState createState() => _FiveSAuditPageState();
}

class _FiveSAuditPageState extends State<FiveSAuditPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, int?> scores = {};
  final Map<String, TextEditingController> comments = {};

  final List<String> sections = [
    'SORT (KUCHAGUA)',
    'SET IN ORDER (KUPANGA)',
    'SHINE (KUSAFISHA)',
    'STANDARDIZE (KUSANIFISHA)',
    'SUSTAIN (KUDUMISHA)',
  ];

  final Map<String, List<String>> questions = {
    'SORT (KUCHAGUA)': [
      'Are all items, packaging, raw materials needed?',
      'Are all machines, benches, tools needed?',
      'Are all tools, cleaning/testing equipment needed?',
      'Is all paperwork at the workstation required?',
      'Are all surfaces/floor clean of items that are not currently needed?',
      'Are all the furniture present in the work place needed?',
    ],
    'SET IN ORDER (KUPANGA)': [
      'Are the work areas and its processes identified? Machines are clearly labelled.',
      'Are all locations for materials clearly marked and respected?',
      'All gangways are clearly marked and respected?',
      'Are all location of equipment clearly marked and respected?',
      'Are all equipment clearly marked?',
      'The floor layout allows for easy process flow?',
    ],
    'SHINE (KUSAFISHA)': [
      'Is there a cleaning schedule? Is it being used?',
      'Are all floors/ stairs free from dirt, dust, trip and fall hazards, slip?',
      'Are all machines clean – underneath, surface and inside machine?',
      'Are walls painted and clean?',
      'Are all rubbish and reject material in an appropriate bin?',
      'Lighting and ventilation are okay for the job being done?',
      'Are all PPE maintained in a sanitary and reliable condition',
    ],
    'STANDARDIZE (KUSANIFISHA)': [
      'Visual management is practiced in the place. Is it possible to identify items at a glance?',
      'Do the workstation have SOP sheets displayed?',
      'Areas of improvement identified during the previous audit have been completed?',
      'Is there a display of the team’s performance in 5S',
      'Does the team use and respect the 5S standards?',
    ],
    'SUSTAIN (KUDUMISHA)': [
      'Does the team constantly conduct self-audit?',
      'All PPE being worn correctly?',
      'All 5S members are assigned 5S activities to be completed at least once a week?',
      'Does the place look tidy and clean?',
      'Everyone understands what 5S is and puts it in practice constantly',
    ],
  };
  final Map<String, List<String>> questionsDesc = {
    'SORT (KUCHAGUA)': [
      'Look for excess material/ unwanted material',
      'Unnecessary equipment, tools, stands etc.',
      'Look in lockers, drawers, cabinets, on top of machines for unnecessary items',
      'Out-dated or otherwise unnecessary posters, memos, announcements, reports.',
      'Look on top of machines, benches, tool trolleys and the work area',
      'Look for excess or otherwise unnecessary chairs, benches and/or broken furniture',
    ],
    'SET IN ORDER (KUPANGA)': [
      'Everyone understands what 5S is and puts it in practice constantly?',
      'Check max/min stock values safely staked? Check floor/ shelf marking',
      'Look for non-standard marking, blockage or gangways.',
      'Look for equipment locations, are they respected?',
      'Check for unlabeled items, wrong-labelled items, illegible marking?',
      'Look for placement of raw materials, blockages of production boards etc.',
    ],
    'SHINE (KUSAFISHA)': [
      'Check if the schedule is displayed in the workplace. Are people doing their responsibilities as stipulated?',
      'Look for presence of dirt, dust on the floors, water or oil spills on the floors.',
      'Check oil, grease, dust and product/by-product contaminations. Also  check for grime accumulation',
      'Check for dirty walls, cobwebs, unrequired stickers on the walls',
      'Look for cluttered floor, benches, check what is in the reject bins.',
      'Look for broken or blown off bulb/fluorescent tubes, poorly ventilated areas and broken switches.',
      'Look for dirty, oily overalls, helmets etc.',
    ],
    'STANDARDIZE (KUSANIFISHA)': [
      'Look for broken or blown off bulb/fluorescent tubes, poorly ventilated areas and broken switches',
      'Visual check that the SOP is displayed at or near each workstation',
      'Look for evidence of improvement of the Section, action plans, completion dates',
      'Look for visual display of graphs or radar charts?',
      'Look for wrongly painted equipment, piping, wrong color labelling, wrong font, non-standard notices, displays, etc.',
    ],
    'SUSTAIN (KUDUMISHA)': [
      'Look for visual display of audit results and actions for improvement',
      'Look for visual display of audit results and actions for improvement',
      'Is the RTM Board updated with current information. Also check noticeboard or evidence of responsibilities.',
      'Look at the entire place for cobwebs, dusty floor, broken boards, unemptied bins etc.',
      'elect and interview members randomly. Ask what they know about 5S',
    ],
  };
  var user = {};
  @override
  void initState() {
    super.initState();
//getting user data from shared preferences
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
    });

    /// Initialize scores and comments for each question
    for (var section in questions.keys) {
      for (var q in questions[section]!) {
        scores[q] = null;
        comments[q] = TextEditingController();
      }
    }
  }

  Widget _buildQuestion(String question, String description) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: 'Score (0-1)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              value: scores[question],
              items: List.generate(
                2,
                (i) => DropdownMenuItem(value: i, child: Text('$i')),
              ),
              onChanged: (val) => setState(() => scores[question] = val),
              validator: (val) => val == null ? 'Required' : null,
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: comments[question],
              decoration: InputDecoration(
                labelText: 'Comments',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> qs, List<String> descs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(title,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: mycolor)),
        SizedBox(height: 10),
        for (int i = 0; i < qs.length; i++) _buildQuestion(qs[i], descs[i]),
      ],
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        List<Map<String, dynamic>> data = [];

        questions.forEach((section, qs) {
          for (int i = 0; i < qs.length; i++) {
            final question = qs[i];
            data.add({
              'category': section,
              'question': question,
              'score': scores[question] ?? 0,
              'comment': comments[question]?.text.trim() ?? '',
            });
          }
        });
        // print(data);
        log(jsonEncode(data));
        String url = "${Api.api_url}loaAPiShedulledUnits";
        var response = await httppost(url, user['data']["token"], context);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Audit submitted successfully!')),
          );
        } else {
          throw Exception('Server returned status: ${response.statusCode}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('5S Audit Checklist'), backgroundColor: mycolor),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ...sections
                  .map(
                      (s) => _buildSection(s, questions[s]!, questionsDesc[s]!))
                  .toList(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit Audit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mycolor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  textStyle: TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
