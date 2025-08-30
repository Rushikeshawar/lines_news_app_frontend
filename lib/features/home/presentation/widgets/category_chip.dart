// lib/features/home/presentation/widgets/category_chip.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../articles/models/article_model.dart';
import '../../../categories/models/category_model.dart';

class CategoryChip extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? AppTheme.primaryTextColor 
                    : AppTheme.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            // Article count (if provided)
            if (category.articleCount > 0) ...[
              const SizedBox(height: 2),
              Text(
                '${category.articleCount}',
                style: AppTextStyles.caption.copyWith(
                  color: AppTheme.mutedTextColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Horizontal category list
class CategoryList extends StatefulWidget {
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
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
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
        // Navigate to categories page or show all categories
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
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
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
                      style: AppTextStyles.headline4,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              // Categories grid
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