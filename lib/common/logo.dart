import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo container with elegant styling
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Image.asset(
              "images/logo2.png",
              width: isSmallScreen ? 180 : 250,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 32),

          // Welcome message
          Column(
            children: [
              Text(
                'InfoPulse System',
                style: TextStyle(
                  fontSize: isSmallScreen ? 22 : 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Professional Quality Management',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                width: 60,
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
