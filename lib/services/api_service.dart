import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
// >>> IMPORT WAJIB AGAR DART MENGENAL MODEL <<<
import '../models/user_model.dart';
import '../models/course_model.dart'; 
import '../models/leaderboard_model.dart';
// >>> AKHIR IMPORT WAJIB <<<

class ApiService {
  // URL sudah dikoreksi ke port 8080.
  final String baseUrl = "http://10.0.2.2:8080/flutter_api"; 

  // --- 1. PROFIL & USER ---

  Future<User> fetchUserProfile(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/get_user.php?id=$userId'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return User.fromJson(jsonResponse['data']); 
    } else {
      throw Exception('Gagal memuat profil pengguna');
    }
  }

  Future<String> registerUser(String email, String password, String confirmPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/handle_register.php'),
      body: {
        'email': email,
        'password': password,
        'password_confirmation': confirmPassword,
      },
    );

    final jsonResponse = json.decode(response.body);

  if (response.statusCode == 200 && jsonResponse['status'] == 'success') {
    // Kembalikan HANYA pesan suksesnya sebagai sebuah String
    return jsonResponse['message']; 
  } else {
    // Jika gagal, tetap lempar exception
    throw Exception(jsonResponse['message'] ?? 'Gagal mendaftar');
  }
}

  Future<User> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/handle_login.php'),
      body: {'email': email, 'password': password},
    );

    final jsonResponse = json.decode(response.body);
 if (response.statusCode == 200 && jsonResponse['status'] == 'success') {
    // INI BAGIAN PALING PENTING:
    // Kita mengambil 'user' DAN 'token' dari JSON response.
    // Lalu kita teruskan KEDUA-DUANYA ke User.fromJson.
    return User.fromJson(jsonResponse['user'], token: jsonResponse['token']);
  } else {
    throw Exception(jsonResponse['message'] ?? 'Kombinasi email/password salah');
  }
}

  // --- 2. COURSE & LESSON (Dashboard) ---
  
  // FUNGSI INI AKAN MENGEMBALIKAN Future<List<Course>>
  Future<List<Course>> fetchCourses(String token) async {
    // Anda harus membuat endpoint get_courses.php di backend
    final url = Uri.parse('$baseUrl/get_courses.php');

    final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // <--- 3. KIRIM TOKEN DI SINI
    },
  );

    if (response.statusCode == 200) {
      final List jsonList = json.decode(response.body)['data'];
      // Dart sekarang mengenal Course karena import di atas sudah ada
      return jsonList.map((json) => Course.fromJson(json)).toList();
    } else {
      final jsonResponse = json.decode(response.body);
      throw Exception('Gagal memuat jalur pembelajaran. Pastikan get_courses.php dibuat.');
    }
  }

  // --- TAMBAHKAN FUNGSI INI DI DALAM CLASS ApiService ---
  
  // Fungsi untuk menyimpan progress ke database (Menembak update_progress.php)
  Future<bool> updateProgress(String token, int lessonId) async {
    final url = Uri.parse('$baseUrl/update_progress.php'); 

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Kirim token untuk validasi user
        },
        body: jsonEncode({
          'lesson_id': lessonId, // Data ID pelajaran yang diselesaikan
        }),
      );

      if (response.statusCode == 200) {
        // Berhasil disimpan (HTTP 200)
        return true; 
      } else {
        // Gagal dari server (misal HTTP 400/401/500)
        print('Gagal update progress: ${response.body}');
        return false;
      }
    } catch (e) {
      // Gagal koneksi / error lain
      print('Error koneksi updateProgress: $e');
      return false;
    }
  }

  // --- 3. LEADERBOARD ---

  // FUNGSI INI AKAN MENGEMBALIKAN Future<List<LeaderboardEntry>>
  Future<List<LeaderboardEntry>> fetchLeaderboard(String token) async {
    final url = Uri.parse('$baseUrl/leaderboard.php');
    
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Kirim Token di sini
      },
    );
    
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List data = jsonResponse['data']; 
      return data.map((json) => LeaderboardEntry.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat papan peringkat.');
    }
  }

  Future<bool> updateUserProfile({
    required String token,
    required String displayName,
    File? imageFile, // File gambar bersifat opsional
  }) async {
    final url = Uri.parse('$baseUrl/handle_update_profile.php');
    
    // Kita pakai MultipartRequest karena ada file yang di-upload
    var request = http.MultipartRequest('POST', url);

    // 1. Tambahkan Header Otorisasi
    request.headers['Authorization'] = 'Bearer $token';

    // 2. Tambahkan field data (nama)
    request.fields['display_name'] = displayName;

    // 3. Tambahkan file gambar jika ada
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_image', // Nama field ini HARUS SAMA dengan di PHP ($_FILES['profile_image'])
          imageFile.path,
        ),
      );
    }
    
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['status'] == 'success';
      } else {
        // Gagal, lempar exception dengan pesan dari server
        final jsonResponse = json.decode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Gagal memperbarui profil.');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }
}