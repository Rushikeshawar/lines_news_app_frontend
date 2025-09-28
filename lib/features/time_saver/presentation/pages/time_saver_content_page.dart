// lib/features/time_saver/presentation/pages/time_saver_content_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/time_saver_provider.dart';
import '../../models/time_saver_model.dart';

class TimeSaverContentPage extends ConsumerStatefulWidget {
  final String contentId;
  
  const TimeSaverContentPage({super.key, required this.contentId});
  
  @override
  ConsumerState<TimeSaverContentPage> createState() => _TimeSaverContentPageState();
}

class _TimeSaverContentPageState extends ConsumerState<TimeSaverContentPage> {
  @override
  void initState() {
    super.initState();
    print('TimeSaverContentPage: initState for contentId: ${widget.contentId}');
  }

  @override
  Widget build(BuildContext context) {
    print('TimeSaverContentPage: build called for contentId: ${widget.contentId}');
    
    final timeSaverAsync = ref.watch(timeSaverProvider);
    
    return timeSaverAsync.when(
      data: (contentList) {
        print('TimeSaverContentPage: Got ${contentList.length} items from provider');
        
        TimeSaverContent? content;
        try {
          content = contentList.firstWhere(
            (item) => item.id == widget.contentId,
          );
          print('TimeSaverContentPage: Found content: ${content.title}');
        } catch (e) {
          print('TimeSaverContentPage: Content not found for ID: ${widget.contentId}');
          // If not found, use the first item as fallback
          content = contentList.isNotEmpty ? contentList.first : null;
        }

        if (content == null) {
          return _buildNotFoundScaffold();
        }

        // Now content is guaranteed to be non-null
        return _buildContentScaffold(content);
      },
      loading: () => _buildLoadingScaffold(),
      error: (error, stack) {
        print('TimeSaverContentPage: Error loading content: $error');
        return _buildErrorScaffold(error);
      },
    );
  }

  Widget _buildNotFoundScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Not Found'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Content not found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Content ID: ${widget.contentId}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading...'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorScaffold(Object error) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load content',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Error: $error',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentScaffold(TimeSaverContent content) {
    final categoryColor = _getCategoryColor(content.category);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar with Image
          SliverAppBar(
            expandedHeight: content.imageUrl != null ? 280 : 200,
            pinned: true,
            backgroundColor: categoryColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  content.category.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image or gradient
                  if (content.imageUrl != null && content.imageUrl!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: content.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              categoryColor,
                              categoryColor.withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              categoryColor,
                              categoryColor.withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            _getCategoryIcon(content.category),
                            size: 80,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            categoryColor,
                            categoryColor.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _getCategoryIcon(content.category),
                          size: 80,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ),
                  
                  // Dark overlay for better text readability
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
                ],
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and metadata card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Metadata row
                        Row(
                          children: [
                            // Priority badge
                            if (content.isPriority) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.priority_high,
                                      size: 14,
                                      color: Colors.red[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'PRIORITY',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.red[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            
                            // Reading time
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 14,
                                    color: Colors.green[700],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    content.readTimeFormatted,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const Spacer(),
                            
                            // Published date
                            Text(
                              _formatDate(content.publishedAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Title
                        Text(
                          content.title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Summary
                        Text(
                          content.summary,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Key Points Section
                  if (content.keyPoints.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.star_rounded,
                                  color: Colors.orange[600],
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Key Points',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...content.keyPoints.asMap().entries.map((entry) {
                            final index = entry.key;
                            final point = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: categoryColor.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: categoryColor,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      point,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey[800],
                                        height: 1.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Enhanced Stats Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.analytics,
                              color: Colors.blue[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Article Statistics',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                Icons.visibility,
                                _formatViewCount(content.viewCount),
                                'Views',
                                Colors.blue,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 50,
                              color: Colors.grey[200],
                            ),
                            Expanded(
                              child: _buildStatItem(
                                Icons.schedule,
                                content.readTimeFormatted,
                                'Read Time',
                                Colors.green,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 50,
                              color: Colors.grey[200],
                            ),
                            Expanded(
                              child: _buildStatItem(
                                Icons.category,
                                content.contentType.name.toUpperCase(),
                                'Type',
                                Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Action Buttons
                  Row(
                    children: [
                      // Read full article button
                      if (content.sourceUrl != null && content.sourceUrl!.isNotEmpty) ...[
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () => _launchUrl(content.sourceUrl!),
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Read Full Article'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: categoryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      
                      // Share button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _shareContent(content),
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: categoryColor,
                            side: BorderSide(color: categoryColor),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays > 0) {
      return '${diff.inDays} days ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hours ago';
    } else {
      return '${diff.inMinutes} minutes ago';
    }
  }

  String _formatViewCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  void _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Cannot open the link');
      }
    } catch (e) {
      _showErrorSnackBar('Error opening link: ${e.toString()}');
    }
  }

  void _shareContent(TimeSaverContent content) {
    // For now, just show a message. In a real app, you'd use share_plus package
    _showSuccessSnackBar('Share feature coming soon!');
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red[600],
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green[600],
          duration: const Duration(seconds: 3),
        ),
      );
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