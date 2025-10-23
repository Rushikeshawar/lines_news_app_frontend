// lib/features/ai_ml/presentation/pages/ai_ml_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/ai_ml_provider.dart';
import '../../widgets/ai_card.dart';
import '../../widgets/trending_ai_card.dart';
import '../../widgets/ai_category_pill.dart';
import '../../models/ai_news_model.dart';
import 'ai_search_page.dart';
import 'ai_category_page.dart';

class AiMlPage extends ConsumerStatefulWidget {
  const AiMlPage({super.key});

  @override
  ConsumerState<AiMlPage> createState() => _AiMlPageState();
}

class _AiMlPageState extends ConsumerState<AiMlPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    
    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('AiMlPage: Triggering data load');
      ref.read(aiMlProvider.notifier).loadAiNews();
    });

    // Setup infinite scroll
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(aiMlProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Futuristic Header
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.purple[900]!.withOpacity(0.8),
                          Colors.blue[900]!.withOpacity(0.6),
                          Colors.cyan[800]!.withOpacity(0.4),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Animated particles background
                        ...List.generate(20, (index) {
                          return AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Positioned(
                                left: (index * 20.0) % MediaQuery.of(context).size.width,
                                top: 50 + (_animationController.value * 100),
                                child: Opacity(
                                  opacity: 0.3,
                                  child: Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      color: Colors.cyan,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                        
                        // Main title
                        Positioned(
                          bottom: 60,
                          left: 24,
                          right: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    Colors.cyan[400]!,
                                    Colors.purple[400]!,
                                    Colors.pink[400]!,
                                  ],
                                ).createShader(bounds),
                                child: const Text(
                                  'AI/ML ZONE',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'The future is here',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.cyan[200],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  // SEARCH - Backend supported
                  IconButton(
                    icon: Icon(
                      Icons.search,
                      color: Colors.cyan[300],
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AiSearchPage(),
                        ),
                      );
                    },
                  ),
                  // REMOVED BOOKMARK - No backend support
                ],
              ),
              
              // AI Categories - With navigation
              // SliverToBoxAdapter(
              //   child: Container(
              //     padding: const EdgeInsets.all(20),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Row(
              //           children: [
              //             Container(
              //               padding: const EdgeInsets.all(8),
              //               decoration: BoxDecoration(
              //                 gradient: LinearGradient(
              //                   colors: [Colors.purple[600]!, Colors.cyan[600]!],
              //                 ),
              //                 borderRadius: BorderRadius.circular(8),
              //               ),
              //               child: const Icon(
              //                 Icons.category,
              //                 color: Colors.white,
              //                 size: 20,
              //               ),
              //             ),
              //             const SizedBox(width: 12),
              //             const Text(
              //               'Hot Topics',
              //               style: TextStyle(
              //                 fontSize: 22,
              //                 fontWeight: FontWeight.w700,
              //                 color: Colors.white,
              //               ),
              //             ),
              //           ],
              //         ),
              //         const SizedBox(height: 16),
              //         _buildCategoryPills(),
              //       ],
              //     ),
              //   ),
              // ),

              // Trending AI Stories
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.only(top: 40, left: 30, right: 30),
                  // padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.orange[600]!, Colors.red[600]!],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.whatshot,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Trending Now',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.purple[600]!, Colors.pink[600]!],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTrendingSection(),
                    ],
                  ),
                ),
              ),
              
              // Latest AI News
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[600]!, Colors.cyan[600]!],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.new_releases,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Latest Drops',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // AI News List
              _buildAiNewsList(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCategoryPills() {
    final categories = [
      {'name': 'ChatGPT', 'icon': Icons.chat_bubble, 'color': Colors.green, 'id': 'ChatGPT'},
      {'name': 'Machine Learning', 'icon': Icons.memory, 'color': Colors.blue, 'id': 'Machine Learning'},
      {'name': 'Deep Learning', 'icon': Icons.psychology, 'color': Colors.purple, 'id': 'Deep Learning'},
      {'name': 'Computer Vision', 'icon': Icons.visibility, 'color': Colors.orange, 'id': 'Computer Vision'},
      {'name': 'NLP', 'icon': Icons.translate, 'color': Colors.pink, 'id': 'NLP'},
      {'name': 'Robotics', 'icon': Icons.smart_toy, 'color': Colors.cyan, 'id': 'Robotics'},
    ];
    
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: AiCategoryPill(
                    name: category['name'] as String,
                    icon: category['icon'] as IconData,
                    color: category['color'] as Color,
                    onTap: () {
                      // Navigate to category page with backend filtering
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AiCategoryPage(
                            categoryId: category['id'] as String,
                            categoryName: category['name'] as String,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  Widget _buildTrendingSection() {
    return Consumer(
      builder: (context, ref, child) {
        final trendingAsync = ref.watch(trendingAiProvider);
        
        print('Building trending section - state: ${trendingAsync.runtimeType}');
        
        return trendingAsync.when(
          data: (articles) {
            print('Trending articles received: ${articles.length}');
            
            if (articles.isEmpty) {
              return _buildEmptyState('No trending AI news available');
            }
            
            return SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  print('Building trending card for: ${article.headline}');
                  
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 400 + (index * 150)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(50 * (1 - value), 0),
                        child: Opacity(
                          opacity: value,
                          child: Container(
                            width: 320,
                            margin: const EdgeInsets.only(right: 16),
                            child: TrendingAiCard(
                              article: article,
                              onTap: () => _navigateToArticle(article),
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
          loading: () {
            print('Trending section loading...');
            return _buildTrendingShimmer();
          },
          error: (error, stack) {
            print('Trending section error: $error');
            return _buildErrorWidget('Failed to load trending AI news: $error');
          },
        );
      },
    );
  }
  
  Widget _buildAiNewsList() {
    return Consumer(
      builder: (context, ref, child) {
        final aiNewsAsync = ref.watch(aiMlProvider);
        
        print('Building AI news list - state: ${aiNewsAsync.runtimeType}');
        
        return aiNewsAsync.when(
          data: (articlesList) {
            print('AI news articles received: ${articlesList.articles.length}');
            
            if (articlesList.articles.isEmpty) {
              return SliverToBoxAdapter(
                child: _buildEmptyState('No AI/ML articles available'),
              );
            }
            
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= articlesList.articles.length) {
                      // Show loading indicator when loading more
                      if (articlesList.isLoadingMore) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.cyan),
                            ),
                          ),
                        );
                      }
                      return null;
                    }
                    
                    final article = articlesList.articles[index];
                    print('Building AI card for: ${article.headline}');
                    
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 200 + (index * 100)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: AiCard(
                                article: article,
                                onTap: () => _navigateToArticle(article),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: articlesList.articles.length + (articlesList.isLoadingMore ? 1 : 0),
                ),
              ),
            );
          },
          loading: () {
            print('AI news list loading...');
            return _buildNewsShimmer();
          },
          error: (error, stack) {
            print('AI news list error: $error');
            return SliverToBoxAdapter(
              child: _buildErrorWidget('Failed to load AI/ML news: $error'),
            );
          },
        );
      },
    );
  }
  
  void _navigateToArticle(AiNewsModel article) {
    try {
      print('Navigating to AI article: ${article.id}');
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AiArticleDetailPage(article: article),
        ),
      );
      
    } catch (e) {
      print('Navigation error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigation error: $e'),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
  
  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.smart_toy_outlined,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildTrendingShimmer() {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[800]!,
              highlightColor: Colors.grey[700]!,
              child: Container(
                width: 320,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildNewsShimmer() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[800]!,
                highlightColor: Colors.grey[700]!,
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(16),
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
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              print('Retry button pressed - refreshing data');
              ref.read(aiMlProvider.notifier).refresh();
              ref.refresh(trendingAiProvider);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Article Detail Page
class AiArticleDetailPage extends ConsumerStatefulWidget {
  final AiNewsModel article;

  const AiArticleDetailPage({super.key, required this.article});

  @override
  ConsumerState<AiArticleDetailPage> createState() => _AiArticleDetailPageState();
}

class _AiArticleDetailPageState extends ConsumerState<AiArticleDetailPage> {
  @override
  void initState() {
    super.initState();
    // Track view when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiMlRepositoryProvider).trackAiArticleView(widget.article.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'AI Article',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple[700]!, Colors.cyan[600]!],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.cyan[300]),
            onPressed: () async {
              // Implement share functionality with backend tracking
              try {
                final repository = ref.read(aiMlRepositoryProvider);
                
                // Track the share interaction
                await repository.trackAiArticleInteraction(widget.article.id, 'SHARE');
                
                // Show share dialog using share_plus package or custom bottom sheet
                // For now, show success message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Article shared! Share count: ${widget.article.shareCount + 1}'),
                      backgroundColor: Colors.cyan,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                print('Error sharing article: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to share article'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category and AI Model badges
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple[600]!, Colors.pink[600]!],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.article.category.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (widget.article.aiModel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.cyan.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.cyan.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.smart_toy, color: Colors.cyan[300], size: 14),
                        const SizedBox(width: 4),
                        Text(
                          widget.article.aiModel!,
                          style: TextStyle(
                            color: Colors.cyan[300],
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Title
            Text(
              widget.article.headline,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color.fromARGB(255, 70, 68, 68),
                height: 1.2,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Meta info row
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Text(
                      widget.article.readingTime,
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility_outlined, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.article.viewCount} views',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
                if (widget.article.shareCount > 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.share_outlined, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.article.shareCount} shares',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    ],
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(widget.article.publishedAt),
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            
            // Author info
            if (widget.article.author != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.purple[700],
                    backgroundImage: widget.article.author!.avatar != null
                        ? CachedNetworkImageProvider(widget.article.author!.avatar!)
                        : null,
                    child: widget.article.author!.avatar == null
                        ? Icon(Icons.person, color: Colors.white, size: 20)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.article.author!.name,
                          style: TextStyle(
                            color: Colors.grey[200],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (widget.article.author!.expertise != null)
                          Text(
                            widget.article.author!.expertise!,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Featured image
            if (widget.article.featuredImage != null)
              Container(
                width: double.infinity,
                height: 220,
                margin: const EdgeInsets.only(bottom: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: widget.article.featuredImage!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.cyan),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, color: Colors.grey, size: 48),
                      ),
                    ),
                  ),
                ),
              ),
            
            // Brief/Summary in highlighted box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple[800]!.withOpacity(0.3),
                    Colors.cyan[800]!.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.cyan.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.cyan[300], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.cyan[300],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.article.briefContent,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[200],
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // FULL CONTENT - This is the main article body
            if (widget.article.fullContent != null && widget.article.fullContent!.isNotEmpty) ...[
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Article',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[200],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.article.fullContent!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[300],
                        height: 1.8,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Additional metadata
            if (widget.article.companyMentioned != null || 
                widget.article.technologyType != null ||
                widget.article.aiApplication != null) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Article Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[300],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (widget.article.companyMentioned != null)
                      _buildDetailRow(
                        Icons.business,
                        'Company',
                        widget.article.companyMentioned!,
                      ),
                    if (widget.article.technologyType != null)
                      _buildDetailRow(
                        Icons.computer,
                        'Technology',
                        widget.article.technologyType!,
                      ),
                    if (widget.article.aiApplication != null)
                      _buildDetailRow(
                        Icons.apps,
                        'Application',
                        widget.article.aiApplication!,
                      ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
// Tags
if (widget.article.tags.isNotEmpty) ...[
  Text(
    'Tags',
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: Colors.grey[300],
    ),
  ),
  const SizedBox(height: 12),
  Wrap(
    spacing: 12,
    runSpacing: 12,
    children: widget.article.tags.map((tag) {
      return Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.4, // Limit max width to 40% of screen width
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple[700]!.withOpacity(0.3),
              Colors.cyan[700]!.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.cyan.withOpacity(0.5)),
        ),
        child: Text( // Simplified to use Text instead of Row
          tag,
          style: TextStyle(
            color: Colors.cyan[300],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis, // Handle long tags
        ),
      );
    }).toList(),
  ),
  const SizedBox(height: 24),
],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyan[400], size: 18),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}