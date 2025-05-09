import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:isuze_pqcs/common/constants.dart';

class JobCardWidget extends StatelessWidget {
  final String Lot_No;
  final String clientName;
  final String vin_no;
  final String engine_no;
  final String color;
  final String model;
  final String deliveryDate;

  const JobCardWidget({
    Key? key,
    required this.deliveryDate,
    required this.Lot_No,
    required this.clientName,
    required this.vin_no,
    required this.engine_no,
    required this.color,
    required this.model,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatDate(deliveryDate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [mycolor, Colors.indigoAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child:
                    _buildInfoRow(Icons.confirmation_number, "VIN NO", vin_no),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInfoRow(Icons.local_parking, "Lot No", Lot_No),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(Icons.color_lens, "Color", color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInfoRow(Icons.directions_car, "Model", model),
              ),
            ],
          ),
          const Divider(color: Colors.white, thickness: 1, height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(Icons.person, "Client", clientName),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInfoRow(
                    Icons.calendar_today, "Receiving Date", formattedDate),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Reusable widget to build info rows with icon, title, and value
  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Formats ISO datetime string to a human-readable form
  String _formatDate(String inputDate) {
    try {
      final date = DateTime.parse(inputDate);
      return DateFormat.yMMMMd()
          .add_jm()
          .format(date); // e.g., April 5, 2025 5:30 PM
    } catch (e) {
      return inputDate; // fallback
    }
  }
}
