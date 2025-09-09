// lib/main.dart - COMPLETELY FIXED VERSION
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/network/api_client.dart';
import 'features/auth/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  
  runApp(
    ProviderScope(
      child: const LinesNewsApp(),
    ),
  );
}

class LinesNewsApp extends ConsumerWidget {
  const LinesNewsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Lines News',
      debugShowCheckedModeBanner: false,
      
      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme, // Use light theme for now
      themeMode: ThemeMode.light,
      
      // Router configuration
      routerConfig: router,
      
      // Builder for additional widgets
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0, // Prevent font scaling issues
          ),
          child: AppDebugWrapper(child: child ?? const SizedBox()),
        );
      },
    );
  }
}

// Debug wrapper to show connection status and auth state
class AppDebugWrapper extends ConsumerWidget {
  final Widget child;

  const AppDebugWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        child,
        
        // Debug overlay in debug mode only
        if (const bool.fromEnvironment('dart.vm.product') == false)
          Positioned(
            top: MediaQuery.of(context).padding.top + 50,
            right: 10,
            child: DebugPanel(),
          ),
      ],
    );
  }
}

class DebugPanel extends ConsumerStatefulWidget {
  @override
  ConsumerState<DebugPanel> createState() => _DebugPanelState();
}

class _DebugPanelState extends ConsumerState<DebugPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: _isExpanded ? 300 : 60,
          maxHeight: _isExpanded ? 400 : 60,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _isExpanded ? _buildExpandedPanel() : _buildCollapsedPanel(),
      ),
    );
  }

  Widget _buildCollapsedPanel() {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = true),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.bug_report,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildExpandedPanel() {
    final authState = ref.watch(authProvider);
    
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Debug Panel',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _isExpanded = false),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Auth Status
          _buildStatusItem(
            'Auth Status',
            authState.when(
              data: (user) => user != null ? 'Logged In' : 'Logged Out',
              loading: () => 'Loading...',
              error: (_, __) => 'Error',
            ),
            authState.when(
              data: (user) => user != null ? Colors.green : Colors.red,
              loading: () => Colors.orange,
              error: (_, __) => Colors.red,
            ),
          ),
          
          if (authState.when(
            data: (user) => user != null,
            loading: () => false,
            error: (_, __) => false,
          ))
            _buildStatusItem(
              'User',
              authState.value?.email ?? 'Unknown',
              Colors.blue,
            ),
          
          const SizedBox(height: 8),
          
          // Connection Test Button
          ElevatedButton(
            onPressed: _testConnection,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: const Text(
              'Test Connection',
              style: TextStyle(fontSize: 10),
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Demo Login Button
          if (!authState.when(
            data: (user) => user != null,
            loading: () => false,
            error: (_, __) => false,
          ))
            ElevatedButton(
              onPressed: _demoLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              child: const Text(
                'Demo Login',
                style: TextStyle(fontSize: 10),
              ),
            ),
          
          // Logout Button
          if (authState.when(
            data: (user) => user != null,
            loading: () => false,
            error: (_, __) => false,
          ))
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testConnection() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final result = await apiClient.testBasicConnection();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result ? 'Connection successful' : 'Connection failed'),
            backgroundColor: result ? Colors.green : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _demoLogin() async {
    try {
      await ref.read(authProvider.notifier).login('demo@example.com', 'demo123');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demo login initiated...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Demo login failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    try {
      await ref.read(authProvider.notifier).logout();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}