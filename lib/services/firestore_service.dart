import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/company.dart';
import '../models/template.dart';
import '../models/application.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Profil işlemleri
  Future<void> saveUserToken(String uid, String token) async {
    await _db.collection('users').doc(uid).set({
      'gmail_access_token': token,
    }, SetOptions(merge: true));
  }

  Future<void> saveProfile({
    required String uid,
    required String phone,
    required String github,
    required String portfolio,
    required String cvUrl,
  }) async {
    await _db.collection('users').doc(uid).set({
      'phone': phone,
      'github_url': github,
      'portfolio_url': portfolio,
      'cv_url': cvUrl,
      'is_profile_complete': true,
    }, SetOptions(merge: true));
  }

  // Firma işlemleri
  Future<void> addCompany(Company company) async {
    await _db.collection('companies').doc(company.id).set(company.toMap());
  }

  Stream<List<Company>> getCompanies(String uid) {
    return _db
        .collection('companies')
        .where('user_id', isEqualTo: uid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Company.fromMap(doc.data())).toList());
  }

  Future<void> deleteCompany(String id) async {
    await _db.collection('companies').doc(id).delete();
  }

  // Şablon işlemleri
  Future<void> addTemplate(MailTemplate template) async {
    await _db.collection('templates').doc(template.id).set(template.toMap());
  }

  Stream<List<MailTemplate>> getTemplates(String uid) {
    return _db
        .collection('templates')
        .where('user_id', isEqualTo: uid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MailTemplate.fromMap(doc.data())).toList());
  }

  Future<void> deleteTemplate(String id) async {
    await _db.collection('templates').doc(id).delete();
  }

  // Başvuru işlemleri
  Future<void> addApplication(Application app) async {
    await _db.collection('applications').doc(app.id).set(app.toMap());
  }

  Stream<List<Application>> getApplications(String uid) {
    return _db
        .collection('applications')
        .where('user_id', isEqualTo: uid)
        .orderBy('tarih', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Application.fromMap(doc.data())).toList());
  }

  Future<void> updateApplicationStatus(String id, String status) async {
    await _db.collection('applications').doc(id).update({'durum': status});
  }

  Future<Map<String, int>> getStats(String uid) async {
    final snapshot = await _db.collection('applications').where('user_id', isEqualTo: uid).get();
    final Map<String, int> stats = {};
    for (var doc in snapshot.docs) {
      final status = doc.data()['durum'] as String;
      stats[status] = (stats[status] ?? 0) + 1;
    }
    return stats;
  }
}
