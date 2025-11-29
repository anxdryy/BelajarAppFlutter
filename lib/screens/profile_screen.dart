import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Pastikan import image_picker
import '../models/user_model.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isLoading = false;
  File? _imageFile; // Untuk menyimpan file gambar yang dipilih

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.displayName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Fungsi Pick Image
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      bool success = await ApiService().updateUserProfile(
        token: widget.user.token,
        displayName: _nameController.text,
        imageFile: _imageFile, // Kirim file gambar jika ada
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Kirim sinyal sukses kembali ke dashboard
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background putih bersih
      extendBodyBehindAppBar: true, // Agar AppBar transparan di atas background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER CUSTOM (UNGU MELENGKUNG) ---
            Stack(
              clipBehavior: Clip.none, // Biarkan avatar keluar dari kotak
              alignment: Alignment.bottomCenter,
              children: [
                // Background Ungu Melengkung
                Container(
                  height: 280,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF6A5AE0), Color(0xFF6A5AE0)], // Ungu Gradient
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                ),
                
                // Posisi Avatar (Setengah di Ungu, Setengah di Putih)
                Positioned(
                  bottom: -50, 
                  child: Stack(
                    children: [
                      // Lingkaran Avatar
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4), // Border putih tebal
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                          ]
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _getImageProvider(), // Helper function
                          child: _imageFile == null && (widget.user.profileImageUrl == null || widget.user.profileImageUrl!.isEmpty)
                              ? const Icon(Icons.person, size: 60, color: Colors.grey)
                              : null,
                        ),
                      ),
                      
                      // Tombol Kamera Kecil
                      
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 70), // Spasi agar form tidak ketutup avatar

            // --- FORM INPUT ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Nama Display (Teks Besar di Tengah)
                    Text(
                      widget.user.email, // Email ditampilkan di bawah avatar (read only)
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    ),
                    const SizedBox(height: 30),

                    // Input Field Nama (Desain Minimalis)
                    _buildTextField(
                      controller: _nameController,
                      label: "Nama Lengkap",
                      icon: Icons.person_outline,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Input Dummy (Hanya visual, biar mirip referensi)
                    _buildTextField(
                      controller: TextEditingController(text: "Teacher"),
                      label: "Pekerjaan",
                      icon: Icons.work_outline,
                      isReadOnly: true,
                    ),
                    
                    const SizedBox(height: 40),

                    // Tombol Simpan
                    _isLoading
                        ? const CircularProgressIndicator(color: Color(0xFF6A5AE0))
                        : SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _updateProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6A5AE0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 5,
                                shadowColor: const Color(0xFF6A5AE0).withOpacity(0.4),
                              ),
                              child: const Text(
                                'Simpan Perubahan',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Helper untuk menampilkan Text Field Cantik
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isReadOnly = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 5))
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        readOnly: isReadOnly,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(icon, color: const Color(0xFF6A5AE0)),
          border: InputBorder.none, // Hilangkan border bawaan
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        validator: (value) => (value == null || value.trim().isEmpty)
            ? 'Field ini tidak boleh kosong'
            : null,
      ),
    );
  }

  // Helper untuk menentukan gambar mana yang dipakai (Lokal/Network/Kosong)
  ImageProvider? _getImageProvider() {
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    } else if (widget.user.profileImageUrl != null && widget.user.profileImageUrl!.isNotEmpty) {
      return NetworkImage(widget.user.profileImageUrl!);
    }
    return null;
  }
}