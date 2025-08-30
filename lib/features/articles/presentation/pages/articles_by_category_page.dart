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

class _ArticlesByCategoryPageState extends ConsumerState<ArticlesByCategoryPage> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final articlesAsync = ref.watch(articlesByCategoryProvider(widget.category));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.categoryName,
          style: AppTextStyles.headline4,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterOptions(context);
            },
          ),
        ],
      ),
      body: articlesAsync.when(
        data: (articles) => _buildArticlesList(articles),
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildArticlesList(List<Article> articles) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Category header
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor.withOpacity(0.1),
                  AppTheme.secondaryColor.withOpacity(0.1),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getCategoryIcon(),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Latest in ${widget.categoryName}',
                            style: AppTextStyles.headline3,
                          ),
                          Text(
                            '${articles.length} articles available',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppTheme.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Articles list
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final article = articles[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ArticleCard(
                    article: article,
                    isHorizontal: true,
                    onTap: () => context.push('/article/${article.id}'),
                  ),
                );
              },
              childCount: articles.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading articles...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
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
            ElevatedButton(
              onPressed: () {
                ref.invalidate(articlesByCategoryProvider(widget.category));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
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
      default:
        return Icons.article;
    }
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Options',
              style: AppTextStyles.headline5,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Most Recent'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement sorting
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sorting by most recent')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: const Text('Most Popular'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement sorting
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sorting by most popular')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('This Week'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement filtering
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Showing articles from this week')),
                );
              },
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
    );
  }
}