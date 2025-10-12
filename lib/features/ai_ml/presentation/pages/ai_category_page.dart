// lib/features/ai_ml/presentation/pages/ai_category_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/ai_ml_provider.dart';
import '../../widgets/ai_card.dart';
import '../../models/ai_news_model.dart';
import 'ai_ml_page.dart';

class AiCategoryPage extends ConsumerStatefulWidget {
  final String categoryId;
  final String categoryName;

  const AiCategoryPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  ConsumerState<AiCategoryPage> createState() => _AiCategoryPageState();
}

class _AiCategoryPageState extends ConsumerState<AiCategoryPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load category articles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiCategoryProvider(widget.categoryId).notifier).loadArticles();
    });

    // Setup infinite scroll
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(aiCategoryProvider(widget.categoryId).notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(aiCategoryProvider(widget.categoryId));

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple[700]!, Colors.cyan[600]!],
            ),
          ),
        ),
      ),
      body: categoryState.when(
        data: (articlesList) {
          if (articlesList.articles.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(aiCategoryProvider(widget.categoryId).notifier).refresh();
            },
            color: Colors.cyan,
            backgroundColor: Colors.grey[900],
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: articlesList.articles.length + (articlesList.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= articlesList.articles.length) {
                  // Loading indicator
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.cyan),
                      ),
                    ),
                  );
                }

                final article = articlesList.articles[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AiCard(
                    article: article,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AiArticleDetailPage(article: article),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.cyan),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(
                'Failed to load articles',
                style: TextStyle(fontSize: 18, color: Colors.grey[300]),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(aiCategoryProvider(widget.categoryId).notifier).refresh();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No articles in this category',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}