// lib/features/time_saver/presentation/pages/time_saver_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/time_saver_provider.dart';
import '../../widgets/time_saver_card.dart';
import '../../widgets/quick_update_tile.dart';
import '../../models/time_saver_model.dart';

class TimeSaverPage extends ConsumerStatefulWidget {
  const TimeSaverPage({super.key});

  @override
  ConsumerState<TimeSaverPage> createState() => _TimeSaverPageState();
}

class _TimeSaverPageState extends ConsumerState<TimeSaverPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    print('TimeSaverPage: initState called');
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _slideController.forward();
    
    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('TimeSaverPage: Triggering data load');
      ref.read(timeSaverProvider.notifier).loadTimeSaverContent();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Time Saver Hub',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(20),
            ),
            // child: TextButton.icon(
            //   onPressed: () => _showAllCategoriesBottomSheet(),
            //   icon: Icon(Icons.dashboard, color: Colors.orange[700], size: 18),
            //   label: Text(
            //     'Categories',
            //     style: TextStyle(
            //       color: Colors.orange[700],
            //       fontSize: 12,
            //       fontWeight: FontWeight.w600,
            //     ),
            //   ),
            // ),
          ),
        ],
      ),
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: RefreshIndicator(
            onRefresh: () async {
              await ref.read(timeSaverProvider.notifier).loadTimeSaverContent();
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Quick Stats Dashboard
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: _buildQuickStatsCards(),
                  ),
                ),
                
                // Top 5 New Today Section
                SliverToBoxAdapter(
                  child: _buildContentSection(
                    icon: Icons.new_releases,
                    title: 'Top 5 New Today',
                    subtitle: 'Latest trending stories',
                    color: Colors.red,
                    contentType: 'today_new',
                    limit: 5,
                    isHorizontalScroll: false,
                  ),
                ),
                
                // Breaking 7 Critical Updates
                SliverToBoxAdapter(
                  child: _buildContentSection(
                    icon: Icons.emergency,
                    title: 'Breaking 7 Critical Updates',
                    subtitle: 'Most important breaking news',
                    color: Colors.red[800]!,
                    contentType: 'breaking_critical',
                    limit: 7,
                    isHorizontalScroll: true,
                  ),
                ),
                
                // Weekly Roundup (15 highlights)
                SliverToBoxAdapter(
                  child: _buildContentSection(
                    icon: Icons.calendar_view_week,
                    title: 'Weekly Roundup',
                    subtitle: '15 key highlights this week',
                    color: Colors.blue,
                    contentType: 'weekly_highlights',
                    limit: 15,
                    isHorizontalScroll: false,
                  ),
                ),
                
                // Monthly Top 30 Quick Rundown
                SliverToBoxAdapter(
                  child: _buildContentSection(
                    icon: Icons.trending_up,
                    title: 'Monthly Top 30',
                    subtitle: 'Quick monthly rundown',
                    color: Colors.green,
                    contentType: 'monthly_top',
                    limit: 30,
                    isHorizontalScroll: true,
                  ),
                ),
                
                // Brief Updates
                SliverToBoxAdapter(
                  child: _buildContentSection(
                    icon: Icons.flash_on,
                    title: 'Brief Updates',
                    subtitle: 'Quick news bites',
                    color: Colors.orange,
                    contentType: 'brief_updates',
                    limit: 15,
                    isHorizontalScroll: true,
                  ),
                ),
                
                // Viral Buzz Online Sensation (10)
                SliverToBoxAdapter(
                  child: _buildContentSection(
                    icon: Icons.whatshot,
                    title: 'Viral Buzz Online Sensation',
                    subtitle: '10 trending online stories',
                    color: Colors.pink,
                    contentType: 'viral_buzz',
                    limit: 10,
                    isHorizontalScroll: false,
                  ),
                ),
                
                // Changing Norms Unedited Lines (10 points)
                SliverToBoxAdapter(
                  child: _buildContentSection(
                    icon: Icons.transform,
                    title: 'Changing Norms Unedited Lines',
                    subtitle: '10 points shaping society',
                    color: Colors.purple,
                    contentType: 'changing_norms',
                    limit: 10,
                    isHorizontalScroll: false,
                  ),
                ),
                
                // Add bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 40),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickStatsCards() {
    return Consumer(
      builder: (context, ref, child) {
        final statsAsync = ref.watch(quickStatsProvider);
        
        return statsAsync.when(
          data: (stats) {
            return Column(
              children: [
                // Main stats row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Today\'s New',
                        '5',
                        Icons.fiber_new,
                        Colors.red,
                        'Fresh content',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Critical',
                        '7',
                        Icons.priority_high,
                        Colors.red[800]!,
                        'Breaking updates',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Secondary stats row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Weekly',
                        '15',
                        Icons.date_range,
                        Colors.blue,
                        'Highlights',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Viral Buzz',
                        '10',
                        Icons.whatshot,
                        Colors.pink,
                        'Trending now',
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => _buildStatsShimmer(),
          error: (error, stack) {
            print('QuickStats error: $error');
            return _buildStatsError();
          },
        );
      },
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildContentSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String contentType,
    required int limit,
    required bool isHorizontalScroll,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _showViewAll(contentType, title),
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Content based on type
          _buildContentByType(contentType, limit, isHorizontalScroll, color),
        ],
      ),
    );
  }
  
  Widget _buildContentByType(String contentType, int limit, bool isHorizontalScroll, Color color) {
    return Consumer(
      builder: (context, ref, child) {
        final timeSaverAsync = ref.watch(timeSaverProvider);
        
        return timeSaverAsync.when(
          data: (contentList) {
            if (contentList.isEmpty) {
              return _buildEmptySection(contentType);
            }
            
            // Filter content based on type
            List<TimeSaverContent> filteredContent = _filterContentByType(contentList, contentType, limit);
            
            if (isHorizontalScroll) {
              return _buildHorizontalContent(filteredContent, color);
            } else {
              return _buildVerticalContent(filteredContent, color);
            }
          },
          loading: () => isHorizontalScroll ? _buildHorizontalShimmer() : _buildVerticalShimmer(),
          error: (error, stack) => _buildErrorWidget('Failed to load $contentType'),
        );
      },
    );
  }
  
  List<TimeSaverContent> _filterContentByType(List<TimeSaverContent> content, String contentType, int limit) {
    // Filter content based on type and limit
    List<TimeSaverContent> filtered = [];
    
    switch (contentType) {
      case 'today_new':
        filtered = content.where((item) => 
          DateTime.now().difference(item.publishedAt).inDays == 0
        ).take(limit).toList();
        break;
      case 'breaking_critical':
        filtered = content.where((item) => 
          item.isPriority || item.contentType == ContentType.digest
        ).take(limit).toList();
        break;
      case 'weekly_highlights':
        filtered = content.where((item) => 
          DateTime.now().difference(item.publishedAt).inDays <= 7 &&
          item.contentType == ContentType.highlights
        ).take(limit).toList();
        break;
      case 'monthly_top':
        filtered = content.where((item) => 
          DateTime.now().difference(item.publishedAt).inDays <= 30
        ).take(limit).toList();
        break;
      case 'brief_updates':
        filtered = content.where((item) => 
          item.contentType == ContentType.quickUpdate ||
          item.readTimeSeconds <= 60
        ).take(limit).toList();
        break;
      case 'viral_buzz':
        filtered = content.where((item) => 
          item.viewCount > 1000 || 
          item.category.toLowerCase().contains('viral') ||
          item.category.toLowerCase().contains('trending')
        ).take(limit).toList();
        break;
      case 'changing_norms':
        filtered = content.where((item) => 
          item.category.toLowerCase().contains('society') ||
          item.category.toLowerCase().contains('culture') ||
          item.category.toLowerCase().contains('social')
        ).take(limit).toList();
        break;
      default:
        filtered = content.take(limit).toList();
    }
    
    // If not enough filtered content, pad with general content
    if (filtered.length < limit && filtered.length < content.length) {
      final remaining = content.where((item) => !filtered.contains(item))
          .take(limit - filtered.length);
      filtered.addAll(remaining);
    }
    
    return filtered;
  }
  
  Widget _buildHorizontalContent(List<TimeSaverContent> content, Color color) {
    if (content.isEmpty) return const SizedBox.shrink();
    
    return SizedBox(
      height: 160,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: content.length,
        itemBuilder: (context, index) {
          final item = content[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 12),
            child: TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 200 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Opacity(
                    opacity: value,
                    child: _buildContentCard(item, color, isHorizontal: true),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildVerticalContent(List<TimeSaverContent> content, Color color) {
    if (content.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: content.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 200 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: _buildContentCard(item, color, isHorizontal: false),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildContentCard(TimeSaverContent content, Color color, {required bool isHorizontal}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToContent(content.id),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: isHorizontal 
                ? _buildHorizontalCardContent(content, color)
                : _buildVerticalCardContent(content, color),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHorizontalCardContent(TimeSaverContent content, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                content.category.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            const Spacer(),
            Text(
              content.readTimeFormatted,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Text(
            content.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Text(
            content.summary,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.visibility, size: 12, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              '${content.viewCount}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 12, color: color),
          ],
        ),
      ],
    );
  }
  
  Widget _buildVerticalCardContent(TimeSaverContent content, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      content.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    content.readTimeFormatted,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                content.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                content.summary,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
      ],
    );
  }
  
  // NAVIGATION METHODS
  void _navigateToContent(String contentId) {
    print('Navigating to content: $contentId');
    try {
      context.goNamed(
        'time-saver-content',
        pathParameters: {'id': contentId},
      );
    } catch (e) {
      print('Navigation error: $e');
      _showErrorSnackBar('Navigation failed: $e');
    }
  }
  
  void _showViewAll(String contentType, String title) {
    // Navigate to a filtered view of all content for this type
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text('View all $contentType content feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showAllCategoriesBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'All Categories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildCategoryTile(Icons.new_releases, 'Top 5 New Today', 'today_new', Colors.red),
                    _buildCategoryTile(Icons.emergency, 'Breaking 7 Critical', 'breaking_critical', Colors.red[800]!),
                    _buildCategoryTile(Icons.calendar_view_week, 'Weekly Roundup', 'weekly_highlights', Colors.blue),
                    _buildCategoryTile(Icons.trending_up, 'Monthly Top 30', 'monthly_top', Colors.green),
                    _buildCategoryTile(Icons.flash_on, 'Brief Updates', 'brief_updates', Colors.orange),
                    _buildCategoryTile(Icons.whatshot, 'Viral Buzz Online', 'viral_buzz', Colors.pink),
                    _buildCategoryTile(Icons.transform, 'Changing Norms', 'changing_norms', Colors.purple),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCategoryTile(IconData icon, String title, String contentType, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: color),
        onTap: () {
          Navigator.pop(context);
          _showViewAll(contentType, title);
        },
      ),
    );
  }
  
  // HELPER WIDGETS
  Widget _buildEmptySection(String contentType) {
    return Container(
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'No content available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Check back later for updates',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatsError() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600]),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Failed to load stats',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: () => ref.refresh(quickStatsProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
  
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red[600],
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
  
  // SHIMMER AND LOADING WIDGETS
  Widget _buildStatsShimmer() {
    return Column(
      children: [
        Row(
          children: List.generate(2, (index) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index < 1 ? 12 : 0),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(2, (index) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index < 1 ? 12 : 0),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
  
  Widget _buildHorizontalShimmer() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 12),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildVerticalShimmer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(4, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
  
  Widget _buildErrorWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red[600],
          ),
          const SizedBox(height: 12),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(
              fontSize: 12,
              color: Colors.red[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(timeSaverProvider.notifier).loadTimeSaverContent();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}