import 'package:flutter/material.dart';
import '../models/leaderboard_model.dart';
import '../services/api_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<LeaderboardEntry>> futureLeaderboard;

  @override
  void initState() {
    super.initState();
    futureLeaderboard = ApiService().fetchLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Papan Peringkat Mingguan')),
      body: FutureBuilder<List<LeaderboardEntry>>(
        future: futureLeaderboard,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error memuat: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final leaderboard = snapshot.data!;
            
            // Mencari user saat ini untuk ditampilkan di bagian atas (seperti di video)
            final currentUserEntry = leaderboard.firstWhere(
                (e) => e.isCurrentUser, 
                orElse: () => LeaderboardEntry(rank: 0, displayName: "Anda", weeklyXp: 0));

            return ListView(
              children: [
                // Bagian Peringkat Anda
                _buildCurrentUserRank(currentUserEntry),
                
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('20 Teratas Minggu Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                
                // Daftar Leaderboard
                ...leaderboard.map((entry) {
                  return ListTile(
                    leading: Text('#${entry.rank}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    title: Text('${entry.displayName} ${entry.isCurrentUser ? '(Anda)' : ''}'),
                    trailing: Text('${entry.weeklyXp} XP', style: const TextStyle(fontWeight: FontWeight.bold)),
                    tileColor: entry.isCurrentUser ? Colors.yellow.shade100 : null,
                  );
                }).toList(),
              ],
            );
          }
          return const Center(child: Text('Tidak ada data peringkat.'));
        },
      ),
    );
  }

  Widget _buildCurrentUserRank(LeaderboardEntry entry) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Peringkat Anda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('#${entry.rank} (${entry.displayName})', style: const TextStyle(fontSize: 20, color: Colors.blue)),
                Text('${entry.weeklyXp} XP', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}