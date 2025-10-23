// lib/features/time_saver/presentation/pages/breaking_news_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/time_saver_provider.dart';
import '../../models/time_saver_model.dart';
import '../../models/breaking_news_model.dart';
import '../../providers/breaking_news_provider.dart';

class BreakingNewsDetailPage extends ConsumerStatefulWidget {
  final String newsId;
  
  const BreakingNewsDetailPage({super.key, required this.newsId});
  
  @override
  ConsumerState<BreakingNewsDetailPage> createState() => _BreakingNewsDetailPageState();
}

class _BreakingNewsDetailPageState extends ConsumerState<BreakingNewsDetailPage> {
  @override
  void initState() {
    super.initState();
    print('BreakingNewsDetailPage: initState for newsId: ${widget.newsId}');
  }

  @override
  Widget build(BuildContext context) {
    print('BreakingNewsDetailPage: build called for newsId: ${widget.newsId}');
    
    final breakingNewsAsync = ref.watch(breakingNewsProvider);
    
    return breakingNewsAsync.when(
      data: (newsList) {
        print('BreakingNewsDetailPage: Got ${newsList.length} items from provider');
        
        BreakingNewsModel? newsItem;
        try {
          newsItem = newsList.firstWhere(
            (item) => item.id == widget.newsId,
          );
          print('BreakingNewsDetailPage: Found news: ${newsItem.title}');
        } catch (e) {
          print('BreakingNewsDetailPage: News not found for ID: ${widget.newsId}');
          // If not found, use the first item as fallback
          newsItem = newsList.isNotEmpty ? newsList.first : null;
        }

        if (newsItem == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Breaking News Not Found'),
              backgroundColor: Colors.red[50],
              foregroundColor: Colors.red[800],
              elevation: 0,
              // leading: IconButton(
              //   icon: const Icon(Icons.arrow_back),
              //   onPressed: () => context.pop(),
              // ),
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
                    'Breaking news not found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'News ID: ${widget.newsId}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: Colors.red[600],
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red[700]?.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.emergency,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'BREAKING NEWS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.red[600]!,
                          Colors.red[800]!,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.emergency,
                        size: 100,
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Main Content Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Timestamp and Priority
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getPriorityColor(newsItem.priority).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    newsItem.priority.name.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: _getPriorityColor(newsItem.priority),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatTime(newsItem.timestamp),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Title
                            Text(
                              newsItem.title,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                                height: 1.3,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Brief/Description
                            Text(
                              newsItem.brief ?? newsItem.summary,
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.grey[700],
                                height: 1.6,
                              ),
                            ),
                            
                            // Location if available
                            if (newsItem.location != null) ...[
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 20,
                                      color: Colors.red[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Location',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        newsItem.location!,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            
                            // Tags if available
                            if (newsItem.tags.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Related Topics',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: newsItem.tags.map((tag) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.blue[200]!),
                                        ),
                                        child: Text(
                                          tag,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Action Buttons
                      if (newsItem.sourceUrl != null && newsItem.sourceUrl!.isNotEmpty) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () => _launchUrl(newsItem!.sourceUrl!),
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Read Full Article'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[600],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      
                      // Share Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () => _shareNews(),
                          icon: const Icon(Icons.share),
                          label: const Text('Share Breaking News'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red[600],
                            side: BorderSide(color: Colors.red[600]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
          backgroundColor: Colors.red[50],
          foregroundColor: Colors.red[800],
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.red),
        ),
      ),
      error: (error, stack) {
        print('BreakingNewsDetailPage: Error loading news: $error');
        return Scaffold(
          appBar: AppBar(
            title: const Text('Error'),
            backgroundColor: Colors.red[50],
            foregroundColor: Colors.red[800],
            elevation: 0,
            // leading: IconButton(
            //   icon: const Icon(Icons.arrow_back),
            //   onPressed: () => context.pop(),
            // ),
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
                  'Failed to load breaking news',
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
      },
    );
  }

  Color _getPriorityColor(BreakingPriority priority) {
    switch (priority) {
      case BreakingPriority.critical:
        return Colors.red[700]!;
      case BreakingPriority.high:
        return Colors.orange[600]!;
      case BreakingPriority.medium:
        return Colors.blue[600]!;
      case BreakingPriority.low:
        return Colors.green[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
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

  void _shareNews() {
    _showErrorSnackBar('Share functionality coming soon');
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
}