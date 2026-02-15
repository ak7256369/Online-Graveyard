import 'dart:typed_data';
import 'package:online_graveyard/features/home/domain/entities/memorial.dart';
import 'package:online_graveyard/features/home/domain/entities/tribute.dart';

/// Abstract repository contract for Memorial operations.
///
/// Defines the interface for data access — implemented by
/// the data layer with Firestore and Firebase Storage.
abstract class MemorialRepository {
  // ─── Memorial CRUD ─────────────────────────────────────

  /// Fetch all memorials, optionally filtered by [category].
  Future<List<Memorial>> getMemorials({String? category});

  /// Search memorials by name (prefix match).
  Future<List<Memorial>> searchMemorials(String query);

  /// Fetch a single memorial by [id].
  Future<Memorial> getMemorialById(String id);

  /// Create a new memorial. Returns the new document ID.
  Future<String> createMemorial(Memorial memorial);

  /// Update an existing memorial.
  Future<void> updateMemorial(Memorial memorial);

  /// Delete a memorial and all its sub-collections.
  Future<void> deleteMemorial(String id);

  // Seed Data
  Future<void> seedDummyData(List<Memorial> memorials, List<Tribute> tributes);

  // ─── Media Upload ──────────────────────────────────────

  /// Upload a profile JPEG image. Returns the download URL.
  Future<String> uploadProfileImage(String memorialId, Uint8List imageBytes);

  /// Upload an MP4 tribute video. Returns the download URL.
  Future<String> uploadTributeVideo(String memorialId, Uint8List videoBytes);

  /// Upload a gallery JPEG image. Returns the download URL.
  Future<String> uploadGalleryImage(String memorialId, Uint8List imageBytes);

  // ─── Tributes (Sub-collection) ─────────────────────────

  /// Post a tribute message to a memorial.
  Future<String> postTribute(Tribute tribute);

  /// Get tributes for a memorial (one-time fetch).
  Future<List<Tribute>> getTributes(String memorialId);

  /// Real-time stream of tributes for a memorial.
  /// Ordered by creation date (newest first).
  Stream<List<Tribute>> watchTributes(String memorialId);

  /// Light a candle on a tribute (increment count).
  Future<void> lightCandle(String memorialId, String tributeId);

  // ─── Candles & Flowers (Memorial-level) ────────────────

  /// Light a candle on a memorial (increment count).
  Future<void> lightMemorialCandle(String memorialId);

  /// Leave a flower on a memorial (increment count).
  Future<void> leaveFlower(String memorialId);

  /// Check if current user has lit candle or left flower.
  Future<Map<String, bool>> getUserInteractionStatus(String memorialId);

  // ─── Stats ─────────────────────────────────────────────
  
  /// Get counts for dashboard (memorials, tributes, etc.)
  Future<Map<String, int>> getStats();
}
