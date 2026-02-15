import 'package:flutter/material.dart';
import 'package:online_graveyard/theme/app_colors.dart';
import 'package:online_graveyard/theme/app_text_styles.dart';

/// Notifications / Alerts page.
class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      _NotificationItem(
        icon: Icons.local_fire_department_rounded,
        iconColor: AppColors.candleAmber,
        title: 'New candle lit',
        subtitle: 'Someone lit a candle for Eleanor Rose Mitchell',
        time: '2 hours ago',
      ),
      _NotificationItem(
        icon: Icons.message_rounded,
        iconColor: AppColors.primary,
        title: 'New tribute posted',
        subtitle: 'Sarah left a heartfelt message on Eleanor\'s memorial',
        time: '5 hours ago',
      ),
      _NotificationItem(
        icon: Icons.filter_vintage_rounded,
        iconColor: AppColors.success,
        title: 'Flowers received',
        subtitle: 'Someone left flowers for Dr. Ahmed Hassan',
        time: '1 day ago',
      ),
      _NotificationItem(
        icon: Icons.cake_rounded,
        iconColor: const Color(0xFFE879A6),
        title: 'Anniversary reminder',
        subtitle: 'Robert Williams\' birthday is coming up on May 1st',
        time: '2 days ago',
      ),
      _NotificationItem(
        icon: Icons.people_rounded,
        iconColor: AppColors.primaryLight,
        title: 'Memorial shared',
        subtitle: 'Maria Santos Garcia\'s memorial was shared 12 times',
        time: '3 days ago',
      ),
    ];

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: AppTextStyles.appTitle.copyWith(color: AppColors.textPrimary),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Mark all read',
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = notifications[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: index < 2
                      ? AppColors.primary.withValues(alpha: 0.04)
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: item.iconColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item.icon, size: 20, color: item.iconColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle,
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.time,
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    if (index < 2)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              );
            },
            childCount: notifications.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _NotificationItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;

  const _NotificationItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}
