import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../articles/models/article_model.dart';
import '../../../favorites/providers/favorites_provider.dart';

class ArticleCard extends ConsumerWidget {
  final Article article;
  final VoidCallback? onTap;
  final bool isHorizontal;
  final bool showAd;

  const ArticleCard({
    super.key,
    required this.article,
    this.onTap,
    this.isHorizontal = false,
    this.showAd = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            isHorizontal ? _buildHorizontalLayout(context, ref) : _buildVerticalLayout(context, ref),
            if (showAd) _buildGoogleAdPlaceholder(),
          ],
        ),
      ),
    );
  }

Widget _buildVerticalLayout(BuildContext context, WidgetRef ref) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      // Image with corner article thumbnail
      Stack(
        children: [
          if (article.featuredImage != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: article.featuredImage!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
          
          if (article.featuredImage != null)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedNetworkImage(
                    imageUrl: article.featuredImage!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.article, size: 20),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      
      // Content
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category and Time - CORRECTED
            Row(
              children: [
                _buildCategoryChip(),
                const SizedBox(width: 8),
                _buildTimeStamp(),
                const Spacer(), // Put Spacer here
                _buildFavoriteButton(ref),
              ],
            ),
            const SizedBox(height: 12),
            
            // Headline
            Text(
              article.headline,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: Colors.black87,
                letterSpacing: -0.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            // Brief content
            if (article.briefContent != null && article.briefContent!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                article.briefContent!,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Stats row - FINAL CORRECTED VERSION
            Row(
              children: [
                _buildStatItem(Icons.visibility_outlined, article.viewCount.toString()),
                const SizedBox(width: 16),
                _buildStatItem(Icons.share_outlined, article.shareCount.toString()),
                const Spacer(),
                Text(
                  article.readingTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildHorizontalLayout(BuildContext context, WidgetRef ref) {
  return SizedBox(
    height: 120,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image with corner thumbnail
        Stack(
          children: [
            if (article.featuredImage != null)
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: article.featuredImage!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 120,
                    height: 120,
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 120,
                    height: 120,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
            
            if (article.featuredImage != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      imageUrl: article.featuredImage!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.article, size: 12),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        
        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category and Favorite - CORRECTED
                Row(
                  children: [
                    _buildCategoryChip(isSmall: true),
                    const Spacer(), // Put Spacer here
                    _buildFavoriteButton(ref, isSmall: true),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Headline
                Expanded(
                  child: Text(
                    article.headline,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      color: Colors.black87,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Bottom row - FINAL CORRECTED VERSION
                Row(
                  children: [
                    _buildStatItem(Icons.visibility_outlined, article.viewCount.toString(), isSmall: true),
                    const SizedBox(width: 12),
                    _buildTimeStamp(isSmall: true),
                    const Spacer(), // Put Spacer here
                    Text(
                      article.readingTime,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildGoogleAdPlaceholder() {
    return Container(
      width: double.infinity,
      height: 60,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.ads_click, color: Colors.grey[600], size: 16),
            const SizedBox(width: 8),
            Text(
              'Advertisement',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip({bool isSmall = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmall ? 8 : 12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        article.categoryDisplayName,
        style: TextStyle(
          fontSize: isSmall ? 10 : 12,
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTimeStamp({bool isSmall = false}) {
    String timeAgo = '';
    if (article.publishedAt != null) {
      final now = DateTime.now();
      final difference = now.difference(article.publishedAt!);
      
      if (difference.inDays > 0) {
        timeAgo = '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        timeAgo = '${difference.inHours}h ago';
      } else {
        timeAgo = '${difference.inMinutes}m ago';
      }
    } else {
      timeAgo = DateFormat('MMM dd').format(article.createdAt);
    }

    return Text(
      timeAgo,
      style: TextStyle(
        fontSize: isSmall ? 10 : 12,
        color: Colors.grey[600],
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildFavoriteButton(WidgetRef ref, {bool isSmall = false}) {
    final isFavorited = article.isFavorited ?? false;
    
    return InkWell(
      onTap: () {
        if (isFavorited) {
          ref.read(favoritesProvider.notifier).removeFavorite(article.id);
        } else {
          ref.read(favoritesProvider.notifier).addFavorite(article.id);
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          isFavorited ? Icons.favorite : Icons.favorite_border,
          color: isFavorited ? Colors.red : Colors.grey[500],
          size: isSmall ? 16 : 20,
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, {bool isSmall = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: isSmall ? 12 : 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          _formatNumber(int.tryParse(value) ?? 0),
          style: TextStyle(
            fontSize: isSmall ? 10 : 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

// Compact article card for lists
class CompactArticleCard extends ConsumerWidget {
  final Article article;
  final VoidCallback? onTap;

  const CompactArticleCard({
    super.key,
    required this.article,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with corner thumbnail
            if (article.featuredImage != null) ...[
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: article.featuredImage!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[200],
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, size: 20),
                      ),
                    ),
                  ),
                  
                  // Small corner article icon
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.article,
                        size: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
            ],
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.headline,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        article.categoryDisplayName,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getTimeAgo(),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Favorite button
            InkWell(
              onTap: () {
                final isFavorited = article.isFavorited ?? false;
                if (isFavorited) {
                  ref.read(favoritesProvider.notifier).removeFavorite(article.id);
                } else {
                  ref.read(favoritesProvider.notifier).addFavorite(article.id);
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  (article.isFavorited ?? false) ? Icons.favorite : Icons.favorite_border,
                  color: (article.isFavorited ?? false) ? Colors.red : Colors.grey[500],
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo() {
    if (article.publishedAt != null) {
      final now = DateTime.now();
      final difference = now.difference(article.publishedAt!);
      
      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inMinutes}m ago';
      }
    }
    return DateFormat('MMM dd').format(article.createdAt);
  }
}