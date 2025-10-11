// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Auth
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/models/auth_models.dart';

// Home & Main
import '../../features/home/presentation/pages/main_wrapper.dart';
import '../../features/home/presentation/pages/home_page.dart';

// Articles
import '../../features/articles/presentation/pages/article_detail_page.dart';
import '../../features/articles/presentation/pages/articles_by_category_page.dart';

// Search & Favorites
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';

// Profile
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/profile/presentation/pages/change_password_page.dart';

// Ads & Notifications
import '../../features/ads/presentation/pages/full_screen_ad_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';

// AI/ML & Time Saver
import '../../features/ai_ml/presentation/pages/ai_ml_page.dart';
import '../../features/time_saver/presentation/pages/time_saver_page.dart';
import '../../features/time_saver/presentation/pages/time_saver_content_page.dart';
import '../../features/time_saver/presentation/pages/breaking_news_detail_page.dart';

// Global keys for router
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// Router provider with proper auth state handling
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    
    redirect: (context, state) {
      final location = state.matchedLocation;
      print('Router redirect check for: $location');
      
      return authState.when(
        data: (user) {
          final isAuthenticated = user != null;
          final isAuthRoute = location.startsWith('/auth');
          
          print('Auth state - User: ${user?.email ?? "none"}, Location: $location');
          
          if (!isAuthenticated && !isAuthRoute) {
            print('Redirecting to login - user not authenticated');
            return '/auth/login';
          }
          
          if (isAuthenticated && isAuthRoute) {
            print('Redirecting to home - user already authenticated');
            return '/';
          }
          
          print('No redirect needed');
          return null;
        },
        loading: () {
          print('Auth loading, no redirect');
          return null;
        },
        error: (error, stack) {
          print('Auth error: $error');
          if (!location.startsWith('/auth')) {
            return '/auth/login';
          }
          return null;
        },
      );
    },
    
    refreshListenable: AuthChangeNotifier(ref),
    
    routes: [
      // ========== AUTH ROUTES ==========
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) {
          print('Building LoginPage');
          return const LoginPage();
        },
      ),
      
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) {
          print('Building RegisterPage');
          return const RegisterPage();
        },
      ),
      
      // ========== MAIN APP SHELL WITH BOTTOM NAV ==========
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          print('Building MainWrapper for ${state.matchedLocation}');
          return MainWrapper(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) {
              print('Building HomePage');
              return const HomePage();
            },
          ),
          
          GoRoute(
            path: '/ai-ml',
            name: 'ai-ml',
            builder: (context, state) {
              print('Building AiMlPage');
              return const AiMlPage();
            },
          ),
          
          GoRoute(
            path: '/time-saver',
            name: 'time-saver',
            builder: (context, state) {
              print('Building TimeSaverPage');
              return const TimeSaverPage();
            },
          ),
          
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) {
              print('Building ProfilePage');
              return const ProfilePage();
            },
          ),
        ],
      ),
      
      // ========== ARTICLE ROUTES ==========
      GoRoute(
        path: '/article/:id',
        name: 'article-detail',
        builder: (context, state) {
          final articleId = state.pathParameters['id']!;
          print('Building ArticleDetailPage with ID: $articleId');
          return ArticleDetailPage(articleId: articleId);
        },
      ),
      
      GoRoute(
        path: '/category/:category',
        name: 'category-articles',
        builder: (context, state) {
          final category = state.pathParameters['category']!;
          final categoryName = state.uri.queryParameters['name'] ?? category;
          print('Building ArticlesByCategoryPage for: $category');
          return ArticlesByCategoryPage(
            category: category,
            categoryName: categoryName,
          );
        },
      ),
      
      // ========== TIME SAVER ROUTES ==========
      GoRoute(
        path: '/time-saver/content/:id',
        name: 'time-saver-content',
        builder: (context, state) {
          final contentId = state.pathParameters['id']!;
          print('Building TimeSaverContentPage with ID: $contentId');
          return TimeSaverContentPage(contentId: contentId);
        },
      ),
      
      GoRoute(
        path: '/time-saver/breaking/:id',
        name: 'breaking-news-detail',
        builder: (context, state) {
          final newsId = state.pathParameters['id']!;
          print('Building BreakingNewsDetailPage with ID: $newsId');
          return BreakingNewsDetailPage(newsId: newsId);
        },
      ),
      
      // ========== PROFILE ROUTES ==========
      GoRoute(
        path: '/profile/edit',
        name: 'edit-profile',
        builder: (context, state) {
          print('Building EditProfilePage');
          return const EditProfilePage();
        },
      ),
      
      GoRoute(
        path: '/profile/settings',
        name: 'profile-settings',
        builder: (context, state) {
          print('Building SettingsPage');
          return const SettingsPage();
        },
      ),
      
      GoRoute(
        path: '/profile/change-password',
        name: 'change-password',
        builder: (context, state) {
          print('Building ChangePasswordPage');
          return const ChangePasswordPage();
        },
      ),
      
      // ========== SEARCH & FAVORITES ==========
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) {
          print('Building SearchPage');
          return const SearchPage();
        },
      ),
      
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) {
          print('Building FavoritesPage');
          return const FavoritesPage();
        },
      ),
      
      // ========== NOTIFICATIONS ==========
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) {
          print('Building NotificationsPage');
          return const NotificationsPage();
        },
      ),
      
      // ========== ADS ==========
      GoRoute(
        path: '/ad/:adId',
        name: 'full-screen-ad',
        builder: (context, state) {
          final adId = state.pathParameters['adId']!;
          print('Building FullScreenAdPage with ID: $adId');
          return FullScreenAdPage(adId: adId);
        },
      ),
    ],
    
    errorBuilder: (context, state) {
      print('Router Error: ${state.error}');
      print('Router Error Path: ${state.matchedLocation}');
      
      return Scaffold(
        appBar: AppBar(
          title: const Text('Page Not Found'),
          backgroundColor: Colors.red[50],
          foregroundColor: Colors.red[800],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                const SizedBox(height: 16),
                Text(
                  'Page Not Found',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The page you\'re looking for doesn\'t exist.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Path: ${state.matchedLocation}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.home),
                  label: const Text('Go Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
});

// Custom change notifier for auth state
class AuthChangeNotifier extends ChangeNotifier {
  final Ref _ref;
  late final ProviderSubscription _subscription;

  AuthChangeNotifier(this._ref) {
    _subscription = _ref.listen<AsyncValue<User?>>(authProvider, (previous, next) {
      print('Auth state changed: ${next.value?.email ?? "logged out"}');
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

// Enhanced navigation extension
extension AppRouterExtension on BuildContext {
  // Article navigation
  void goToArticle(String articleId) {
    try {
      print('Navigation: goToArticle with ID: $articleId');
      GoRouter.of(this).go('/article/$articleId');
    } catch (e) {
      print('Article navigation error: $e');
      _handleNavigationError(e);
    }
  }
  
  void pushToArticle(String articleId) {
    try {
      GoRouter.of(this).push('/article/$articleId');
    } catch (e) {
      _handleNavigationError(e);
    }
  }
  
  // Category navigation
  void goToCategory(String category, {String? categoryName}) {
    try {
      final queryParams = categoryName != null ? '?name=$categoryName' : '';
      print('Navigation: goToCategory $category');
      GoRouter.of(this).go('/category/$category$queryParams');
    } catch (e) {
      print('Category navigation error: $e');
      _handleNavigationError(e);
    }
  }
  
  // Time Saver navigation
  void goToTimeSaverContent(String contentId) {
    try {
      print('Navigation: goToTimeSaverContent with ID: $contentId');
      GoRouter.of(this).go('/time-saver/content/$contentId');
    } catch (e) {
      print('Time saver content navigation error: $e');
      _handleNavigationError(e);
    }
  }
  
  void goToBreakingNews(String newsId) {
    try {
      print('Navigation: goToBreakingNews with ID: $newsId');
      GoRouter.of(this).go('/time-saver/breaking/$newsId');
    } catch (e) {
      print('Breaking news navigation error: $e');
      _handleNavigationError(e);
    }
  }
  
  // Profile navigation
  void goToProfile() {
    try {
      print('Navigation: goToProfile');
      GoRouter.of(this).go('/profile');
    } catch (e) {
      print('Profile navigation error: $e');
      _handleNavigationError(e);
    }
  }
  
  void goToEditProfile() {
    try {
      print('Navigation: goToEditProfile');
      GoRouter.of(this).go('/profile/edit');
    } catch (e) {
      print('Edit profile navigation error: $e');
      _handleNavigationError(e);
    }
  }
  
  void goToSettings() {
    try {
      print('Navigation: goToSettings');
      GoRouter.of(this).go('/profile/settings');
    } catch (e) {
      print('Settings navigation error: $e');
      _handleNavigationError(e);
    }
  }
  
  void goToChangePassword() {
    try {
      print('Navigation: goToChangePassword');
      GoRouter.of(this).go('/profile/change-password');
    } catch (e) {
      print('Change password navigation error: $e');
      _handleNavigationError(e);
    }
  }
  
  // Other navigation
  void goToFavorites() {
    try {
      print('Navigation: goToFavorites');
      GoRouter.of(this).go('/favorites');
    } catch (e) {
      print('Favorites navigation error: $e');
      _handleNavigationError(e);
    }
  }
  
  void goToSearch() {
    try {
      print('Navigation: goToSearch');
      GoRouter.of(this).go('/search');
    } catch (e) {
      print('Search navigation error: $e');
      _handleNavigationError(e);
    }
  }
  
  void goToNotifications() {
    try {
      print('Navigation: goToNotifications');
      GoRouter.of(this).go('/notifications');
    } catch (e) {
      print('Notifications navigation error: $e');
      _handleNavigationError(e);
    }
  }
  
  // Tab navigation
  void goToHome() {
    try {
      GoRouter.of(this).go('/');
    } catch (e) {
      _handleNavigationError(e);
    }
  }
  
  void goToAiMl() {
    try {
      GoRouter.of(this).go('/ai-ml');
    } catch (e) {
      _handleNavigationError(e);
    }
  }
  
  void goToTimeSaver() {
    try {
      GoRouter.of(this).go('/time-saver');
    } catch (e) {
      _handleNavigationError(e);
    }
  }
  
  // Auth navigation
  void goToLogin() {
    try {
      GoRouter.of(this).go('/auth/login');
    } catch (e) {
      _handleNavigationError(e);
    }
  }
  
  void goToRegister() {
    try {
      GoRouter.of(this).go('/auth/register');
    } catch (e) {
      _handleNavigationError(e);
    }
  }
  
  // Safe pop
  void safePop() {
    try {
      if (canPop()) {
        print('Navigation: pop()');
        GoRouter.of(this).pop();
      } else {
        print('Navigation: can\'t pop, going home');
        GoRouter.of(this).go('/');
      }
    } catch (e) {
      print('Navigation error (pop): $e');
      GoRouter.of(this).go('/');
    }
  }
  
  // Error handling helper
  void _handleNavigationError(dynamic error) {
    print('Navigation error handler: $error');
    
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: const Text('Navigation error occurred'),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'Go Home',
          onPressed: () => GoRouter.of(this).go('/'),
        ),
      ),
    );
    
    try {
      GoRouter.of(this).go('/');
    } catch (fallbackError) {
      print('Even fallback navigation failed: $fallbackError');
    }
  }
}