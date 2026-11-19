class PrayerRequest {
  final String? id;
  final String requesterName;
  final String contactInfo;
  final bool isAnonymous;
  final String requestText;
  final String status;
  final String category;
  final DateTime? submittedAt;

  const PrayerRequest({
    this.id,
    required this.requesterName,
    required this.contactInfo,
    required this.isAnonymous,
    required this.requestText,
    this.status = 'New',
    this.category = 'General',
    this.submittedAt,
  });

  Map<String, dynamic> toInsertJson() {
    return {
      'requester_name': isAnonymous ? 'Anonymous Believer' : requesterName.trim(),
      'contact_info': isAnonymous ? '' : contactInfo.trim(),
      'is_anonymous': isAnonymous,
      'request_text': category.isNotEmpty ? '[$category] ${requestText.trim()}' : requestText.trim(),
      'status': status,
    };
  }
}
