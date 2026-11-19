class DailyVerse {
  final String id;
  final DateTime verseDate;
  final String verseEn;
  final String verseTa;
  final String reference;
  final DateTime? createdAt;

  const DailyVerse({
    required this.id,
    required this.verseDate,
    required this.verseEn,
    required this.verseTa,
    required this.reference,
    this.createdAt,
  });

  factory DailyVerse.fromJson(Map<String, dynamic> json) {
    return DailyVerse(
      id: json['id']?.toString() ?? '',
      verseDate: json['verse_date'] != null
          ? DateTime.tryParse(json['verse_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      verseEn: json['verse_en']?.toString() ?? '',
      verseTa: json['verse_ta']?.toString() ?? '',
      reference: json['reference']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'verse_date': "${verseDate.year.toString().padLeft(4, '0')}-${verseDate.month.toString().padLeft(2, '0')}-${verseDate.day.toString().padLeft(2, '0')}",
      'verse_en': verseEn,
      'verse_ta': verseTa,
      'reference': reference,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
