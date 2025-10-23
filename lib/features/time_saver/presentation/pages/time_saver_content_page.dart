import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lines_news_app/core/router/app_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
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
    // Track view when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackView();
    });
  }

  Future<void> _trackView() async {
    try {
      await ref.read(timeSaverProvider.notifier).trackView(widget.contentId);
    } catch (e) {
      print('Error tracking view: $e');
    }
  }

  // Navigate to linked article
  void _navigateToArticle(TimeSaverContent content) {
  if (content.linkedArticle != null) {
    final articleId = content.linkedArticle!['id'] as String?;
    if (articleId != null && articleId.isNotEmpty) {
      context.pushToArticle(articleId);  // ✨ Uses your custom extension!
    } else {
      _showSnackBar('Article ID not available', isError: true);
    }
  } else if (content.linkedAiArticle != null) {
    final aiArticleId = content.linkedAiArticle!['id'] as String?;
    if (aiArticleId != null && aiArticleId.isNotEmpty) {
      context.pushToArticle(aiArticleId);  // ✨ Same method!
    } else {
      _showSnackBar('Article ID not available', isError: true);
    }
  } else {
    _showSnackBar('No article linked to this content', isError: true);
  }
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
          content = contentList.isNotEmpty ? contentList.first : null;
        }

        if (content == null) {
          return _buildNotFoundScaffold();
        }

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
    final hasLinkedArticle = content.linkedArticle != null || content.linkedAiArticle != null;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar with Image
          SliverAppBar(
            expandedHeight: content.imageUrl != null ? 280 : 200,
            pinned: true,
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
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareContent(content),
              ),
            ],
          ),

          // Content Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    content.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Meta Information
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${content.readTimeSeconds ~/ 60} min read',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${content.viewCount} views',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (content.isPriority) ...[
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'PRIORITY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // PROMINENT READ FULL ARTICLE BUTTON
                  if (hasLinkedArticle)
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () => _navigateToArticle(content),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  categoryColor,
                                  categoryColor.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.article_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Read Full Article',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Summary
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 20,
                              color: categoryColor,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Summary',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          content.summary,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Key Points
                  if (content.keyPoints.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.checklist_rounded,
                                size: 20,
                                color: categoryColor,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Key Points',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...content.keyPoints.map((point) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 6),
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: categoryColor,
                                        shape: BoxShape.circle,
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
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Linked Article Preview (if available)
                  if (content.linkedArticle != null)
                    _buildLinkedArticlePreview(content, categoryColor),
                  
                  if (content.linkedAiArticle != null)
                    _buildLinkedAiArticlePreview(content, categoryColor),

                  const SizedBox(height: 20),

                  // Source Link
                  if (content.sourceUrl != null && content.sourceUrl!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: InkWell(
                        onTap: () => _launchUrl(content.sourceUrl!),
                        child: Row(
                          children: [
                            Icon(Icons.link, color: Colors.blue[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Original Source',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    content.sourceUrl!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[700],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.open_in_new,
                              size: 18,
                              color: Colors.blue[700],
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Bottom CTA Button
                  if (hasLinkedArticle)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToArticle(content),
                        icon: const Icon(Icons.article_rounded),
                        label: const Text(
                          'Continue Reading Full Article',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: categoryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedArticlePreview(TimeSaverContent content, Color categoryColor) {
    final article = content.linkedArticle!;
    final headline = article['headline'] as String? ?? 'Untitled';
    final briefContent = article['briefContent'] as String? ?? '';
    final featuredImage = article['featuredImage'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: categoryColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.article, color: categoryColor),
                const SizedBox(width: 8),
                const Text(
                  'Linked Full Article',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (featuredImage != null && featuredImage.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: featuredImage,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (featuredImage != null && featuredImage.isNotEmpty)
                  const SizedBox(height: 12),
                
                Text(
                  headline,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (briefContent.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    briefContent,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 16),
                
                // Read Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateToArticle(content),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Read Full Article'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: categoryColor,
                      side: BorderSide(color: categoryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedAiArticlePreview(TimeSaverContent content, Color categoryColor) {
    final article = content.linkedAiArticle!;
    final headline = article['headline'] as String? ?? 'Untitled';
    final briefContent = article['briefContent'] as String? ?? '';
    final featuredImage = article['featuredImage'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.smart_toy, color: Colors.purple[700]),
                const SizedBox(width: 8),
                const Text(
                  'Linked AI Article',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (featuredImage != null && featuredImage.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: featuredImage,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (featuredImage != null && featuredImage.isNotEmpty)
                  const SizedBox(height: 12),
                
                Text(
                  headline,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (briefContent.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    briefContent,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 16),
                
                // Read Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateToArticle(content),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Read Full AI Article'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.purple[700],
                      side: BorderSide(color: Colors.purple[700]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _shareContent(TimeSaverContent content) {
    Share.share(
      '${content.title}\n\n${content.summary}',
      subject: content.title,
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar('Could not open link', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red[600] : Colors.green[600],
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'TECHNOLOGY':
        return const Color(0xFF3B82F6);
      case 'BUSINESS':
        return const Color(0xFF10B981);
      case 'HEALTH':
        return const Color(0xFFEF4444);
      case 'SCIENCE':
        return const Color(0xFF8B5CF6);
      case 'ENTERTAINMENT':
        return const Color(0xFFF59E0B);
      case 'SPORTS':
        return const Color(0xFF06B6D4);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'TECHNOLOGY':
        return Icons.computer;
      case 'BUSINESS':
        return Icons.business_center;
      case 'HEALTH':
        return Icons.health_and_safety;
      case 'SCIENCE':
        return Icons.science;
      case 'ENTERTAINMENT':
        return Icons.movie;
      case 'SPORTS':
        return Icons.sports;
      default:
        return Icons.article;
    }
  }
}