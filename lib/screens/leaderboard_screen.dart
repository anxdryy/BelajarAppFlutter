import 'package:flutter/material.dart';
import '../models/leaderboard_model.dart';
import '../services/api_service.dart';

class LeaderboardScreen extends StatefulWidget {
  final String token;
  const LeaderboardScreen({super.key, required this.token});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<LeaderboardEntry>> futureLeaderboard;

  // --- Palet Warna ---
  final Color _primaryPurple = Color(0xFF6A5AE0);
  final Color _podiumPurpleDark = Colors.deepPurple.shade700;
  final Color _podiumPurpleLight = Colors.deepPurple.shade400;
  final Color _goldColor = const Color(0xFFFFD700);
  final Color _silverColor = const Color(0xFFC0C0C0);
  final Color _bronzeColor = const Color(0xFFCD7F32);
  // -------------------

  @override
  void initState() {
    super.initState();
    futureLeaderboard = ApiService().fetchLeaderboard(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Latar belakang bersih
      appBar: AppBar(
        title: const Text('Papan Peringkat', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: _primaryPurple,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<LeaderboardEntry>>(
        future: futureLeaderboard,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: _primaryPurple));
          } else if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final leaderboard = snapshot.data!;
            
            // 1. Pastikan data TERURUT dari XP terbesar
            leaderboard.sort((a, b) => b.weeklyXp.compareTo(a.weeklyXp));

            // 2. Pisahkan data: Top 3 untuk podium, sisanya untuk list bawah
            List<LeaderboardEntry?> topThree = [null, null, null]; // Slot untuk Juara 1, 2, 3
            List<LeaderboardEntry> remainingList = [];

            // Isi slot Top 3 jika datanya tersedia
            if (leaderboard.isNotEmpty) topThree[0] = leaderboard[0]; // Rank 1
            if (leaderboard.length > 1) topThree[1] = leaderboard[1]; // Rank 2
            if (leaderboard.length > 2) topThree[2] = leaderboard[2]; // Rank 3
            
            // Isi list sisanya (mulai index ke-3 / Rank 4)
            if (leaderboard.length > 3) {
              remainingList = leaderboard.sublist(3);
            }

            return Column(
              children: [
                // === BAGIAN VISUAL PODIUM (TOP 3) ===
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 30, 16, 0),
                  decoration: BoxDecoration(
                    color: _primaryPurple, // Latar ungu untuk area podium
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end, // Align bawah agar podium napak
                    children: [
                      // Urutan visual: Juara 2 (Kiri), Juara 1 (Tengah), Juara 3 (Kanan)
                      _buildPodiumItem(entry: topThree[1], rank: 2, height: 140), // Podium Kiri (Lebih Pendek)
                      _buildPodiumItem(entry: topThree[0], rank: 1, height: 180, showCrown: true), // Podium Tengah (Tertinggi)
                      _buildPodiumItem(entry: topThree[2], rank: 3, height: 120), // Podium Kanan (Terpendek)
                    ],
                  ),
                ),
                
                // === BAGIAN DAFTAR SISANYA (RANK 4+) ===
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: remainingList.isEmpty
                        ? Center(child: Text("Belum ada peringkat lainnya.", style: TextStyle(color: Colors.grey[600])))
                        : ListView.builder(
                            itemCount: remainingList.length,
                            itemBuilder: (context, index) {
                              // Peringkat visual dimulai dari 4
                              final entry = remainingList[index];
                              // Kita asumsikan rank di data sudah benar, kalau tidak pakai (index + 4)
                              return _buildListItem(entry);
                            },
                          ),
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

  // --- WIDGET BUILDER: PODIUM ITEM (Visual Tangga) ---
  Widget _buildPodiumItem({LeaderboardEntry? entry, required int rank, required double height, bool showCrown = false}) {
    if (entry == null) return SizedBox(width: 80, height: height); // Placeholder kosong jika data kurang

    Color trophyColor;
    if (rank == 1) trophyColor = _goldColor;
    else if (rank == 2) trophyColor = _silverColor;
    else trophyColor = _bronzeColor;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 1. Mahkota (Hanya untuk Juara 1)
        if (showCrown)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Icon(Icons.emoji_events, color: _goldColor, size: 40), // Ikon Mahkota/Piala Besar
          ),
          
        // 2. Foto Profil & Data User
        Stack(
          alignment: Alignment.topCenter,
          children: [
             Container(
              margin: const EdgeInsets.only(top: 35), // Jarak agar foto menonjol keluar podium
              width: 90,
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_podiumPurpleLight, _podiumPurpleDark] // Gradasi ungu podium
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))]
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30), // Ruang untuk foto
                  Text(entry.displayName, 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    textAlign: TextAlign.center,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: trophyColor, size: 14), // Ikon bintang/piala kecil
                      const SizedBox(width: 4),
                      Text('${entry.weeklyXp}', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            // Foto Profil Besar di atas podium
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: trophyColor, width: 3), // Border warna juara
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
              ),
              child: CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white,
                // Ganti dengan NetworkImage(entry.photoUrl) jika ada
                child: const Icon(Icons.person, size: 35, color: Colors.grey), 
              ),
            ),
          ],
        ),
        // 3. Angka Peringkat Besar di Badan Podium
        Container(
           width: 90,
           padding: const EdgeInsets.only(bottom: 10),
           decoration: BoxDecoration(color: _podiumPurpleDark), // Warna dasar podium bawah
           child: Text('$rank', 
             textAlign: TextAlign.center,
             style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 50, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
           )
        )
      ],
    );
  }

  // --- WIDGET BUILDER: LIST ITEM BIASA (Rank 4 ke bawah) ---
  Widget _buildListItem(LeaderboardEntry entry) {
    Color rankColor = entry.isCurrentUser ? _primaryPurple : Colors.grey.shade600;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: entry.isCurrentUser ? Colors.deepPurple.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: entry.isCurrentUser ? Border.all(color: _primaryPurple, width: 1) : null,
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          // Nomor Peringkat
          SizedBox(
            width: 30,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(fontWeight: FontWeight.bold, color: rankColor, fontSize: 16),
            ),
          ),
          const SizedBox(width: 10),
          // Foto Profil Kecil
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade100,
            child: Icon(Icons.person, color: Colors.grey.shade400, size: 20),
          ),
          const SizedBox(width: 15),
          // Nama
          Expanded(
            child: Text(
              entry.displayName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: entry.isCurrentUser ? _primaryPurple : Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // XP
          Text(
            '${entry.weeklyXp} XP',
            style: TextStyle(fontWeight: FontWeight.bold, color: _primaryPurple.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}