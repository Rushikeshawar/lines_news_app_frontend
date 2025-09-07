// lib/features/home/presentation/widgets/category_chip.dart - FIXED COMPILATION ERRORS
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../articles/models/article_model.dart';
import '../../../categories/models/category_model.dart';
import '../../../articles/providers/missing_providers.dart';

class CategoryChip extends ConsumerWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FIXED: Get dynamic article count from API
    final categoryArticlesAsync = ref.watch(articlesByCategoryProvider(category.category.name));
    
    return GestureDetector(
      onTap: onTap ?? () {
        context.pushNamed(
          'category-articles',
          pathParameters: {'category': category.category.name},
          queryParameters: {'name': category.name},
        );
      },
      child: Container(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected 
                    ? category.color 
                    : category.color.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: category.color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                category.icon,
                color: isSelected ? Colors.white : category.color,
                size: 24,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Category name
            Text(
              category.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? AppTheme.primaryTextColor 
                    : AppTheme.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            // FIXED: Dynamic article count from API - removed .future error
            const SizedBox(height: 2),
            categoryArticlesAsync.when(
              data: (articles) {
                final count = articles.length;
                if (count == 0) {
                  return const SizedBox.shrink(); // Don't show if no articles
                }
                return Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.mutedTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
              loading: () => SizedBox(
                height: 10,
                width: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 1,
                  color: AppTheme.mutedTextColor,
                ),
              ),
              error: (error, stack) {
                print('Error loading category ${category.name} articles: $error');
                return const SizedBox.shrink(); // Hide count on error
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Category List with better error handling
class CategoryList extends ConsumerStatefulWidget {
  final List<CategoryModel> categories;
  final NewsCategory? selectedCategory;
  final Function(NewsCategory?)? onCategorySelected;
  final bool showAll;

  const CategoryList({
    super.key,
    required this.categories,
    this.selectedCategory,
    this.onCategorySelected,
    this.showAll = false,
  });

  @override
  ConsumerState<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends ConsumerState<CategoryList> {
  @override
  Widget build(BuildContext context) {
    final categoriesToShow = widget.showAll 
        ? widget.categories 
        : widget.categories.take(8).toList();
    
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categoriesToShow.length + (widget.showAll ? 0 : 1),
        itemBuilder: (context, index) {
          if (!widget.showAll && index == categoriesToShow.length) {
            // "See All" button
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildSeeAllChip(context),
            );
          }
          
          final category = categoriesToShow[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: CategoryChip(
              category: category,
              isSelected: widget.selectedCategory == category.category,
              onTap: () {
                widget.onCategorySelected?.call(category.category);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeeAllChip(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _buildCategoriesBottomSheet(context),
        );
      },
      child: Container(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Icon(
                Icons.apps,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'See All',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14), // Balance the space
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesBottomSheet(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      'All Categories',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTextColor,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              // Categories grid with dynamic counts
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: widget.categories.length,
                  itemBuilder: (context, index) {
                    final category = widget.categories[index];
                    return CategoryChip(
                      category: category,
                      isSelected: widget.selectedCategory == category.category,
                      onTap: () {
                        Navigator.pop(context);
                        widget.onCategorySelected?.call(category.category);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}