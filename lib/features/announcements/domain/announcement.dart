class ChurchAnnouncement {
  final String id;
  final String title;
  final String titleTa;
  final String description;
  final String descriptionTa;
  final String? date;
  final String? flyerUrl;
  final String category; // 'Fasting Prayer', 'Convention', 'Youth Meeting', 'General'
  final bool isUrgent;
  final String? actionUrl;

  const ChurchAnnouncement({
    required this.id,
    required this.title,
    this.titleTa = '',
    required this.description,
    this.descriptionTa = '',
    this.date,
    this.flyerUrl,
    this.category = 'General',
    this.isUrgent = false,
    this.actionUrl,
  });

  factory ChurchAnnouncement.fromJson(Map<String, dynamic> json) {
    String titleEn = '';
    String titleTamil = '';
    if (json['title'] is Map) {
      titleEn = json['title']['en']?.toString() ?? '';
      titleTamil = json['title']['ta']?.toString() ?? '';
    } else {
      titleEn = json['title']?.toString() ?? '';
    }

    String descEn = '';
    String descTamil = '';
    if (json['description'] is Map) {
      descEn = json['description']['en']?.toString() ?? '';
      descTamil = json['description']['ta']?.toString() ?? '';
    } else {
      descEn = json['description']?.toString() ?? '';
    }

    return ChurchAnnouncement(
      id: json['id']?.toString() ?? '',
      title: titleEn,
      titleTa: titleTamil,
      description: descEn,
      descriptionTa: descTamil,
      date: json['date']?.toString(),
      flyerUrl: json['flyerUrl']?.toString() ?? json['image_url']?.toString(),
      category: json['category']?.toString() ?? 'General',
      isUrgent: json['isUrgent'] == true || json['is_urgent'] == true,
      actionUrl: json['actionUrl']?.toString() ?? json['action_url']?.toString(),
    );
  }
}
