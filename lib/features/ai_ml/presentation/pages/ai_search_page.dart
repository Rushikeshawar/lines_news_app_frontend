// lib/features/ai_ml/presentation/pages/ai_search_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/ai_ml_provider.dart';
import '../../widgets/ai_card.dart';
import '../../models/ai_news_model.dart';
import 'ai_ml_page.dart';

class AiSearchPage extends ConsumerStatefulWidget {
  const AiSearchPage({super.key});

  @override
  ConsumerState<AiSearchPage> createState() => _AiSearchPageState();
}

class _AiSearchPageState extends ConsumerState<AiSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    // Auto focus on search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      ref.read(aiSearchProvider.notifier).search(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(aiSearchProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 57, 57, 57)),
    onPressed: () => Navigator.of(context).pop(),
  ),
  title: Container(
    height: 40,
    decoration: BoxDecoration(
      color: const Color(0xFF0A0A0B).withOpacity(0.8), // Matches the body background
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.cyan.withOpacity(0.3)),
    ),
    child: TextField(
      controller: _searchController,
      focusNode: _focusNode,
      style: const TextStyle(color: Color.fromARGB(255, 31, 31, 31), fontSize: 16),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        hintText: 'Search AI/ML articles...',
        hintStyle: TextStyle(color: const Color.fromARGB(255, 64, 63, 63), fontWeight: FontWeight.w400),
        border: InputBorder.none,
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: const Color.fromARGB(255, 53, 53, 53), size: 20),
                onPressed: () {
                  _searchController.clear();
                  ref.read(aiSearchProvider.notifier).clear();
                  setState(() {});
                },
              )
            : null,
      ),
      onSubmitted: (_) => _performSearch(),
      onChanged: (value) => setState(() {}),
    ),
  ),
  flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.purple[800]!.withOpacity(0.9),
          Colors.cyan[600]!.withOpacity(0.9),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.search, color: Colors.white),
      onPressed: _performSearch,
    ),
  ],
),
      body: searchState.when(
        data: (results) {
          if (_searchController.text.isEmpty) {
            return _buildSearchSuggestions();
          }
          
          if (results.isEmpty) {
            return _buildEmptyResults();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final article = results[index];
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
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.cyan),
          ),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(
                'Search failed',
                style: TextStyle(fontSize: 18, color: Colors.grey[300]),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(fontSize: 14, color: const Color.fromARGB(255, 78, 77, 77)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    final popularTopics = [
      'ChatGPT', 'Machine Learning', 'Deep Learning',
      'Computer Vision', 'NLP', 'Neural Networks',
      'AI Ethics', 'Robotics', 'GPT-4', 'Transformers'
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Topics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: popularTopics.map((topic) {
              return InkWell(
                onTap: () {
                  _searchController.text = topic;
                  _performSearch();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple[700]!.withOpacity(0.3),
                        Colors.cyan[700]!.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.cyan.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search, color: Colors.cyan[300], size: 16),
                      const SizedBox(width: 8),
                      Text(
                        topic,
                        style: TextStyle(
                          color: Colors.cyan[300],
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try different keywords',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}