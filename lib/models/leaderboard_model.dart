// File: lib/models/leaderboard_model.dart

class LeaderboardEntry {
  final int rank;
  final String displayName;
  final int weeklyXp;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.rank,
    required this.displayName,
    required this.weeklyXp,
    this.isCurrentUser = false,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] ?? 0,
      displayName: json['display_name'] ?? 'Anonim',
      weeklyXp: json['weekly_xp'] ?? 0,
      isCurrentUser: json['is_user'] ?? false,
    );
  }
}