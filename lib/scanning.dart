import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class QRScanDialog extends StatefulWidget {
  @override
  _QRScanDialogState createState() => _QRScanDialogState();
}

class _QRScanDialogState extends State<QRScanDialog>
    with SingleTickerProviderStateMixin {
  MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    autoStart: true,
    formats: [
      BarcodeFormat.qrCode,
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.code93,
      BarcodeFormat.codabar,
      BarcodeFormat.itf,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
    ],
  );
  String? result;
  bool showRefresh = false;
  double zoomScale = 0.5;
  bool isBarcodeMode = false; // false = QR mode, true = Barcode mode
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _startRefreshTimer();

    // Setup pulse animation for scanner border
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
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

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (result == null && capture.barcodes.isNotEmpty) {
      final String? code = capture.barcodes.first.rawValue;
      if (code != null) {
        setState(() => result = code);
        Navigator.pop(context, result);
      }
    }
  }

  void _refreshCamera() {
    controller.start();
    setState(() {
      result = null;
      showRefresh = false;
    });
    _startRefreshTimer();
  }

  @override
  void dispose() {
    _animationController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    final dialogWidth = isBarcodeMode && isLargeScreen
        ? screenWidth * 0.9
        : (screenWidth > 420 ? 420.0 : screenWidth * 0.9);

    return Container(
      // backgroundColor: Colors.transparent,
      // insetPadding: EdgeInsets.all(20),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: isBarcodeMode && isLargeScreen ? 350 : 420,
        width: dialogWidth,
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
              child: MobileScanner(
                controller: controller,
                onDetect: _onBarcodeDetected,
              ),
            ),
            // Dynamic scanning area overlay with animated corners
            Center(
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: isBarcodeMode
                          ? (isLargeScreen ? screenWidth * 0.75 : 320)
                          : 260,
                      height: isBarcodeMode ? 180 : 260,
                      child: Stack(
                        children: [
                          // Corner markers for flexible scanning with animated glow
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: mycolor, width: 4),
                                  left: BorderSide(color: mycolor, width: 4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: mycolor.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: mycolor, width: 4),
                                  right: BorderSide(color: mycolor, width: 4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: mycolor.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: mycolor, width: 4),
                                  left: BorderSide(color: mycolor, width: 4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: mycolor.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: mycolor, width: 4),
                                  right: BorderSide(color: mycolor, width: 4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: mycolor.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 16,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        isBarcodeMode ? "Barcode Mode" : "QR Code Mode",
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Scans in any direction",
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Row(
                children: [
                  SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: Icon(
                        isBarcodeMode ? Icons.qr_code : Icons.view_week,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          isBarcodeMode = !isBarcodeMode;
                        });
                      },
                      tooltip:
                          isBarcodeMode ? 'Switch to QR' : 'Switch to Barcode',
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 70,
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
            Positioned(
              bottom: 16,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: mycolor,
                    inactiveTrackColor: Colors.white30,
                    thumbColor: Colors.white,
                    overlayColor: mycolor.withOpacity(0.3),
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: zoomScale,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (value) {
                      setState(() {
                        zoomScale = value;
                      });
                      controller.setZoomScale(zoomScale);
                    },
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
