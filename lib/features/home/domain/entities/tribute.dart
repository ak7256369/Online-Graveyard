/// Tribute entity — represents a community tribute/message on a memorial.
///
/// Each tribute belongs to a memorial (stored as a Firestore sub-collection).
class Tribute {
  final String id;
  final String memorialId;
  final String authorName;
  final String? authorAvatarUrl;
  final String message;
  final int candleCount;
  final bool hasCandleLit; // whether current user has lit a candle
  final DateTime createdAt;

  const Tribute({
    required this.id,
    required this.memorialId,
    required this.authorName,
    this.authorAvatarUrl,
    required this.message,
    this.candleCount = 0,
    this.hasCandleLit = false,
    required this.createdAt,
  });

  /// Author initials for avatar fallback (e.g., "JD" for "John Doe").
  String get authorInitials {
    final parts = authorName.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return authorName.isNotEmpty ? authorName[0].toUpperCase() : '?';
  }

  /// Time-ago display string.
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inDays > 365) return '${diff.inDays ~/ 365} year${diff.inDays ~/ 365 > 1 ? 's' : ''} ago';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30} month${diff.inDays ~/ 30 > 1 ? 's' : ''} ago';
    if (diff.inDays > 7) return '${diff.inDays ~/ 7} week${diff.inDays ~/ 7 > 1 ? 's' : ''} ago';
    if (diff.inDays > 0) return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    if (diff.inHours > 0) return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
    return 'Just now';
  }

  Tribute copyWith({
    String? id,
    String? memorialId,
    String? authorName,
    String? authorAvatarUrl,
    String? message,
    int? candleCount,
    bool? hasCandleLit,
    DateTime? createdAt,
  }) {
    return Tribute(
      id: id ?? this.id,
      memorialId: memorialId ?? this.memorialId,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      message: message ?? this.message,
      candleCount: candleCount ?? this.candleCount,
      hasCandleLit: hasCandleLit ?? this.hasCandleLit,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
