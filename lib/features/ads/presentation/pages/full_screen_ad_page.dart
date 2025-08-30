
// lib/features/ads/presentation/pages/full_screen_ad_page.dart - FIXED
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../articles/models/article_model.dart';
import '../../providers/ads_provider.dart';

class FullScreenAdPage extends ConsumerStatefulWidget {
  final String adId;

  const FullScreenAdPage({super.key, required this.adId});

  @override
  ConsumerState<FullScreenAdPage> createState() => _FullScreenAdPageState();
}

class _FullScreenAdPageState extends ConsumerState<FullScreenAdPage> {
  @override
  void initState() {
    super.initState();
    // Track ad impression
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adsProvider).trackAdClick(widget.adId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // For demo purposes, create a sample ad
    final sampleAd = Advertisement(
      id: widget.adId,
      title: 'Premium News Experience',
      content: 'Get unlimited access to all news articles, exclusive content, and ad-free reading experience. Subscribe now and stay informed with the world\'s most trusted news source.',
      imageUrl: 'https://via.placeholder.com/800x600/2C5FED/FFFFFF?text=Premium+News',
      targetUrl: 'https://example.com/subscribe',
      position: AdPosition.interstitial,
      isActive: true,
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 30)),
      clickCount: 0,
      impressions: 0,
      createdBy: 'admin',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'AD',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              AppTheme.primaryColor.withOpacity(0.8),
              AppTheme.secondaryColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ad image
                      if (sampleAd.imageUrl != null)
                        Container(
                          height: 200,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 32),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              color: AppTheme.primaryColor,
                              child: const Center(
                                child: Text(
                                  'PREMIUM NEWS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Ad title
                      Text(
                        sampleAd.title,
                        style: AppTextStyles.headline2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      // Ad content
                      if (sampleAd.content != null)
                        Text(
                          sampleAd.content!,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),

                      const SizedBox(height: 48),

                      // CTA Buttons
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () => _handleAdAction(sampleAd),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppTheme.primaryColor,
                                elevation: 8,
                                shadowColor: Colors.white.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              child: Text(
                                'Learn More',
                                style: AppTextStyles.headline6.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () => context.pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: const Text('Maybe Later'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom info
              Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'This advertisement helps support free content',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAdAction(Advertisement ad) async {
    // Track the click
    ref.read(adsProvider).trackAdClick(ad.id);

    // Launch URL or perform action
    if (ad.targetUrl != null) {
      final uri = Uri.parse(ad.targetUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }

    // Close the ad
    if (mounted) {
      context.pop();
    }
  }
}