import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/mood_model.dart';

/// Halaman Mood Tracker — menampilkan grafik perkembangan mood dinamis dan insight.
class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  final ApiService _api = ApiService();
  List<Map<String, dynamic>> _moodHistory = [];
  bool _isLoading = true;
  int _selectedDays = 7;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final data = await _api.fetchMoodHistory(days: _selectedDays);
    if (mounted) {
      setState(() {
        _moodHistory = data;
        _isLoading = false;
      });
    }
  }

  // Menghitung statistik mood
  Map<String, dynamic> _calculateStats() {
    if (_moodHistory.isEmpty) {
      return {
        'average': 2.0,
        'averageLabel': 'Oke',
        'averageEmoji': '😊',
        'dominant': 'Tidak ada data',
        'dominantEmoji': '—',
        'total': 0
      };
    }

    double sum = 0;
    final Map<int, int> frequencies = {};

    for (var entry in _moodHistory) {
      final int idx = entry['mood_index'] ?? 2;
      sum += idx;
      frequencies[idx] = (frequencies[idx] ?? 0) + 1;
    }

    final double avg = sum / _moodHistory.length;
    final int avgRound = avg.round().clamp(0, 4);

    int dominantIdx = 2;
    int maxFreq = -1;
    frequencies.forEach((key, val) {
      if (val > maxFreq) {
        maxFreq = val;
        dominantIdx = key;
      }
    });

    final avgMood = MoodType.values[avgRound];
    final dominantMood = MoodType.values[dominantIdx];

    return {
      'average': avg,
      'averageLabel': avgMood.label,
      'averageEmoji': avgMood.emoji,
      'dominant': dominantMood.label,
      'dominantEmoji': dominantMood.emoji,
      'total': _moodHistory.length
    };
  }

  String _generateInsight(double avg) {
    if (_moodHistory.isEmpty) {
      return 'Mulai catat suasana hatimu di halaman beranda untuk melihat tren emosimu di sini.';
    }
    if (avg >= 3.0) {
      return 'Luar biasa! Suasana hatimu sangat positif akhir-akhir ini. Teruskan energi positif ini dengan berbagi kebahagiaan bersama orang-orang terdekat 💚';
    } else if (avg <= 1.5) {
      return 'Kamu tampak sedang melewati masa-masa yang menantang. Jangan ragu untuk mengambil jeda sejenak, ikuti Meditasi Pernapasan, atau ceritakan perasaanmu ke AI Teman Curhat.';
    } else {
      return 'Suasana hatimu cukup stabil dan seimbang. Menulis jurnal secara rutin dapat membantumu menemukan kebahagiaan-kebahagiaan kecil yang tak terduga.';
    }
  }

  List<FlSpot> _getChartSpots() {
    if (_moodHistory.isEmpty) return [];

    // Balik urutan agar kronologis (kiri ke kanan)
    final reversedList = _moodHistory.reversed.toList();
    final List<FlSpot> spots = [];

    for (int i = 0; i < reversedList.length; i++) {
      final double val = (reversedList[i]['mood_index'] ?? 2).toDouble();
      spots.add(FlSpot(i.toDouble(), val));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();
    final spots = _getChartSpots();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Analisis Pola Emosi'),
        backgroundColor: AppTheme.background,
        centerTitle: false,
        actions: [
          // Range Selector Dropdown
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedDays,
                dropdownColor: AppTheme.cardDark,
                style: const TextStyle(color: AppTheme.darkText, fontSize: 13, fontWeight: FontWeight.bold),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedDays = val);
                    _loadHistory();
                  }
                },
                items: const [
                  DropdownMenuItem(value: 7, child: Text('7 Hari')),
                  DropdownMenuItem(value: 30, child: Text('30 Hari')),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : RefreshIndicator(
              onRefresh: _loadHistory,
              color: AppTheme.primaryGreen,
              backgroundColor: AppTheme.cardDark,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Grafik Mood ──────────────────────────────────────────
                    Container(
                      height: 250,
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(10, 24, 20, 10),
                      decoration: AppTheme.cardDecoration(borderRadius: 24),
                      child: spots.isEmpty
                          ? const Center(
                              child: Text(
                                'Belum ada data untuk digambar 📈',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                            )
                          : LineChart(
                              LineChartData(
                                gridData: const FlGridData(show: false),
                                titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 22,
                                      interval: (spots.length / 5).clamp(1.0, 10.0),
                                      getTitlesWidget: (value, meta) {
                                        final idx = value.toInt();
                                        if (idx >= 0 && idx < _moodHistory.length) {
                                          // Ambil tanggal entri (balik urutan)
                                          final revList = _moodHistory.reversed.toList();
                                          final DateTime date = revList[idx]['timestamp'] != null
                                              ? DateTime.parse(revList[idx]['timestamp'])
                                              : DateTime.now();
                                          return Text(
                                            DateFormat('d/M').format(date),
                                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                                          );
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 34,
                                      getTitlesWidget: (value, meta) {
                                        final int val = value.toInt();
                                        if (val >= 0 && val < MoodType.values.length) {
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 6),
                                            child: Text(
                                              MoodType.values[val].emoji,
                                              style: const TextStyle(fontSize: 16),
                                              textAlign: TextAlign.right,
                                            ),
                                          );
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                minX: 0,
                                maxX: (spots.length - 1).toDouble(),
                                minY: 0,
                                maxY: 4,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: spots,
                                    isCurved: true,
                                    preventCurveOverShooting: true,
                                    barWidth: 4,
                                    color: AppTheme.primaryGreen,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter: (spot, percent, barData, index) =>
                                          FlDotCirclePainter(
                                        radius: 4,
                                        color: Colors.white,
                                        strokeWidth: 2,
                                        strokeColor: AppTheme.primaryGreen,
                                      ),
                                    ),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          AppTheme.primaryGreen.withValues(alpha: 0.3),
                                          AppTheme.primaryGreen.withValues(alpha: 0.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),

                    const SizedBox(height: 24),

                    // ── Ringkasan Statistik ─────────────────────────────────
                    const Text(
                      'Statistik Mood',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Rata-rata',
                            stats['averageLabel'],
                            stats['averageEmoji'],
                            AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildStatCard(
                            'Sering Muncul',
                            stats['dominant'],
                            stats['dominantEmoji'],
                            AppTheme.accentPurple,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Mental Health Insights ──────────────────────────────
                    const Text(
                      'Rekomendasi & Insight',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: AppTheme.cardDecoration(borderRadius: 22),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 26)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Personalized Insight',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _generateInsight(stats['average'] as double),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.darkText,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, String emoji, Color accent) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration(borderRadius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
