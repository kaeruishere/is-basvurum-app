import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _githubController = TextEditingController();
  final _portfolioController = TextEditingController();
  
  File? _cvFile;
  bool _isLoading = false;

  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();

  Future<void> _pickCV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() => _cvFile = File(result.files.single.path!));
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _cvFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun ve CV yükleyin.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      // 1. CV'yi yükle
      final cvUrl = await _storageService.uploadCV(user.uid, _cvFile!);

      // 2. Firestore'a kaydet
      await _firestoreService.saveProfile(
        uid: user.uid,
        phone: _phoneController.text,
        github: _githubController.text,
        portfolio: _portfolioController.text,
        cvUrl: cvUrl,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Profilini\nTamamla',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'İş başvurularında kullanılacak temel bilgilerini gir.',
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
                const SizedBox(height: 48),
                _buildTextField(_phoneController, 'Telefon Numarası', Icons.phone_outlined),
                const SizedBox(height: 16),
                _buildTextField(_githubController, 'GitHub URL', Icons.code_rounded),
                const SizedBox(height: 16),
                _buildTextField(_portfolioController, 'Portfolio URL', Icons.language_rounded),
                const SizedBox(height: 32),
                
                // CV Seçme Alanı
                GestureDetector(
                  onTap: _pickCV,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _cvFile != null ? const Color(0xFFE8FF47) : Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _cvFile != null ? Icons.check_circle_rounded : Icons.picture_as_pdf_outlined,
                          color: _cvFile != null ? const Color(0xFFE8FF47) : Colors.white.withOpacity(0.3),
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _cvFile != null ? 'CV Yüklendi: ${_cvFile!.path.split('/').last}' : 'CV Yükle (PDF)',
                          style: TextStyle(
                            color: _cvFile != null ? Colors.white : Colors.white.withOpacity(0.5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 48),
                
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFE8FF47)))
                    : ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8FF47),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Devam Et', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: const Color(0xFFE8FF47), size: 18),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE8FF47)),
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Gerekli alan' : null,
    );
  }
}
