// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../articles/models/article_model.dart';
import '../../../articles/providers/articles_provider_home.dart';
import '../../../ads/providers/ads_provider.dart';
import '../../../categories/providers/categories_provider.dart';
import '../../../favorites/providers/favorites_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/article_card.dart';
import '../widgets/trending_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/ad_banner.dart';
import '../widgets/lines_logo.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _oneLineController;
  late Animation<double> _oneLineAnimation;
  bool _showOneLine = false;
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    _oneLineController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _oneLineAnimation = CurvedAnimation(
      parent: _oneLineController,
      curve: Curves.easeInOut,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    try {
      final authState = ref.read(authProvider);
      final isAuthenticated = authState.when(
        data: (user) => user != null,
        loading: () => false,
        error: (_, __) => false,
      );

      if (!isAuthenticated) {
        print('User not authenticated, redirecting to login');
        if (mounted) {
          context.go('/auth/login');
        }
        return;
      }

      await ref.read(articlesProvider.notifier).refresh();
      
      try {
        ref.invalidate(favoritesProvider);
      } catch (e) {
        print('Error loading favorites: $e');
        _handleAuthError(e);
      }
    } catch (e) {
      print('Error initializing data: $e');
      _handleAuthError(e);
    }
  }

  void _handleAuthError(dynamic error) {
    if (error.toString().contains('401') || 
        error.toString().contains('No token provided') ||
        error.toString().contains('Unauthorized')) {
      
      print('Authentication error detected, clearing session');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Session expired. Please log in again.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Login',
              textColor: Colors.white,
              onPressed: () => context.go('/auth/login'),
            ),
          ),
        );
        
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            ref.read(authProvider.notifier).logout();
            context.go('/auth/login');
          }
        });
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels > 100 && !_showOneLine) {
      setState(() => _showOneLine = true);
      _oneLineController.forward();
    } else if (_scrollController.position.pixels <= 100 && _showOneLine) {
      setState(() => _showOneLine = false);
      _oneLineController.reverse();
    }
  }

  Future<void> _loadMoreArticles() async {
    try {
      await ref.read(articlesProvider.notifier).loadMore();
    } catch (e) {
      print('Error loading more articles: $e');
      _handleAuthError(e);
    }
  }

  void _navigateToArticle(String articleId) {
    context.push('/article/$articleId');
  }

  // CHECK AUTH BEFORE FAVORITES
  void _navigateToFavorites() {
    final authState = ref.read(authProvider);
    final isAuthenticated = authState.when(
      data: (user) => user != null,
      loading: () => false,
      error: (_, __) => false,
    );

    if (!isAuthenticated) {
      _showLoginPrompt();
      return;
    }

    context.go('/favorites');
  }

  void _navigateToSearch() {
    try {
      context.go('/search');
    } catch (e) {
      context.goNamed('search');
    }
  }

  void _navigateToNotifications() {
    try {
      context.push('/notifications');
    } catch (e) {
      context.pushNamed('notifications');
    }
  }

  void _navigateToCategories() {
    try {
      context.push('/categories');
    } catch (e) {
      print('Categories navigation error: $e');
    }
  }

  void _showLoginPrompt() {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.lock_outline, color: AppTheme.primaryColor, size: 28),
              const SizedBox(width: 12),
              const Text('Login Required'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'You need to be logged in to access your favorites.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                'Please log in with your credentials or use the demo account.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/auth/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _oneLineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                try {
                  final authState = ref.read(authProvider);
                  final isAuthenticated = authState.when(
                    data: (user) => user != null,
                    loading: () => false,
                    error: (_, __) => false,
                  );

                  if (!isAuthenticated) {
                    _showLoginPrompt();
                    return;
                  }

                  await ref.read(articlesProvider.notifier).refresh();
                  
                  try {
                    ref.invalidate(favoritesProvider);
                  } catch (e) {
                    print('Error refreshing favorites: $e');
                  }
                  
                  ref.invalidate(trendingArticlesProvider);
                  ref.invalidate(categoriesProvider);
                  ref.invalidate(bannerAdsProvider);
                } catch (e) {
                  print('Error during refresh: $e');
                  _handleAuthError(e);
                }
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    scrolledUnderElevation: 2,
                    shadowColor: Colors.black12,
                    toolbarHeight: 70,
                    title: const LinesLogo(),
                    centerTitle: true,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.black87),
                        tooltip: 'Refresh',
                        onPressed: () async {
                          try {
                            await ref.read(articlesProvider.notifier).refresh();
                            ref.invalidate(trendingArticlesProvider);
                            ref.invalidate(categoriesProvider);
                            ref.invalidate(bannerAdsProvider);
                            
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Content refreshed'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          } catch (e) {
                            print('Refresh error: $e');
                            _handleAuthError(e);
                          }
                        },
                      ),
                      
                      IconButton(
                        icon: const Icon(Icons.search_outlined, color: Colors.black87),
                        onPressed: _navigateToSearch,
                      ),
                      
                      // FAVORITES BUTTON WITH AUTH CHECK
                      Consumer(
                        builder: (context, ref, child) {
                          final authState = ref.watch(authProvider);
                          final isAuthenticated = authState.when(
                            data: (user) => user != null,
                            loading: () => false,
                            error: (_, __) => false,
                          );

                          if (!isAuthenticated) {
                            return IconButton(
                              icon: const Icon(
                                Icons.favorite_border_outlined,
                                color: Colors.black87,
                              ),
                              onPressed: _showLoginPrompt,
                              tooltip: 'Login to access favorites',
                            );
                          }

                          final favoritesState = ref.watch(favoritesProvider);
                          
                          return favoritesState.when(
                            data: (favoriteIds) => Stack(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    favoriteIds.isNotEmpty 
                                        ? Icons.favorite 
                                        : Icons.favorite_border_outlined,
                                    color: favoriteIds.isNotEmpty 
                                        ? Colors.red 
                                        : Colors.black87,
                                  ),
                                  onPressed: _navigateToFavorites,
                                  tooltip: 'My Favorites',
                                ),
                                if (favoriteIds.isNotEmpty)
                                  Positioned(
                                    right: 6,
                                    top: 6,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1,
                                        ),
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 18,
                                        minHeight: 18,
                                      ),
                                      child: Text(
                                        '${favoriteIds.length > 99 ? '99+' : favoriteIds.length}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            loading: () => IconButton(
                              icon: const Icon(
                                Icons.favorite_border_outlined,
                                color: Colors.black87,
                              ),
                              onPressed: _navigateToFavorites,
                            ),
                            error: (error, stack) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (error.toString().contains('401') || 
                                    error.toString().contains('No token provided')) {
                                  _handleAuthError(error);
                                }
                              });
                              
                              return IconButton(
                                icon: const Icon(
                                  Icons.favorite_border_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: _showLoginPrompt,
                                tooltip: 'Login to access favorites',
                              );
                            },
                          );
                        },
                      ),
                      
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
                            onPressed: _navigateToNotifications,
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good ${_getGreeting()}!',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Stay updated with the latest news',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: const Text(
                            'Categories',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        _buildCategoriesSection(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: _buildBannerAd(),
                  ),

                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.trending_up,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Trending Now',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTrendingSection(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.fiber_new,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Latest News',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  _buildLatestArticlesList(),

                  SliverToBoxAdapter(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final articlesState = ref.watch(articlesProvider);
                        
                        return articlesState.when(
                          data: (articles) {
                            if (articles.isLoadingMore) {
                              return Container(
                                padding: const EdgeInsets.all(24),
                                child: Center(
                                  child: Column(
                                    children: [
                                      CircularProgressIndicator(
                                        color: AppTheme.primaryColor,
                                        strokeWidth: 2,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Loading more articles...',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            
                            if (articles.hasNext) {
                              return Container(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _loadMoreArticles,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  icon: const Icon(Icons.expand_more, size: 20),
                                  label: const Text(
                                    'Load More Articles',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            }
                            
                            return Container(
                              padding: const EdgeInsets.all(24),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.green[400],
                                      size: 48,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'You\'ve reached the end',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Pull down to refresh for new content',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          loading: () => Container(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          error: (_, __) => const SizedBox(height: 24),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _oneLineAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -60 * (1 - _oneLineAnimation.value)),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade600, Colors.red.shade700],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'LIVE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.flash_on,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Breaking: Major news updates happening now - Tap for details',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  // Rest of the helper methods remain the same...
  Widget _buildCategoriesSection() {
    return Consumer(
      builder: (context, ref, child) {
        final categoriesAsync = ref.watch(categoriesProvider);
        
        return categoriesAsync.when(
          data: (categories) {
            if (categories.isEmpty) {
              return _buildEmptyState('No categories available');
            }
            
            return SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: CategoryChip(category: categories[index]),
                  );
                },
              ),
            );
          },
          loading: () => _buildCategoriesShimmer(),
          error: (error, stack) => _buildErrorWidget('Failed to load categories'),
        );
      },
    );
  }

  Widget _buildBannerAd() {
    return Consumer(
      builder: (context, ref, child) {
        final bannerAds = ref.watch(bannerAdsProvider);
        
        return bannerAds.when(
          data: (ads) {
            if (ads.isEmpty) return const SizedBox.shrink();
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: AdBanner(advertisement: ads.first),
            );
          },
          loading: () => _buildAdShimmer(),
          error: (error, stack) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildTrendingSection() {
    return Consumer(
      builder: (context, ref, child) {
        final trendingAsync = ref.watch(trendingArticlesProvider);
        
        return trendingAsync.when(
          data: (articles) {
            if (articles.isEmpty) {
              return _buildEmptyState('No trending articles available');
            }
            
            return SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => _navigateToArticle(articles[index].id),
                      child: TrendingCard(article: articles[index]),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => _buildTrendingShimmer(),
          error: (error, stack) => _buildErrorWidget('Failed to load trending articles'),
        );
      },
    );
  }

  Widget _buildLatestArticlesList() {
    return Consumer(
      builder: (context, ref, child) {
        final articlesAsync = ref.watch(articlesProvider);
        final authState = ref.watch(authProvider);
        final isAuthenticated = authState.when(
          data: (user) => user != null,
          loading: () => false,
          error: (_, __) => false,
        );
        
        return articlesAsync.when(
          data: (articlesList) {
            List<Article> articles = List<Article>.from(articlesList.articles);
            articles.sort((a, b) {
              final aDate = a.publishedAt ?? a.createdAt;
              final bDate = b.publishedAt ?? b.createdAt;
              return bDate.compareTo(aDate);
            });
            
            if (articles.isEmpty) {
              return SliverToBoxAdapter(
                child: _buildEmptyState('No articles available'),
              );
            }

            // Only try to get favorites if authenticated
            final favoritesState = isAuthenticated 
                ? ref.watch(favoritesProvider) 
                : const AsyncValue.data(<String>[]);
            
            return SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= articles.length) return null;
                    
                    final article = articles[index];
                    final shouldShowAd = (index + 1) % 10 == 0;
                    
                    final isFavorited = favoritesState.when(
                      data: (favoriteIds) => favoriteIds.contains(article.id),
                      loading: () => false,
                      error: (_, __) => false,
                    );
                    
                    final updatedArticle = Article(
                      id: article.id,
                      headline: article.headline,
                      briefContent: article.briefContent,
                      fullContent: article.fullContent,
                      category: article.category,
                      status: article.status,
                      priorityLevel: article.priorityLevel,
                      authorId: article.authorId,
                      approvedBy: article.approvedBy,
                      featuredImage: article.featuredImage,
                      tags: article.tags,
                      slug: article.slug,
                      metaTitle: article.metaTitle,
                      metaDescription: article.metaDescription,
                      viewCount: article.viewCount,
                      shareCount: article.shareCount,
                      publishedAt: article.publishedAt,
                      scheduledAt: article.scheduledAt,
                      createdAt: article.createdAt,
                      updatedAt: article.updatedAt,
                      author: article.author,
                      approver: article.approver,
                      isFavorited: isFavorited,
                      savedAt: article.savedAt,
                    );
                    
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ArticleCard(
                            article: updatedArticle,
                            onTap: () => _navigateToArticle(article.id),
                          ),
                        ),
                        if (shouldShowAd) _buildGoogleAdPlaceholder(),
                      ],
                    );
                  },
                  childCount: articles.length,
                ),
              ),
            );
          },
          loading: () => _buildArticlesShimmer(),
          error: (error, stack) => SliverToBoxAdapter(
            child: _buildErrorWidget('Failed to load articles'),
          ),
        );
      },
    );
  }

  Widget _buildGoogleAdPlaceholder() {
    return Container(
      width: double.infinity,
      height: 120,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.ads_click, color: Colors.grey[500], size: 32),
            const SizedBox(height: 8),
            Text(
              'Google Advertisement',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesShimmer() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 60,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdShimmer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingShimmer() {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildArticlesShimmer() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            );
          },
          childCount: 6,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ref.invalidate(articlesProvider);
              ref.invalidate(trendingArticlesProvider);
              ref.invalidate(categoriesProvider);
              ref.invalidate(bannerAdsProvider);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}