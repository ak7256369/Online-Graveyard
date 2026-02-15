import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:online_graveyard/features/admin/presentation/providers/admin_provider.dart';
import 'package:online_graveyard/features/home/domain/entities/memorial.dart';
import 'package:online_graveyard/theme/app_colors.dart';
import 'package:online_graveyard/theme/app_text_styles.dart';
import 'package:intl/intl.dart';

class AdminMemorialsTable extends StatelessWidget {
  const AdminMemorialsTable({super.key});

  @override
  Widget build(BuildContext context) {
    // For now we use recentMemorials until full pagination is ready in Provider
    final provider = context.watch<AdminProvider>();
    final memorials = provider.recentMemorials;

    if (memorials.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_rounded, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text('No memorials found', style: AppTextStyles.bodyText.copyWith(color: AppColors.textMuted)),
          ],
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(24),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(AppColors.backgroundLight),
          dataRowMaxHeight: 72,
          columns: const [
            DataColumn(label: Text('Memorial')),
            DataColumn(label: Text('Created By')),
            DataColumn(label: Text('Created At')),
            DataColumn(label: Text('Interactions')),
            DataColumn(label: Text('Actions')),
          ],
          rows: memorials.map((memorial) => _buildRow(context, memorial)).toList(),
        ),
      ),
    );
  }

  DataRow _buildRow(BuildContext context, Memorial memorial) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: memorial.profileImageUrl != null
                    ? NetworkImage(memorial.profileImageUrl!)
                    : null,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: memorial.profileImageUrl == null
                    ? Text(memorial.name[0], style: const TextStyle(fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(memorial.name, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                  Text(memorial.dateRange, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
        ),
        DataCell(Text(memorial.createdBy, style: AppTextStyles.bodyMedium)), // Show ID for now, pending Creator Name
        DataCell(Text(dateFormat.format(memorial.createdAt), style: AppTextStyles.bodyMedium)),
        DataCell(
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded, size: 16, color: AppColors.candleAmber),
              const SizedBox(width: 4),
              Text('${memorial.candleCount}', style: AppTextStyles.labelSmall),
              const SizedBox(width: 12),
              const Icon(Icons.filter_vintage_rounded, size: 16, color: Colors.pink),
              const SizedBox(width: 4),
              Text('${memorial.flowerCount}', style: AppTextStyles.labelSmall),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_rounded, color: AppColors.primary),
                tooltip: 'View',
                onPressed: () {
                   // Navigate to profile
                   Navigator.of(context).pushNamed(
                     '/profile', // Assuming we have a named route or we push normally
                     arguments: memorial,
                   );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                tooltip: 'Delete',
                onPressed: () => _confirmDelete(context, memorial),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, Memorial memorial) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Memorial?'),
        content: Text('Are you sure you want to permanently delete the memorial for "${memorial.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminProvider>().deleteMemorial(memorial.id);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
