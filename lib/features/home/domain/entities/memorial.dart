/// Memorial entity — pure domain object.
///
/// Represents a memorial page for a deceased person.
/// This is the core business object, independent of any data source.
class Memorial {
  final String id;
  final String name;
  final DateTime birthDate;
  final DateTime deathDate;
  final String? bio;
  final String? epitaph;
  final String? profileImageUrl;
  final String? tributeVideoUrl;
  final String? tributeVideoTitle;
  final Duration? tributeVideoDuration;
  final List<String> galleryImageUrls;
  final int candleCount;
  final int flowerCount;
  final String category; // 'family', 'friends', 'colleagues'
  final DateTime createdAt;
  final String createdBy;

  const Memorial({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.deathDate,
    this.bio,
    this.epitaph,
    this.profileImageUrl,
    this.tributeVideoUrl,
    this.tributeVideoTitle,
    this.tributeVideoDuration,
    this.galleryImageUrls = const [],
    this.candleCount = 0,
    this.flowerCount = 0,
    this.category = 'family',
    required this.createdAt,
    required this.createdBy,
  });

  /// Formatted date range string like "1978 – 2023".
  String get dateRange {
    return '${birthDate.year} – ${deathDate.year}';
  }

  /// Display-friendly candle count (e.g., "999+").
  String get displayCandleCount {
    if (candleCount > 999) return '999+';
    return candleCount.toString();
  }

  Memorial copyWith({
    String? id,
    String? name,
    DateTime? birthDate,
    DateTime? deathDate,
    String? bio,
    String? epitaph,
    String? profileImageUrl,
    String? tributeVideoUrl,
    String? tributeVideoTitle,
    Duration? tributeVideoDuration,
    List<String>? galleryImageUrls,
    int? candleCount,
    int? flowerCount,
    String? category,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return Memorial(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      deathDate: deathDate ?? this.deathDate,
      bio: bio ?? this.bio,
      epitaph: epitaph ?? this.epitaph,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      tributeVideoUrl: tributeVideoUrl ?? this.tributeVideoUrl,
      tributeVideoTitle: tributeVideoTitle ?? this.tributeVideoTitle,
      tributeVideoDuration: tributeVideoDuration ?? this.tributeVideoDuration,
      galleryImageUrls: galleryImageUrls ?? this.galleryImageUrls,
      candleCount: candleCount ?? this.candleCount,
      flowerCount: flowerCount ?? this.flowerCount,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
