import 'package:flutter/material.dart';
import 'package:online_graveyard/features/home/domain/entities/memorial.dart';
import 'package:online_graveyard/theme/app_colors.dart';
import 'package:online_graveyard/theme/app_text_styles.dart';

/// Memorial card widget — fully dynamic height, no overflow.
///
/// Features:
/// - Compact portrait image (fixed 140px) with gradient overlay
/// - Optional favorite (heart) button
/// - Person name (max 1 line, ellipsis) + bold dates
/// - Optional epitaph (max 2 lines, ellipsis)
/// - Candle/flower stats row
/// - Rounded corners (20px), subtle shadow
class MemorialCard extends StatelessWidget {
  final Memorial memorial;
  final double imageHeight;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onQrCode;

  const MemorialCard({
    super.key,
    required this.memorial,
    this.imageHeight = 140,
    this.onTap,
    this.onFavorite,
    this.onQrCode,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight, width: 1),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowCard,
              offset: Offset(0, 4),
              blurRadius: 16,
              spreadRadius: -2,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImageSection(),
            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return SizedBox(
      height: 140,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          memorial.profileImageUrl != null
              ? Image.network(
                  memorial.profileImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                )
              : _buildPlaceholderImage(),

          // Gradient overlay
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0x80000000),
                ],
                stops: [0.4, 1.0],
              ),
            ),
          ),

          // Favorite button (top-right)
          if (onFavorite != null)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onFavorite,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),

          // QR Code button (top-left)
          if (onQrCode != null)
            Positioned(
              top: 8,
              left: 8,
              child: GestureDetector(
                onTap: onQrCode,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.qr_code_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: const Color(0xFFE8ECF1),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: 44,
          color: AppColors.textMuted.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Name — bold, 1 line max
          Text(
            memorial.name,
            style: AppTextStyles.cardName.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          // Dates — visible, slightly larger
          Text(
            memorial.dateRange,
            style: AppTextStyles.dates.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Epitaph — max 2 lines
          if (memorial.epitaph != null && memorial.epitaph!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '"${memorial.epitaph}"',
              style: AppTextStyles.quote.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 8),

          // Stats row
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.only(top: 6),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            size: 14,
            color: AppColors.candleAmber,
          ),
          const SizedBox(width: 3),
          Text(
            memorial.displayCandleCount,
            style: AppTextStyles.statCount.copyWith(
              color: AppColors.candleAmber,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),

          if (memorial.flowerCount > 0) ...[
            const SizedBox(width: 10),
            Icon(
              Icons.filter_vintage_rounded,
              size: 14,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 3),
            Text(
              memorial.flowerCount.toString(),
              style: AppTextStyles.statCount.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
