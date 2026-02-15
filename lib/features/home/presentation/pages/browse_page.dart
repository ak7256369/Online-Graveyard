import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:online_graveyard/features/home/presentation/providers/memorial_provider.dart';
import 'package:online_graveyard/features/home/presentation/pages/memorial_profile_page.dart';
import 'package:online_graveyard/theme/app_colors.dart';
import 'package:online_graveyard/theme/app_text_styles.dart';
import 'package:online_graveyard/features/home/presentation/widgets/filter_chips.dart';

/// Browse page — grid gallery view of all memorials.
class BrowsePage extends StatelessWidget {
  const BrowsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MemorialProvider>(
      builder: (context, provider, _) {
        final memorials = provider.memorials;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            // Header with Search and Filters
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gallery',
                      style: AppTextStyles.appTitle.copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 16),
                    
                    // Search Bar
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search memorials...',
                        hintStyle: AppTextStyles.bodyText.copyWith(color: AppColors.textMuted),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.surfaceLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      ),
                      onChanged: (value) {
                        provider.search(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // Filter Chips
                    FilterChips(
                      categories: const ['All', 'Family', 'Friends', 'Pets', 'Veterans', 'Public Figure', 'Colleague'],
                      selectedCategory: provider.selectedCategory.isEmpty ? 'All' : _capitalize(provider.selectedCategory),
                      onSelected: (category) {
                        final value = category == 'All' ? '' : category.toLowerCase();
                        provider.fetchMemorials(category: value.isEmpty ? null : value);
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    Text(
                      '${memorials.length} memorials found',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),

            // Grid
            if (memorials.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No memorials to browse yet.',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final memorial = memorials[index];
                      return GestureDetector(
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
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.borderLight,
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              memorial.profileImageUrl != null
                                  ? Image.network(
                                      memorial.profileImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _placeholder(memorial.name),
                                    )
                                  : _placeholder(memorial.name),
                              // Bottom gradient with name
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(6, 20, 6, 6),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.transparent, Colors.black87],
                                    ),
                                  ),
                                  child: Text(
                                    memorial.name.split(' ').first,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: memorials.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

  Widget _placeholder(String name) {
    final initials = name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();
    return Container(
      color: AppColors.primary.withValues(alpha: 0.15),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.sectionHeading.copyWith(
            color: AppColors.primary.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }


  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
