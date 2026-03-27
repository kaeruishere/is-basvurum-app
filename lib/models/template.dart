class MailTemplate {
  final String id;
  final String userId;
  final String title;
  final String htmlContent;
  final String sectorType;

  MailTemplate({
    required this.id,
    required this.userId,
    required this.title,
    required this.htmlContent,
    required this.sectorType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'baslik': title,
      'html_icerik': htmlContent,
      'sektor_tipi': sectorType,
    };
  }

  factory MailTemplate.fromMap(Map<String, dynamic> map) {
    return MailTemplate(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      title: map['baslik'] ?? '',
      htmlContent: map['html_icerik'] ?? '',
      sectorType: map['sektor_tipi'] ?? '',
    );
  }
}
