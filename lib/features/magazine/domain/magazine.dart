class Magazine {
  final String id;
  final String title;
  final String description;
  final String? coverImageUrl;
  final String pdfUrl;
  final String? issueDate;
  final int year;
  final String issuePeriod;
  final DateTime? createdAt;
  final bool isDownloaded;
  final String? localPath;

  const Magazine({
    required this.id,
    required this.title,
    required this.description,
    this.coverImageUrl,
    required this.pdfUrl,
    this.issueDate,
    required this.year,
    required this.issuePeriod,
    this.createdAt,
    this.isDownloaded = false,
    this.localPath,
  });

  factory Magazine.fromJson(Map<String, dynamic> json) {
    return Magazine(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Paripoorana Jeevan',
      description: json['description']?.toString() ??
          'Rev. Dr. Jerry Daniel’s Messages from Paripoorana Jeevan',
      coverImageUrl: json['cover_image_url']?.toString(),
      pdfUrl: json['pdf_url']?.toString() ?? '',
      issueDate: json['issue_date']?.toString(),
      year: int.tryParse(json['year']?.toString() ?? '') ?? DateTime.now().year,
      issuePeriod: json['issue_period']?.toString() ?? 'Bi-Monthly',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Magazine copyWith({
    bool? isDownloaded,
    String? localPath,
  }) {
    return Magazine(
      id: id,
      title: title,
      description: description,
      coverImageUrl: coverImageUrl,
      pdfUrl: pdfUrl,
      issueDate: issueDate,
      year: year,
      issuePeriod: issuePeriod,
      createdAt: createdAt,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localPath: localPath ?? this.localPath,
    );
  }

  /// Converts Google Drive preview links to direct PDF download stream links
  String get directDownloadUrl {
    if (pdfUrl.contains('drive.google.com/file/d/')) {
      final regExp = RegExp(r'/file/d/([a-zA-Z0-9_-]+)');
      final match = regExp.firstMatch(pdfUrl);
      if (match != null && match.groupCount >= 1) {
        final fileId = match.group(1);
        return 'https://drive.google.com/uc?export=download&id=$fileId';
      }
    }
    return pdfUrl;
  }
}
