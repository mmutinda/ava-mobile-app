import 'package:flutter/material.dart';
import 'package:isuze_pqcs/pages/QCA_home.dart/checkList.dart';
import 'package:isuze_pqcs/pages/QCA_home.dart/illustration.dart';
import 'package:isuze_pqcs/pages/QCA_home.dart/notes.dart';

class ReportPage extends StatefulWidget {
  final gcaType;
  final stepId;
  final vehicle_id;
  final vinNo;
  final modelName;
  final categoryId;
  final query_group_name;
  const ReportPage(
      {super.key,
      this.gcaType,
      this.stepId,
      this.vehicle_id,
      this.vinNo,
      this.modelName,
      this.categoryId,
      this.query_group_name});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage>
    with SingleTickerProviderStateMixin {
  var user = {};
  late TabController _tabController;

  final _selectedColor = const Color(0xff1a73e8);
  final _tabs = const [
    Tab(
      child: FittedBox(child: Text('Notes', textAlign: TextAlign.center)),
    ),
    Tab(
      child:
          FittedBox(child: Text('illustrations', textAlign: TextAlign.center)),
    ),
    Tab(
      child: FittedBox(child: Text('CheckList', textAlign: TextAlign.center)),
    ),
  ];

  @override
  void initState() {
    _tabController = TabController(length: _tabs.length, vsync: this);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            "Report ",
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: _tabs,
            labelColor: Colors.white,
            indicatorColor: _selectedColor,
            unselectedLabelColor: Colors.grey,
            indicatorSize: TabBarIndicatorSize.label,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            Notes(gcaType: widget.gcaType, stepId: widget.stepId),
            illustration(gcaType: widget.gcaType, stepId: widget.stepId),
            CheckList(
              gcaType: widget.gcaType,
              stepId: widget.stepId,
              vehicle_id: widget.vehicle_id,
              CategoryId: widget.categoryId,
              query_group_name: widget.query_group_name,
            )
            // CNCMaterialMissingParts(),
          ],
        ));
  }
}
