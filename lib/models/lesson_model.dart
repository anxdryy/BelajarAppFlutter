class Lesson {
  final int id;
  final String title;
  final int lessonOrder;
  final int xpValue;
  bool isCompleted; 

  Lesson({
    required this.id,
    required this.title,
    required this.lessonOrder,
    required this.xpValue,
    this.isCompleted = false,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'],
      lessonOrder: int.tryParse(json['lesson_order'].toString()) ?? 0,
      xpValue: int.tryParse(json['xp_value'].toString()) ?? 10,
      isCompleted: json['is_completed'] == 1 || json['is_completed'] == true,
    );
  }
}