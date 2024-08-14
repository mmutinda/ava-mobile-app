import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:photo_view/photo_view.dart';

class illustration extends StatefulWidget {
  // final String vinNo;
  // final String modelName;
  final gcaType;
  final stepId;
  // final Map<String, dynamic> data;

  illustration({
    // required this.vinNo,
    // required this.modelName,
    required this.gcaType,
    required this.stepId,
    // required this.data,
  });

  @override
  _illustrationState createState() => _illustrationState();
}

class _illustrationState extends State<illustration> {
  bool isLoading = false;
  String message = '';
  var user = {};
  var data;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      fetchData();
    });
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    var url = "${Api.api_url}loadZoneItems/${widget.stepId}/${widget.gcaType}";
    print(url);

    try {
      var response = await httpget(url, user['data']['token'], context);

      // print(response['data']);
      if (response == null) {
        print("No Internet");
        // Handle no internet scenario
        return;
      }

      if (response['success'] && response['data'] != null) {
        // List<dynamic> responseData = response['data'];
        setState(() {
          isLoading = false;
          data = response['data'];
          message = '';
        });
      } else {
        // Handle other scenarios
        setState(() {
          isLoading = false;
          message = '${response['msg']}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        message = 'Network Problem';
      });
      // message = '${"Network Problem"}';
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(data['zoneitems']);
    return Scaffold(
      body: SingleChildScrollView(
        child: data == null
            ? Center(
                child: Container(
                  width: double.infinity,
                  child: SizedBox(
                    height: 200,
                    child: FacebookLikeShimmer2(),
                  ),
                ),
              )
            : message.isNotEmpty
                ? ErrorMessageWidget(
                    errorMessage: message,
                    onRetry: () {
                      fetchData();
                    },
                  ) // Show message for success or failure
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: widget.gcaType == 'CV'
                        ? _buildCardForLCV()
                        : _buildCardForLCV(),
                  ),
      ),
    );
  }

  Widget _buildCardForCV() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.stepId == '4' ||
            widget.stepId == '5' ||
            widget.stepId == '6' ||
            widget.stepId == '7' ||
            widget.stepId == '9')
          _buildImageContainer(),
      ],
    );
  }

  Widget _buildCardForLCV() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.stepId == '4' ||
            widget.stepId == '5' ||
            widget.stepId == '6' ||
            widget.stepId == '7' ||
            widget.stepId == '8' ||
            widget.stepId == '9')
          _buildImageContainer(),
      ],
    );
  }

  Widget _buildImageContainer() {
    return Container(
      // Equivalent to ion-card
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 8),
            child: _buildImageCards(),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCards() {
    return Column(
      children: [
        // Container for step_id 4

        Container(
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            children: [
              _buildImageCard(data['imageOneUri']),
              _buildImageCard(data['imageTwoUri']),
              _buildImageCard(data['imageThreeUri']),
            ],
          ),
        ),
        // Repeat similar structures for other step_ids
      ],
    );
  }

  // Widget _buildImageCard(String? imageUrl) {
  //   return Container(
  //     child: imageUrl != null
  //         ? Image.network(imageUrl)
  //         : SizedBox(),
  //   );
  // }
  Widget _buildImageCard(String? imageUrl) {
    return Container(
      child: imageUrl != null
          ? GestureDetector(
              onTap: () {
                // Handle image tap if needed
              },
              child: PhotoView(
                backgroundDecoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                imageProvider: NetworkImage(imageUrl),

                // initialScale: PhotoViewComputedScale.contained,
                enableRotation: true, // Enable image rotation
              ),
            )
          : SizedBox(),
    );
  }
}
