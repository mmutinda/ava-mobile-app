import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class QFLIssuesPage extends StatelessWidget {
  final List<Map<String, dynamic>> issues;

  const QFLIssuesPage({super.key, required this.issues});

  Color _classificationColor(String classif) {
    switch (classif.toUpperCase()) {
      case 'A':
        return Colors.redAccent;
      case 'B':
        return Colors.orangeAccent;
      case 'C':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_top;
      case 'resolved':
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupByShop(
      List<Map<String, dynamic>> items) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in items) {
      final shopName = item['qfl4']?['shop']?['shop_name'] ?? 'Unknown Shop';
      grouped.putIfAbsent(shopName, () => []).add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    if (issues.isEmpty) {
      return const Center(child: Text("No issues found"));
    }

    final groupedIssues = _groupByShop(issues);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: groupedIssues.entries.map((entry) {
        final shopName = entry.key;
        final shopIssues = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              shopName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[700],
                  ),
            ),
            const SizedBox(height: 10),
            ...shopIssues
                .map((issue) => _buildIssueCard(context, issue))
                .toList(),
            const SizedBox(height: 24),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildIssueCard(BuildContext context, Map<String, dynamic> issue) {
    final qfl4 = issue['qfl4'];
    final shop = qfl4?['shop'];
    final createdAt = DateTime.tryParse(issue['created_at'] ?? '');
    final formattedDate = createdAt != null
        ? DateFormat.yMMMEd().add_jm().format(createdAt)
        : 'Unknown date';

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to detail/resolve page
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        _classificationColor(issue['classification']),
                    radius: 18,
                    child: Text(
                      issue['classification'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      issue['issue'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _statusIcon(issue['status']),
                    color: Colors.blueGrey,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Details Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailItem(Icons.person, ''),
                  _buildDetailItem(Icons.store, shop?['shop_name'] ?? 'N/A'),
                ],
              ),

              const SizedBox(height: 12),

              // Status + Date
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
