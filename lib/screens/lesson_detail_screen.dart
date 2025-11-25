import 'package:flutter/material.dart';
import '../models/lesson_model.dart';

class LessonDetailScreen extends StatelessWidget {
  final Lesson lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    // 1. CEK JUDUL MATERI
    // Cek apakah ini materi A-P atau materi Q-Z
    // (Sesuaikan string 'A-P' atau 'A-E' dengan judul asli di database kamu)
    final bool isAlfabetPart1 = lesson.title.contains('A-P') || lesson.title.contains('A-E') || lesson.title.contains('F-J');
    final bool isAlfabetPart2 = lesson.title.contains('Q-Z');

    // 2. DATA MATERI BAGIAN 1 (A-P)
    final List<Map<String, String>> materiPart1 = [
      {'huruf': 'A', 'image': 'assets/images/A.png'},
      {'huruf': 'B', 'image': 'assets/images/B.png'},
      {'huruf': 'C', 'image': 'assets/images/C.png'},
      {'huruf': 'D', 'image': 'assets/images/D.png'}, // Sesuaikan nama file
      {'huruf': 'E', 'image': 'assets/images/E.png'},
      {'huruf': 'F', 'image': 'assets/images/F.png'},
      {'huruf': 'G', 'image': 'assets/images/G.png'},
      {'huruf': 'H', 'image': 'assets/images/H.png'},
      {'huruf': 'I', 'image': 'assets/images/I.png'},
      {'huruf': 'J', 'image': 'assets/images/J.png'},
      {'huruf': 'K', 'image': 'assets/images/K.png'},
      {'huruf': 'L', 'image': 'assets/images/L.png'},
      {'huruf': 'M', 'image': 'assets/images/M.png'},
      {'huruf': 'N', 'image': 'assets/images/N.png'},
      {'huruf': 'O', 'image': 'assets/images/O.png'},
      {'huruf': 'P', 'image': 'assets/images/P.png'},
    ];

    // 3. DATA MATERI BAGIAN 2 (Q-Z) - [BARU]
    final List<Map<String, String>> materiPart2 = [
      {'huruf': 'Q', 'image': 'assets/images/Q.png'},
      {'huruf': 'R', 'image': 'assets/images/R.png'},
      {'huruf': 'S', 'image': 'assets/images/S.png'},
      {'huruf': 'T', 'image': 'assets/images/T.png'},
      {'huruf': 'U', 'image': 'assets/images/U.png'},
      {'huruf': 'V', 'image': 'assets/images/V.png'},
      {'huruf': 'W', 'image': 'assets/images/W.png'},
      {'huruf': 'X', 'image': 'assets/images/X.png'},
      {'huruf': 'Y', 'image': 'assets/images/Y.png'},
      {'huruf': 'Z', 'image': 'assets/images/Z.png'},
    ];

    // Tentukan list mana yang akan dipakai
    List<Map<String, String>> activeData = [];
    if (isAlfabetPart1) {
      activeData = materiPart1;
    } else if (isAlfabetPart2) {
      activeData = materiPart2;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul Materi
            Text(
              'Pelajari Gerakan Isyarat:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade800,
              ),
            ),
            const SizedBox(height: 16),

            // LOGIKA TAMPILAN
            if (activeData.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activeData.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Bagian Huruf Besar
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                activeData[index]['huruf']!,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple.shade800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          
                          // Bagian Gambar Isyarat
                          Expanded(
                            child: Container(
                              height: 150,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                activeData[index]['image']!,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.broken_image, color: Colors.red),
                                      Text("Gbr tdk ditemukan", style: TextStyle(fontSize: 10)),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            else
              // Tampilan default jika judul lesson tidak cocok dengan keduanya
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text("Materi belum tersedia untuk judul ini."),
                ),
              ),
              
            const SizedBox(height: 20),
            // Tombol Selesai Belajar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, true); // Kirim sinyal selesai
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Selamat! Anda telah menyelesaikan materi ini.")),
                  );
                },
                child: const Text("Selesai Membaca", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}