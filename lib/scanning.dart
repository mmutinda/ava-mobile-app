import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class QRScanDialog extends StatefulWidget {
  @override
  _QRScanDialogState createState() => _QRScanDialogState();
}

class _QRScanDialogState extends State<QRScanDialog> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? result;
  bool showRefresh = false;

  @override
  void initState() {
    super.initState();
    _startRefreshTimer();
  }

  void _startRefreshTimer() {
    Future.delayed(Duration(seconds: 10), () {
      if (result == null && mounted) {
        setState(() {
          showRefresh = true;
        });
      }
    });
  }

  void _onQRViewCreated(QRViewController ctrl) {
    controller = ctrl;
    ctrl.scannedDataStream.listen((scanData) {
      if (result == null) {
        controller?.pauseCamera();
        setState(() => result = scanData.code);
        Navigator.pop(context, result);
      }
    });
  }

  void _refreshCamera() {
    controller?.resumeCamera();
    setState(() {
      result = null;
      showRefresh = false;
    });
    _startRefreshTimer();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
     
      // backgroundColor: Colors.transparent,
      // insetPadding: EdgeInsets.all(20),
      child: Container(
        height: 420,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: Offset(0, 10),
            )
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: mycolor,
                  borderRadius: 12,
                  borderLength: 32,
                  borderWidth: 8,
                  cutOutSize: 260,
                ),
              ),
            ),
            Positioned(
              top: 16,
              child: Text(
                "Align QR within frame",
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: showRefresh
                    ? ElevatedButton.icon(
                        key: ValueKey("refresh"),
                        onPressed: _refreshCamera,
                        icon: Icon(Icons.refresh),
                        label: Text("Refresh", style: GoogleFonts.poppins()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.deepPurple,
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 5,
                        ),
                      )
                    : Shimmer.fromColors(
                        key: ValueKey("scanning"),
                        baseColor: Colors.white54,
                        highlightColor: Colors.white,
                        child: Text(
                          "🔍 Scanning...",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
