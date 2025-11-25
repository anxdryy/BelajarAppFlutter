import 'package:flutter/material.dart';
import '../models/leaderboard_model.dart';
import '../services/api_service.dart';

class LeaderboardScreen extends StatefulWidget {
  // Tambahkan variabel token
  final String token; 
  
  // Wajibkan token saat dipanggil
  const LeaderboardScreen({super.key, required this.token});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<LeaderboardEntry>> futureLeaderboard;

  @override
  void initState() {
    super.initState();
    // Kirim token yang didapat dari widget ke API Service
    futureLeaderboard = ApiService().fetchLeaderboard(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Papan Peringkat'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: FutureBuilder<List<LeaderboardEntry>>(
        future: futureLeaderboard,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final leaderboard = snapshot.data!;
            
            // Cari data user yang login (untuk ditampilkan paling atas)
            final currentUserEntry = leaderboard.firstWhere(
                (e) => e.isCurrentUser, 
                orElse: () => LeaderboardEntry(rank: 0, displayName: "Anda", weeklyXp: 0, isCurrentUser: true));

            return Column(
              children: [
                // Widget Spesial: Peringkat Saya
                if (currentUserEntry.rank != 0) 
                  _buildCurrentUserRank(currentUserEntry),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text('Top Global', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                      const SizedBox(height: 10),
                      
                      // Mapping List
                      ...leaderboard.map((entry) {
                        return Card(
                          elevation: entry.isCurrentUser ? 4 : 1,
                          color: entry.isCurrentUser ? Colors.yellow.shade50 : Colors.white,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _getRankColor(entry.rank), // Warna beda buat juara 1,2,3
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '#${entry.rank}', 
                                  style: TextStyle(fontWeight: FontWeight.bold, color: entry.rank <= 3 ? Colors.white : Colors.black)
                                ),
                              ),
                            ),
                            title: Text(
                              entry.displayName,
                              style: TextStyle(fontWeight: entry.isCurrentUser ? FontWeight.bold : FontWeight.normal),
                            ),
                            trailing: Text('${entry.weeklyXp} XP', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text('Belum ada data peringkat.'));
        },
      ),
    );
  }

  // Helper untuk warna piala (Juara 1 Emas, 2 Perak, 3 Perunggu)
  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber; // Emas
    if (rank == 2) return Colors.grey;  // Perak
    if (rank == 3) return Colors.brown.shade300; // Perunggu
    return Colors.grey.shade200; // Biasa
  }

  Widget _buildCurrentUserRank(LeaderboardEntry entry) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        border: Border(bottom: BorderSide(color: Colors.deepPurple.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Peringkat Anda:', style: TextStyle(fontSize: 16)),
          Row(
            children: [
              Text('#${entry.rank}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              const SizedBox(width: 10),
              Text('${entry.weeklyXp} XP', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}