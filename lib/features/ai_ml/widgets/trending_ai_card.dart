// lib/features/ai_ml/widgets/trending_ai_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/ai_news_model.dart';

class TrendingAiCard extends StatelessWidget {
  final AiNewsModel article;
  final VoidCallback onTap;

  const TrendingAiCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300, // Fixed height to prevent overflow
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple[800]!,
            Colors.blue[800]!,
            Colors.cyan[700]!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16), // Reduced from 20
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6), // Reduced from 8
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.whatshot,
                        color: Colors.orange,
                        size: 18, // Reduced from 20
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'TRENDING',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    if (article.aiModel != null)
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            article.aiModel!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 12), // Reduced from 16
                
                // Image
                if (article.featuredImage != null)
                  Container(
                    height: 100, // Reduced from 120
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: article.featuredImage!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.white.withOpacity(0.1),
                          child: const Center(
                            child: SizedBox(
                              width: 20, // Reduced from 24
                              height: 20, // Reduced from 24
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.white.withOpacity(0.1),
                          child: const Center(
                            child: Icon(
                              Icons.smart_toy,
                              color: Colors.white,
                              size: 28, // Reduced from 32
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                
                const SizedBox(height: 12), // Reduced from 16
                
                // Title
                Flexible(
                  child: Text(
                    article.headline,
                    style: const TextStyle(
                      fontSize: 16, // Reduced from 18
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2, // Reduced line height
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                const SizedBox(height: 6), // Reduced from 8
                
                // Brief
                Flexible(
                  child: Text(
                    article.briefContent,
                    style: TextStyle(
                      fontSize: 13, // Reduced from 14
                      color: Colors.white.withOpacity(0.8),
                      height: 1.3, // Reduced line height
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                const Spacer(), // This will push footer to bottom
                
                // Footer
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14, // Reduced from 16
                      color: Colors.white.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        article.readingTime,
                        style: TextStyle(
                          fontSize: 11, // Reduced from 12
                          color: Colors.white.withOpacity(0.7),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white.withOpacity(0.7),
                      size: 14, // Reduced from 16
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
