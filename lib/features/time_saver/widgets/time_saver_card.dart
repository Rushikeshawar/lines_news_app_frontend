// lib/features/time_saver/widgets/time_saver_card.dart
import 'package:flutter/material.dart';
import '../models/time_saver_model.dart';

class TimeSaverCard extends StatelessWidget {
  final TimeSaverContent content;
  final VoidCallback onTap;

  const TimeSaverCard({
    super.key,
    required this.content,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12), // Reduced padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and time
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6), // Reduced padding
                      decoration: BoxDecoration(
                        color: _getCategoryColor(content.category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        _getCategoryIcon(content.category),
                        color: _getCategoryColor(content.category),
                        size: 16, // Reduced icon size
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        content.readTimeFormatted,
                        style: TextStyle(
                          fontSize: 9, // Reduced font size
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8), // Reduced spacing
                
                // Category
                Text(
                  content.category.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10, // Reduced font size
                    fontWeight: FontWeight.w700,
                    color: _getCategoryColor(content.category),
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Title - Fixed overflow issue
                Flexible(
                  child: Text(
                    content.title,
                    style: const TextStyle(
                      fontSize: 14, // Reduced font size
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      height: 1.2, // Reduced line height
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                const SizedBox(height: 6), // Reduced spacing
                
                // Summary - Fixed overflow issue
                Flexible(
                  child: Text(
                    content.summary,
                    style: TextStyle(
                      fontSize: 12, // Reduced font size
                      color: Colors.grey[600],
                      height: 1.3, // Reduced line height
                    ),
                    maxLines: 2, // Reduced max lines
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // Key points count - Made more compact
                if (content.keyPoints.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.list_alt,
                        size: 14, // Reduced icon size
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${content.keyPoints.length} key points',
                          style: TextStyle(
                            fontSize: 11, // Reduced font size
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12, // Reduced icon size
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'business':
        return Colors.blue;
      case 'technology':
        return Colors.purple;
      case 'sports':
        return Colors.orange;
      case 'politics':
        return Colors.red;
      case 'health':
        return Colors.green;
      default:
        return Colors.indigo;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'business':
        return Icons.business_center;
      case 'technology':
        return Icons.computer;
      case 'sports':
        return Icons.sports;
      case 'politics':
        return Icons.account_balance;
      case 'health':
        return Icons.health_and_safety;
      default:
        return Icons.article;
    }
  }
}