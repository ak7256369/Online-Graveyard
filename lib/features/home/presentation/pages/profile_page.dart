import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:online_graveyard/features/auth/presentation/providers/auth_provider.dart';
import 'package:online_graveyard/theme/app_colors.dart';
import 'package:online_graveyard/theme/app_text_styles.dart';

/// Profile page — shows current user info and their memorials.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch AuthProvider for user data changes
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('Profile', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 22),
            onPressed: () {
              // Edit Profile feature coming in Phase 2
              // For now we can show a snackbar or bottom sheet
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit Profile coming soon in Phase 2')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.2),
                    AppColors.primaryProfile.withValues(alpha: 0.2),
                  ],
                ),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                image: authProvider.photoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(authProvider.photoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: authProvider.photoUrl == null
                  ? Center(
                      child: Text(
                        authProvider.initials,
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              authProvider.displayName,
              style: AppTextStyles.sectionHeading.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Member since ${authProvider.memberSince}',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            ),
            if (authProvider.email.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                authProvider.email,
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
              ),
            ],

            const SizedBox(height: 28),

            // Stats Row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatColumn(count: '0', label: 'Memorials'), // Placeholder for now
                  Container(width: 1, height: 36, color: AppColors.borderLight),
                  _StatColumn(count: '0', label: 'Candles'),   // Placeholder
                  Container(width: 1, height: 36, color: AppColors.borderLight),
                  _StatColumn(count: '0', label: 'Flowers'),   // Placeholder
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Actions
            _ActionTile(
              icon: Icons.spa_rounded,
              title: 'My Memorials',
              subtitle: '0 memorials created',
              color: AppColors.primary,
            ),
            const SizedBox(height: 8),
            _ActionTile(
              icon: Icons.favorite_rounded,
              title: 'Saved Memorials',
              subtitle: '0 memorials saved',
              color: const Color(0xFFE879A6),
            ),
            const SizedBox(height: 8),
            _ActionTile(
              icon: Icons.local_fire_department_rounded,
              title: 'Candles Lit',
              subtitle: '0 candles lit',
              color: AppColors.candleAmber,
            ),
            const SizedBox(height: 8),
            _ActionTile(
              icon: Icons.history_rounded,
              title: 'Activity History',
              subtitle: 'View all your interactions',
              color: AppColors.textSecondary,
            ),
            
            if (authProvider.isAdmin) ...[
              const SizedBox(height: 24),
              _ActionTile(
                icon: Icons.admin_panel_settings_rounded,
                title: 'Admin Panel',
                subtitle: 'Optimized for Desktop',
                color: AppColors.primary,
                onTap: () => Navigator.pushNamed(context, '/admin'),
              ),
            ],

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String count;
  final String label;
  const _StatColumn({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: AppTextStyles.sectionHeading.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 22),
        ],
      ),
    ),
    );
  }
}
