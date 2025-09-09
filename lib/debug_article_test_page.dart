// lib/debug_article_test_page.dart - Create this file temporarily for testing
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/articles/providers/missing_providers.dart';

class DebugArticleTestPage extends ConsumerWidget {
  final String articleId;
  
  const DebugArticleTestPage({
    super.key,
    required this.articleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Article Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Testing Article ID: $articleId',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Debug info display
            Consumer(
              builder: (context, ref, child) {
                final debugAsync = ref.watch(debugArticleProvider(articleId));
                
                return debugAsync.when(
                  data: (debugInfo) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDebugItem('Article Found', debugInfo['articleFound'].toString()),
                        _buildDebugItem('Headline', debugInfo['headline'].toString()),
                        _buildDebugItem('Brief Content Length', debugInfo['briefContentLength'].toString()),
                        _buildDebugItem('Full Content Length', debugInfo['fullContentLength'].toString()),
                        _buildDebugItem('Category', debugInfo['category'].toString()),
                        _buildDebugItem('Published At', debugInfo['publishedAt'].toString()),
                        _buildDebugItem('Featured Image', debugInfo['featuredImage'].toString()),
                        const SizedBox(height: 20),
                        const Text('Full Content Preview:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            debugInfo['fullContentPreview'].toString(),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Column(
                    children: [
                      const Text('Error loading debug info:', style: TextStyle(color: Colors.red)),
                      Text(error.toString()),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 30),
            
            // Regular article provider test
            const Text(
              'Regular Article Provider Test:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            Consumer(
              builder: (context, ref, child) {
                final articleAsync = ref.watch(articleByIdProvider(articleId));
                
                return articleAsync.when(
                  data: (article) {
                    if (article == null) {
                      return const Text('Article is null', style: TextStyle(color: Colors.red));
                    }
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Headline: ${article.headline}'),
                        Text('Brief Content: ${article.briefContent?.substring(0, (article.briefContent?.length ?? 0).clamp(0, 50))}...'),
                        Text('Full Content Length: ${article.fullContent?.length ?? 0}'),
                        Text('Full Content Available: ${article.fullContent != null && article.fullContent!.isNotEmpty}'),
                        if (article.fullContent != null && article.fullContent!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          const Text('Full Content Preview:'),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              border: Border.all(color: Colors.green),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              article.fullContent!.substring(0, article.fullContent!.length.clamp(0, 200)),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error', style: const TextStyle(color: Colors.red)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}