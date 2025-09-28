// lib/features/profile/presentation/pages/profile_page.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/models/auth_models.dart'; // ADDED: Import User and UserRole

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Not logged in'),
                  SizedBox(height: 16),
                  Text('Please log in to view your profile'),
                ],
              ),
            );
          }
          return _buildProfileContent(user, Theme.of(context), Theme.of(context).colorScheme);
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading profile...'),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              const Text('Failed to load profile'),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(authProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(User user, ThemeData theme, ColorScheme colorScheme) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(user, colorScheme),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildUserInfo(user, theme, colorScheme),
                const SizedBox(height: 24),
                _buildStatsSection(user, colorScheme),
                const SizedBox(height: 24),
                _buildActionButtons(theme, colorScheme),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(User user, ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: colorScheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Profile',
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.primary,
                colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Consumer(
          builder: (context, ref, child) {
            return PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: colorScheme.onPrimary),
              onSelected: (value) async {
                switch (value) {
                  case 'edit':
                    context.push('/profile/edit');
                    break;
                  case 'settings':
                    context.push('/profile/settings');
                    break;
                  case 'change_password':
                    context.push('/profile/change-password');
                    break;
                  case 'logout':
                    await ref.read(authProvider.notifier).logout();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit Profile'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 8),
                      Text('Settings'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'change_password',
                  child: Row(
                    children: [
                      Icon(Icons.lock),
                      SizedBox(width: 8),
                      Text('Change Password'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Logout', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildUserInfo(User user, ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
              child: user.avatar == null
                  ? Text(
                      user.initials,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getRoleColor(user.role).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getRoleColor(user.role).withOpacity(0.5),
                ),
              ),
              child: Text(
                user.role.displayName,
                style: TextStyle(
                  color: _getRoleColor(user.role),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            if (!user.isEmailVerified) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.5),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, size: 16, color: Colors.orange),
                    SizedBox(width: 4),
                    Text(
                      'Email not verified',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(User user, ColorScheme colorScheme) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Member since',
              _formatDate(user.createdAt),
              Icons.calendar_today,
              colorScheme,
            ),
            _buildInfoRow(
              'Last updated',
              _formatDate(user.updatedAt),
              Icons.update,
              colorScheme,
            ),
            _buildInfoRow(
              'Account status',
              user.isActive ? 'Active' : 'Inactive',
              user.isActive ? Icons.check_circle : Icons.cancel,
              colorScheme,
              statusColor: user.isActive ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    ColorScheme colorScheme, {
    Color? statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: statusColor ?? colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: statusColor ?? colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        _buildActionCard(
          'Edit Profile',
          'Update your personal information',
          Icons.edit,
          colorScheme,
          () => {},
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          'Settings',
          'Manage your preferences',
          Icons.settings,
          colorScheme,
          () => {},
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          'Change Password',
          'Update your account security',
          Icons.lock,
          colorScheme,
          () => {},
        ),
        const SizedBox(height: 12),
        Consumer(
          builder: (context, ref, child) {
            return _buildActionCard(
              'Logout',
              'Sign out of your account',
              Icons.logout,
              colorScheme,
              () async {
                await ref.read(authProvider.notifier).logout();
              },
              isDestructive: true,
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    ColorScheme colorScheme,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red : colorScheme.primary;
    
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: color,
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months months ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years years ago';
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.editor:
        return Colors.orange;
      case UserRole.user:
        return Colors.blue;
    }
  }
}

