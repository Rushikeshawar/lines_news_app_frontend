// lib/features/profile/presentation/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/providers/auth_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return _buildAuthRequired(context);
          }
          return _buildSettingsContent(context, ref, colorScheme);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, ref),
      ),
    );
  }

  Widget _buildAuthRequired(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80,
              color: AppTheme.primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'Login Required',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please log in to access settings',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/auth/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              icon: const Icon(Icons.login),
              label: const Text('Log In'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Session Expired',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Please log in again to continue'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                context.go('/auth/login');
              },
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context, WidgetRef ref, ColorScheme colorScheme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Notifications', colorScheme),
        _buildSettingsCard(
          children: [
            _buildSettingsTile(
              icon: Icons.notifications_active,
              title: 'Push Notifications',
              subtitle: 'Receive notifications about new articles',
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notification settings updated'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              colorScheme: colorScheme,
            ),
            const Divider(height: 1),
            _buildSettingsTile(
              icon: Icons.email_outlined,
              title: 'Email Notifications',
              subtitle: 'Receive weekly newsletter',
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Email settings updated'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              colorScheme: colorScheme,
            ),
          ],
        ),

        const SizedBox(height: 24),

        _buildSectionHeader('Appearance', colorScheme),
        _buildSettingsCard(
          children: [
            _buildSettingsTile(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              subtitle: 'Use dark theme',
              trailing: Switch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Theme toggle coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              colorScheme: colorScheme,
            ),
            const Divider(height: 1),
            _buildSettingsTile(
              icon: Icons.text_fields,
              title: 'Font Size',
              subtitle: 'Adjust reading font size',
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Font size settings coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              colorScheme: colorScheme,
            ),
            const Divider(height: 1),
            _buildSettingsTile(
              icon: Icons.language,
              title: 'Language',
              subtitle: 'English (US)',
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Language settings coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              colorScheme: colorScheme,
            ),
          ],
        ),

        const SizedBox(height: 24),

        _buildSectionHeader('Reading Preferences', colorScheme),
        _buildSettingsCard(
          children: [
            _buildSettingsTile(
              icon: Icons.auto_stories,
              title: 'Auto-mark as Read',
              subtitle: 'Mark articles as read when scrolled',
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Auto-mark settings updated'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              colorScheme: colorScheme,
            ),
            const Divider(height: 1),
            _buildSettingsTile(
              icon: Icons.bookmark_border,
              title: 'Save Reading Progress',
              subtitle: 'Remember where you left off',
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Progress settings updated'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              colorScheme: colorScheme,
            ),
          ],
        ),

        const SizedBox(height: 24),

        _buildSectionHeader('Privacy & Security', colorScheme),
        _buildSettingsCard(
          children: [
            _buildSettingsTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
              subtitle: 'Update your account password',
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => context.push('/profile/change-password'),
              colorScheme: colorScheme,
            ),
            const Divider(height: 1),
            _buildSettingsTile(
              icon: Icons.security,
              title: 'Two-Factor Authentication',
              subtitle: 'Add extra security to your account',
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('2FA settings coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              colorScheme: colorScheme,
            ),
            const Divider(height: 1),
            _buildSettingsTile(
              icon: Icons.fingerprint,
              title: 'Biometric Login',
              subtitle: 'Use fingerprint or face ID',
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Biometric login coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              colorScheme: colorScheme,
            ),
          ],
        ),

        const SizedBox(height: 24),

        _buildSectionHeader('Data & Storage', colorScheme),
        _buildSettingsCard(
          children: [
            _buildSettingsTile(
              icon: Icons.cloud_download,
              title: 'Offline Reading',
              subtitle: 'Download articles for offline access',
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Offline reading coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              colorScheme: colorScheme,
            ),
            const Divider(height: 1),
            _buildSettingsTile(
              icon: Icons.delete_outline,
              title: 'Clear Cache',
              subtitle: 'Free up storage space',
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () async {
                final shouldClear = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Cache'),
                    content: const Text('This will remove all cached data. Continue?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
                
                if (shouldClear == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cache cleared successfully'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              colorScheme: colorScheme,
            ),
          ],
        ),

        const SizedBox(height: 24),

        _buildSectionHeader('About', colorScheme),
        _buildSettingsCard(
          children: [
            _buildSettingsTile(
              icon: Icons.info_outline,
              title: 'App Version',
              subtitle: '1.0.0 (Build 1)',
              colorScheme: colorScheme,
            ),
            const Divider(height: 1),
            _buildSettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              trailing: const Icon(Icons.open_in_new, size: 20),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening privacy policy...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              colorScheme: colorScheme,
            ),
            const Divider(height: 1),
            _buildSettingsTile(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              subtitle: 'Read our terms',
              trailing: const Icon(Icons.open_in_new, size: 20),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening terms of service...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              colorScheme: colorScheme,
            ),
            const Divider(height: 1),
            _buildSettingsTile(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get help or contact us',
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening help center...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              colorScheme: colorScheme,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Danger Zone
        _buildSectionHeader('Danger Zone', Colors.red),
        _buildSettingsCard(
          children: [
            _buildSettingsTile(
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.red),
              onTap: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Logout'),
                      ],
                    ),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
                
                if (shouldLogout == true && context.mounted) {
                  await ref.read(authProvider.notifier).logout();
                  context.go('/auth/login');
                }
              },
              colorScheme: colorScheme,
              textColor: Colors.red,
            ),
            const Divider(height: 1),
            _buildSettingsTile(
              icon: Icons.delete_forever,
              title: 'Delete Account',
              subtitle: 'Permanently delete your account',
              trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.red),
              onTap: () async {
                final shouldDelete = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Delete Account'),
                      ],
                    ),
                    content: const Text(
                      'This action cannot be undone. All your data will be permanently deleted.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                
                if (shouldDelete == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account deletion coming soon'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              colorScheme: colorScheme,
              textColor: Colors.red,
            ),
          ],
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionHeader(String title, dynamic color) {
    Color headerColor;
    if (color is ColorScheme) {
      headerColor = color.primary;
    } else if (color is Color) {
      headerColor = color;
    } else {
      headerColor = AppTheme.primaryColor;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: headerColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required ColorScheme colorScheme,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    final color = textColor ?? colorScheme.onSurface;
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: (textColor ?? colorScheme.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: textColor ?? colorScheme.primary,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: color,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: color.withOpacity(0.7),
          fontSize: 13,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}