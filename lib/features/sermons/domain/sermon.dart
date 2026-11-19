class Sermon {
  final String id;
  final String date;
  final String titleEn;
  final String titleTa;
  final String series;
  final String speaker;
  final String language;
  final String scripture;
  final String youtubeId;
  final bool isFeatured;
  final String youtubeUrl;
  final String descriptionEn;
  final String descriptionTa;
  final String thumbnailUrl;

  const Sermon({
    required this.id,
    required this.date,
    required this.titleEn,
    required this.titleTa,
    required this.series,
    required this.speaker,
    required this.language,
    required this.scripture,
    required this.youtubeId,
    required this.isFeatured,
    required this.youtubeUrl,
    required this.descriptionEn,
    required this.descriptionTa,
    required this.thumbnailUrl,
  });

  factory Sermon.fromJson(Map<String, dynamic> json) {
    String tEn = '';
    String tTa = '';
    if (json['title'] is Map) {
      tEn = json['title']['en']?.toString() ?? '';
      tTa = json['title']['ta']?.toString() ?? '';
    } else {
      tEn = json['title']?.toString() ?? '';
    }

    String dEn = '';
    String dTa = '';
    if (json['description'] is Map) {
      dEn = json['description']['en']?.toString() ?? '';
      dTa = json['description']['ta']?.toString() ?? '';
    } else if (json['description'] != null) {
      dEn = json['description'].toString();
    }

    final ytId = json['youtubeId']?.toString() ?? '';
    final thumb = json['thumbnailUrl']?.toString() ??
        (ytId.isNotEmpty
            ? 'https://img.youtube.com/vi/$ytId/hqdefault.jpg'
            : '');

    return Sermon(
      id: json['id']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      titleEn: tEn,
      titleTa: tTa,
      series: json['series']?.toString() ?? '',
      speaker: json['speaker']?.toString() ?? 'Rev. Dr. Jerry Daniel',
      language: json['language']?.toString() ?? 'Tamil',
      scripture: json['scripture']?.toString() ?? '',
      youtubeId: ytId,
      isFeatured: json['isFeatured'] == true,
      youtubeUrl: json['youtubeUrl']?.toString() ?? 'https://youtu.be/$ytId',
      descriptionEn: dEn,
      descriptionTa: dTa,
      thumbnailUrl: thumb,
    );
  }
}
