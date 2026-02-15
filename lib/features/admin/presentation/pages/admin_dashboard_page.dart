import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:online_graveyard/features/auth/presentation/providers/auth_provider.dart';
import 'package:online_graveyard/features/admin/presentation/providers/admin_provider.dart';
import 'package:online_graveyard/features/admin/presentation/widgets/admin_sidebar.dart';
import 'package:online_graveyard/theme/app_colors.dart';
import 'package:online_graveyard/theme/app_text_styles.dart';
import 'package:online_graveyard/features/admin/presentation/widgets/admin_memorials_table.dart';
import 'package:online_graveyard/features/admin/presentation/widgets/admin_users_table.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check Admin Role
    final authProvider = context.watch<AuthProvider>();
    
    if (!authProvider.isLoggedIn) {
       return const Scaffold(body: Center(child: Text('Please login')));
    }
    
    if (!authProvider.isAdmin) {
       return const Scaffold(body: Center(child: Text('Access Denied: Admins Only')));
    }

    // Basic responsive check - Admin panel is improved for desktop
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    if (!isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceDark,
          title: const Text('Admin'),
        ),
        drawer: const Drawer(child: AdminSidebar()),
        body: const Center(
          child: Text(
            'Admin dashboard is optimized for desktop view.\nPlease open on a larger screen.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight, // Use light bg for content area contrast
      body: Row(
        children: [
          const AdminSidebar(),
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, provider, child) {
                return Column(
                  children: [
                    // Top Bar
                    Container(
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _getTitle(provider.currentTab),
                        style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                    
                    // Content
                    Expanded(
                      child: provider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _buildContent(provider),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle(AdminTab tab) {
    switch (tab) {
      case AdminTab.dashboard: return 'Dashboard';
      case AdminTab.memorials: return 'Memorial Management';
      case AdminTab.users: return 'User Management';
      case AdminTab.settings: return 'Settings';
    }
  }

  Widget _buildContent(AdminProvider provider) {
    switch (provider.currentTab) {
      case AdminTab.dashboard:
        return _buildDashboardContent(provider);
      case AdminTab.memorials:
        return const AdminMemorialsTable();
      case AdminTab.users:
        return const AdminUsersTable();
      default:
        return const Center(child: Text('Coming Soon'));
    }
  }

  Widget _buildDashboardContent(AdminProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // KPI Cards
        Row(
          children: [
            _KpiCard(
              title: 'Total Memorials',
              value: provider.totalMemorials.toString(),
              icon: Icons.temple_buddhist_rounded,
              color: Colors.blue,
            ),
            const SizedBox(width: 16),
            _KpiCard(
              title: 'Total Users',
              value: provider.totalUsers.toString(),
              icon: Icons.people_alt_rounded,
              color: Colors.purple,
            ),
             const SizedBox(width: 16),
            _KpiCard(
              title: 'Tributes Posted',
              value: provider.totalTributes.toString(),
              icon: Icons.favorite_rounded,
              color: Colors.pink,
            ),
          ],
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(title, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
