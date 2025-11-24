import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../models/lesson_model.dart';
import '../models/user_model.dart'; // Wajib di-import
import '../services/api_service.dart';
import 'profile_screen.dart';
import 'leaderboard_screen.dart';
import 'auth_screen.dart';

class DashboardScreen extends StatefulWidget {
  final User user;
  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Course>> futureCourses;
  late User currentUser;

  // Asumsi data user disimpan secara lokal setelah login
  // Nanti, data ini akan diambil dari hasil login API

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
    // Panggil API untuk memuat daftar kursus saat screen dibuka
    futureCourses = ApiService().fetchCourses(currentUser.token);
  }

  Future<void> _refreshUserData() async {
    try {
      // Panggil API untuk mendapatkan data user terbaru dari database
      final updatedUser = await ApiService().fetchUserProfile(currentUser.id);

      // PENTING: Jaga token asli dari login agar tidak hilang
      // karena fetchUserProfile tidak mengembalikan token.
      setState(() {
        currentUser = User(
          id: updatedUser.id,
          displayName: updatedUser.displayName,
          email: updatedUser.email,
          totalXp: updatedUser.totalXp,
          streakCount: updatedUser.streakCount,
          profileImageUrl: updatedUser.profileImageUrl,
          token: currentUser.token, // Gunakan token LAMA yang masih valid
        );
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat ulang data profil: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jalur Pembelajaran'),
        elevation: 0,
        // Tombol hamburger untuk membuka Drawer
      ),
      // Struktur Sidebar (Drawer) - Sesuai Video
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple.shade700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profil Ringkas di Sidebar
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentUser.displayName,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    currentUser.email,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            // Menu Navigasi Sesuai Video
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Jalur Pembelajaran'),
              selected: true, // Karena sedang berada di screen ini
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () async {
                // <-- 1. JADIKAN ASYNC
                Navigator.pop(context); // Tutup drawer terlebih dahulu

                // 2. TUNGGU HASIL DARI PROFILESCREEN
                // Aplikasi akan 'pause' di sini sampai ProfileScreen ditutup
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(user: currentUser),
                  ),
                );

                // 3. JIKA HASILNYA 'true' (artinya ada update), PANGGIL FUNGSI REFRESH
                if (result == true) {
                  _refreshUserData();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events),
              title: const Text('Papan Peringkat'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LeaderboardScreen(),
                  ),
                );
              },
            ),
            const Divider(),

            // Informasi XP dan Streak di Sidebar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level: ${currentUser.totalXp ~/ 100}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Kontunan harian: ${currentUser.streakCount} hari'),
                  Text('Total XP: ${currentUser.totalXp} XP'),
                ],
              ),
            ),
            // Tombol Logout (Sesuai Video)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                // Navigasi ke AuthScreen dan hapus semua rute sebelumnya dari tumpukan
                Navigator.of(context).pushAndRemoveUntil(
                  // Buat rute baru ke AuthScreen
                  MaterialPageRoute(builder: (context) => const AuthScreen()),

                  // Predikat (route) => false akan menghapus SEMUA rute sebelumnya.
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),

      // KODE FUTUREBUILDER UNTUK COURSES
      body: FutureBuilder<List<Course>>(
        future: futureCourses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Error ini akan muncul jika get_courses.php belum dibuat atau error
            return Center(
              child: Text('Gagal memuat jalur pembelajaran: ${snapshot.error}'),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView(
              padding: const EdgeInsets.all(16.0),
              // Membangun daftar Course (Dasar 1, Dasar 2, dst.)
              children: snapshot.data!.map((course) {
                return _buildCourseSection(context, course);
              }).toList(),
            );
          }
          return const Center(child: Text('Belum ada kursus yang tersedia.'));
        },
      ),
    );
  }

  // === HELPER WIDGETS ===

  // Fungsi untuk membangun setiap bagian Course (Dasar 1: Perkenalan)
  Widget _buildCourseSection(BuildContext context, Course course) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(
            course.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ),
        // Daftar Lesson di bawah Course
        ...course.lessons
            .map((lesson) => _buildLessonTile(context, lesson))
            .toList(),

        // Tambahkan Ujian Akhir (Quiz) jika ada (Sesuai Struktur Data MySQL Anda)
        if (course.id == 1) // Asumsi Quiz hanya ada di Course ID 1
          _buildQuizTile(context, 'Ujian Akhir: Dasar 1'),
      ],
    );
  }

  // Komponen List Tile untuk setiap Lesson (Alfabet Jari A-E, F-J, dst.)
  Widget _buildLessonTile(BuildContext context, Lesson lesson) {
    // Sesuaikan warna latar belakang berdasarkan status isCompleted (hijau atau abu-abu/putih)
    Color tileColor = lesson.isCompleted ? Colors.green.shade100 : Colors.white;

    return Card(
      color: tileColor,
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: 1,
      child: ListTile(
        leading: Icon(
          lesson.isCompleted ? Icons.check_box : Icons.book,
          color: lesson.isCompleted ? Colors.green.shade700 : Colors.grey,
        ),
        title: Text(lesson.title),
        trailing: Text('${lesson.xpValue} XP'),
        onTap: () {
          // Aksi: Navigasi ke Lesson Detail Screen
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Membuka ${lesson.title}')));
        },
      ),
    );
  }

  // Komponen untuk Ujian Akhir
  Widget _buildQuizTile(BuildContext context, String title) {
    return Card(
      color: Colors.red.shade50,
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: 1,
      child: ListTile(
        leading: Icon(Icons.assignment, color: Colors.red.shade700),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        onTap: () {
          // Aksi: Navigasi ke Quiz Screen
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Membuka Ujian')));
        },
      ),
    );
  }
}
