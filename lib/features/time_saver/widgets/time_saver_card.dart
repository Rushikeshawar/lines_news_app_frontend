// lib/features/time_saver/widgets/time_saver_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/time_saver_model.dart';

class TimeSaverCard extends StatelessWidget {
  final TimeSaverContent content;
  final VoidCallback onTap;
  final Color? accentColor;
  final bool isHorizontal;
  final bool showImage;
  final bool showFullContent;

  const TimeSaverCard({
    super.key,
    required this.content,
    required this.onTap,
    this.accentColor,
    this.isHorizontal = false,
    this.showImage = true,
    this.showFullContent = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? _getCategoryColor(content.category);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
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
          child: isHorizontal 
              ? _buildHorizontalLayout(color)
              : _buildVerticalLayout(color),
        ),
      ),
    );
  }
  
  Widget _buildVerticalLayout(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image section
        if (showImage && content.imageUrl != null && content.imageUrl!.isNotEmpty) ...[
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 16/9,
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: content.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color.withOpacity(0.3),
                            color.withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color.withOpacity(0.3),
                            color.withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _getCategoryIcon(content.category),
                          size: 40,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                  
                  // Gradient overlay for better text visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                  
                  // Priority badge overlay
                  if (content.isPriority) 
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red[600],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.priority_high,
                              size: 12,
                              color: Colors.white,
                            ),
                            SizedBox(width: 2),
                            Text(
                              'PRIORITY',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Content type badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        content.contentType.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else if (showImage) ...[
          // Fallback colored header when no image
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.3),
                  color.withOpacity(0.1),
                ],
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    _getCategoryIcon(content.category),
                    size: 40,
                    color: color,
                  ),
                ),
                
                // Priority badge for non-image cards
                if (content.isPriority) 
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red[600],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'PRIORITY',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                
                // Content type badge for non-image cards
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      content.contentType.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        
        // Content section
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      content.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 10,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          content.readTimeFormatted,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Title
              Text(
                content.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Summary
              Text(
                content.summary,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.3,
                ),
                maxLines: showFullContent ? null : 2,
                overflow: showFullContent ? null : TextOverflow.ellipsis,
              ),
              
              // Key points preview (if available and showFullContent is true)
              if (showFullContent && content.keyPoints.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Key Points',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ...content.keyPoints.take(3).map((point) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          '• $point',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[700],
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )).toList(),
                      if (content.keyPoints.length > 3)
                        Text(
                          '+${content.keyPoints.length - 3} more',
                          style: TextStyle(
                            fontSize: 9,
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Footer with stats and actions
              Row(
                children: [
                  // View count
                  Icon(Icons.visibility, size: 12, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    _formatViewCount(content.viewCount),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Published date
                  Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(content.publishedAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Action indicator
                  if (!content.isPriority || !showImage) ...[
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.grey[400],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildHorizontalLayout(Color color) {
    return Row(
      children: [
        // Image section
        if (showImage && content.imageUrl != null && content.imageUrl!.isNotEmpty) ...[
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            child: SizedBox(
              width: 120,
              height: 160,
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: content.imageUrl!,
                    fit: BoxFit.cover,
                    width: 120,
                    height: 160,
                    placeholder: (context, url) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color.withOpacity(0.3),
                            color.withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color.withOpacity(0.3),
                            color.withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _getCategoryIcon(content.category),
                          size: 30,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                  
                  // Priority badge for horizontal layout
                  if (content.isPriority) 
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red[600],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'HOT',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ] else if (showImage) ...[
          // Fallback colored section when no image
          Container(
            width: 120,
            height: 160,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.3),
                  color.withOpacity(0.1),
                ],
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    _getCategoryIcon(content.category),
                    size: 30,
                    color: color,
                  ),
                ),
                if (content.isPriority) 
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red[600],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'HOT',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
        
        // Content section
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        content.category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        content.readTimeFormatted,
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Title
                Text(
                  content.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 6),
                
                // Summary
                Expanded(
                  child: Text(
                    content.summary,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Footer
                Row(
                  children: [
                    Icon(Icons.visibility, size: 11, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      _formatViewCount(content.viewCount),
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.access_time, size: 11, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(content.publishedAt),
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[500],
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios, size: 12, color: color),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  String _formatViewCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d';
    } else {
      return '${date.day}/${date.month}';
    }
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
      case 'entertainment':
        return Colors.pink;
      case 'society':
        return Colors.indigo;
      case 'culture':
        return Colors.teal;
      default:
        return Colors.grey[600]!;
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
      case 'entertainment':
        return Icons.movie;
      case 'society':
        return Icons.people;
      case 'culture':
        return Icons.palette;
      default:
        return Icons.article;
    }
  }
}