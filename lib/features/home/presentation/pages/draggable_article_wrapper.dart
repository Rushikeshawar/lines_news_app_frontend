import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../articles/presentation/pages/article_detail_page.dart';

class DraggableArticleWrapper extends StatefulWidget {
  final String articleId;

  const DraggableArticleWrapper({
    super.key,
    required this.articleId,
  });

  @override
  State<DraggableArticleWrapper> createState() => _DraggableArticleWrapperState();
}

class _DraggableArticleWrapperState extends State<DraggableArticleWrapper>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  double _dragOffset = 0.0;
  bool _isDragging = false;
  double _initialDragPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(_slideAnimation);
    
    _opacityAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(_slideAnimation);

    // Start with animation forward
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _isDragging = true;
    _initialDragPosition = details.globalPosition.dy;
    _animationController.stop();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    setState(() {
      _dragOffset += details.delta.dy;
      // Only allow downward drag
      _dragOffset = _dragOffset.clamp(0.0, double.infinity);
    });

    // Provide haptic feedback when reaching dismiss threshold
    final screenHeight = MediaQuery.of(context).size.height;
    final dismissThreshold = screenHeight * 0.25;
    
    if (_dragOffset > dismissThreshold && _dragOffset - details.delta.dy <= dismissThreshold) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;

    final screenHeight = MediaQuery.of(context).size.height;
    final dismissThreshold = screenHeight * 0.25; // 25% of screen height
    final velocityThreshold = 1200.0; // pixels per second

    final shouldDismiss = _dragOffset > dismissThreshold || 
                         details.velocity.pixelsPerSecond.dy > velocityThreshold;

    if (shouldDismiss) {
      // Dismiss the page with haptic feedback
      HapticFeedback.mediumImpact();
      _animateDismiss();
    } else {
      // Snap back to original position
      _animateReturn();
    }
  }

  void _animateDismiss() {
    final screenHeight = MediaQuery.of(context).size.height;
    final remainingDistance = screenHeight - _dragOffset;
    
    // Calculate duration based on remaining distance
    final duration = Duration(
      milliseconds: (200 * (remainingDistance / screenHeight)).round().clamp(100, 300),
    );

    AnimationController dismissController = AnimationController(
      duration: duration,
      vsync: this,
    );

    Animation<double> dismissAnimation = Tween<double>(
      begin: _dragOffset,
      end: screenHeight,
    ).animate(CurvedAnimation(
      parent: dismissController,
      curve: Curves.easeInCubic,
    ));

    dismissAnimation.addListener(() {
      setState(() {
        _dragOffset = dismissAnimation.value;
      });
    });

    dismissController.forward().then((_) {
      dismissController.dispose();
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _animateReturn() {
    _animationController.reset();
    _animationController.forward().then((_) {
      if (mounted) {
        setState(() {
          _dragOffset = 0.0;
        });
      }
    });
  }

  double _calculateOpacity() {
    if (_dragOffset == 0.0) return 1.0;
    
    final screenHeight = MediaQuery.of(context).size.height;
    final progress = (_dragOffset / screenHeight).clamp(0.0, 1.0);
    return (1.0 - progress * 0.4).clamp(0.6, 1.0);
  }

  double _calculateScale() {
    if (_dragOffset == 0.0) return 1.0;
    
    final screenHeight = MediaQuery.of(context).size.height;
    final progress = (_dragOffset / screenHeight).clamp(0.0, 1.0);
    return (1.0 - progress * 0.1).clamp(0.9, 1.0);
  }

  double _calculateBackgroundOpacity() {
    if (_dragOffset == 0.0) return 0.5;
    
    final screenHeight = MediaQuery.of(context).size.height;
    final progress = (_dragOffset / screenHeight).clamp(0.0, 1.0);
    return (0.5 - progress * 0.5).clamp(0.0, 0.5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(_calculateBackgroundOpacity()),
      body: GestureDetector(
        onPanStart: _handleDragStart,
        onPanUpdate: _handleDragUpdate,
        onPanEnd: _handleDragEnd,
        child: Stack(
          children: [
            // Background that can be tapped to dismiss
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
            
            // Article content
            AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                final currentOffset = _isDragging 
                    ? _dragOffset 
                    : _dragOffset * (1 - _slideAnimation.value);
                
                final currentScale = _isDragging
                    ? _calculateScale()
                    : _scaleAnimation.value;
                    
                final currentOpacity = _isDragging
                    ? _calculateOpacity()
                    : _opacityAnimation.value;
                
                return Transform.translate(
                  offset: Offset(0, currentOffset),
                  child: Transform.scale(
                    scale: currentScale,
                    child: Opacity(
                      opacity: currentOpacity,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(currentOffset > 0 ? 20 : 0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: Offset(0, -2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(currentOffset > 0 ? 20 : 0),
                          ),
                          child: ArticleDetailPage(articleId: widget.articleId),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Drag indicator at the top
            if (_dragOffset > 10)
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
