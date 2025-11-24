import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart'; // Setelah login, navigasi ke Dashboard
import '../models/user_model.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoginMode = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // Deklarasi variabel untuk menyimpan data user yang berhasil login/register
    User? authenticatedUser;

    try {
      if (isLoginMode) {
        // --- LOGIKA LOGIN (INI TIDAK BERUBAH SAMA SEKALI) ---
        final authenticatedUser = await ApiService().loginUser(
          _emailController.text,
          _passwordController.text,
        );

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => DashboardScreen(user: authenticatedUser),
            ),
          );
        }
      } else {
        // --- LOGIKA REGISTER (INI YANG KITA UBAH) ---
        final successMessage = await ApiService().registerUser(
          _emailController.text,
          _passwordController.text,
          _confirmPasswordController.text,
        );

        if (mounted) {
          // Tampilkan pesan sukses dari server
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor: Colors.green,
            ),
          );
          // Pindahkan UI ke mode login
          setState(() {
            isLoginMode = true;
            _passwordController.clear();
            _confirmPasswordController.clear();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isLoginMode ? 'Login Guru' : 'Buat Akun Baru',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isLoginMode
                          ? 'Selamat datang kembali! Silakan masuk untuk melanjutkan.'
                          : 'Bergabunglah bersama kami dan mulailah belajar hari ini!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 30),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email:',
                        hintText: 'Masukkan alamat email Anda',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email tidak boleh kosong.';
                        }
                        // Pola Regular Expression untuk validasi email
                        final emailRegex = RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        );
                        if (!emailRegex.hasMatch(value)) {
                          return 'Masukkan format email yang valid.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password:',
                        hintText: 'Minimal 6 karakter',
                      ),
                      obscureText: true,
                      validator: (value) => (value == null || value.length < 6)
                          ? 'Password minimal 6 karakter.'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password Field (Hanya untuk Register)
                    if (!isLoginMode)
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Konfirmasi Password:',
                          hintText: 'Ulangi password di atas',
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Konfirmasi password tidak cocok.';
                          }
                          return null;
                        },
                      ),
                    if (!isLoginMode) const SizedBox(height: 30),

                    // Tombol Login/Daftar
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor:
                                  Colors.green, // Warna Hijau sesuai video
                            ),
                            child: Text(
                              isLoginMode ? 'Login' : 'Daftar',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                    const SizedBox(height: 20),

                    // Link Switch Mode
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isLoginMode = !isLoginMode;
                          _formKey.currentState?.reset();
                          _emailController.clear();
                          _passwordController.clear();
                          _confirmPasswordController.clear();
                        });
                      },
                      child: Text(
                        isLoginMode
                            ? 'Belum punya akun? Daftar di sini'
                            : 'Sudah punya akun? Login di sini',
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
