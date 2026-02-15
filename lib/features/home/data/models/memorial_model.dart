import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_graveyard/features/home/domain/entities/memorial.dart';

/// Firestore-serializable data model for Memorial.
///
/// Handles conversion between Firestore documents and domain entities.
/// Stored in the `memorials` collection.
class MemorialModel extends Memorial {
  const MemorialModel({
    required super.id,
    required super.name,
    required super.birthDate,
    required super.deathDate,
    super.bio,
    super.epitaph,
    super.profileImageUrl,
    super.tributeVideoUrl,
    super.tributeVideoTitle,
    super.tributeVideoDuration,
    super.galleryImageUrls,
    super.candleCount,
    super.flowerCount,
    super.category,
    required super.createdAt,
    required super.createdBy,
  });

  /// Create from Firestore document snapshot.
  factory MemorialModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MemorialModel(
      id: doc.id,
      name: data['name'] ?? '',
      birthDate: (data['birthDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deathDate: (data['deathDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      bio: data['bio'],
      epitaph: data['epitaph'],
      profileImageUrl: data['profileImageUrl'],
      tributeVideoUrl: data['tributeVideoUrl'],
      tributeVideoTitle: data['tributeVideoTitle'],
      tributeVideoDuration: data['tributeVideoDurationMs'] != null
          ? Duration(milliseconds: data['tributeVideoDurationMs'])
          : null,
      galleryImageUrls: List<String>.from(data['galleryImageUrls'] ?? []),
      candleCount: data['candleCount'] ?? 0,
      flowerCount: data['flowerCount'] ?? 0,
      category: data['category'] ?? 'family',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  /// Create from domain entity.
  factory MemorialModel.fromEntity(Memorial memorial) {
    return MemorialModel(
      id: memorial.id,
      name: memorial.name,
      birthDate: memorial.birthDate,
      deathDate: memorial.deathDate,
      bio: memorial.bio,
      epitaph: memorial.epitaph,
      profileImageUrl: memorial.profileImageUrl,
      tributeVideoUrl: memorial.tributeVideoUrl,
      tributeVideoTitle: memorial.tributeVideoTitle,
      tributeVideoDuration: memorial.tributeVideoDuration,
      galleryImageUrls: memorial.galleryImageUrls,
      candleCount: memorial.candleCount,
      flowerCount: memorial.flowerCount,
      category: memorial.category,
      createdAt: memorial.createdAt,
      createdBy: memorial.createdBy,
    );
  }

  /// Serialize to Firestore document map.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'birthDate': Timestamp.fromDate(birthDate),
      'deathDate': Timestamp.fromDate(deathDate),
      'bio': bio,
      'epitaph': epitaph,
      'profileImageUrl': profileImageUrl,
      'tributeVideoUrl': tributeVideoUrl,
      'tributeVideoTitle': tributeVideoTitle,
      'tributeVideoDurationMs': tributeVideoDuration?.inMilliseconds,
      'galleryImageUrls': galleryImageUrls,
      'candleCount': candleCount,
      'flowerCount': flowerCount,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }
}
