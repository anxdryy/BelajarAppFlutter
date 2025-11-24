import 'package:flutter/material.dart';
// Hapus semua import yang duplikat
import 'screens/profile_screen.dart'; // Jika path ini benar
import 'screens/auth_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Belajar Isyarat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      
      // >>> GANTI HOMEPAGE KE AUTH SCREEN <<<
      home: const AuthScreen(), 
      // >>> HINGGA SINI <<<
    );
  }
}