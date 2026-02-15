import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:online_graveyard/theme/app_colors.dart';
import 'package:online_graveyard/theme/app_text_styles.dart';

class QrCodeDialog extends StatelessWidget {
  final String memorialId;
  final String memorialName;

  const QrCodeDialog({
    super.key,
    required this.memorialId,
    required this.memorialName,
  });

  @override
  Widget build(BuildContext context) {
    final String deepLink = 'https://online-graveyard.app/memorial/$memorialId';

    return Dialog(
      backgroundColor: AppColors.surfaceLight,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Scan to Visit',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              memorialName,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: QrImageView(
                data: deepLink,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
                dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.textPrimary,
              ),
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.textPrimary,
              ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Share this QR code with friends and family.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
