import 'lesson_model.dart'; // <--- Wajib, agar Course mengenal Lesson

class Course {
  final int id;
  final String title;
  final String? description;
  final int courseOrder;
  final List<Lesson> lessons; // Menggunakan tipe Lesson

  Course({
    required this.id,
    required this.title,
    this.description,
    required this.courseOrder,
    required this.lessons,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    var lessonsList = json['lessons'] as List? ?? [];
    List<Lesson> parsedLessons = lessonsList.map((i) => Lesson.fromJson(i)).toList();

    return Course(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'],
      description: json['description'],
      courseOrder: int.tryParse(json['course_order'].toString()) ?? 0,
      lessons: parsedLessons,
    );
  }
}