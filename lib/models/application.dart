import 'package:cloud_firestore/cloud_firestore.dart';

class Application {
  final String id;
  final String userId;
  final String companyId;
  final String templateId;
  final DateTime date;
  final String status;
  final String mailContent;

  Application({
    required this.id,
    required this.userId,
    required this.companyId,
    required this.templateId,
    required this.date,
    required this.status,
    required this.mailContent,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'company_id': companyId,
      'template_id': templateId,
      'tarih': Timestamp.fromDate(date),
      'durum': status,
      'mail_icerigi': mailContent,
    };
  }

  factory Application.fromMap(Map<String, dynamic> map) {
    return Application(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      companyId: map['company_id'] ?? '',
      templateId: map['template_id'] ?? '',
      date: (map['tarih'] as Timestamp).toDate(),
      status: map['durum'] ?? 'Beklemede',
      mailContent: map['mail_icerigi'] ?? '',
    );
  }
}
