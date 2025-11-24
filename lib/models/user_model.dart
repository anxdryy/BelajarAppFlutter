// lib/models/user_model.dart

class User {
  final int id;
  final String displayName;
  final String email;
  final int totalXp;
  final int streakCount;
  final String? profileImageUrl;
  final String token;

  User({
    required this.id,
    required this.displayName,
    required this.email,
    required this.totalXp,
    required this.streakCount,
    this.profileImageUrl,
    required this.token,
  });

  // Factory constructor FINAL yang sudah diperbaiki total
  factory User.fromJson(Map<String, dynamic> json, {String? token}) {
    return User(
      id: int.tryParse(json['id'].toString()) ?? 0,
      displayName: json['display_name'] ?? 'User Baru',
      email: json['email'] ?? '',
      totalXp: int.tryParse(json['total_xp'].toString()) ?? 0,
      streakCount: int.tryParse(json['streak_count'].toString()) ?? 0,
      profileImageUrl: json['profile_image_url'],
      
      // Jika token dikirim dari ApiService, gunakan itu.
      // Jika tidak, default-nya adalah string KOSONG. TIDAK ADA LAGI "dummy_token".
      token: token ?? '', 
    );
  }
}