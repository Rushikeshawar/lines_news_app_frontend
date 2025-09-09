// lib/features/articles/presentation/pages/articles_by_category_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/article_model.dart';
import '../../providers/missing_providers.dart';
import '../../../home/presentation/widgets/article_card.dart';

class ArticlesByCategoryPage extends ConsumerStatefulWidget {
  final String category;
  final String categoryName;

  const ArticlesByCategoryPage({
    super.key,
    required this.category,
    required this.categoryName,
  });

  @override
  ConsumerState<ArticlesByCategoryPage> createState() => _ArticlesByCategoryPageState();
}

class _ArticlesByCategoryPageState extends ConsumerState<ArticlesByCategoryPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _sortBy = 'latest'; // latest, popular, oldest
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start animation
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final articlesAsync = ref.watch(articlesByCategoryProvider(widget.category));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Enhanced App Bar
              _buildSliverAppBar(),
              
              // Content
              articlesAsync.when(
                data: (articles) => _buildArticlesContent(articles),
                loading: () => _buildLoadingSliver(),
                error: (error, stack) => _buildErrorSliver(error.toString()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.black),
          onPressed: () => _showFilterOptions(context),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
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
          child: Container(
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
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _getCategoryIcon(),
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.categoryName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Consumer(
                      builder: (context, ref, child) {
                        final articlesAsync = ref.watch(articlesByCategoryProvider(widget.category));
                        return articlesAsync.when(
                          data: (articles) => Text(
                            '${articles.length} articles available',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                          loading: () => Text(
                            'Loading articles...',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                          error: (_, __) => Text(
                            'Error loading articles',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArticlesContent(List<Article> articles) {
    if (articles.isEmpty) {
      return _buildEmptyStateSliver();
    }

    // Sort articles based on selected criteria
    final sortedArticles = _sortArticles(articles);

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              // Add sort indicator at the top
              return Column(
                children: [
                  _buildSortIndicator(),
                  const SizedBox(height: 16),
                  _buildArticleItem(sortedArticles[index], index),
                ],
              );
            }
            return _buildArticleItem(sortedArticles[index - 1], index - 1);
          },
          childCount: sortedArticles.length + 1, // +1 for sort indicator
        ),
      ),
    );
  }

  Widget _buildSortIndicator() {
    String sortText = '';
    IconData sortIcon = Icons.sort;
    
    switch (_sortBy) {
      case 'latest':
        sortText = 'Latest Articles';
        sortIcon = Icons.schedule;
        break;
      case 'popular':
        sortText = 'Most Popular';
        sortIcon = Icons.trending_up;
        break;
      case 'oldest':
        sortText = 'Oldest First';
        sortIcon = Icons.history;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Reduced padding
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: IntrinsicHeight( // Fix 1: Use IntrinsicHeight to prevent overflow
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Fix 2: Better space distribution
          children: [
            Expanded( // Fix 3: Use Expanded for flexible text
              child: Row(
                children: [
                  Icon(
                    sortIcon,
                    size: 20,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Flexible( // Fix 4: Make text flexible
                    child: Text(
                      sortText,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis, // Fix 5: Handle text overflow
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Tap filter to change',
              style: TextStyle(
                color: AppTheme.primaryColor.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleItem(Article article, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: ArticleCard(
                article: article,
                isHorizontal: true,
                onTap: () {
                  // Navigate to article detail
                  context.push('/article/${article.id}');
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyStateSliver() {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getCategoryIcon(),
                size: 64,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'No Articles Found',
                style: AppTextStyles.headline5.copyWith(
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'There are no articles in the ${widget.categoryName} category yet.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(articlesByCategoryProvider(widget.category));
                },
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSliver() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading ${widget.categoryName} articles...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSliver(String error) {
    return SliverFillRemaining(
      child: Center(
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
                'Failed to Load Articles',
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
                      ref.invalidate(articlesByCategoryProvider(widget.category));
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

  List<Article> _sortArticles(List<Article> articles) {
    final sortedArticles = List<Article>.from(articles);
    
    switch (_sortBy) {
      case 'latest':
        sortedArticles.sort((a, b) {
          final aDate = a.publishedAt ?? a.createdAt;
          final bDate = b.publishedAt ?? b.createdAt;
          return bDate.compareTo(aDate); // Latest first
        });
        break;
      case 'popular':
        sortedArticles.sort((a, b) {
          // Sort by view count first, then by date
          final viewComparison = b.viewCount.compareTo(a.viewCount);
          if (viewComparison != 0) return viewComparison;
          
          final aDate = a.publishedAt ?? a.createdAt;
          final bDate = b.publishedAt ?? b.createdAt;
          return bDate.compareTo(aDate);
        });
        break;
      case 'oldest':
        sortedArticles.sort((a, b) {
          final aDate = a.publishedAt ?? a.createdAt;
          final bDate = b.publishedAt ?? b.createdAt;
          return aDate.compareTo(bDate); // Oldest first
        });
        break;
    }
    
    return sortedArticles;
  }

  IconData _getCategoryIcon() {
    switch (widget.category.toLowerCase()) {
      case 'technology':
        return Icons.computer;
      case 'business':
        return Icons.business_center;
      case 'health':
        return Icons.health_and_safety;
      case 'sports':
        return Icons.sports;
      case 'politics':
        return Icons.account_balance;
      case 'environment':
        return Icons.eco;
      case 'science':
        return Icons.science;
      case 'education':
        return Icons.school;
      case 'entertainment':
        return Icons.movie;
      case 'crime':
        return Icons.security;
      case 'general':
        return Icons.article;
      case 'national':
        return Icons.flag;
      case 'international':
        return Icons.public;
      case 'lifestyle':
        return Icons.favorite;
      case 'finance':
        return Icons.attach_money;
      case 'food':
        return Icons.restaurant;
      case 'fashion':
        return Icons.checkroom;
      default:
        return Icons.article;
    }
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: SafeArea( // Fix 6: Wrap in SafeArea to handle bottom padding properly
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              Text(
                'Sort Articles',
                style: AppTextStyles.headline5,
              ),
              const SizedBox(height: 20),
              
              // Sort options
              _buildSortOption(
                title: 'Latest Articles',
                subtitle: 'Most recent articles first',
                icon: Icons.schedule,
                value: 'latest',
                isSelected: _sortBy == 'latest',
              ),
              _buildSortOption(
                title: 'Most Popular',
                subtitle: 'Articles with most views',
                icon: Icons.trending_up,
                value: 'popular',
                isSelected: _sortBy == 'popular',
              ),
              _buildSortOption(
                title: 'Oldest First',
                subtitle: 'Show older articles first',
                icon: Icons.history,
                value: 'oldest',
                isSelected: _sortBy == 'oldest',
              ),
              
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required bool isSelected,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.primaryColor.withOpacity(0.1) 
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: isSelected 
              ? Border.all(color: AppTheme.primaryColor, width: 2)
              : null,
        ),
        child: Icon(
          icon,
          color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppTheme.primaryColor : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: isSelected 
          ? Icon(
              Icons.check_circle,
              color: AppTheme.primaryColor,
            )
          : null,
      onTap: () {
        setState(() {
          _sortBy = value;
        });
        Navigator.pop(context);
        
        // Show confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sorted by $title'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }
}