import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';
import '../models/lesson_model.dart';
import '../models/user_model.dart'; // Wajib di-import
import '../services/api_service.dart';
import 'profile_screen.dart';
import 'leaderboard_screen.dart';
import 'auth_screen.dart';
import 'lesson_detail_screen.dart';
import 'quiz_screen.dart';

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
                    // KITA KIRIM TOKEN DARI CURRENT USER KE SINI
                    builder: (context) => LeaderboardScreen(token: currentUser.token),
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
                  // LOGIKA LEVEL:
                  // 0-99 XP = Level 1
                  // 100-199 XP = Level 2, dst.
                  // Rumus: (XP dibagi 100) + 1
                  Text(
                    'Level: ${(currentUser.totalXp ~/ 100) + 1}', 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  
                  // LOGIKA STREAK
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                      const SizedBox(width: 4),
                      Text('Kontunan harian: ${currentUser.streakCount} hari'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // INFO TOTAL XP
                  Text('Total XP: ${currentUser.totalXp} XP'),
                  
                  // PROGRESS BAR MENUJU LEVEL BERIKUTNYA (Opsional, biar keren)
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      // Menghitung sisa XP (Modulus)
                      // Contoh: 85 XP -> 0.85 (85%)
                      value: (currentUser.totalXp % 100) / 100, 
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.deepPurple,
                      minHeight: 6,
                    ),
                  ),
                  Text(
                    '${100 - (currentUser.totalXp % 100)} XP lagi naik level',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
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

  bool isCourse1Passed = false;
  // === HELPER WIDGETS ===

  // Fungsi untuk membangun setiap bagian Course (Dasar 1: Perkenalan)
  Widget _buildCourseSection(BuildContext context, Course course) {
    bool isCourseLocked = false;
    
    // 1. LOGIKA GEMBOK MODUL (Antar Course)
    if (course.id == 2) {
      if (!isCourse1Passed) {
        isCourseLocked = true;
      }
    }

    // 2. LOGIKA GEMBOK PELAJARAN (Di dalam Course)
    // Kita butuh variabel untuk melacak apakah materi SEBELUMNYA sudah selesai
    bool isPreviousContentFinished = true; // Materi pertama dianggap terbuka
    
    List<Widget> lessonWidgets = [];

    for (var lesson in course.lessons) {
      // Sebuah pelajaran terkunci JIKA:
      // 1. Course-nya sendiri terkunci (misal Modul 2 masih gembok)
      // 2. ATAU Materi sebelumnya belum selesai
      bool isLessonLocked = isCourseLocked || !isPreviousContentFinished;

      lessonWidgets.add(_buildLessonTile(context, lesson, isLessonLocked));

      // Update status untuk putaran berikutnya:
      // Jika lesson ini belum selesai, maka lesson BERIKUTNYA harus dikunci.
      if (!lesson.isCompleted) {
        isPreviousContentFinished = false;
      }
    }

    // 3. LOGIKA GEMBOK QUIZ
    // Quiz hanya terbuka jika Course tidak terkunci DAN semua materi sebelumnya selesai
    bool isQuizLocked = isCourseLocked || !isPreviousContentFinished;

    // Simpan status kelulusan Course 1 untuk dipakai Course 2
    if (course.id == 1 && course.quiz != null) {
       isCourse1Passed = course.quiz!.isPassed;
    }

    return Opacity(
      opacity: isCourseLocked ? 0.5 : 1.0, 
      child: AbsorbPointer( 
        absorbing: isCourseLocked, 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul Course
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Row(
                children: [
                  Text(course.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                  if (isCourseLocked) const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.lock, color: Colors.grey),
                  )
                ],
              ),
            ),

            // Tampilkan Daftar Lesson yang sudah di-generate logic di atas
            ...lessonWidgets,

            // Tampilkan QUIZ TILE
            if (course.quiz != null)
              _buildQuizTile(context, course.quiz!, course.id, isQuizLocked),
          ],
        ),
      ),
    );
  }
  // Komponen List Tile untuk setiap Lesson (Alfabet Jari A-E, F-J, dst.)
  Widget _buildLessonTile(BuildContext context, Lesson lesson, bool isLocked) {
    Color tileColor;
    if (isLocked) {
      tileColor = Colors.grey.shade200; // Warna abu jika terkunci
    } else {
      tileColor = lesson.isCompleted ? Colors.green.shade100 : Colors.white;
    }

    return Card(
      color: tileColor,
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: isLocked ? 0 : 1,
      child: ListTile(
        leading: Icon(
          // Jika terkunci -> Gembok
          // Jika selesai -> Ceklis
          // Jika belum -> Buku
          isLocked ? Icons.lock : (lesson.isCompleted ? Icons.check_box : Icons.book),
          color: isLocked ? Colors.grey : (lesson.isCompleted ? Colors.green.shade700 : Colors.deepPurple),
        ),
        title: Text(
          lesson.title,
          style: TextStyle(
            color: isLocked ? Colors.grey : Colors.black,
          ),
        ),
        trailing: isLocked 
            ? const SizedBox() // Kosongkan jika terkunci
            : Text('${lesson.xpValue} XP'),
        
        onTap: isLocked 
          ? () {
              // Jika diklik saat terkunci, munculkan pesan
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Selesaikan materi sebelumnya untuk membuka ini!')),
              );
            }
          : () async {
              // Logika Normal (Buka Materi)
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LessonDetailScreen(lesson: lesson),
                ),
              );

              if (result == true) {
                if (!lesson.isCompleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Menyimpan progres...'), duration: Duration(milliseconds: 500)),
                  );

                  bool success = await ApiService().updateProgress(currentUser.token, lesson.id);

                  if (success) {
                    await _refreshUserData(); 
                    setState(() {
                      lesson.isCompleted = true;
                      
                    });
                  } 
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Materi ini sudah selesai.')));
                }
              }
            },
      ),
    );
  }

  // Komponen untuk Ujian Akhir
 Widget _buildQuizTile(BuildContext context, Quiz quiz, int courseId, bool isLocked) {
    bool isPassed = quiz.isPassed;

    return Card(
      // Warna abu jika terkunci
      color: isLocked ? Colors.grey.shade200 : (isPassed ? Colors.green.shade100 : Colors.red.shade50),
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Icon(
          isLocked ? Icons.lock : (isPassed ? Icons.check_circle : Icons.quiz), 
          color: isLocked ? Colors.grey : (isPassed ? Colors.green : Colors.red)
        ),
        title: Text(
          quiz.title,
          style: TextStyle(color: isLocked ? Colors.grey : Colors.black),
        ),
        subtitle: isLocked 
            ? const Text("Terkunci") 
            : Text(isPassed ? "Lulus (Nilai: ${quiz.userScore})" : "Min. Nilai: 80"),
        
        trailing: isLocked 
            ? const SizedBox() 
            : (isPassed ? const Text("Selesai") : const Icon(Icons.arrow_forward_ios, size: 16)),
        
        onTap: isLocked
            ? () {
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Selesaikan semua materi di modul ini dulu!')),
                );
              } 
            : () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(
                      courseId: courseId,
                      quizInfo: quiz,
                      token: currentUser.token,
                    ),
                  ),
                );
                
                _refreshUserData(); 
                setState(() {
                   futureCourses = ApiService().fetchCourses(currentUser.token);
                });
              },
      ),
    );
  }
}