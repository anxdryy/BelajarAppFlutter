class LeaderboardEntry {
  final int rank;
  final String displayName;
  final int weeklyXp;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.rank,
    required this.displayName,
    required this.weeklyXp,
    required this.isCurrentUser,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: int.parse(json['rank'].toString()),
      displayName: json['display_name'] ?? 'User',
      weeklyXp: int.parse(json['weekly_xp'].toString()),
      isCurrentUser: json['is_current_user'] ?? false,
    );
  }
}