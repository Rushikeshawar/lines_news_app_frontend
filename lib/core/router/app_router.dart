// lib/core/router/app_router.dart - UPDATED VERSION WITH NEW ROUTES
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/main_wrapper.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/articles/presentation/pages/article_detail_page.dart';
import '../../features/articles/presentation/pages/articles_by_category_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/ads/presentation/pages/full_screen_ad_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/ai_ml/presentation/pages/ai_ml_page.dart';
import '../../features/time_saver/presentation/pages/time_saver_page.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/time_saver/presentation/pages/time_saver_content_page.dart';
import '../../features/time_saver/presentation/pages/breaking_news_detail_page.dart';
import '../../features/time_saver/presentation/pages/breaking_news_detail_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = ref.read(authProvider).when(
        data: (user) => user != null,
        loading: () => false,
        error: (_, __) => false,
      );
      
      final isAuthRoute = state.uri.toString().startsWith('/auth');
      
      if (!isAuthenticated && !isAuthRoute) {
        return '/auth/login';
      }
      
      if (isAuthenticated && isAuthRoute) {
        return '/';
      }
      
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      
      // Main app routes with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainWrapper(child: child),
        routes: [
          // Home
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomePage(),
            routes: [
              GoRoute(
                path: 'article/:id',
                name: 'article-detail',
                builder: (context, state) {
                  final articleId = state.pathParameters['id']!;
                  return ArticleDetailPage(articleId: articleId);
                },
              ),
            ],
          ),
          
          // AI/ML Section
          GoRoute(
            path: '/ai-ml',
            name: 'ai-ml',
            builder: (context, state) => const AiMlPage(),
            routes: [
              GoRoute(
                path: 'article/:id',
                name: 'ai-article-detail',
                builder: (context, state) {
                  final articleId = state.pathParameters['id']!;
                  return ArticleDetailPage(articleId: articleId);
                },
              ),
              GoRoute(
                path: 'category/:category',
                name: 'ai-category',
                builder: (context, state) {
                  final category = state.pathParameters['category']!;
                  return ArticlesByCategoryPage(
                    category: category,
                    categoryName: category,
                  );
                },
              ),
            ],
          ),
          
          // Time Saver Section
          GoRoute(
            path: '/time-saver',
            name: 'time-saver',
            builder: (context, state) => const TimeSaverPage(),
            routes: [
              GoRoute(
                path: 'content/:id',
                name: 'time-saver-content',
                builder: (context, state) {
                  final contentId = state.pathParameters['id']!;
                  return TimeSaverContentPage(contentId: contentId);
                },
              ),
              GoRoute(
                path: 'update/:id',
                name: 'quick-update-detail',
                builder: (context, state) {
                  final updateId = state.pathParameters['id']!;
                  return QuickUpdateDetailPage(updateId: updateId);
                },
              ),
              GoRoute(
                path: 'breaking/:id',
                name: 'breaking-news-detail',
                builder: (context, state) {
                  final newsId = state.pathParameters['id']!;
                  return BreakingNewsDetailPage(newsId: newsId);
                },
              ),
            ],
          ),
          
          // Profile
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
      
      // Standalone routes (without bottom navigation)
      GoRoute(
        path: '/category/:category',
        name: 'category-articles',
        builder: (context, state) {
          final category = state.pathParameters['category']!;
          final categoryName = state.uri.queryParameters['name'] ?? category;
          return ArticlesByCategoryPage(
            category: category,
            categoryName: categoryName,
          );
        },
      ),
      
      // Search page (standalone)
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchPage(),
      ),
      
      // Favorites page (standalone)
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) => const FavoritesPage(),
      ),
      
      // Notifications
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      
      // Full screen ad
      GoRoute(
        path: '/ad/:adId',
        name: 'full-screen-ad',
        builder: (context, state) {
          final adId = state.pathParameters['adId']!;
          return FullScreenAdPage(adId: adId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

// Navigation helper extension
extension AppRouterExtension on BuildContext {
  void pushNamed(String name, {Map<String, String>? pathParameters, Map<String, String>? queryParameters}) {
    GoRouter.of(this).pushNamed(name, 
      pathParameters: pathParameters ?? {}, 
      queryParameters: queryParameters ?? {}
    );
  }
  
  void goNamed(String name, {Map<String, String>? pathParameters, Map<String, String>? queryParameters}) {
    GoRouter.of(this).goNamed(name, 
      pathParameters: pathParameters ?? {}, 
      queryParameters: queryParameters ?? {}
    );
  }
  
  void pop() {
    GoRouter.of(this).pop();
  }
}

// Additional detail pages that would need to be created
class TimeSaverContentPage extends StatelessWidget {
  final String contentId;
  
  const TimeSaverContentPage({super.key, required this.contentId});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Time Saver Content')),
      body: Center(
        child: Text('Time Saver Content ID: $contentId'),
      ),
    );
  }
}

class QuickUpdateDetailPage extends StatelessWidget {
  final String updateId;
  
  const QuickUpdateDetailPage({super.key, required this.updateId});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Update')),
      body: Center(
        child: Text('Update ID: $updateId'),
      ),
    );
  }
}

class BreakingNewsDetailPage extends StatelessWidget {
  final String newsId;
  
  const BreakingNewsDetailPage({super.key, required this.newsId});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Breaking News')),
      body: Center(
        child: Text('Breaking News ID: $newsId'),
      ),
    );
  }
}