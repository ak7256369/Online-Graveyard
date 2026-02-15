import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:online_graveyard/features/admin/presentation/providers/admin_provider.dart';
import 'package:online_graveyard/theme/app_colors.dart';
import 'package:online_graveyard/theme/app_text_styles.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Container(
      width: 250,
      color: AppColors.backgroundDark,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Admin',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _AdminNavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  isSelected: provider.currentTab == AdminTab.dashboard,
                  onTap: () => provider.setTab(AdminTab.dashboard),
                ),
                _AdminNavItem(
                  icon: Icons.storefront_rounded,
                  label: 'Memorials',
                  isSelected: provider.currentTab == AdminTab.memorials,
                  onTap: () => provider.setTab(AdminTab.memorials),
                ),
                _AdminNavItem(
                  icon: Icons.people_rounded,
                  label: 'Users',
                  isSelected: provider.currentTab == AdminTab.users,
                  onTap: () => provider.setTab(AdminTab.users),
                ),
                const Divider(color: Colors.white10),
                _AdminNavItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  isSelected: provider.currentTab == AdminTab.settings,
                  onTap: () => provider.setTab(AdminTab.settings),
                ),
              ],
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'v1.0.0',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AdminNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: isSelected ? Colors.white : AppColors.textMuted,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
