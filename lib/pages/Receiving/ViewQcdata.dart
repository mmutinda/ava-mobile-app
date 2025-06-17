import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/pages/Receiving/widget.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class QCView extends StatefulWidget {
  final Id;
  final chasis;
  const QCView({super.key, required this.Id, required this.chasis});
  @override
  State<QCView> createState() => _QCViewState();
}

class _QCViewState extends State<QCView> {
  var user = {};
  var checklistData = [];
  // var vehicles;
  var loadingText = '';
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      fetchData().then(
        (value) {
          if (checklistData.isEmpty) {
            print(value);
            setState(() {
              loadingText = 'No data available at the moment';
            });
          }
        },
      );
      ;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.chasis}'),
      ),
      body: RefreshIndicator(
        color: mycolor,
        onRefresh: () {
          return Future.delayed(
            const Duration(seconds: 1),
            () {
              fetchData().then(
                (value) {
                  toasty(context, "Refreshed",
                      bgColor: mycolor,
                      textColor: textWhite,
                      padding: EdgeInsets.all(12));
                },
              );
            },
          );
        },
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: SizedBox(
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : loadingText.isNotEmpty
                          ? ErrorMessageWidget(
                              errorMessage: loadingText,
                              onRetry: () {
                                fetchData().then(
                                  (value) {
                                    if (checklistData.isEmpty) {
                                      setState(() {
                                        loadingText =
                                            'No data available at the moment';
                                      });
                                    }
                                  },
                                );
                              },
                            )
                          : SizedBox(
                              child: ListView.builder(
                                itemCount: checklistData.length,
                                itemBuilder: (context, index) {
                                  return ChecklistItemCard(
                                    checklistItem: checklistData[index],
                                  );
                                },
                              ),
                            )),
            ),
          ],
        ),
      ),
    );
  }

  Future fetchData() async {
    setState(() {
      loadingText = '';
      isLoading = checklistData.isEmpty ? true : false;
    });
    String url = "${Api.api_url}viewVehicleReceivingChecklist/${widget.Id}";
    print(url);
    ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
    // pr.show();
    var responsedata = await httpget(url, user['data']["token"], context);
    print("responsedata: $responsedata");
    if (responsedata != null) {
      pr.hide();
      setState(() {
        isLoading = false;
        checklistData = (responsedata["data"] as List<dynamic>);
      });
    } else {
      pr.hide().whenComplete(() {
        setState(() {
          isLoading = false;
          loadingText = responsedata["message"].toString();
        });
        toasty(context, "${responsedata["message"]}",
            bgColor: Colors.red, textColor: textWhite);
      });
    }
    Future.delayed(const Duration(seconds: dismissseconds), () {
      if (pr.isShowing()) {
        pr.hide();
        setState(() {
          isLoading = false;
          loadingText = internetmessage;
        });
      }
    });
  }
}
