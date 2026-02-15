import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:online_graveyard/features/home/domain/entities/memorial.dart';
import 'package:online_graveyard/features/home/domain/entities/tribute.dart';
import 'package:online_graveyard/features/home/domain/repositories/memorial_repository.dart';

/// Provider for memorial data — manages state and exposes data to UI.
class MemorialProvider extends ChangeNotifier {
  final MemorialRepository _repository;

  MemorialProvider(this._repository);

  // ─── State ──────────────────────────────────────────────
  List<Memorial> _memorials = [];
  List<Memorial> get memorials => _memorials;

  List<Tribute> _tributes = [];
  List<Tribute> get tributes => _tributes;

  Memorial? _selectedMemorial;
  Memorial? get selectedMemorial => _selectedMemorial;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _selectedCategory = '';
  String get selectedCategory => _selectedCategory;

  StreamSubscription<List<Tribute>>? _tributeSubscription;

  // ─── Dummy Data ─────────────────────────────────────────
  static final List<Memorial> _dummyMemorials = [
    Memorial(
      id: 'demo-1',
      name: 'Eleanor Rose Mitchell',
      birthDate: DateTime(1945, 3, 15),
      deathDate: DateTime(2023, 11, 2),
      bio: 'A beloved grandmother and retired schoolteacher who touched the lives of thousands of students over 40 years. She was known for her warm smile and love of gardening.',
      epitaph: 'Forever in our hearts, forever teaching us to love.',
      profileImageUrl: 'https://i.pravatar.cc/300?img=47',
      category: 'family',
      candleCount: 247,
      flowerCount: 89,
      createdAt: DateTime(2023, 11, 5),
      createdBy: 'user_1',
    ),
    Memorial(
      id: 'demo-2',
      name: 'James "Jimmy" O\'Brien',
      birthDate: DateTime(1962, 7, 22),
      deathDate: DateTime(2024, 1, 10),
      bio: 'An avid musician and community volunteer who brought joy to everyone around him. Jimmy played guitar at every family gathering.',
      epitaph: 'The music plays on.',
      profileImageUrl: 'https://i.pravatar.cc/300?img=52',
      category: 'friends',
      candleCount: 156,
      flowerCount: 42,
      createdAt: DateTime(2024, 1, 15),
      createdBy: 'user_2',
    ),
    Memorial(
      id: 'demo-3',
      name: 'Sofia Chen',
      birthDate: DateTime(1988, 12, 8),
      deathDate: DateTime(2024, 6, 19),
      bio: 'A brilliant software engineer and passionate advocate for education equality. Sofia mentored dozens of young women in STEM.',
      epitaph: 'She coded a better world.',
      profileImageUrl: 'https://i.pravatar.cc/300?img=44',
      category: 'colleagues',
      candleCount: 512,
      flowerCount: 201,
      createdAt: DateTime(2024, 6, 25),
      createdBy: 'user_3',
    ),
    Memorial(
      id: 'demo-4',
      name: 'Robert "Bob" Williams',
      birthDate: DateTime(1938, 5, 1),
      deathDate: DateTime(2023, 8, 14),
      bio: 'A decorated veteran and loving father of four. Bob spent his retirement years volunteering at the local VA hospital.',
      epitaph: 'A hero in every sense of the word.',
      profileImageUrl: 'https://i.pravatar.cc/300?img=59',
      category: 'family',
      candleCount: 384,
      flowerCount: 67,
      createdAt: DateTime(2023, 8, 20),
      createdBy: 'user_4',
    ),
    Memorial(
      id: 'demo-5',
      name: 'Maria Santos Garcia',
      birthDate: DateTime(1955, 9, 30),
      deathDate: DateTime(2024, 3, 7),
      bio: 'A chef who brought the flavors of her homeland to everyone\'s table. Maria\'s tamales were legendary at the neighborhood festivals.',
      epitaph: 'Love was her secret ingredient.',
      profileImageUrl: 'https://i.pravatar.cc/300?img=23',
      category: 'friends',
      candleCount: 198,
      flowerCount: 134,
      createdAt: DateTime(2024, 3, 12),
      createdBy: 'user_5',
    ),
    Memorial(
      id: 'demo-6',
      name: 'Dr. Ahmed Hassan',
      birthDate: DateTime(1970, 2, 14),
      deathDate: DateTime(2024, 9, 28),
      bio: 'A cardiologist who saved countless lives during his 25-year career. Known for his compassion and tireless dedication to his patients.',
      epitaph: 'He healed hearts in more ways than one.',
      profileImageUrl: 'https://i.pravatar.cc/300?img=68',
      category: 'colleagues',
      candleCount: 723,
      flowerCount: 310,
      createdAt: DateTime(2024, 10, 2),
      createdBy: 'user_6',
    ),
  ];

  static final List<Tribute> _dummyTributes = [
    Tribute(
      id: 'tribute-1',
      memorialId: 'demo-1',
      authorName: 'Sarah Mitchell',
      message: 'Grandma, you taught me everything about kindness. I miss our Sunday garden walks. Love you always. 💐',
      createdAt: DateTime(2024, 1, 15),
    ),
    Tribute(
      id: 'tribute-2',
      memorialId: 'demo-1',
      authorName: 'David Mitchell',
      message: 'Mom, your apple pie recipe lives on. Every time I bake it, I feel you right here with us.',
      createdAt: DateTime(2024, 2, 10),
    ),
    Tribute(
      id: 'tribute-3',
      memorialId: 'demo-1',
      authorName: 'former student',
      message: 'Mrs. Mitchell was my 3rd grade teacher. She changed my life. Rest in peace. 🕯️',
      createdAt: DateTime(2024, 3, 5),
    ),
  ];

  // ─── Seed Data (One-time) ───────────────────────────────
  Future<void> seedData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.seedDummyData(_dummyMemorials, _dummyTributes);
      await fetchMemorials(); // Refresh to show new data
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Memorial Operations ────────────────────────────────

  Future<void> selectMemorial(Memorial memorial) async {
    _selectedMemorial = memorial;
    _errorMessage = null;
    notifyListeners();
    await checkUserInteraction();
    _subscribeTributes(memorial.id);
  }

  /// Fetch all memorials, optionally filtered by category.
  Future<void> fetchMemorials({String? category}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedCategory = category ?? '';
      _memorials = await _repository.getMemorials(
        category: category?.isNotEmpty == true ? category : null,
      );
      // If Firestore returned empty, show dummy data
      if (_memorials.isEmpty) {
        _memorials = _filterDummy(category);
      }
    } catch (e) {
      // On error, load dummy data so the app isn't blank
      _errorMessage = null; // Don't show error, show dummy data instead
      _memorials = _filterDummy(category);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filter dummy data by category.
  List<Memorial> _filterDummy(String? category) {
    if (category == null || category.isEmpty) return List.from(_dummyMemorials);
    return _dummyMemorials.where((m) => m.category == category).toList();
  }

  /// Search memorials by name.
  Future<void> search(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (query.isEmpty) {
        await fetchMemorials(category: _selectedCategory.isNotEmpty ? _selectedCategory : null);
        return;
      } else {
        _memorials = await _repository.searchMemorials(query);
        if (_memorials.isEmpty) {
          // Search dummy data too
          _memorials = _dummyMemorials
              .where((m) => m.name.toLowerCase().contains(query.toLowerCase()))
              .toList();
        }
      }
    } catch (e) {
      // Fallback to searching dummy data
      _memorials = _dummyMemorials
          .where((m) => m.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Select a memorial for detailed view by ID.
  Future<void> selectMemorialById(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedMemorial = await _repository.getMemorialById(id);
      await checkUserInteraction();
      _subscribeTributes(id);
    } catch (e) {
      // Check dummy data
      final dummy = _dummyMemorials.where((m) => m.id == id).toList();
      if (dummy.isNotEmpty) {
        _selectedMemorial = dummy.first;
        await checkUserInteraction();
        _subscribeTributes(id);
      } else {
        _errorMessage = 'Memorial not found';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<String?> createMemorial(
    Memorial memorial, {
    Uint8List? profileImageBytes,
    List<Uint8List>? galleryImageBytesList,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final id = await _repository.createMemorial(memorial);
      
      // Upload Profile Image
      if (profileImageBytes != null) {
        final imageUrl = await _repository.uploadProfileImage(id, profileImageBytes);
        final updatedMemorial = memorial.copyWith(
          id: id, 
          profileImageUrl: imageUrl,
        );
        await _repository.updateMemorial(updatedMemorial);
      }
      
      // Upload Gallery Images
      if (galleryImageBytesList != null && galleryImageBytesList.isNotEmpty) {
        final List<String> galleryUrls = [];
        for (final bytes in galleryImageBytesList) {
          final url = await _repository.uploadGalleryImage(id, bytes);
          galleryUrls.add(url);
        }
        
        // Fetch fresh to get current state (e.g. if profile image updated)
        final currentMemorial = await _repository.getMemorialById(id);
        
        // Update with gallery URLs
        await _repository.updateMemorial(
          currentMemorial.copyWith(galleryImageUrls: galleryUrls),
        );
      }

      await fetchMemorials();
      return id;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateMemorial(
    Memorial memorial, {
    Uint8List? newProfileImageBytes,
    List<Uint8List>? newGalleryImageBytesList,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Upload new profile image if provided
      var updatedMemorial = memorial;
      if (newProfileImageBytes != null) {
        final imageUrl = await _repository.uploadProfileImage(memorial.id, newProfileImageBytes);
        updatedMemorial = updatedMemorial.copyWith(profileImageUrl: imageUrl);
      }

      // 2. Upload new gallery images if provided
      if (newGalleryImageBytesList != null && newGalleryImageBytesList.isNotEmpty) {
        final List<String> newUrls = [];
        for (final bytes in newGalleryImageBytesList) {
          final url = await _repository.uploadGalleryImage(memorial.id, bytes);
          newUrls.add(url);
        }
        // Append to existing list
        final currentUrls = List<String>.from(updatedMemorial.galleryImageUrls);
        currentUrls.addAll(newUrls);
        updatedMemorial = updatedMemorial.copyWith(galleryImageUrls: currentUrls);
      }

      // 3. Update Firestore
      await _repository.updateMemorial(updatedMemorial);
      
      // 4. Refresh local state
      await fetchMemorials();
      if (_selectedMemorial?.id == memorial.id) {
        _selectedMemorial = updatedMemorial;
      }
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteMemorial(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.deleteMemorial(id);
      await fetchMemorials();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  // ─── Tribute Operations (Real-time) ────────────────────

  void _subscribeTributes(String memorialId) {
    _tributeSubscription?.cancel();
    _tributeSubscription = _repository.watchTributes(memorialId).listen(
      (tributes) {
        _tributes = tributes;
        if (_tributes.isEmpty) {
          _tributes = _dummyTributes.where((t) => t.memorialId == memorialId).toList();
        }
        notifyListeners();
      },
      onError: (error) {
        _tributes = _dummyTributes.where((t) => t.memorialId == memorialId).toList();
        notifyListeners();
      },
    );
  }

  Future<void> postTribute({
    required String authorName,
    String? authorAvatarUrl,
    required String message,
  }) async {
    if (_selectedMemorial == null) return;

    try {
      final tribute = Tribute(
        id: '',
        memorialId: _selectedMemorial!.id,
        authorName: authorName,
        authorAvatarUrl: authorAvatarUrl,
        message: message,
        createdAt: DateTime.now(),
      );
      await _repository.postTribute(tribute);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> lightTributeCandle(String tributeId) async {
    if (_selectedMemorial == null) return;
    try {
      await _repository.lightCandle(_selectedMemorial!.id, tributeId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ─── Interaction State ────────────────────────────────
  
  bool _hasLitCandle = false;
  bool _hasLeftFlower = false;
  
  bool get hasLitCandle => _hasLitCandle;
  bool get hasLeftFlower => _hasLeftFlower;

  Future<void> checkUserInteraction() async {
    if (_selectedMemorial == null) return;
    final status = await _repository.getUserInteractionStatus(_selectedMemorial!.id);
    _hasLitCandle = status['litCandle'] ?? false;
    _hasLeftFlower = status['leftFlower'] ?? false;
    notifyListeners();
  }

  Future<void> lightMemorialCandle() async {
    if (_selectedMemorial == null) return;
    if (_hasLitCandle) {
       _errorMessage = 'You have already lit a candle.';
       notifyListeners();
       return;
    }
    
    // Optimistic Update
    final previousCount = _selectedMemorial!.candleCount;
    _hasLitCandle = true;
    _selectedMemorial = _selectedMemorial!.copyWith(candleCount: previousCount + 1);
    // Optimistic Update log removed
    notifyListeners();

    try {
      await _repository.lightMemorialCandle(_selectedMemorial!.id);
      // Confirm with fresh data
      _selectedMemorial = await _repository.getMemorialById(_selectedMemorial!.id);
      notifyListeners();
    } catch (e) {
      // Revert on error
      _hasLitCandle = false;
      _selectedMemorial = _selectedMemorial!.copyWith(candleCount: previousCount);
      _errorMessage = e.toString();
      // Error log removed
      notifyListeners();
    }
  }

  Future<void> leaveFlower() async {
    if (_selectedMemorial == null) return;
    if (_hasLeftFlower) {
       _errorMessage = 'You have already left a flower.';
       notifyListeners();
       return;
    }

    // Optimistic Update
    final previousCount = _selectedMemorial!.flowerCount;
    _hasLeftFlower = true;
    _selectedMemorial = _selectedMemorial!.copyWith(flowerCount: previousCount + 1);
    // Optimistic Update log removed
    notifyListeners();

    try {
      await _repository.leaveFlower(_selectedMemorial!.id);
      // Confirm with fresh data
      _selectedMemorial = await _repository.getMemorialById(_selectedMemorial!.id);
      notifyListeners();
    } catch (e) {
       // Revert on error
      _hasLeftFlower = false;
      _selectedMemorial = _selectedMemorial!.copyWith(flowerCount: previousCount);
       _errorMessage = e.toString();
       // Error log removed
       notifyListeners();
    }
  }

  // ─── Cleanup ────────────────────────────────────────────

  void clearSelection() {
    _selectedMemorial = null;
    _tributes = [];
    _hasLitCandle = false;
    _hasLeftFlower = false;
    _tributeSubscription?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _tributeSubscription?.cancel();
    super.dispose();
  }
}

