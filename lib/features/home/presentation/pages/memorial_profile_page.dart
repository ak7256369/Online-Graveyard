import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:online_graveyard/features/home/domain/entities/memorial.dart';
import 'package:online_graveyard/features/home/presentation/providers/memorial_provider.dart';
import 'package:online_graveyard/features/home/presentation/widgets/video_player_widget.dart';
import 'package:online_graveyard/features/home/presentation/widgets/add_tribute_dialog.dart';
import 'package:online_graveyard/theme/app_colors.dart';
import 'package:online_graveyard/theme/app_colors.dart';
import 'package:online_graveyard/theme/app_text_styles.dart';
import 'package:online_graveyard/features/auth/presentation/providers/auth_provider.dart';
import 'package:online_graveyard/features/home/presentation/pages/edit_memorial_page.dart';
import 'package:online_graveyard/theme/app_theme.dart';
import 'package:share_plus/share_plus.dart';

class MemorialProfilePage extends StatefulWidget {
  final String memorialId;
  final Memorial? initialData;

  const MemorialProfilePage({
    super.key,
    required this.memorialId,
    this.initialData,
  });

  @override
  State<MemorialProfilePage> createState() => _MemorialProfilePageState();
}

class _MemorialProfilePageState extends State<MemorialProfilePage> {
  @override
  void initState() {
    super.initState();
    // Fetch fresh data and subscribe to tributes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialData != null) {
        context.read<MemorialProvider>().selectMemorial(widget.initialData!);
      } else {
        // Fallback or fetch by ID if needed (for deep links)
        // context.read<MemorialProvider>().getMemorialById(widget.memorialId);
        // For now we assume initialData is passed from Browse/Home
      }
    });
  }

  @override
  void dispose() {
    // Clean up provider selection when leaving the page
    // Use addPostFrameCallback to avoid calling notifyListeners during dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MemorialProvider>(
        builder: (context, provider, child) {
          final memorial = provider.selectedMemorial ?? widget.initialData;
          final tributes = provider.tributes;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: memorial == null
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
                    slivers: [
                      // ... (Slivers content referencing 'memorial' and 'tributes') ...
                      SliverAppBar(
                        // ...
                        expandedHeight: 300,
                        pinned: true,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                               if (memorial.profileImageUrl != null)
                                Image.network(
                                  memorial.profileImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(color: Colors.grey[850]),
                                ),
                               Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.2),
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.8),
                                    ],
                                  ),
                                ),
                               ),
                            ],
                          ),
                        ),
                        actions: [
                          IconButton(
                             icon: const Icon(Icons.share_rounded),
                             onPressed: () {
                               if (memorial.profileImageUrl != null) {
                                  Share.share('Remembering ${memorial.name} on The Online Graveyard. View their memorial here.');
                               }
                             },
                          ),
                          if (context.read<AuthProvider>().currentUser?.uid == memorial.createdBy)
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                   Navigator.push(
                                     context,
                                     MaterialPageRoute(builder: (_) => EditMemorialPage(memorial: memorial)),
                                   );
                                } else if (value == 'delete') {
                                   // ... delete logic ...
                                   showDialog(
                                     context: context,
                                     builder: (ctx) => AlertDialog(
                                       title: const Text('Delete Memorial?'),
                                       content: const Text('This action cannot be undone.'),
                                       actions: [
                                         TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                         TextButton(
                                           onPressed: () async {
                                             Navigator.pop(ctx);
                                             final success = await context.read<MemorialProvider>().deleteMemorial(memorial.id);
                                             if (success && mounted) Navigator.pop(context);
                                           },
                                           child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                         ),
                                       ],
                                     ),
                                   );
                                }
                              },
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(value: 'edit', child: Text('Edit Memorial')),
                                const PopupMenuItem<String>(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                              ],
                            ),
                        ],
                      ),
                      
                      SliverToBoxAdapter(
                         child: Padding(
                           padding: const EdgeInsets.all(16),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(memorial.name, style: AppTextStyles.headlineMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
                               const SizedBox(height: 8),
                               Text(memorial.dateRange, style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),)),
                               const SizedBox(height: 16),
                               if (memorial.bio != null && memorial.bio!.isNotEmpty) ...[
                                 Text('Biography', style: AppTextStyles.titleMedium.copyWith(color: AppColors.accentGold)),
                                 const SizedBox(height: 8),
                                 Text(memorial.bio!, style: AppTextStyles.bodyText.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.9))),
                                 const SizedBox(height: 24),
                               ],
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStat(Icons.local_fire_department_rounded, '${memorial.candleCount} Candles', AppColors.accentCandle),
                                    _buildStat(Icons.filter_vintage_rounded, '${memorial.flowerCount} Flowers', Colors.pinkAccent),
                                  ],
                                ),
                                const SizedBox(height: 24),
                             ],
                           ),
                         ),
                      ),
                      
                      // ... Tributes List ...
                      if (tributes.isNotEmpty)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final tribute = tributes[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: AppColors.textMuted,
                                          backgroundImage: tribute.authorAvatarUrl != null ? NetworkImage(tribute.authorAvatarUrl!) : null,
                                          child: tribute.authorAvatarUrl == null
                                              ? Text(tribute.authorInitials, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(child: Text(tribute.authorName, style: AppTextStyles.labelLarge.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color))),
                                        Text(tribute.timeAgo, style: AppTextStyles.labelSmall.copyWith(color: Theme.of(context).textTheme.bodySmall?.color)),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(tribute.message, style: AppTextStyles.bodyText.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color)),
                                    const SizedBox(height: 8),
                                     Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            context.read<MemorialProvider>().lightTributeCandle(tribute.id);
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.local_fire_department_rounded, size: 16, color: tribute.candleCount > 0 ? AppColors.accentCandle : AppColors.textMuted),
                                              const SizedBox(width: 4),
                                              Text(tribute.candleCount > 0 ? '${tribute.candleCount}' : 'Light', style: AppTextStyles.labelSmall.copyWith(color: tribute.candleCount > 0 ? AppColors.accentCandle : AppColors.textMuted)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                            childCount: tributes.length,
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: AppColors.backgroundDark,
                  builder: (_) => const AddTributeDialog(),
                );
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text('Write Tribute'),
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: provider.hasLeftFlower 
                          ? null 
                          : () {
                              context.read<MemorialProvider>().leaveFlower();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You left a flower 🌸')));
                            },
                        icon: Icon(Icons.filter_vintage_rounded, color: provider.hasLeftFlower ? AppColors.textMuted : Theme.of(context).colorScheme.primary),
                        label: Text(provider.hasLeftFlower ? 'Flower Left' : 'Leave Flower', style: TextStyle(color: provider.hasLeftFlower ? AppColors.textMuted : Theme.of(context).colorScheme.primary)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          side: BorderSide(color: provider.hasLeftFlower ? Colors.transparent : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          disabledForegroundColor: AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: provider.hasLitCandle
                          ? null
                          : () {
                              context.read<MemorialProvider>().lightMemorialCandle();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You lit a candle 🕯️')));
                            },
                        icon: const Icon(Icons.local_fire_department_rounded),
                        label: Text(provider.hasLitCandle ? 'Candle Lit' : 'Light Candle'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentCandle,
                          disabledBackgroundColor: AppColors.surfaceLight.withOpacity(0.1),
                          foregroundColor: AppColors.backgroundDark,
                          disabledForegroundColor: AppColors.textMuted,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
  }



  Widget _buildStat(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.statCount.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
