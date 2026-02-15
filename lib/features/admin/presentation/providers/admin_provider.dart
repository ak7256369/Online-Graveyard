import 'package:flutter/material.dart';
import 'package:online_graveyard/features/auth/domain/entities/app_user.dart';
import 'package:online_graveyard/features/auth/domain/repositories/auth_repository.dart';
import 'package:online_graveyard/features/home/domain/entities/memorial.dart';
import 'package:online_graveyard/features/home/domain/repositories/memorial_repository.dart';

enum AdminTab { dashboard, memorials, users, settings }

class AdminProvider extends ChangeNotifier {
  final MemorialRepository _memorialRepository;
  final AuthRepository _authRepository;

  AdminProvider(this._memorialRepository, this._authRepository);

  // ─── State ──────────────────────────────────────────────
  AdminTab _currentTab = AdminTab.dashboard;
  AdminTab get currentTab => _currentTab;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Stats
  int _totalMemorials = 0;
  int get totalMemorials => _totalMemorials;

  int _totalUsers = 0;
  int get totalUsers => _totalUsers;
  
  int _totalTributes = 0;
  int get totalTributes => _totalTributes;

  // Data
  List<Memorial> _recentMemorials = [];
  List<Memorial> get recentMemorials => _recentMemorials;

  List<AppUser> _users = [];
  List<AppUser> get users => _users;

  // ─── Actions ────────────────────────────────────────────

  void setTab(AdminTab tab) {
    _currentTab = tab;
    notifyListeners();
  }

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Fetch Stats
      final stats = await _memorialRepository.getStats();
      _totalMemorials = stats['memorials'] ?? 0;
      _totalTributes = stats['tributes'] ?? 0;

      // 2. Fetch Memorials
      final memorials = await _memorialRepository.getMemorials();
      _recentMemorials = memorials.take(10).toList();

      // Fallback: If stats API failed or returned 0, but we have memorials, use the list count
      if (_totalMemorials == 0 && memorials.isNotEmpty) {
        _totalMemorials = memorials.length;
      }

      // 3. Fetch Users
      _users = await _authRepository.getAllUsers();
      _totalUsers = _users.length;

    } catch (e) {
      // Error log removed
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMemorial(String id) async {
    try {
      await _memorialRepository.deleteMemorial(id);
      await loadDashboardData(); // Refresh
    } catch (e) {
      rethrow;
    }
  }
}
