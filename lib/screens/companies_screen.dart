import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/company.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();

  void _showAddCompanySheet() {
    final nameController = TextEditingController();
    final sectorController = TextEditingController();
    final hrController = TextEditingController();
    final webController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Yeni Firma Ekle',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 24),
            _buildDialogField(nameController, 'Firma Adı', Icons.business_rounded),
            const SizedBox(height: 12),
            _buildDialogField(sectorController, 'Sektör (Oyun, Mobil, vb.)', Icons.category_rounded),
            const SizedBox(height: 12),
            _buildDialogField(hrController, 'İK Sorumlusu', Icons.person_outline),
            const SizedBox(height: 12),
            _buildDialogField(webController, 'Web Sitesi', Icons.language_rounded),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                final user = _authService.currentUser;
                if (user == null) return;

                final company = Company(
                  id: const Uuid().v4(),
                  userId: user.uid,
                  name: nameController.text,
                  sector: sectorController.text,
                  hrSorumlusu: hrController.text,
                  webSite: webController.text,
                );

                await _firestoreService.addCompany(company);
                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8FF47),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Kaydet', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: const Color(0xFFE8FF47), size: 18),
        filled: true,
        fillColor: Colors.black.withOpacity(0.2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) return const Scaffold();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firmalar', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCompanySheet,
        backgroundColor: const Color(0xFFE8FF47),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: StreamBuilder<List<Company>>(
        stream: _firestoreService.getCompanies(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE8FF47)));
          }

          final companies = snapshot.data ?? [];
          if (companies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.business_center_outlined, size: 64, color: Colors.white.withOpacity(0.1)),
                   const SizedBox(height: 16),
                   Text('Henüz firma eklenmemiş.', style: TextStyle(color: Colors.white.withOpacity(0.3))),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: companies.length,
            itemBuilder: (context, index) {
              final company = companies[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  title: Text(company.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('${company.sector} · ${company.hrSorumlusu}', style: TextStyle(color: Colors.white.withOpacity(0.5))),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () => _firestoreService.deleteCompany(company.id),
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
