import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/constants.dart';

class AuditChecklistItem {
  final String sn;
  final String group;
  final String resp;
  final String description;
  int? rating;
  String? comment;

  AuditChecklistItem({
    required this.sn,
    required this.group,
    required this.resp,
    required this.description,
    this.rating,
    this.comment,
  });
}

class AuditChecklistPage extends StatefulWidget {
  const AuditChecklistPage({super.key});

  @override
  State<AuditChecklistPage> createState() => _AuditChecklistPageState();
}

class _AuditChecklistPageState extends State<AuditChecklistPage> {
  List<AuditChecklistItem> auditItems = [
    AuditChecklistItem(
        sn: '1.1',
        group: 'Man',
        resp: 'Prodn',
        description: 'Is the Operator Skill Level match the requirement'),
    AuditChecklistItem(
        sn: '1.2',
        group: 'Man',
        resp: 'Prodn',
        description: 'Are the Self Check points known & confirmed by operator'),
    AuditChecklistItem(
        sn: '1.2',
        group: 'Man',
        resp: 'Prodn',
        description: 'check station condition before & at the end of shift'),
    AuditChecklistItem(
        sn: '1.2',
        group: 'Man',
        resp: 'Prodn',
        description:
            'Is the operator aware of the torque parameter & torque tool set value'),
    AuditChecklistItem(
        sn: '1.2',
        group: 'Man',
        resp: 'Prodn',
        description:
            'Is the operator awares about the consequences of the keypoints in the operation'),
    AuditChecklistItem(
        sn: '1.2',
        group: 'Man',
        resp: 'Prodn',
        description:
            'Is the operator aware of the quality requirements/safety requirements'),
    AuditChecklistItem(
        sn: '1.2',
        group: 'Man',
        resp: 'Prodn',
        description:
            'Is the operator aware of the consequence of the failure.'),
    AuditChecklistItem(
        sn: '1.2',
        group: 'Man',
        resp: 'Prodn',
        description: 'Are standard work instructions followed by the Operator'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Machine',
        resp: 'ME',
        description: 'Are Specified Equipments / Tools used'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Machine',
        resp: 'ME',
        description:
            'Are they calibrated (in case of gauges) / Are they periodically checked (incase of Equip)'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Machine',
        resp: 'FM',
        description:
            'Are they calibrated (in case of gauges) / Are they periodically checked (incase of Equip)'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Machine',
        resp: 'QM',
        description:
            'Are they calibrated (in case of gauges) / Are they periodically checked (incase of Equip)'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Machine',
        resp: 'ME',
        description: 'Is the tool use procedure adhered to requirement'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Machine',
        resp: 'ME',
        description: ' Is the Poka yoke working'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Machine',
        resp: 'ME',
        description: 'Is the boundary marking on each station visible'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Machine',
        resp: 'ME',
        description: 'Is the tool parking available and is it being utilized?'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Machine',
        resp: 'ME',
        description: 'Is the tool parking available and is it being utilized?'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Method',
        resp: 'Prodn',
        description: 'Is the Process Flow update as on date available'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Method',
        resp: 'Prodn',
        description:
            'Are the SWI/JES/Assembly manual available in the station?'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Method',
        resp: 'Prodn',
        description: 'Are the operations sequence defined'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Method',
        resp: 'Prodn',
        description: 'Is the Assembly procedure being followed?'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Method',
        resp: 'Prodn',
        description: 'Check station condition before & at the end of shift'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Method',
        resp: 'Prodn',
        description: ' Is DS/DZ characteristic monitoring Process done?'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Method',
        resp: 'Prodn',
        description: 'Are parts easily identified after shopping?'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Method',
        resp: 'Prodn',
        description: 'Is there a safe ergonomics practiced in the station'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Method',
        resp: 'Prodn',
        description:
            'Is there 5S practice in the station during working hours?'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Method',
        resp: 'Prodn',
        description:
            ' Is the station organized during production? 5S in process?'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Method',
        resp: 'Prodn',
        description:
            ' Are defects properly tracked in History card / check  sheets'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Method',
        resp: 'Prodn',
        description: '  Is the skill matrix available in the station?'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Method',
        resp: 'Prodn',
        description:
            '  Is the product quality standard known to the operators?'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Method',
        resp: 'Prodn',
        description:
            'Is there a process in place to capture the lessons learnt in the respective stations'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Material',
        resp: 'Logistic',
        description: ' Is adequate traceability available for material'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Material',
        resp: 'Logistic',
        description: ' Is adequate traceability available for material'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Material',
        resp: 'Logistic',
        description: 'Are non-conformance parts handled as per procedure'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Material',
        resp: 'Logistic',
        description:
            'Is the work station is free of unwanted material to avoid wrong assembly'),
    AuditChecklistItem(
        sn: '5.1',
        group: 'Milieu',
        resp: 'Prodn',
        description:
            'Is the lighting appropriate with respect to the station requirement'),
    AuditChecklistItem(
        sn: '5.1',
        group: 'Milieu',
        resp: 'Prodn',
        description: 'Is there an identified waste bin in the station?'),
    AuditChecklistItem(
        sn: '5.1',
        group: 'Milieu',
        resp: 'Prodn',
        description: 'Are the safety equipments available to operator'),
    AuditChecklistItem(
        sn: '5.1',
        group: 'Milieu',
        resp: 'Prodn',
        description: 'Is Control of Hazardous materials adhered to standards'),
    AuditChecklistItem(
        sn: '5.1',
        group: 'Milieu',
        resp: 'Logistic',
        description: 'Is Control of Hazardous materials adhered to standards'),
    AuditChecklistItem(
        sn: '5.1',
        group: 'Milieu',
        resp: 'Prodn',
        description:
            'Is Safety instruction displayed in the workstation (PPE)?'),
  ];

  String? selectedResp = "Prodn";
  String? selectedGroup = "Man";

  List<AuditChecklistItem> get filteredItems {
    return auditItems.where((item) {
      final matchResp = selectedResp == null || item.resp == selectedResp;
      final matchGroup = selectedGroup == null || item.group == selectedGroup;
      return matchResp && matchGroup;
    }).toList();
  }

  Color getRatingColor(int value) {
    switch (value) {
      case 0:
        return Colors.redAccent;
      case 1:
        return Colors.orangeAccent;
      case 2:
        return Colors.green;
      case 3:
        return Colors.grey;
      default:
        return Colors.transparent;
    }
  }

  String getRatingLabel(int value) {
    switch (value) {
      case 0:
        return "Non-Conforming";
      case 1:
        return "Needs Improvement";
      case 2:
        return "OK";
      case 3:
        return "N/A";
      default:
        return "";
    }
  }

  void handleSubmit() {
    final answered = auditItems
        .where((item) => item.rating != null)
        .map((item) => {
              'sn': item.sn,
              'group': item.group,
              'resp': item.resp,
              'description': item.description,
              'rating': item.rating,
              'comment': item.comment ?? '',
            })
        .toList();

    // For demo: print in console
    print("Answered Items:");
    for (var entry in answered) {
      print(entry);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Submitted successfully! Check console.")),
    );
  }

  bool showFilters = false;

  @override
  Widget build(BuildContext context) {
    final uniqueResps = auditItems.map((e) => e.resp).toSet().toList();
    final uniqueGroups = auditItems.map((e) => e.group).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text("Audit Checklist",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Responsible: ${selectedResp}",
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text("Group: ${selectedGroup}",
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              showFilters ? Icons.filter_alt_off : Icons.filter_alt,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                showFilters = !showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          AnimatedCrossFade(
            crossFadeState: showFilters
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: showFilters
                ? const Duration(milliseconds: 500)
                : const Duration(milliseconds: 0),
            firstChild: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Card(
                color: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const Text(
                      //   "Filter Checklist",
                      //   style: TextStyle(
                      //       fontSize: 16, fontWeight: FontWeight.bold),
                      // ),
                      // const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("RESP",
                                    style: TextStyle(fontSize: 14)),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey.shade100,
                                  ),
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    value: selectedResp,
                                    hint: const Text("Select RESP"),
                                    items: uniqueResps.map((resp) {
                                      return DropdownMenuItem<String>(
                                        value: resp,
                                        child: Text(resp),
                                      );
                                    }).toList(),
                                    onChanged: (value) =>
                                        setState(() => selectedResp = value),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Group",
                                    style: TextStyle(fontSize: 14)),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey.shade100,
                                  ),
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    value: selectedGroup!.isNotEmpty
                                        ? selectedGroup
                                        : null,
                                    hint: const Text("Select Group"),
                                    items: uniqueGroups.map((group) {
                                      return DropdownMenuItem<String>(
                                        value: group,
                                        child: Text(group),
                                      );
                                    }).toList(),
                                    onChanged: (value) => setState(
                                        () => selectedGroup = value ?? ''),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),

          // Checklist
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 30),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox,
                              size: 48, color: Colors.grey.shade500),
                          const SizedBox(height: 12),
                          Text(
                            "No items found",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Try adjusting your filters or search.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return Card(
                        color: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${index + 1}. ${item.description}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 10,
                                children: List.generate(4, (value) {
                                  return ChoiceChip(
                                    label: Text(getRatingLabel(value)),
                                    selected: item.rating == value,
                                    selectedColor: getRatingColor(value),
                                    onSelected: (_) {
                                      setState(() {
                                        item.rating = value;
                                      });
                                    },
                                  );
                                }),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                initialValue: item.comment,
                                decoration: InputDecoration(
                                  hintText: 'Add comment (optional)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                ),
                                onChanged: (val) {
                                  item.comment = val;
                                },
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Submit Button
          filteredItems.isEmpty
              ? Container()
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        backgroundColor: mycolor,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.send),
                      label: const Text("Submit"),
                      onPressed: handleSubmit,
                    ),
                  ),
                )
        ],
      ),
    );
  }
}
