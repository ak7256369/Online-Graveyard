import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:online_graveyard/features/home/data/models/memorial_model.dart';
import 'package:online_graveyard/features/home/data/models/tribute_model.dart';
import 'package:online_graveyard/features/home/domain/entities/memorial.dart';
import 'package:online_graveyard/features/home/domain/entities/tribute.dart';
import 'package:online_graveyard/features/home/domain/repositories/memorial_repository.dart';

/// Firestore + Firebase Storage implementation of [MemorialRepository].
///
/// Collection structure:
///   memorials/{memorialId}
///   memorials/{memorialId}/tributes/{tributeId}
///
/// Storage structure:
///   memorials/{memorialId}/profile.jpg
///   memorials/{memorialId}/tribute_video.mp4
///   memorials/{memorialId}/gallery/{timestamp}.jpg
class MemorialRepositoryImpl implements MemorialRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  MemorialRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _memorialsRef =>
      _firestore.collection('memorials');

  CollectionReference<Map<String, dynamic>> _tributesRef(String memorialId) =>
      _memorialsRef.doc(memorialId).collection('tributes');

  // ─── Seed Data ─────────────────────────────────────────
  @override
  Future<void> seedDummyData(List<Memorial> memorials, List<Tribute> tributes) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Must be logged in to seed data');

    final batch = _firestore.batch();

    for (final memorial in memorials) {
      // 1. Create new ID for Firestore
      final newMemorialRef = _memorialsRef.doc();
      
      // 2. Overwrite ID and Seed ID to current user
      final seedMemorial = memorial.copyWith(
        id: newMemorialRef.id,
        createdBy: user.uid,
      );
      
      final memorialModel = MemorialModel.fromEntity(seedMemorial);
      batch.set(newMemorialRef, memorialModel.toFirestore());

      // 3. Add associated tributes
      final memorialTributes = tributes.where((t) => t.memorialId == memorial.id);
      for (final tribute in memorialTributes) {
        final newTributeRef = newMemorialRef.collection('tributes').doc();
        final tributeModel = TributeModel.fromEntity(tribute.copyWith(
          id: newTributeRef.id,
          memorialId: newMemorialRef.id, // Link to new memorial ID
        ));
        batch.set(newTributeRef, tributeModel.toFirestore());
      }
    }

    await batch.commit();
  }

  // ─── Memorial CRUD ─────────────────────────────────────

  @override
  Future<List<Memorial>> getMemorials({String? category}) async {
    try {
      Query<Map<String, dynamic>> query = _memorialsRef.orderBy('createdAt', descending: true);

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category.toLowerCase());
      }

      final snapshot = await query.limit(50).get();
      return snapshot.docs.map((doc) => MemorialModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch memorials: $e');
    }
  }

  @override
  Future<List<Memorial>> searchMemorials(String query) async {
    try {
      if (query.isEmpty) return getMemorials();

      // Firestore prefix search: name >= query AND name < query + high Unicode char
      final end = query.substring(0, query.length - 1) +
          String.fromCharCode(query.codeUnitAt(query.length - 1) + 1);

      final snapshot = await _memorialsRef
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: end)
          .limit(20)
          .get();

      return snapshot.docs.map((doc) => MemorialModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to search memorials: $e');
    }
  }

  @override
  Future<Memorial> getMemorialById(String id) async {
    try {
      final doc = await _memorialsRef.doc(id).get();
      if (!doc.exists) {
        throw Exception('Memorial not found');
      }
      return MemorialModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to fetch memorial: $e');
    }
  }

  @override
  Future<String> createMemorial(Memorial memorial) async {
    try {
      final model = MemorialModel.fromEntity(memorial);
      final docRef = await _memorialsRef.add(model.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create memorial: $e');
    }
  }

  @override
  Future<void> updateMemorial(Memorial memorial) async {
    try {
      final model = MemorialModel.fromEntity(memorial);
      await _memorialsRef.doc(memorial.id).update(model.toFirestore());
    } catch (e) {
      throw Exception('Failed to update memorial: $e');
    }
  }

  @override
  Future<void> deleteMemorial(String id) async {
    try {
      // Delete all tributes in sub-collection first
      final tributesSnap = await _tributesRef(id).get();
      final batch = _firestore.batch();
      for (final doc in tributesSnap.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_memorialsRef.doc(id));
      await batch.commit();

      // Clean up storage files (best-effort, don't throw on failure)
      try {
        final storageRef = _storage.ref('memorials/$id');
        final listResult = await storageRef.listAll();
        for (final item in listResult.items) {
          await item.delete();
        }
        // Also delete gallery subfolder
        final galleryRef = _storage.ref('memorials/$id/gallery');
        final galleryResult = await galleryRef.listAll();
        for (final item in galleryResult.items) {
          await item.delete();
        }
      } catch (_) {
        // Storage cleanup is best-effort
      }
    } catch (e) {
      throw Exception('Failed to delete memorial: $e');
    }
  }

  // ─── Media Upload (Cross-platform: uses Uint8List) ─────

  @override
  Future<String> uploadProfileImage(String memorialId, Uint8List imageBytes) async {
    try {
      final ref = _storage.ref('memorials/$memorialId/profile.jpg');
      final uploadTask = await ref.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  @override
  Future<String> uploadTributeVideo(String memorialId, Uint8List videoBytes) async {
    try {
      final ref = _storage.ref('memorials/$memorialId/tribute_video.mp4');
      final uploadTask = await ref.putData(
        videoBytes,
        SettableMetadata(contentType: 'video/mp4'),
      );
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload tribute video: $e');
    }
  }

  @override
  Future<String> uploadGalleryImage(String memorialId, Uint8List imageBytes) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = _storage.ref('memorials/$memorialId/gallery/$timestamp.jpg');
      final uploadTask = await ref.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload gallery image: $e');
    }
  }

  // ─── Tributes (Sub-collection) ─────────────────────────

  @override
  Future<String> postTribute(Tribute tribute) async {
    try {
      final model = TributeModel.fromEntity(tribute);
      final docRef = await _tributesRef(tribute.memorialId).add(model.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to post tribute: $e');
    }
  }

  @override
  Future<List<Tribute>> getTributes(String memorialId) async {
    try {
      final snapshot = await _tributesRef(memorialId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      return snapshot.docs
          .map((doc) => TributeModel.fromFirestore(doc, memorialId))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch tributes: $e');
    }
  }

  @override
  Stream<List<Tribute>> watchTributes(String memorialId) {
    return _tributesRef(memorialId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TributeModel.fromFirestore(doc, memorialId))
            .toList());
  }

  @override
  Future<void> lightCandle(String memorialId, String tributeId) async {
    try {
      await _tributesRef(memorialId).doc(tributeId).update({
        'candleCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to light candle on tribute: $e');
    }
  }

  // ─── Candles & Flowers (Memorial-level) ────────────────

  @override
  Future<void> lightMemorialCandle(String memorialId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Must be logged in');

    final interactionRef = _memorialsRef.doc(memorialId).collection('interactions').doc(user.uid);
    final memorialRef = _memorialsRef.doc(memorialId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(interactionRef);
      if (snapshot.exists && (snapshot.data()?['litCandle'] == true)) {
        throw Exception('You have already lit a candle.');
      }

      transaction.set(interactionRef, {'litCandle': true}, SetOptions(merge: true));
      transaction.update(memorialRef, {'candleCount': FieldValue.increment(1)});
    });
  }

  @override
  Future<void> leaveFlower(String memorialId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Must be logged in');

    final interactionRef = _memorialsRef.doc(memorialId).collection('interactions').doc(user.uid);
    final memorialRef = _memorialsRef.doc(memorialId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(interactionRef);
      if (snapshot.exists && (snapshot.data()?['leftFlower'] == true)) {
        throw Exception('You have already left a flower.');
      }

      transaction.set(interactionRef, {'leftFlower': true}, SetOptions(merge: true));
      transaction.update(memorialRef, {'flowerCount': FieldValue.increment(1)});
    });
  }

  @override
  Future<Map<String, bool>> getUserInteractionStatus(String memorialId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {'litCandle': false, 'leftFlower': false};

    try {
      final doc = await _memorialsRef.doc(memorialId).collection('interactions').doc(user.uid).get();
      if (!doc.exists) return {'litCandle': false, 'leftFlower': false};
      
      final data = doc.data()!;
      return {
        'litCandle': data['litCandle'] == true,
        'leftFlower': data['leftFlower'] == true,
      };
    } catch (e) {
      return {'litCandle': false, 'leftFlower': false};
    }
  }

  @override
  Future<Map<String, int>> getStats() async {
    int memorials = 0;
    int tributes = 0;

    try {
      final snapshot = await _memorialsRef.count().get();
      memorials = snapshot.count ?? 0;
    } catch (e) {
      // Error log removed
    }

    try {
      final snapshot = await _firestore.collectionGroup('tributes').count().get();
      tributes = snapshot.count ?? 0;
    } catch (e) {
      // Error log removed
      // Note: Collection group queries often require an index. 
      // Check the browser console for a link to create it.
    }

    return {
      'memorials': memorials,
      'tributes': tributes,
    };
  }
}
