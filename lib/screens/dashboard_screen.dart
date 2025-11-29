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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F6FC), // Background abu-abu sangat muda (biar kartu pop-up)
      
      // --- DRAWER TETAP ADA TAPI KITA SEMBUNYIKAN TOMBOLNYA DI HEADER CUSTOM ---
      drawer: _buildDrawer(),

      body: Column(
        children: [
          // --- 1. HEADER CUSTOM (MIRIP REFERENSI) ---
          _buildCustomHeader(),

          // --- 2. BODY CONTENT (LIST PELAJARAN) ---
          Expanded(
            child: FutureBuilder<List<Course>>(
              future: futureCourses,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Gagal memuat: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    children: snapshot.data!.map((course) {
                      return _buildCourseSection(context, course);
                    }).toList(),
                  );
                }
                return const Center(child: Text('Belum ada kursus.'));
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HEADER BARU (DESAIN UNGU MELENGKUNG) ---
  Widget _buildCustomHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF6A5AE0), // Warna Ungu Utama
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
        ]
      ),
      child: Column(
        children: [
          // Baris Atas: Menu & Notifikasi (Opsional)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              const Text(
                "Dashboard Belajar",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 48), // Spacer biar title tengah
            ],
          ),
          const SizedBox(height: 20),

          // Baris Profil: Avatar & Nama
          Row(
            children: [
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage: currentUser.profileImageUrl != null 
                      ? NetworkImage(currentUser.profileImageUrl!) 
                      : null,
                  child: currentUser.profileImageUrl == null 
                      ? const Icon(Icons.person, size: 35, color: Color(0xFF6A5AE0)) 
                      : null,
                ),
              ),
              const SizedBox(width: 15),
              // Nama & Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUser.displayName,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      currentUser.email,
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),

          // Baris Statistik (Level, Streak, XP) - Mirip bagian "Buckets" di referensi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem("Level", "${(currentUser.totalXp ~/ 100) + 1}"),
              _buildVerticalDivider(),
              _buildStatItem("Streak", "${currentUser.streakCount} Hari"),
              _buildVerticalDivider(),
              _buildStatItem("Total XP", "${currentUser.totalXp}"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 30, width: 1, color: Colors.white.withOpacity(0.3));
  }

  // --- DRAWER ASLI (Hanya Dipoles Sedikit) ---
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF6A5AE0)),
            accountName: Text(currentUser.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(currentUser.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(currentUser.displayName[0].toUpperCase(), style: const TextStyle(fontSize: 24, color: Color(0xFF6A5AE0))),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: Color(0xFF6A5AE0)),
            title: const Text('Jalur Pembelajaran'),
            selected: true,
            selectedTileColor: const Color(0xFF6A5AE0).withOpacity(0.1),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profil'),
            onTap: () async {
              Navigator.pop(context);
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ProfileScreen(user: currentUser)),
              );
              if (result == true) _refreshUserData();
            },
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events),
            title: const Text('Papan Peringkat'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => LeaderboardScreen(token: currentUser.token)),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AuthScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
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