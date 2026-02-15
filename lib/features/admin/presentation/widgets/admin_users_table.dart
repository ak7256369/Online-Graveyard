import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:online_graveyard/features/admin/presentation/providers/admin_provider.dart';
import 'package:online_graveyard/theme/app_colors.dart';
import 'package:online_graveyard/theme/app_text_styles.dart';
import 'package:intl/intl.dart';

class AdminUsersTable extends StatelessWidget {
  const AdminUsersTable({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final users = provider.users;
    final dateFormat = DateFormat('MMM d, yyyy');

    if (users.isEmpty) {
       return const Center(child: Padding(
         padding: EdgeInsets.all(32.0),
         child: Text('No users found'),
       ));
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
          columns: const [
            DataColumn(label: Text('User')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Joined')),
            DataColumn(label: Text('Role')),
            DataColumn(label: Text('Actions')),
          ],
          rows: users.map((user) => DataRow(
            cells: [
              DataCell(
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                      child: user.photoUrl == null 
                          ? Text((user.displayName ?? user.email)[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold))
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(user.displayName ?? 'No Name', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              DataCell(Text(user.email, style: AppTextStyles.bodyMedium)),
              DataCell(Text(
                user.creationTime != null ? dateFormat.format(user.creationTime!) : 'Unknown',
                style: AppTextStyles.bodyMedium,
              )),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.role == 'admin' ? AppColors.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: user.role == 'admin' ? AppColors.primary.withOpacity(0.2) : Colors.transparent),
                  ),
                  child: Text(
                    user.role.toUpperCase(),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: user.role == 'admin' ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.block_rounded, color: AppColors.textMuted),
                  tooltip: 'Ban User',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ban functionality coming soon')));
                  },
                ),
              ),
            ],
          )).toList(),
        ),
      ),
    );
  }
}
