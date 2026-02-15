import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:online_graveyard/features/auth/domain/repositories/auth_repository.dart';

/// Auth state provider — manages authentication state for the UI.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthProvider(this._repository) {
    // Listen to auth state changes
    _repository.authStateChanges.listen((user) {
      _currentUser = user;
      _userRole = null; // Reset role
      notifyListeners();
      
      if (user != null) {
        _fetchUserRole(user.uid);
      }
    });
    _currentUser = _repository.currentUser;
  }

  String? _userRole;
  bool get isAdmin => _userRole == 'admin';

  StreamSubscription<DocumentSnapshot>? _roleSubscription;
 
   void _fetchUserRole(String uid) {
     _roleSubscription?.cancel();
     _roleSubscription = _firestore.collection('users').doc(uid).snapshots().listen((snapshot) {
       if (snapshot.exists) {
         _userRole = snapshot.data()?['role'] as String?;
       } else {
         _userRole = null;
       }
       notifyListeners();
     }, onError: (e) {
       // Error log removed
     });
   }
 
   @override
   void dispose() {
     _roleSubscription?.cancel();
     super.dispose();
   }

  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// User display name (fallback to email prefix).
  String get displayName {
    if (_currentUser == null) return 'Guest';
    if (_currentUser!.displayName != null && _currentUser!.displayName!.isNotEmpty) {
      return _currentUser!.displayName!;
    }
    return _currentUser!.email?.split('@').first ?? 'User';
  }

  /// User email.
  String get email => _currentUser?.email ?? '';

  /// User initials for avatar fallback.
  String get initials {
    final name = displayName;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  /// User photo URL.
  String? get photoUrl => _currentUser?.photoURL;

  /// Member since date.
  String get memberSince {
    final created = _currentUser?.metadata.creationTime;
    if (created == null) return 'Recently';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[created.month - 1]} ${created.year}';
  }

  // ─── Auth Operations ──────────────────────────────────

  Future<bool> signInWithEmail(String email, String password) async {
    return _authAction(() => _repository.signInWithEmail(email, password));
  }

  Future<bool> signUpWithEmail(String email, String password, String displayName) async {
    return _authAction(() => _repository.signUpWithEmail(email, password, displayName));
  }

  Future<bool> signInWithGoogle() async {
    return _authAction(() => _repository.signInWithGoogle());
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.resetPassword(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDisplayName(String name) async {
    try {
      await _repository.updateDisplayName(name);
      _currentUser = _repository.currentUser;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update name';
      notifyListeners();
    }
  }

  Future<void> syncUserSession() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Manually trigger the self-healing logic by checking doc
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'email': user.email,
            'displayName': user.displayName ?? 'User',
            'createdAt': FieldValue.serverTimestamp(),
            'role': 'user',
          });
          _userRole = 'user';
        } else {
          _userRole = doc.data()?['role'] as String?;
        }
        notifyListeners();
      } catch (e) {
        // ignore
      }
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _currentUser = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ─── Private Helper ────────────────────────────────────

  Future<bool> _authAction(Future<UserCredential> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
