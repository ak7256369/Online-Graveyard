import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_graveyard/features/home/domain/entities/tribute.dart';

/// Firestore-serializable data model for Tribute.
///
/// Stored as sub-collection `memorials/{memorialId}/tributes`.
class TributeModel extends Tribute {
  const TributeModel({
    required super.id,
    required super.memorialId,
    required super.authorName,
    super.authorAvatarUrl,
    required super.message,
    super.candleCount,
    super.hasCandleLit,
    required super.createdAt,
  });

  /// Create from Firestore document snapshot.
  factory TributeModel.fromFirestore(DocumentSnapshot doc, String memorialId) {
    final data = doc.data() as Map<String, dynamic>;
    return TributeModel(
      id: doc.id,
      memorialId: memorialId,
      authorName: data['authorName'] ?? '',
      authorAvatarUrl: data['authorAvatarUrl'],
      message: data['message'] ?? '',
      candleCount: data['candleCount'] ?? 0,
      hasCandleLit: data['hasCandleLit'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Create from domain entity.
  factory TributeModel.fromEntity(Tribute tribute) {
    return TributeModel(
      id: tribute.id,
      memorialId: tribute.memorialId,
      authorName: tribute.authorName,
      authorAvatarUrl: tribute.authorAvatarUrl,
      message: tribute.message,
      candleCount: tribute.candleCount,
      hasCandleLit: tribute.hasCandleLit,
      createdAt: tribute.createdAt,
    );
  }

  /// Serialize to Firestore document map.
  Map<String, dynamic> toFirestore() {
    return {
      'authorName': authorName,
      'authorAvatarUrl': authorAvatarUrl,
      'message': message,
      'candleCount': candleCount,
      'hasCandleLit': hasCandleLit,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
