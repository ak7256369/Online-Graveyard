import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:online_graveyard/features/home/presentation/widgets/memorial_card.dart';
import 'package:online_graveyard/features/home/presentation/widgets/qr_code_dialog.dart';
import 'package:online_graveyard/features/home/presentation/pages/memorial_profile_page.dart';
import 'package:online_graveyard/features/home/presentation/pages/create_memorial_page.dart';
import 'package:online_graveyard/features/home/presentation/pages/browse_page.dart';
import 'package:online_graveyard/features/home/presentation/pages/alerts_page.dart';
import 'package:online_graveyard/features/home/presentation/pages/settings_page.dart';
import 'package:online_graveyard/features/home/presentation/pages/profile_page.dart';
import 'package:online_graveyard/features/home/presentation/widgets/filter_chips.dart';
import 'package:online_graveyard/theme/app_colors.dart';
import 'package:online_graveyard/theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import 'package:online_graveyard/features/home/presentation/providers/memorial_provider.dart';

/// Main shell — manages bottom nav page switching.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemorialProvider>().fetchMemorials();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: SafeArea(
          child: IndexedStack(
            index: _currentNavIndex,
            children: const [
              _HomeTab(),
              BrowsePage(),
              AlertsPage(),
              SettingsPage(),
            ],
          ),
        ),
        floatingActionButton: _currentNavIndex == 0 ? _buildFAB() : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.primary],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CreateMemorialPage()),
            );
            if (mounted) {
              context.read<MemorialProvider>().fetchMemorials();
            }
          },
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: const Border(
          top: BorderSide(color: AppColors.borderLight, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_rounded, 0, 'Home'),
              _navItem(Icons.grid_view_rounded, 1, 'Browse'),
              _navItem(Icons.notifications_rounded, 2, 'Alerts'),
              _navItem(Icons.settings_rounded, 3, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index, String label) {
    final isSelected = _currentNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentNavIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Home Tab Content ──────────────────────────────────────────
class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  String _selectedCategory = 'All Memories';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  static const List<String> _categories = [
    'All Memories',
    'Family',
    'Friends',
    'Colleagues',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String? _categoryToFirestore(String category) {
    switch (category) {
      case 'Family':
        return 'family';
      case 'Friends':
        return 'friends';
      case 'Colleagues':
        return 'colleagues';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<MemorialProvider>().fetchMemorials(
        category: _categoryToFirestore(_selectedCategory),
      ),
      color: AppColors.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // ─── Header ──────────────────────
          SliverToBoxAdapter(child: _buildHeader()),

          // ─── Filter Chips ────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FilterChips(
                categories: _categories,
                selectedCategory: _selectedCategory,
                onSelected: (category) {
                  setState(() => _selectedCategory = category);
                  context.read<MemorialProvider>().fetchMemorials(
                    category: _categoryToFirestore(category),
                  );
                },
              ),
            ),
          ),

          // ─── Content ─────────────────────
          Consumer<MemorialProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.memorials.isEmpty) {
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(child: _ShimmerGrid()),
                );
              }

              if (provider.errorMessage != null && provider.memorials.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.error),
                          ),
                          const SizedBox(height: 20),
                          Text('Something went wrong',
                            style: AppTextStyles.sectionHeading.copyWith(color: AppColors.textPrimary)),
                          const SizedBox(height: 8),
                          Text(provider.errorMessage!,
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                            textAlign: TextAlign.center),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => provider.fetchMemorials(
                              category: _categoryToFirestore(_selectedCategory)),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Try Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              if (provider.memorials.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.spa_rounded, size: 56,
                              color: AppColors.primary.withValues(alpha: 0.6)),
                          ),
                          const SizedBox(height: 24),
                          Text('A place for remembrance',
                            style: AppTextStyles.sectionHeading.copyWith(
                              color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          Text(
                            'Honor the memory of your loved ones.\nTap the + button to create the first memorial\nand keep their story alive.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary, height: 1.6),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),
                          Icon(Icons.arrow_downward_rounded, size: 24,
                            color: AppColors.primary.withValues(alpha: 0.4)),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // 2-column Wrap (dynamic height)
              final memorials = provider.memorials;
              final cardWidth = (MediaQuery.of(context).size.width - 48) / 2;

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: List.generate(memorials.length, (index) {
                      final memorial = memorials[index];
                      return SizedBox(
                        width: cardWidth,
                        child: MemorialCard(
                          memorial: memorial,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MemorialProfilePage(
                                  memorialId: memorial.id,
                                  initialData: memorial,
                                ),
                              ),
                            );
                          },
                          onFavorite: () {},
                          onQrCode: () {
                            showDialog(
                              context: context,
                              builder: (context) => QrCodeDialog(
                                memorialId: memorial.id,
                                memorialName: memorial.name,
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_isSearching)
            _buildSearchField()
          else
            Text('The Online\nGraveyard',
              style: AppTextStyles.appTitle.copyWith(color: AppColors.textPrimary)),

          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    if (_isSearching) {
                      _isSearching = false;
                      _searchController.clear();
                      context.read<MemorialProvider>().fetchMemorials(
                        category: _categoryToFirestore(_selectedCategory));
                    } else {
                      _isSearching = true;
                    }
                  });
                },
                icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded, size: 26),
                color: AppColors.textSecondary,
              ),
              if (!_isSearching) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    );
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.1),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 20),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search memorials...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textMuted),
              prefixIconConstraints: const BoxConstraints(minWidth: 32),
            ),
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            onChanged: (value) {
              context.read<MemorialProvider>().search(value);
            },
          ),
        ),
      ),
    );
  }
}

// ─── Shimmer Loading Grid ──────────────────────────────────────
class _ShimmerGrid extends StatefulWidget {
  @override
  State<_ShimmerGrid> createState() => _ShimmerGridState();
}

class _ShimmerGridState extends State<_ShimmerGrid> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: List.generate(6, (index) {
            final cardWidth = (MediaQuery.of(context).size.width - 48) / 2;
            return SizedBox(width: cardWidth, child: _buildShimmerCard());
          }),
        );
      },
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(_animation.value - 1, 0),
                end: Alignment(_animation.value, 0),
                colors: const [
                  Color(0xFFE8ECF1), Color(0xFFF3F6FA), Color(0xFFE8ECF1),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBar(width: 100, height: 14),
                const SizedBox(height: 8),
                _shimmerBar(width: 70, height: 10),
                const SizedBox(height: 10),
                _shimmerBar(width: double.infinity, height: 10),
                const SizedBox(height: 6),
                _shimmerBar(width: 80, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          begin: Alignment(_animation.value - 1, 0),
          end: Alignment(_animation.value, 0),
          colors: const [
            Color(0xFFE8ECF1), Color(0xFFF3F6FA), Color(0xFFE8ECF1),
          ],
        ),
      ),
    );
  }
}
