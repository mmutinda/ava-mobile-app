import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:honeywell_mobility_sdk/honeywell_mobility_sdk.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/pages/QCA_home.dart/chooseGCA.dart';
import 'package:nb_utils/nb_utils.dart';

class QCAHome extends StatefulWidget {
  @override
  _QCAHomeState createState() => _QCAHomeState();
}

class _QCAHomeState extends State<QCAHome> {
  BarcodeReader? _barcodeReader;
  String? data;
  String? error;
  String? trigger;
  String scaned = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      _scanfun();
    });
    _initiatescanner();
  }

  Future<bool> _invoke(
    Future<void> Function(BarcodeReader reader) callback,
  ) async {
    if (_barcodeReader == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unsupported device.')),
      );
      return false;
    }

    try {
      await callback(_barcodeReader!);
    } on PlatformException catch (e) {
      error = '${e.message} (${e.code}) (${e.details})';
      if (mounted) setState(() {});
    }
    return true;
  }

  Future<void> _scanfun() async {
    await _invoke(
      (reader) => reader.setProperty(
        BarcodeReaderProperty.trigger.scanMode(TriggerScanMode.oneShot),
      ),
    );
    final supported = await _invoke((reader) => reader.claim());
    print(supported);
  }

  Future<void> _initiatescanner() async {
    _barcodeReader = await HoneywellMobilitySdk.createBarcodeReader(
      onRead: (event) {
        var sku = event.barcodeData;
        showInDialog(context,
            builder: (context) => ChooseGCA(
                  sku: sku,
                ),
            dialogAnimation: DialogAnimation.SCALE);

        print(sku);
        error = null;
        if (mounted) {
          // setState(() {});
        }
      },
      onFailure: (event) {
        error = 'Could not read barcode.';
        awesomeTopSnackbar(context, "Try Again",
            iconWithDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(),
                color: Colors.white),
            icon: Icon(
              Icons.close,
              color: Colors.red,
            ),
            backgroundColor: Colors.red[900]);
        data = null;
        if (mounted) {
          // setState(() {});
        }
      },
      onTrigger: (event) {
        print(event);
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('GCA'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(0),
                        leading: Icon(
                          Icons.chat_bubble,
                          color: mycolor,
                        ),
                        title: Text('CV-GCA'),
                        onTap: () {
                          showInDialog(context,
                              builder: (context) => ChooseGCA(
                                    sku: "JAAN1R81KN7100812",
                                  ),
                              dialogAnimation: DialogAnimation.SCALE);
                        },
                      ),
                    ),
                  ),
                  Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(0),
                        leading: Icon(
                          Icons.chat_bubble,
                          color: mycolor,
                        ),
                        title: Text('LCV-GCA'),
                        onTap: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(),
                        backgroundColor: mycolor,
                        foregroundColor: textWhite),
                    onPressed: () async {
                      await _invoke(
                        (reader) => reader.setProperty(
                          BarcodeReaderProperty.trigger
                              .scanMode(TriggerScanMode.oneShot),
                        ),
                      );
                      final supported =
                          await _invoke((reader) => reader.claim());
                      if (supported) {
                        await _invoke((reader) => reader.softwareTrigger(true));
                        setState(() {
                          // isButtonEnabled = false;
                        });
                        Future.delayed(
                          const Duration(seconds: 2),
                          () async {
                            await _invoke(
                                (reader) => reader.softwareTrigger(false));
                            // await _invoke((reader) => reader.release());
                            setState(() {
                              // isButtonEnabled = true;
                            });
                          },
                        );
                      }
                    },
                    child: const Text('SCAN')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
