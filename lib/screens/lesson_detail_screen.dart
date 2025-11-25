import 'package:flutter/material.dart';
import '../models/lesson_model.dart';

class LessonDetailScreen extends StatelessWidget {
  final Lesson lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    // Kita cek judul lessonnya.
    // Jika materinya tentang Alfabet, kita siapkan data A-E.
    // Nanti bisa dikembangkan lagi agar datanya dinamis dari API.
    final bool isAlfabetPart1 = lesson.title.contains('A-E');

    // Data dummy untuk materi A-E (Pastikan kamu punya gambar di folder assets)
    // Jika belum ada gambar, kode ini akan menampilkan Icon sebagai pengganti sementara.
    final List<Map<String, String>> materiAlfabet = [
      {'huruf': 'A', 'image': 'assets/images/A.png'},
      {'huruf': 'B', 'image': 'assets/images/B.png'}
    ];

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

            // Logika Tampilan:
            // Jika judul mengandung "A-E", tampilkan kartu A-E.
            if (isAlfabetPart1)
              ListView.builder(
                shrinkWrap: true, // Agar bisa di dalam SingleChildScrollView
                physics: const NeverScrollableScrollPhysics(),
                itemCount: materiAlfabet.length,
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
                                materiAlfabet[index]['huruf']!,
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
                              height: 150, // Tinggi diperbesar agar gambar jelas
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                materiAlfabet[index]['image']!, // Memanggil gambar
                                fit: BoxFit.contain, // Agar gambar pas di kotak
                                errorBuilder: (context, error, stackTrace) {
                                  // Jika gambar tidak ketemu/salah nama, muncul icon rusak
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
              // Tampilan default jika bukan materi A-E
              const Center(
                child: Text("Materi belum tersedia."),
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
                  // Aksi ketika selesai membaca materi
                  // Bisa tambahkan logika update progress ke API disini
                  Navigator.pop(context, true);
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