// lib/features/ai_ml/widgets/ai_article_share_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart'; // Add to pubspec.yaml: share_plus: ^7.2.1
import '../models/ai_news_model.dart';
import '../repositories/ai_ml_repository.dart';
import '../providers/ai_ml_provider.dart';

// Share Provider - tracks share interactions
final aiArticleShareProvider = Provider<AiArticleShareService>((ref) {
  final repository = ref.read(aiMlRepositoryProvider);
  return AiArticleShareService(repository);
});

class AiArticleShareService {
  final AiMlRepository _repository;
  
  AiArticleShareService(this._repository);
  
  /// Share an AI article with tracking
  Future<void> shareArticle(
    BuildContext context, {
    required AiNewsModel article,
    Rect? sharePositionOrigin,
  }) async {
    try {
      // Create shareable content
      final String shareText = _buildShareText(article);
      
      // Track the share interaction (fire and forget)
      _repository.trackAiArticleInteraction(article.id, 'SHARE');
      
      // Share using platform share dialog
      await Share.share(
        shareText,
        subject: article.headline,
        sharePositionOrigin: sharePositionOrigin,
      );
      
      // Show success message after sharing
      if (context.mounted) {
        _showSnackBar(context, 'Article shared successfully!');
      }
    } catch (e) {
      print('Error sharing article: $e');
      if (context.mounted) {
        _showSnackBar(context, 'Failed to share article');
      }
    }
  }
  
  /// Copy article link to clipboard with tracking
  Future<void> copyArticleLink(
    BuildContext context, {
    required AiNewsModel article,
  }) async {
    try {
      final String link = article.sourceUrl ?? 'https://yourapp.com/ai/article/${article.id}';
      
      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: link));
      
      // Track as share interaction
      _repository.trackAiArticleInteraction(article.id, 'SHARE');
      
      if (context.mounted) {
        _showSnackBar(context, 'Link copied to clipboard!');
      }
    } catch (e) {
      print('Error copying link: $e');
      if (context.mounted) {
        _showSnackBar(context, 'Failed to copy link');
      }
    }
  }
  
  /// Share article with specific platform
  Future<void> shareToSpecificPlatform(
    BuildContext context, {
    required AiNewsModel article,
    required String platform, // 'whatsapp', 'twitter', 'linkedin', etc.
  }) async {
    try {
      final String shareText = _buildShareText(article);
      
      // Track the share interaction
      _repository.trackAiArticleInteraction(article.id, 'SHARE');
      
      // Different sharing strategies based on platform
      switch (platform.toLowerCase()) {
        case 'whatsapp':
          // Use share_plus or url_launcher to open WhatsApp
          await Share.share(shareText);
          break;
        case 'twitter':
          // Use share_plus or url_launcher to open Twitter
          await Share.share(shareText);
          break;
        case 'linkedin':
          // Use share_plus or url_launcher to open LinkedIn
          await Share.share(shareText);
          break;
        default:
          await Share.share(shareText);
      }
      
      if (context.mounted) {
        _showSnackBar(context, 'Shared to $platform!');
      }
    } catch (e) {
      print('Error sharing to $platform: $e');
      if (context.mounted) {
        _showSnackBar(context, 'Failed to share');
      }
    }
  }
  
  String _buildShareText(AiNewsModel article) {
    final buffer = StringBuffer();
    buffer.writeln(article.headline);
    buffer.writeln();
    buffer.writeln(article.briefContent);
    buffer.writeln();
    
    if (article.sourceUrl != null) {
      buffer.writeln('Read more: ${article.sourceUrl}');
    } else {
      buffer.writeln('Read more: https://yourapp.com/ai/article/${article.id}');
    }
    
    if (article.tags.isNotEmpty) {
      buffer.writeln();
      buffer.write('Tags: ${article.tags.take(3).join(', ')}');
    }
    
    return buffer.toString();
  }
  
  void _showSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

/// Share Button Widget
class AiArticleShareButton extends ConsumerWidget {
  final AiNewsModel article;
  final IconData icon;
  final String? tooltip;
  final Color? iconColor;
  final double? iconSize;
  final VoidCallback? onShareComplete;
  
  const AiArticleShareButton({
    Key? key,
    required this.article,
    this.icon = Icons.share,
    this.tooltip = 'Share',
    this.iconColor,
    this.iconSize = 24,
    this.onShareComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shareService = ref.read(aiArticleShareProvider);
    
    return IconButton(
      icon: Icon(icon, size: iconSize),
      color: iconColor ?? Theme.of(context).iconTheme.color,
      tooltip: tooltip,
      onPressed: () async {
        // Get the button position for iPad/tablet share dialog
        final box = context.findRenderObject() as RenderBox?;
        final sharePositionOrigin = box != null 
            ? box.localToGlobal(Offset.zero) & box.size
            : null;
        
        await shareService.shareArticle(
          context,
          article: article,
          sharePositionOrigin: sharePositionOrigin,
        );
        
        onShareComplete?.call();
      },
    );
  }
}

/// Share Options Bottom Sheet
class AiArticleShareBottomSheet extends ConsumerWidget {
  final AiNewsModel article;
  
  const AiArticleShareBottomSheet({
    Key? key,
    required this.article,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shareService = ref.read(aiArticleShareProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Share Article',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(),
          
          // Share Options
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share via...'),
            subtitle: const Text('Share using system share dialog'),
            onTap: () async {
              Navigator.pop(context);
              await shareService.shareArticle(context, article: article);
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('Copy Link'),
            subtitle: const Text('Copy article link to clipboard'),
            onTap: () async {
              Navigator.pop(context);
              await shareService.copyArticleLink(context, article: article);
            },
          ),
          
          // Add more platform-specific options if needed
          ListTile(
            leading: Icon(Icons.download, color: Colors.green[700]),
            title: const Text('Download Article'),
            subtitle: const Text('Save for offline reading'),
            onTap: () async {
              Navigator.pop(context);
              // Implement download functionality
              final repository = ref.read(aiMlRepositoryProvider);
              await repository.trackAiArticleInteraction(article.id, 'DOWNLOAD');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Download feature coming soon!')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
  
  static void show(BuildContext context, AiNewsModel article) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AiArticleShareBottomSheet(article: article),
    );
  }
}

/// Floating Share Button for article detail pages
class AiArticleFloatingShareButton extends ConsumerWidget {
  final AiNewsModel article;
  
  const AiArticleFloatingShareButton({
    Key? key,
    required this.article,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () {
        AiArticleShareBottomSheet.show(context, article);
      },
      child: const Icon(Icons.share),
      tooltip: 'Share Article',
    );
  }
}