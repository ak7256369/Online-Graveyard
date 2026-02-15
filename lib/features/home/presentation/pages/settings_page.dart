import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:online_graveyard/features/auth/presentation/providers/auth_provider.dart';
import 'package:online_graveyard/features/home/presentation/providers/memorial_provider.dart';
import 'package:online_graveyard/theme/app_colors.dart';
import 'package:online_graveyard/theme/app_text_styles.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:online_graveyard/theme/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _biometricsEnabled = false;
  bool _canCheckBiometrics = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      });
    }
  }

  Future<void> _checkBiometrics() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('auth_biometrics_enabled') ?? false;
    
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics && await auth.isDeviceSupported();
    } catch (e) {
      canCheckBiometrics = false;
    }

    if (mounted) {
      setState(() {
        _biometricsEnabled = enabled;
        _canCheckBiometrics = canCheckBiometrics;
      });
    }
  }

  Future<void> _toggleBiometrics(bool value) async {
    if (value) {
      bool didAuthenticate = false;
      try {
        didAuthenticate = await auth.authenticate(
          localizedReason: 'Please authenticate to enable biometric login',
          // options: const AuthenticationOptions(stickyAuth: true), // Removing problematic option
        );
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
        return;
      }
      
      if (!didAuthenticate) return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auth_biometrics_enabled', value);
    if (mounted) {
      setState(() {
        _biometricsEnabled = value;
      });
      if (value) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biometric login enabled')));
      }
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final themeProvider = context.watch<ThemeProvider>();
    
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Text(
              'Settings',
              style: AppTextStyles.appTitle.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              _SectionHeader(title: 'SECURITY'),
              if (_canCheckBiometrics)
                _SettingsTile(
                  icon: Icons.fingerprint_rounded,
                  title: 'Biometric Login',
                  subtitle: 'Use fingerprint/face ID to open app',
                  trailing: Switch(
                    value: _biometricsEnabled,
                    onChanged: _toggleBiometrics,
                    activeColor: AppColors.primary,
                  ),
                ),
              
              if (context.watch<AuthProvider>().isAdmin)
                _SettingsTile(
                  icon: Icons.admin_panel_settings_rounded,
                  title: 'Admin Panel',
                  subtitle: 'Manage memorials and users',
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                  onTap: () => Navigator.pushNamed(context, '/admin'),
                ),

              const SizedBox(height: 8),
              // Dark Mode removed
              const SizedBox(height: 8),
              _SectionHeader(title: 'PREFERENCES'),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Push notifications for tributes & candles',
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: _toggleNotifications,
                  activeColor: AppColors.primary,
                ),
              ),
              _SettingsTile(
                icon: Icons.language_rounded,
                title: 'Language',
                subtitle: 'English',
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ),
 
              const SizedBox(height: 8),
              _SectionHeader(title: 'ACCOUNT'),
              // Sync removed
              _SettingsTile(
                icon: Icons.cloud_upload_outlined,
                title: 'Backup & Sync',
                subtitle: 'Connected to Firebase',
                trailing: const Icon(Icons.check_circle_rounded, size: 20, color: AppColors.success),
              ),
              _SettingsTile(
                icon: Icons.lock_outline_rounded,
                title: 'Privacy',
                subtitle: 'Manage memorial visibility',
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ),
              _SettingsTile(
                icon: Icons.storage_rounded,
                title: 'Storage',
                subtitle: '23 MB used',
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ),
 
              const SizedBox(height: 8),
              _SectionHeader(title: 'ABOUT'),
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'About',
                subtitle: 'Version 1.0.0',
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ),
              _SettingsTile(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                subtitle: 'FAQ and contact us',
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ),
              _SettingsTile(
                icon: Icons.policy_outlined,
                title: 'Terms & Privacy Policy',
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ),
 
              const SizedBox(height: 24),
              // Temporary Seed Button removed
              /*
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                   // ... button code ...
                ),
              ),
              */
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await context.read<AuthProvider>().signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                      }
                    },
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
 
              const SizedBox(height: 120),
            ],
          ),
        ),
      ],
    );
  }
}
 
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: AppTextStyles.dividerLabel.copyWith(color: AppColors.textMuted),
        ),
      ),
    );
  }
}
 
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
 
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
              )
            : null,
        trailing: trailing,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
