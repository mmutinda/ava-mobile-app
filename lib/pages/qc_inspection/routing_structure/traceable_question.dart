import 'dart:convert';

import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:honeywell_mobility_sdk/honeywell_mobility_sdk.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class TraceableQuestion extends StatefulWidget {
  final int id;
  final String question;
  final can_sign;
  final checkanswered;
  final answer_given;
  final ValueChanged<String> onValueChanged;
  final ValueChanged<String> onValueChanged2;

  const TraceableQuestion({
    Key? key,
    required this.id,
    required this.question,
    required this.onValueChanged,
    required this.onValueChanged2,
    this.can_sign,
    this.checkanswered,
    this.answer_given,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TraceableQuestionState createState() => _TraceableQuestionState();
}

class _TraceableQuestionState extends State<TraceableQuestion>
    with AutomaticKeepAliveClientMixin {
  late TextEditingController inputController;
  Uint8List? _signatureImage;

  @override
  bool get wantKeepAlive => true;
  BarcodeReader? _barcodeReader;
  String? data;
  String? error;
  String? trigger;
  String scaned = '';
  @override
  void initState() {
    super.initState();
    // _initiatescanner();
    inputController = TextEditingController();
    inputController = TextEditingController(text: widget.answer_given);
    inputController.addListener(_handleValueChanged);
    // inputController.addListener(_handleValueChanged);
    Future.delayed(const Duration(seconds: 1), () {
      _scanfun();
    });
    _initiatescanner();
  }

  @override
  void dispose() {
    inputController.removeListener(_handleValueChanged);
    inputController.dispose();
    super.dispose();
  }

  void _handleValueChanged() {
    widget.onValueChanged(inputController.text);
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
        setState(() {
          inputController.text = sku;
          scaned = event.barcodeData;
        });
        // print(sku);
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
    // print(widget.answer_given == '');
    super.build(context);
    return Container(
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.question,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          TextFormField(
            enabled: widget.answer_given == '' ? true : false,
            controller: inputController,
            onChanged: (value) {
              print(value);
            },
            decoration: InputDecoration(
              labelText: 'Input',
              isDense: true,
              hintText: 'Enter input Here',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: OutlineInputBorder(),
              suffixIcon: Padding(
                padding: EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () async {
                    _initiatescanner().then((value) async {
                      await _invoke(
                        (reader) => reader.setProperty(
                          BarcodeReaderProperty.trigger
                              .scanMode(TriggerScanMode.oneShot),
                        ),
                      ).then((value) {});
                      final supported =
                          await _invoke((reader) => reader.claim());
                      if (supported) {
                        await _invoke((reader) =>
                            reader.softwareTrigger(true).then((value) {}));
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
                    });
                  },
                  child: widget.answer_given == ''
                      ? Icon(
                          Icons.qr_code_scanner_rounded,
                          color: mycolor,
                          size: 35,
                        )
                      : Icon(
                          Icons.done,
                          color: mycolor,
                        ),
                ),
              ),
            ),
          ),
          if (widget.can_sign == 'Yes' && widget.checkanswered == false) ...[
            if (_signatureImage != null) ...[
              Container(
                height: 80,
                width: 100,
                // decoration: BoxDecoration(
                //   border: Border.all(color: Colors.grey),
                // ),
                // child: Image.memory(_signatureImage!),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      child: SizedBox(
                        child: Image.memory(
                          _signatureImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 70,
                      child: InkWell(
                        onTap: () {
                          print("tapped");
                          setState(() {
                            _signatureImage = null;
                          });
                        },
                        child: Container(
                          child: CircleAvatar(
                            backgroundColor: app_colorPrimary,
                            radius: 15,
                            child: Icon(
                              Icons.close,
                              color: textWhite,
                              size: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              TextButton.icon(
                  onPressed: () {
                    showInDialog(context,
                        builder: (context) => SignatureField(
                              onSignatureChanged: (signature) async {
                                // Do something with the signature
                                setState(() {
                                  _signatureImage = signature;
                                });
                                String base64Image = 'data:image/png;base64,' +
                                    base64Encode(_signatureImage!);

                                widget.onValueChanged2(base64Image);
                                // print('Signature saved');
                                Navigator.pop(context);
                              },
                            ),
                        dialogAnimation: DialogAnimation.SLIDE_TOP_BOTTOM);
                  },
                  icon: Icon(Icons.edit),
                  label: Text("Sign Here")),
            ]
          ],
          const Divider(),
        ],
      ),
    );
  }
}
