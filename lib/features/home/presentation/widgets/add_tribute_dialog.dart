import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:online_graveyard/features/auth/presentation/providers/auth_provider.dart';
import 'package:online_graveyard/features/home/presentation/providers/memorial_provider.dart';
import 'package:online_graveyard/theme/app_colors.dart';
import 'package:online_graveyard/theme/app_text_styles.dart';

class AddTributeDialog extends StatefulWidget {
  const AddTributeDialog({super.key});

  @override
  State<AddTributeDialog> createState() => _AddTributeDialogState();
}

class _AddTributeDialogState extends State<AddTributeDialog> {
  final _messageController = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() => _isPosting = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final memorialProvider = context.read<MemorialProvider>();
      
      // Use logged-in user or "Guest"
      final authorName = authProvider.displayName.isNotEmpty 
          ? authProvider.displayName 
          : 'Guest';
      final authorAvatar = authProvider.photoUrl;

      await memorialProvider.postTribute(
        message: message,
        authorName: authorName,
        authorAvatarUrl: authorAvatar,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your tribute has been posted.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post tribute: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Write a Tribute', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              maxLines: 4,
              style: AppTextStyles.bodyText.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Share a memory, a story, or a message of love...',
                hintStyle: AppTextStyles.bodyText.copyWith(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.backgroundLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isPosting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: _isPosting 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Post Tribute', style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
