import 'package:firebase_auth/firebase_auth.dart';
import 'package:online_graveyard/features/auth/domain/entities/app_user.dart';

/// Abstract authentication repository contract.
abstract class AuthRepository {
  /// Current authenticated user (null if not logged in).
  User? get currentUser;

  /// Stream of auth state changes.
  Stream<User?> get authStateChanges;

  /// Sign in with email and password.
  Future<UserCredential> signInWithEmail(String email, String password);

  /// Create account with email and password.
  Future<UserCredential> signUpWithEmail(String email, String password, String displayName);

  /// Sign in with Google.
  Future<UserCredential> signInWithGoogle();

  /// Send password reset email.
  Future<void> resetPassword(String email);

  /// Update user display name.
  Future<void> updateDisplayName(String name);

  /// Get user role from Firestore (e.g. 'admin').
  Future<String?> getUserRole(String uid);

  /// Sign out.
  Future<void> signOut();

  /// Get all registered users (Admin only).
  Future<List<AppUser>> getAllUsers();
}
