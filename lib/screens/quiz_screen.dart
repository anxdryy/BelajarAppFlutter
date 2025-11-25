import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/course_model.dart'; // Import model Quiz

class QuizScreen extends StatefulWidget {
  final int courseId;
  final Quiz quizInfo;
  final String token;

  const QuizScreen({super.key, required this.courseId, required this.quizInfo, required this.token});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<dynamic> questions = [];
  bool isLoading = true;
  Map<int, int> answers = {}; // Map<IndexSoal, IndexJawabanDipilih>

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    // Ganti URL sesuai IP kamu
    final url = Uri.parse("http://10.0.2.2:8080/flutter_api/get_quiz.php?course_id=${widget.courseId}");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            questions = data['questions'];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _submitQuiz() async {
    // 1. Hitung Nilai Lokal
    int correctCount = 0;
    for (int i = 0; i < questions.length; i++) {
      if (answers.containsKey(i)) {
        List options = questions[i]['options'];
        int selectedIdx = answers[i]!;
        // Cek apakah opsi yang dipilih is_correct == true/1
        if (options[selectedIdx]['is_correct'] == true || options[selectedIdx]['is_correct'] == 1) {
          correctCount++;
        }
      }
    }

    // Rumus Nilai: (Benar / Total Soal) * 100
    double finalScore = (correctCount / questions.length) * 100;
    int scoreInt = finalScore.round();

    // 2. Kirim ke Server
    final url = Uri.parse("http://10.0.2.2:8080/flutter_api/submit_quiz.php");
    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer ${widget.token}'},
        body: jsonEncode({
          'quiz_id': widget.quizInfo.id,
          'score': scoreInt,
          'xp_reward': widget.quizInfo.xpValue
        }),
      );
      
      final result = json.decode(response.body);

      // 3. Tampilkan Hasil
      _showResultDialog(scoreInt, result['passed']);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal kirim nilai: $e")));
    }
  }

  void _showResultDialog(int score, bool passed) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(passed ? "Selamat! Lulus 🎉" : "Belum Lulus 😢"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Nilai kamu: $score", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(passed 
              ? "Kamu bisa lanjut ke materi Keluarga!" 
              : "Minimal nilai 80. Silakan coba lagi."),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup Dialog
              Navigator.pop(context, true); // Kembali ke Dashboard (Refresh)
            },
            child: const Text("Tutup"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: Text(widget.quizInfo.title), backgroundColor: Colors.deepPurple),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final q = questions[index];
          
          return Card(
            margin: const EdgeInsets.only(bottom: 24), // Jarak antar kartu diperbesar
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. HEADER SOAL
                  Text(
                    "Soal ${index + 1}", 
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple.shade300)
                  ),
                  const SizedBox(height: 8),
                  
                  // 2. TEKS SOAL
                  Text(
                    q['question_text'], 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 12),

                  // 3. GAMBAR SOAL (JIKA ADA)
                  if (q['question_image'] != null && q['question_image'].toString().isNotEmpty)
                    Container(
                      height: 150, // Tinggi gambar soal
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          q['question_image'], 
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, err, stack) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                        ),
                      ),
                    ),

                  // 4. OPSI JAWABAN
                  ...List.generate(q['options'].length, (optIndex) {
                    final option = q['options'][optIndex];
                    bool hasOptionImage = option['image'] != null && option['image'].toString().isNotEmpty;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8), // Jarak antar opsi
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: answers[index] == optIndex ? Colors.deepPurple : Colors.grey.shade200
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: answers[index] == optIndex ? Colors.deepPurple.shade50 : Colors.white,
                      ),
                      child: RadioListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        activeColor: Colors.deepPurple,
                        title: hasOptionImage
                            ? Row(
                                children: [
                                  // Tampilkan Gambar Opsi Kecil
                                  Container(
                                    width: 60, height: 60,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.asset(
                                        option['image'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (c,e,s) => const Icon(Icons.image_not_supported, size: 20),
                                      ),
                                    ),
                                  ),
                                  // Teks Opsi
                                  Expanded(child: Text(option['text'], style: const TextStyle(fontSize: 16))),
                                ],
                              )
                            : Text(option['text'], style: const TextStyle(fontSize: 16)), // Jika tidak ada gambar, teks biasa
                        
                        value: optIndex,
                        groupValue: answers[index],
                        onChanged: (val) {
                          setState(() {
                            answers[index] = val as int;
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: answers.length == questions.length ? _submitQuiz : null,
          child: const Text("Kirim Jawaban", style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}