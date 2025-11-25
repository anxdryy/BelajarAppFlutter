import 'lesson_model.dart'; // <--- Wajib, agar Course mengenal Lesson

class Course {
  final int id;
  final String title;
  final String? description;
  final int courseOrder;
  final List<Lesson> lessons; // Menggunakan tipe Lesson

  final Quiz? quiz;

  Course({
    required this.id,
    required this.title,
    this.description,
    required this.courseOrder,
    required this.lessons,
    this.quiz,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    var lessonsList = json['lessons'] as List? ?? [];
    List<Lesson> parsedLessons = lessonsList.map((i) => Lesson.fromJson(i)).toList();

    return Course(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'],
      courseOrder: int.tryParse(json['course_order'].toString()) ?? 0,
      lessons: parsedLessons,
      // Parsing Quiz
      quiz: json['quiz'] != null ? Quiz.fromJson(json['quiz']) : null,
    );
  }
}

class Quiz {
  final int id;
  final String title;
  final int passingScore;
  final int xpValue;
  final int userScore;
  final bool isPassed;

  Quiz({
    required this.id,
    required this.title,
    required this.passingScore,
    required this.xpValue,
    required this.userScore,
    required this.isPassed,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: int.parse(json['id'].toString()),
      title: json['title'],
      passingScore: int.parse(json['passing_score'].toString()),
      xpValue: int.parse(json['xp_value'].toString()),
      userScore: int.tryParse(json['user_score'].toString()) ?? 0,
      isPassed: json['is_passed'] ?? false,
    );
  }
}