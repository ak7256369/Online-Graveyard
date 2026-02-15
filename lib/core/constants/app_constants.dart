/// Application-wide constants.
///
/// Centralize all magic strings, API endpoints, and configuration
/// values here to avoid scattering them across the codebase.

class AppConstants {
  AppConstants._(); // Prevent instantiation

  // App Info
  static const String appName = 'Online Graveyard';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String memorialsCollection = 'memorials';
  static const String tributesSubcollection = 'tributes';
  static const String usersCollection = 'users';

  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String videosPath = 'videos';
  static const String documentsPath = 'documents';

  // Pagination
  static const int defaultPageSize = 20;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
