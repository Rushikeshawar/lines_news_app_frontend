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
      begin: const Offset(0.0, 1.0), // Start from bottom
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
    
    // Setup scroll listener for app bar animation
    _scrollController.addListener(_onScroll);
    
    // Start entrance animations
    _startEntranceAnimations();
    
    // Track article view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(articleActionsProvider).trackView(widget.articleId);
    });
  }
  
  void _startEntranceAnimations() {
    // Start slide animation immediately
    _slideController.forward();
    
    // Start fade animation with a slight delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _fadeController.forward();
      }
    });
  }
  
  void _onScroll() {
    final currentScrollOffset = _scrollController.offset;
    final isScrollingUp = currentScrollOffset < _previousScrollOffset;
    
    if (_isScrollingUp != isScrollingUp) {
      setState(() {
        _isScrollingUp = isScrollingUp;
      });
      
      // Animate app bar based on scroll direction
      if (isScrollingUp && currentScrollOffset > 100) {
        _appBarController.reverse(); // Show app bar
      } else if (!isScrollingUp && currentScrollOffset > 100) {
        _appBarController.forward(); // Hide app bar
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
      physics: const BouncingScrollPhysics(), // Smooth bouncing effect
      slivers: [
        // Animated App Bar with scroll effects
        SliverAppBar(
          expandedHeight: article.featuredImage != null ? 300.0 : 120.0,
          floating: true, // Changed to true for better scroll behavior
          pinned: true,
          snap: true, // Added snap effect
          backgroundColor: Colors.white.withOpacity(0.95),
          elevation: _isScrollingUp ? 4.0 : 0.0, // Dynamic elevation
          flexibleSpace: AnimatedBuilder(
            animation: _appBarController,
            builder: (context, child) {
              return Opacity(
                opacity: 1.0 - (_appBarOpacity.value * 0.3),
                child: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (article.featuredImage != null)
                        Hero( // Hero animation for featured image
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
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported),
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
                                AppTheme.primaryColor.withOpacity(0.9),
                                AppTheme.secondaryColor.withOpacity(0.9),
                              ],
                            ),
                          ),
                        ),
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
                  ),
                ),
              );
            },
          ),
          actions: [
            // Animated action buttons
            AnimatedScale(
              scale: _isScrollingUp ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  ref.read(articleActionsProvider).shareArticle(article.id);
                },
              ),
            ),
            Consumer(
              builder: (context, ref, child) {
                final isFavorite = ref.watch(isArticleFavoritedProvider(article.id));
                
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
                    onPressed: () {
                      if (isFavorite) {
                        ref.read(favoritesProvider.notifier).removeFavorite(article.id);
                      } else {
                        ref.read(favoritesProvider.notifier).addFavorite(article.id);
                      }
                    },
                  ),
                );
              },
            ),
          ],
        ),

        // Animated article content
        SliverToBoxAdapter(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: EdgeInsets.all(_isScrollingUp ? 18 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animated category badge
                TweenAnimationBuilder<double>(
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
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            article.categoryDisplayName.toUpperCase(),
                            style: AppTextStyles.caption.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Animated article headline
                TweenAnimationBuilder<double>(
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
                              style: AppTextStyles.headline3.copyWith(
                                height: 1.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Animated metadata section
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1200),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: _buildMetadataSection(article),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Animated article stats
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1400),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 15 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: Row(
                          children: [
                            _buildAnimatedStatItem(Icons.visibility_outlined, article.viewCount.toString(), 0),
                            const SizedBox(width: 24),
                            _buildAnimatedStatItem(Icons.share_outlined, article.shareCount.toString(), 100),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Animated article content
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1600),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 25 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: _buildArticleContentSection(article),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Animated tags section
                if (article.tagsList.isNotEmpty) 
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1800),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: _buildTagsSection(article),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),

        // Animated related articles section
        SliverToBoxAdapter(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 2000),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: _buildRelatedArticlesSection(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataSection(Article article) {
    return Row(
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
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            article.author!.displayName,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: Text(
            _getTimeAgo(article.publishedAt ?? article.createdAt),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.mutedTextColor,
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
            style: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.mutedTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedStatItem(IconData icon, String value, int delay) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animationValue, child) {
        return Transform.scale(
          scale: animationValue,
          child: Container(
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
                  color: AppTheme.mutedTextColor,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatNumber(int.tryParse(value) ?? 0),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTheme.mutedTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildArticleContentSection(Article article) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (article.briefContent != null) ...[
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
              style: AppTextStyles.bodyLarge.copyWith(
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
        
        if (article.fullContent != null) ...[
          Text(
            article.fullContent!,
            style: AppTextStyles.bodyMedium.copyWith(
              height: 1.8,
            ),
          ),
        ] else ...[
          Text(
            'This is the full article content. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.\n\nDuis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\nSed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.',
            style: AppTextStyles.bodyMedium.copyWith(
              height: 1.8,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTagsSection(Article article) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: AppTextStyles.headline6,
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
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
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
                      style: AppTextStyles.bodySmall.copyWith(
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
    );
  }

  Widget _buildRelatedArticlesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Related Articles',
            style: AppTextStyles.headline5,
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
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(50 * (1 - value), 0),
                            child: Opacity(
                              opacity: value,
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
                padding: EdgeInsets.all(16),
                child: Text('Error loading related articles: $error'),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // Keep existing helper methods unchanged
  Widget _buildLoadingState() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
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
                style: AppTextStyles.headline5.copyWith(
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: AppTextStyles.bodyMedium.copyWith(
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
                style: AppTextStyles.headline5.copyWith(
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The requested article could not be found.',
                style: AppTextStyles.bodyMedium.copyWith(
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
