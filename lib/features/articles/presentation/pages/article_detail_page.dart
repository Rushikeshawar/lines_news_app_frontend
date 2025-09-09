// lib/features/articles/presentation/pages/article_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/article_model.dart';
import '../../providers/missing_providers.dart';
import '../../../favorites/providers/favorites_provider.dart';
import '../../../home/presentation/widgets/article_card.dart';

class ArticleDetailPage extends ConsumerStatefulWidget {
  final String articleId;
  
  const ArticleDetailPage({
    super.key,
    required this.articleId,
  });

  @override
  ConsumerState<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends ConsumerState<ArticleDetailPage>
    with TickerProviderStateMixin {
  
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _appBarController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _appBarOpacity;
  
  ScrollController _scrollController = ScrollController();
  bool _isScrollingUp = false;
  double _previousScrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _appBarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Initialize animations
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _appBarOpacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _appBarController,
      curve: Curves.easeInOut,
    ));
    
    // Setup scroll listener
    _scrollController.addListener(_onScroll);
    
    // Start entrance animations
    _startEntranceAnimations();
    
    // Track article view with error handling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackArticleView();
    });
  }
  
  void _startEntranceAnimations() {
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _fadeController.forward();
      }
    });
  }
  
  void _trackArticleView() async {
    try {
      await ref.read(articleActionsProvider).trackView(widget.articleId);
    } catch (e) {
      // Silently handle view tracking errors - it's not critical
      print('View tracking failed: $e');
    }
  }
  
  void _onScroll() {
    final currentScrollOffset = _scrollController.offset;
    final isScrollingUp = currentScrollOffset < _previousScrollOffset;
    
    if (_isScrollingUp != isScrollingUp) {
      setState(() {
        _isScrollingUp = isScrollingUp;
      });
      
      if (isScrollingUp && currentScrollOffset > 100) {
        _appBarController.reverse();
      } else if (!isScrollingUp && currentScrollOffset > 100) {
        _appBarController.forward();
      }
    }
    
    _previousScrollOffset = currentScrollOffset;
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _appBarController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Debug the article data
    final articleAsync = ref.watch(articleByIdProvider(widget.articleId));

    return Scaffold(
      body: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: articleAsync.when(
            data: (article) {
              if (article == null) {
                return _buildNotFoundState();
              }
              
              // Debug logging
              print('🔍 Article loaded: ${article.headline}');
              print('🔍 Brief content length: ${article.briefContent?.length ?? 0}');
              print('🔍 Full content length: ${article.fullContent?.length ?? 0}');
              if (article.fullContent != null) {
                print('🔍 Full content preview: ${article.fullContent!.substring(0, article.fullContent!.length.clamp(0, 100))}...');
              }
              
              return _buildArticleContent(article);
            },
            loading: () => _buildLoadingState(),
            error: (error, stack) => _buildErrorState(error.toString()),
          ),
        ),
      ),
    );
  }

  Widget _buildArticleContent(Article article) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // App bar with proper image handling
        SliverAppBar(
          expandedHeight: _hasValidImage(article.featuredImage) ? 300.0 : 120.0,
          floating: true,
          pinned: true,
          snap: true,
          backgroundColor: Colors.white.withOpacity(0.95),
          elevation: _isScrollingUp ? 4.0 : 0.0,
          flexibleSpace: AnimatedBuilder(
            animation: _appBarController,
            builder: (context, child) {
              return Opacity(
                opacity: 1.0 - (_appBarOpacity.value * 0.3),
                child: FlexibleSpaceBar(
                  background: _buildArticleImageHeader(article),
                ),
              );
            },
          ),
          actions: [
            // Share button
            AnimatedScale(
              scale: _isScrollingUp ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                icon: const Icon(Icons.share),
                onPressed: () async {
                  try {
                    await ref.read(articleActionsProvider).shareArticle(article.id);
                  } catch (e) {
                    // Handle share error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Share failed: $e')),
                    );
                  }
                },
              ),
            ),
            // Favorite button
            Consumer(
              builder: (context, ref, child) {
                final favoritesAsync = ref.watch(favoritesProvider);
                final isFavorite = favoritesAsync.when(
                  data: (favoriteIds) => favoriteIds.contains(article.id),
                  loading: () => article.isFavorited ?? false,
                  error: (_, __) => article.isFavorited ?? false,
                );
                
                return AnimatedScale(
                  scale: _isScrollingUp ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        key: ValueKey(isFavorite),
                        color: isFavorite ? Colors.red : null,
                      ),
                    ),
                    onPressed: () async {
                      try {
                        if (isFavorite) {
                          await ref.read(favoritesProvider.notifier).removeFavorite(article.id);
                        } else {
                          await ref.read(favoritesProvider.notifier).addFavorite(article.id);
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to update favorites: $e')),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ],
        ),

        // Article content
        SliverToBoxAdapter(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: EdgeInsets.all(_isScrollingUp ? 18 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category badge
                _buildAnimatedCategoryBadge(article),
                const SizedBox(height: 20),
                
                // Article headline
                _buildAnimatedHeadline(article),
                const SizedBox(height: 20),
                
                // Metadata section
                _buildAnimatedMetadata(article),
                const SizedBox(height: 24),
                
                // Article stats
                _buildAnimatedStats(article),
                const SizedBox(height: 32),
                
                // Article content - FIXED
                _buildAnimatedContent(article),
                const SizedBox(height: 32),
                
                // Tags section
                if (article.tagsList.isNotEmpty) 
                  _buildAnimatedTags(article),
              ],
            ),
          ),
        ),

        // Related articles section
        SliverToBoxAdapter(
          child: _buildRelatedArticlesSection(),
        ),
      ],
    );
  }

  // Proper image validation and display
  Widget _buildArticleImageHeader(Article article) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_hasValidImage(article.featuredImage))
          Hero(
            tag: 'article-image-${article.id}',
            child: CachedNetworkImage(
              imageUrl: article.featuredImage!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) {
                print('Image load error: $error for URL: $url');
                return _buildFallbackImage(article);
              },
            ),
          )
        else
          _buildFallbackImage(article),
        
        // Gradient overlay for better text readability
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
    );
  }

  // Helper method to check if image URL is valid
  bool _hasValidImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return false;
    
    try {
      final uri = Uri.parse(imageUrl);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  // Better fallback image
  Widget _buildFallbackImage(Article article) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.9),
            AppTheme.secondaryColor.withOpacity(0.9),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(article.category),
              size: 64,
              color: Colors.white.withOpacity(0.8),
            ),
            const SizedBox(height: 12),
            Text(
              article.categoryDisplayName.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(NewsCategory category) {
    switch (category) {
      case NewsCategory.technology:
        return Icons.computer;
      case NewsCategory.business:
        return Icons.business_center;
      case NewsCategory.health:
        return Icons.health_and_safety;
      case NewsCategory.sports:
        return Icons.sports;
      case NewsCategory.politics:
        return Icons.account_balance;
      case NewsCategory.environment:
        return Icons.eco;
      case NewsCategory.science:
        return Icons.science;
      case NewsCategory.education:
        return Icons.school;
      case NewsCategory.entertainment:
        return Icons.movie;
      case NewsCategory.crime:
        return Icons.security;
      case NewsCategory.national:
        return Icons.flag;
      case NewsCategory.international:
        return Icons.public;
      case NewsCategory.lifestyle:
        return Icons.favorite;
      case NewsCategory.finance:
        return Icons.attach_money;
      case NewsCategory.food:
        return Icons.restaurant;
      case NewsCategory.fashion:
        return Icons.checkroom;
      default:
        return Icons.article;
    }
  }

  Widget _buildAnimatedCategoryBadge(Article article) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getCategoryIcon(article.category),
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    article.categoryDisplayName.toUpperCase(),
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedHeadline(Article article) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Hero(
              tag: 'article-title-${article.id}',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  article.headline,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedMetadata(Article article) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Row(
              children: [
                if (article.author != null) ...[
                  Hero(
                    tag: 'author-avatar-${article.author!.id}',
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                      child: Text(
                        article.author!.displayName.isNotEmpty 
                            ? article.author!.displayName[0].toUpperCase()
                            : 'A',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    article.author!.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Text(
                    _getTimeAgo(article.publishedAt ?? article.createdAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    article.readingTime,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedStats(Article article) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1400),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 15 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Row(
              children: [
                _buildStatItem(Icons.visibility_outlined, article.viewCount.toString()),
                const SizedBox(width: 24),
                _buildStatItem(Icons.share_outlined, article.shareCount.toString()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 6),
          Text(
            _formatNumber(int.tryParse(value) ?? 0),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // FIXED: Article content display logic
  Widget _buildAnimatedContent(Article article) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 25 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brief content section
                if (article.briefContent != null && article.briefContent!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                      ),
                    ),
                    child: Text(
                      article.briefContent!,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Full content section - FIXED
                if (article.fullContent != null && article.fullContent!.isNotEmpty) ...[
                  Text(
                    article.fullContent!,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.8,
                      color: Colors.black87,
                    ),
                  ),
                ] else if (article.briefContent != null && article.briefContent!.isNotEmpty) ...[
                  // Show additional content message if only brief content exists
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This is a developing story. More details will be added as they become available.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Fallback message if no content
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_outlined,
                          color: Colors.orange[700],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Article content is currently being updated. Please check back later for the full story.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTags(Article article) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tags',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: article.tagsList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final tag = entry.value;
                    
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 200 + (index * 100)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, tagValue, child) {
                        return Transform.scale(
                          scale: tagValue,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.grey[100]!,
                                  Colors.grey[50]!,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRelatedArticlesSection() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 2000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Related Articles',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Consumer(
                  builder: (context, ref, child) {
                    final relatedArticlesAsync = ref.watch(relatedArticlesProvider(widget.articleId));
                    
                    return relatedArticlesAsync.when(
                      data: (articles) {
                        if (articles.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No related articles found.'),
                          );
                        }
                        
                        return SizedBox(
                          height: 220,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            physics: const BouncingScrollPhysics(),
                            itemCount: articles.length,
                            itemBuilder: (context, index) {
                              final relatedArticle = articles[index];
                              
                              return TweenAnimationBuilder<double>(
                                duration: Duration(milliseconds: 300 + (index * 150)),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, animValue, child) {
                                  return Transform.translate(
                                    offset: Offset(50 * (1 - animValue), 0),
                                    child: Opacity(
                                      opacity: animValue,
                                      child: Container(
                                        width: 300,
                                        margin: const EdgeInsets.symmetric(horizontal: 6),
                                        child: Hero(
                                          tag: 'related-article-${relatedArticle.id}',
                                          child: ArticleCard(
                                            article: relatedArticle,
                                            onTap: () {
                                              context.push('/article/${relatedArticle.id}');
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, stack) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Error loading related articles: $error'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading...'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading article...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to Load Article',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.grey[700],
                    ),
                    child: const Text('Go Back'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(articleByIdProvider(widget.articleId));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Not Found'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.article_outlined,
                size: 64,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Article Not Found',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The requested article could not be found.',
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
      ),
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

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}