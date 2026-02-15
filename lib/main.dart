import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:online_graveyard/firebase_options.dart';
import 'package:online_graveyard/theme/app_theme.dart';
import 'package:online_graveyard/features/onboarding/splash_page.dart';
import 'package:online_graveyard/features/auth/presentation/providers/auth_provider.dart';
import 'package:online_graveyard/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:online_graveyard/features/home/presentation/providers/memorial_provider.dart';
import 'package:online_graveyard/features/home/data/repositories/memorial_repository_impl.dart';
import 'package:online_graveyard/features/admin/presentation/providers/admin_provider.dart';
import 'package:online_graveyard/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:online_graveyard/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthRepositoryImpl()),
        ),
        ChangeNotifierProvider(
          create: (_) => MemorialProvider(MemorialRepositoryImpl()),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminProvider(
            MemorialRepositoryImpl(),
            AuthRepositoryImpl(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'The Online Graveyard',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // themeMode: ThemeMode.light, // Default is system or light, but we enforced lightTheme above as default.
        routes: {
          '/admin': (context) => const AdminDashboardPage(),
        },
        builder: (context, widget) {
          // Global error boundary for release mode / web
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            return Material(
              color: Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Rendering Error',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorDetails.exception.toString(),
                      style: const TextStyle(color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          };
          return widget!;
        },
        home: const SplashPage(),
      ),
    );
  }
}
