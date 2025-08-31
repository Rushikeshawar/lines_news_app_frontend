// lib/features/ai_ml/presentation/pages/ai_ml_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/ai_ml_provider.dart';
import '../../widgets/ai_card.dart';
import '../../widgets/trending_ai_card.dart';
import '../../widgets/ai_category_pill.dart';

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
      ref.read(aiMlProvider.notifier).loadAiNews();
    });
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
                                'The future is here 🤖✨',
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
                  IconButton(
                    icon: Icon(
                      Icons.search,
                      color: Colors.cyan[300],
                    ),
                    onPressed: () {
                      // Add search functionality
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.bookmark_border,
                      color: Colors.cyan[300],
                    ),
                    onPressed: () {
                      // Add bookmark functionality
                    },
                  ),
                ],
              ),
              
              // AI Categories
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.purple[600]!, Colors.cyan[600]!],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.category,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Hot Topics',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildCategoryPills(),
                    ],
                  ),
                ),
              ),

              // Trending AI Stories
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
      {'name': 'ChatGPT', 'icon': Icons.chat_bubble, 'color': Colors.green},
      {'name': 'Machine Learning', 'icon': Icons.memory, 'color': Colors.blue},
      {'name': 'Deep Learning', 'icon': Icons.psychology, 'color': Colors.purple},
      {'name': 'Computer Vision', 'icon': Icons.visibility, 'color': Colors.orange},
      {'name': 'NLP', 'icon': Icons.translate, 'color': Colors.pink},
      {'name': 'Robotics', 'icon': Icons.smart_toy, 'color': Colors.cyan},
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
                      // Navigate to category specific page
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
        
        return trendingAsync.when(
          data: (articles) {
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
                              onTap: () => _navigateToArticle(article.id),
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
          loading: () => _buildTrendingShimmer(),
          error: (error, stack) => _buildErrorWidget('Failed to load trending AI news'),
        );
      },
    );
  }
  
  Widget _buildAiNewsList() {
    return Consumer(
      builder: (context, ref, child) {
        final aiNewsAsync = ref.watch(aiMlProvider);
        
        return aiNewsAsync.when(
          data: (articlesList) {
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
                    if (index >= articlesList.articles.length) return null;
                    
                    final article = articlesList.articles[index];
                    
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
                                onTap: () => _navigateToArticle(article.id),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: articlesList.articles.length,
                ),
              ),
            );
          },
          loading: () => _buildNewsShimmer(),
          error: (error, stack) => SliverToBoxAdapter(
            child: _buildErrorWidget('Failed to load AI/ML news'),
          ),
        );
      },
    );
  }
  
  void _navigateToArticle(String articleId) {
    context.push('/article/$articleId');
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
              ref.read(aiMlProvider.notifier).loadAiNews();
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