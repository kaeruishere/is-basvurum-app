import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/company.dart';
import '../models/template.dart';
import '../models/application.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/gmail_service.dart';

class ApplyScreen extends StatefulWidget {
  const ApplyScreen({super.key});

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  final _gmailService = GmailService();

  Company? _selectedCompany;
  MailTemplate? _selectedTemplate;
  bool _isSending = false;

  String _generatePreview() {
    if (_selectedCompany == null || _selectedTemplate == null) return '';
    
    String content = _selectedTemplate!.htmlContent;
    content = content.replaceAll('{{firma_adi}}', _selectedCompany!.name);
    content = content.replaceAll('{{ik_ismi}}', _selectedCompany!.hrSorumlusu);
    // User data should also be handled here...
    return content;
  }

  Future<void> _sendApplication() async {
    if (_selectedCompany == null || _selectedTemplate == null) return;

    setState(() => _isSending = true);
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      final body = _generatePreview();
      final subject = 'İş Başvurusu - ${user.displayName ?? ''}';

      // 1. Gmail ile gönder
      // Not: Gerçek mail adresi company modeline de eklenmeli, şimdilik placeholder.
      await _gmailService.sendEmail(
        to: 'hr@example.com', // Placeholder
        subject: subject,
        body: body,
      );

      // 2. Firestore'a kaydet
      final app = Application(
        id: const Uuid().v4(),
        userId: user.uid,
        companyId: _selectedCompany!.id,
        templateId: _selectedTemplate!.id,
        date: DateTime.now(),
        status: 'Beklemede',
        mailContent: body,
      );

      await _firestoreService.addApplication(app);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Başvuru başarıyla gönderildi!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) return const Scaffold();

    return Scaffold(
      appBar: AppBar(title: const Text('Başvuru Gönder')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Firma Seçimi
            StreamBuilder<List<Company>>(
              stream: _firestoreService.getCompanies(user.uid),
              builder: (context, snapshot) {
                final companies = snapshot.data ?? [];
                return DropdownButtonFormField<Company>(
                  value: _selectedCompany,
                  decoration: const InputDecoration(labelText: 'Firma Seçin'),
                  items: companies.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                  onChanged: (val) => setState(() => _selectedCompany = val),
                );
              },
            ),
            const SizedBox(height: 16),
            // Şablon Seçimi
            StreamBuilder<List<MailTemplate>>(
              stream: _firestoreService.getTemplates(user.uid),
              builder: (context, snapshot) {
                final templates = snapshot.data ?? [];
                return DropdownButtonFormField<MailTemplate>(
                  value: _selectedTemplate,
                  decoration: const InputDecoration(labelText: 'Şablon Seçin'),
                  items: templates.map((t) => DropdownMenuItem(value: t, child: Text(t.title))).toList(),
                  onChanged: (val) => setState(() => _selectedTemplate = val),
                );
              },
            ),
            const SizedBox(height: 32),
            if (_selectedCompany != null && _selectedTemplate != null) ...[
              const Text('Önizleme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_generatePreview(), style: const TextStyle(fontFamily: 'monospace')),
              ),
              const SizedBox(height: 48),
              _isSending
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFE8FF47)))
                  : ElevatedButton(
                      onPressed: _sendApplication,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8FF47),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Mail Gönder', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
            ],
          ],
        ),
      ),
    );
  }
}
