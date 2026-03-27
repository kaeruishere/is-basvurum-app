import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/application.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();

  void _showStatusDialog(Application app) {
    const statuses = ['Beklemede', 'Mülakat', 'Red', 'Kabul'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Durum Güncelle', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statuses.map((s) => ListTile(
            title: Text(s, style: const TextStyle(color: Colors.white)),
            onTap: () async {
              await _firestoreService.updateApplicationStatus(app.id, s);
              if (mounted) Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Mülakat': return Colors.blueAccent;
      case 'Red': return Colors.redAccent;
      case 'Kabul': return Colors.greenAccent;
      default: return Colors.orangeAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) return const Scaffold();

    return Scaffold(
      appBar: AppBar(title: const Text('Başvurularım')),
      body: StreamBuilder<List<Application>>(
        stream: _firestoreService.getApplications(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE8FF47)));
          }

          final apps = snapshot.data ?? [];
          if (apps.isEmpty) {
            return Center(
              child: Text('Henüz başvuru yapılmadı.', style: TextStyle(color: Colors.white.withOpacity(0.3))),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              final dateStr = DateFormat('dd.MM.yyyy HH:mm').format(app.date);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: ListTile(
                  title: const Text('İş Başvurusu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(dateStr, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                  trailing: TextButton(
                    onPressed: () => _showStatusDialog(app),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(app.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        app.status,
                        style: TextStyle(color: _getStatusColor(app.status), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
