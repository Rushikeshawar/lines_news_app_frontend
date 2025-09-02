// lib/core/router/app_router.dart - FIXED VERSION WITHOUT CONFLICTS
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
import '../../features/time_saver/presentation/pages/time_saver_content_page.dart';
import '../../features/time_saver/presentation/pages/breaking_news_detail_page.dart';
import '../../features/auth/providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true, // Enable debug logging for navigation
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
        builder: (context, state) {
          print('Router: Building LoginPage');
          return const LoginPage();
        },
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) {
          print('Router: Building RegisterPage');
          return const RegisterPage();
        },
      ),
      
      // Main app routes with bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          print('Router: Building MainWrapper for ${state.matchedLocation}');
          return MainWrapper(child: child);
        },
        routes: [
          // Home
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) {
              print('Router: Building HomePage');
              return const HomePage();
            },
            routes: [
              GoRoute(
                path: 'article/:id',
                name: 'article-detail',
                builder: (context, state) {
                  final articleId = state.pathParameters['id']!;
                  print('Router: Building ArticleDetailPage with ID: $articleId');
                  return ArticleDetailPage(articleId: articleId);
                },
              ),
            ],
          ),
          
          // AI/ML Section
          GoRoute(
            path: '/ai-ml',
            name: 'ai-ml',
            builder: (context, state) {
              print('Router: Building AiMlPage');
              return const AiMlPage();
            },
            routes: [
              GoRoute(
                path: 'article/:id',
                name: 'ai-article-detail',
                builder: (context, state) {
                  final articleId = state.pathParameters['id']!;
                  print('Router: Building AI ArticleDetailPage with ID: $articleId');
                  return ArticleDetailPage(articleId: articleId);
                },
              ),
              GoRoute(
                path: 'category/:category',
                name: 'ai-category',
                builder: (context, state) {
                  final category = state.pathParameters['category']!;
                  print('Router: Building AI ArticlesByCategoryPage for: $category');
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
            builder: (context, state) {
              print('Router: Building TimeSaverPage');
              return const TimeSaverPage();
            },
            routes: [
              GoRoute(
                path: 'content/:id',
                name: 'time-saver-content',
                builder: (context, state) {
                  final contentId = state.pathParameters['id']!;
                  print('Router: Building TimeSaverContentPage with ID: $contentId');
                  return TimeSaverContentPage(contentId: contentId);
                },
              ),
              GoRoute(
                path: 'breaking/:id',
                name: 'breaking-news-detail',
                builder: (context, state) {
                  final newsId = state.pathParameters['id']!;
                  print('Router: Building BreakingNewsDetailPage with ID: $newsId');
                  return BreakingNewsDetailPage(newsId: newsId);
                },
              ),
            ],
          ),
          
          // Profile
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) {
              print('Router: Building ProfilePage');
              return const ProfilePage();
            },
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
          print('Router: Building standalone ArticlesByCategoryPage for: $category');
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
        builder: (context, state) {
          print('Router: Building SearchPage');
          return const SearchPage();
        },
      ),
      
      // Favorites page (standalone)
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) {
          print('Router: Building FavoritesPage');
          return const FavoritesPage();
        },
      ),
      
      // Notifications
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) {
          print('Router: Building NotificationsPage');
          return const NotificationsPage();
        },
      ),
      
      // Full screen ad
      GoRoute(
        path: '/ad/:adId',
        name: 'full-screen-ad',
        builder: (context, state) {
          final adId = state.pathParameters['adId']!;
          print('Router: Building FullScreenAdPage with ID: $adId');
          return FullScreenAdPage(adId: adId);
        },
      ),
    ],
    errorBuilder: (context, state) {
      print('Router Error: ${state.error}');
      print('Router Error Path: ${state.matchedLocation}');
      
      return Scaffold(
        appBar: AppBar(
          title: const Text('Navigation Error'),
          backgroundColor: Colors.red[50],
          foregroundColor: Colors.red[800],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Path: ${state.matchedLocation}',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (state.error != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Error: ${state.error}',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    },
  );
});

// Navigation helper extension
extension AppRouterExtension on BuildContext {
  void pushNamed(String name, {Map<String, String>? pathParameters, Map<String, String>? queryParameters}) {
    print('Navigation: pushNamed $name with params: $pathParameters');
    GoRouter.of(this).pushNamed(name, 
      pathParameters: pathParameters ?? {}, 
      queryParameters: queryParameters ?? {}
    );
  }
  
  void goNamed(String name, {Map<String, String>? pathParameters, Map<String, String>? queryParameters}) {
    print('Navigation: goNamed $name with params: $pathParameters');
    GoRouter.of(this).goNamed(name, 
      pathParameters: pathParameters ?? {}, 
      queryParameters: queryParameters ?? {}
    );
  }
  
  void pop() {
    print('Navigation: pop()');
    GoRouter.of(this).pop();
  }
  
  // Helper methods for Time Saver navigation
  void goToTimeSaverContent(String contentId) {
    print('Navigation: goToTimeSaverContent with ID: $contentId');
    GoRouter.of(this).go('/time-saver/content/$contentId');
  }
  
  void goToBreakingNews(String newsId) {
    print('Navigation: goToBreakingNews with ID: $newsId');
    GoRouter.of(this).go('/time-saver/breaking/$newsId');
  }
}