import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class LinesLogo extends StatelessWidget {
  final double? height;
  final bool showTagline;

  const LinesLogo({
    super.key,
    this.height = 40,
    this.showTagline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo Icon (Three lines - all equal width)
          Container(
            width: height! * 0.8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLine(height! * 0.15, height! * 0.7), // Changed from 0.6 to 0.7
                SizedBox(height: height! * 0.08),
                _buildLine(height! * 0.15, height! * 0.7), // Kept at 0.7
                SizedBox(height: height! * 0.08),
                _buildLine(height! * 0.15, height! * 0.7), // Changed from 0.5 to 0.7
              ],
            ),
          ),
          SizedBox(width: height! * 0.3),
          // Text Logo - Wrapped in Flexible to prevent overflow
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LINES',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: height! * 0.45,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor,
                    letterSpacing: 2,
                  ),
                ),
                if (showTagline) ...[
                  SizedBox(height: height! * 0.02),
                  Text(
                    'The World in One Line',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: height! * 0.20,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.secondaryTextColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLine(double lineHeight, double width) {
    return Container(
      height: lineHeight,
      width: width,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(lineHeight / 2),
      ),
    );
  }
}

class AnimatedLinesLogo extends StatefulWidget {
  final double? height;
  final bool showTagline;
  final Duration animationDuration;

  const AnimatedLinesLogo({
    super.key,
    this.height = 40,
    this.showTagline = false,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<AnimatedLinesLogo> createState() => _AnimatedLinesLogoState();
}

class _AnimatedLinesLogoState extends State<AnimatedLinesLogo>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _line1Animation;
  late Animation<double> _line2Animation;
  late Animation<double> _line3Animation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _line1Animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    _line2Animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
    ));

    _line3Animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
    ));

    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: widget.height,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Logo Icon (Three lines - all equal width)
              Container(
                width: widget.height! * 0.8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAnimatedLine(
                      widget.height! * 0.15,
                      widget.height! * 0.7, // Changed from 0.6 to 0.7
                      _line1Animation,
                    ),
                    SizedBox(height: widget.height! * 0.08),
                    _buildAnimatedLine(
                      widget.height! * 0.15,
                      widget.height! * 0.7, // Kept at 0.7
                      _line2Animation,
                    ),
                    SizedBox(height: widget.height! * 0.08),
                    _buildAnimatedLine(
                      widget.height! * 0.15,
                      widget.height! * 0.7, // Changed from 0.5 to 0.7
                      _line3Animation,
                    ),
                  ],
                ),
              ),
              SizedBox(width: widget.height! * 0.3),
              // Animated Text Logo - Wrapped in Flexible to prevent overflow
              Flexible(
                child: Opacity(
                  opacity: _textAnimation.value,
                  child: Transform.translate(
                    offset: Offset(
                      (1 - _textAnimation.value) * 20,
                      0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LINES',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: widget.height! * 0.45,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                            letterSpacing: 2,
                          ),
                        ),
                        if (widget.showTagline) ...[
                          SizedBox(height: widget.height! * 0.02),
                          Text(
                            'The World in One Line',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: widget.height! * 0.20,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.secondaryTextColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedLine(double lineHeight, double maxWidth, Animation<double> animation) {
    return Container(
      height: lineHeight,
      width: maxWidth * animation.value,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(lineHeight / 2),
      ),
    );
  }
}