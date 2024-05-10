import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

Widget gap() => const SizedBox(height: 16);
Widget width() => const SizedBox(width: 16);

class FacebookLikeShimmer extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  FacebookLikeShimmer({
    this.width = 200.0,
    this.height = 20.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              padding: EdgeInsets.all(12),
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: borderRadius,
              ),
            ),
          ),
        );
      },
    );
  }
}

class ErrorMessageWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry; // Callback for retry action, if needed

  ErrorMessageWidget({required this.errorMessage, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 80.0,
          ),
          SizedBox(height: 20.0),
          Text(
            'Oops!',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.0),
          Text(
            errorMessage,
            style: TextStyle(
              fontSize: 16.0,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) // Show retry button if callback provided
            SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: onRetry,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class FacebookLikeShimmer2 extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  FacebookLikeShimmer2({
    this.width = 200.0,
    this.height = 20.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            2, // You can adjust the cross axis count as per your requirement
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: 10,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              padding: EdgeInsets.all(12),
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: borderRadius,
              ),
            ),
          ),
        );
      },
    );
  }
}

class showPosition extends StatelessWidget {
  final String errorMessage;

  showPosition({required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.info_outline,
            color: mycolor,
            size: 80.0,
          ),
          // SizedBox(height: 20.0),
          Text(
            'Unit In',
            style: TextStyle(
              fontSize: 24.0,
            ),
          ),
          Text(
            errorMessage,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Ok'),
            ),
          ),
        ],
      ),
    );
  }
}

class SignatureField extends StatefulWidget {
  final void Function(Uint8List?)? onSignatureChanged;

  const SignatureField({Key? key, this.onSignatureChanged}) : super(key: key);

  @override
  _SignatureFieldState createState() => _SignatureFieldState();
}

class _SignatureFieldState extends State<SignatureField> {
  late GlobalKey<SfSignaturePadState> _signaturePadKey;
  Uint8List? _signatureImage;

  @override
  void initState() {
    super.initState();
    _signaturePadKey = GlobalKey<SfSignaturePadState>();
  }

  Future<void> _saveSignature() async {
    final data = await _signaturePadKey.currentState?.toImage(pixelRatio: 3.0);
    if (data != null) {
      final byteData = await data.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        setState(() {
          _signatureImage = byteData.buffer.asUint8List();
        });
        if (widget.onSignatureChanged != null) {
          widget.onSignatureChanged!(_signatureImage);
        }
      }
    }
  }

  void _clearSignature() {
    _signaturePadKey.currentState?.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340,
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SfSignaturePad(
                key: _signaturePadKey,
                backgroundColor: white,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _saveSignature,
                child: Text('Save Signature'),
              ),
              ElevatedButton(
                onPressed: _clearSignature,
                child: Text('Clear Signature'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
