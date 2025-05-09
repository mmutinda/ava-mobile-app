import 'package:flutter/material.dart';
import 'package:isuze_pqcs/pages/Receiving/Dispatch_take_photos.dart';
import 'package:isuze_pqcs/pages/Receiving/view.dart';

class VehicleReceivingHome extends StatefulWidget {
  final id;
  final title;
  final sku;

  const VehicleReceivingHome({
    super.key,
    this.id,
    this.title,
    required this.sku,
  });

  @override
  State<VehicleReceivingHome> createState() => _VehicleReceivingHomeState();
}

class _VehicleReceivingHomeState extends State<VehicleReceivingHome>
    with SingleTickerProviderStateMixin {
  var user = {};
  late TabController _tabController;

  final _tabs = const [
    Tab(
      child: FittedBox(
          child: Text('Upload Image & View', textAlign: TextAlign.center)),
    ),
    Tab(
      child: FittedBox(
          child: Text('View Vehicle Data', textAlign: TextAlign.center)),
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

  TextEditingController searchController = TextEditingController();
  String searchText = '';
  @override
  Widget build(BuildContext context) {
    Widget _buildSearchField() {
      return TextField(
        autofocus: true,
        style: TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        controller: searchController,
        onChanged: (value) {
          setState(() {
            searchText = value;
          });
        },
        decoration: InputDecoration(
            hintText: 'search...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white)),
      );
    }

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(90),
          child: AppBar(
            title: FittedBox(
              child: Text(
                "${widget.title} - ${widget.sku}",
              ),
            ),
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              tabs: _tabs,
              // labelColor: _selectedColor,
              labelColor: Colors.white,
              indicatorColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              indicatorSize: TabBarIndicatorSize.label,
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            Dispatch_take_photos(
              id: widget.id,
              title: widget.title,
              sku: widget.sku,
            ),
            ViewEntryFormPage(
              VehicleId: widget.id.toString(),
            ),
          ],
        ));
  }
}
