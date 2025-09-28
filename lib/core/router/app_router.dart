// lib/core/router/app_router.dart - CORRECTED VERSION WITH PROPER IMPORTS
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
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/profile/presentation/pages/change_password_page.dart';
import '../../features/ads/presentation/pages/full_screen_ad_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/ai_ml/presentation/pages/ai_ml_page.dart';
import '../../features/time_saver/presentation/pages/time_saver_page.dart';
import '../../features/time_saver/presentation/pages/time_saver_content_page.dart';
import '../../features/time_saver/presentation/pages/breaking_news_detail_page.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/models/auth_models.dart'; // ADDED: Import User model


// Global keys for router
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// Router provider with proper auth state handling
final appRouterProvider = Provider<GoRouter>((ref) {
  // Watch auth state for automatic redirects
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    
    // Redirect logic with proper auth state handling
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
          // During loading, don't redirect to prevent flicker
          print('Auth loading, no redirect');
          return null;
        },
        error: (error, stack) {
          print('Auth error: $error');
          // On auth error, redirect to login unless already there
          if (!location.startsWith('/auth')) {
            return '/auth/login';
          }
          return null;
        },
      );
    },
    
    // Refresh listenable to handle auth state changes
    refreshListenable: AuthChangeNotifier(ref),
    
    routes: [
      // Auth routes - No bottom navigation
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
      
      // Main app routes with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          print('Building MainWrapper for ${state.matchedLocation}');
          return MainWrapper(child: child);
        },
        routes: [
          // Home Tab Routes
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) {
              print('Building HomePage');
              return const HomePage();
            },
          ),
          
          // AI/ML Tab Routes
          GoRoute(
            path: '/ai-ml',
            name: 'ai-ml',
            builder: (context, state) {
              print('Building AiMlPage');
              return const AiMlPage();
            },
          ),
          
          // Time Saver Tab Routes
          GoRoute(
            path: '/time-saver',
            name: 'time-saver',
            builder: (context, state) {
              print('Building TimeSaverPage');
              return const TimeSaverPage();
            },
          ),
          
          // Profile Tab Routes
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
      
      // Nested routes for detailed pages
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
      
      // Category routes
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
      
      // Search page
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) {
          print('Building SearchPage');
          return const SearchPage();
        },
      ),
      
      // Favorites page
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) {
          print('Building FavoritesPage');
          return const FavoritesPage();
        },
      ),
      
      // Notifications
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) {
          print('Building NotificationsPage');
          return const NotificationsPage();
        },
      ),
      
      // Full screen ad
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
    
    // Better error handling
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
              // Try to go back, fallback to home
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
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[400],
                ),
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
    // Listen to auth state changes
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

// Enhanced navigation extension with better error handling
extension AppRouterExtension on BuildContext {
  // Safe navigation methods
  void pushNamed(String name, {Map<String, String>? pathParameters, Map<String, String>? queryParameters}) {
    try {
      print('Navigation: pushNamed $name with params: $pathParameters');
      GoRouter.of(this).pushNamed(name, 
        pathParameters: pathParameters ?? {}, 
        queryParameters: queryParameters ?? {}
      );
    } catch (e) {
      print('Navigation error (pushNamed): $e');
      _handleNavigationError(e);
    }
  }
  
  void goNamed(String name, {Map<String, String>? pathParameters, Map<String, String>? queryParameters}) {
    try {
      print('Navigation: goNamed $name with params: $pathParameters');
      GoRouter.of(this).goNamed(name, 
        pathParameters: pathParameters ?? {}, 
        queryParameters: queryParameters ?? {}
      );
    } catch (e) {
      print('Navigation error (goNamed): $e');
      _handleNavigationError(e);
    }
  }
  
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
      // Fallback to home
      GoRouter.of(this).go('/');
    }
  }
  
  // Helper methods for specific routes
  void goToArticle(String articleId) {
    try {
      print('Navigation: goToArticle with ID: $articleId');
      GoRouter.of(this).go('/article/$articleId');
    } catch (e) {
      print('Article navigation error: $e');
      _handleNavigationError(e);
    }
  }
  
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
  
  // Logout helper with proper cleanup
  void logout() {
    try {
      print('Navigation: logout - redirecting to login');
      GoRouter.of(this).go('/auth/login');
    } catch (e) {
      print('Logout navigation error: $e');
      // Force navigation to login
      GoRouter.of(this).go('/auth/login');
    }
  }
  
  // Error handling helper
  void _handleNavigationError(dynamic error) {
    print('Navigation error handler: $error');
    
    // Show a snackbar to inform user
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
    
    // Fallback to home page
    try {
      GoRouter.of(this).go('/');
    } catch (fallbackError) {
      print('Even fallback navigation failed: $fallbackError');
    }
  }
}