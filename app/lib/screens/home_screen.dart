import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/mood_tracker_widget.dart';
import '../widgets/feature_card.dart';
import 'meditation_screen.dart';
import 'journal_screen.dart';
import 'exercise_screen.dart';
import 'graph_screen.dart';

/// Halaman utama aplikasi MindCare.
class HomePage extends StatefulWidget {
  final VoidCallback? onNavigateToCurhat;

  const HomePage({super.key, this.onNavigateToCurhat});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _api = ApiService();
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    final stats = await _api.fetchUserStats();
    if (mounted) {
      setState(() {
        _streak = stats['streak'] ?? 0;
      });
    }
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    ).then((_) {
      // Reload stats when returning to Home
      _loadUserStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadUserStats,
        color: AppTheme.primaryGreen,
        backgroundColor: AppTheme.cardDark,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────
              _buildHeader(),

              const SizedBox(height: 28),

              // ── Mood Tracker (stateful, business logic di controller) ─────
              const MoodTrackerWidget(),

              const SizedBox(height: 20),

              // ── Streak ──────────────────────────────────────────────────
              _buildStreakCard(),

              const SizedBox(height: 22),

              // ── Feature Grid (4 card, masing-masing navigable) ───────────
              _buildFeatureGrid(context),

              const SizedBox(height: 24),

              // ── Banner AI Curhat (tappable) ──────────────────────────────
              _buildAICurhatBanner(context),

              const SizedBox(height: 22),

              // ── Reminder cards ───────────────────────────────────────────
              _buildReminderRow(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Private builders ────────────────────────────────────────────────────

  Widget _buildHeader() {
    final name = _api.userName ?? 'User';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    final hour = DateTime.now().hour;
    String greeting = 'Selamat malam 🌙';
    if (hour >= 5 && hour < 12) {
      greeting = 'Selamat pagi 🍃';
    } else if (hour >= 12 && hour < 17) {
      greeting = 'Selamat siang ☀️';
    } else if (hour >= 17 && hour < 20) {
      greeting = 'Selamat sore 🌇';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Halo, $name!',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
          ],
        ),
        const CircleAvatar(
          radius: 26,
          backgroundColor: Colors.transparent,
          backgroundImage: AssetImage('assets/images/logo.jpg'),
        ),
      ],
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: AppTheme.cardDecoration(borderRadius: 24, color: AppTheme.pastelYellow),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: AppTheme.accentOrange,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$_streak',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentOrange,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Hari Berturut-turut',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Pertahankan streak check-in mood harianmu!',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    final features = [
      (
        icon: Icons.self_improvement_rounded,
        title: 'Meditasi',
        subtitle: 'Sesi relaksasi 5 menit',
        bgColor: AppTheme.softGreen,
        screen: const MeditationScreen(),
      ),
      (
        icon: Icons.book_rounded,
        title: 'Journal',
        subtitle: 'Tulis rasa syukur',
        bgColor: AppTheme.softGreen,
        screen: const JournalPage(),
      ),
      (
        icon: Icons.directions_run_rounded,
        title: 'Olahraga',
        subtitle: 'Tracking aktivitas',
        bgColor: AppTheme.softGreen,
        screen: const ExerciseScreen(),
      ),
      (
        icon: Icons.bar_chart_rounded,
        title: 'Pola Emosi',
        subtitle: 'Grafik mood mingguan',
        bgColor: AppTheme.softGreen,
        screen: const GraphPage(),
      ),
    ];

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.95,
      children: features
          .map(
            (f) => FeatureCard(
              icon: f.icon,
              title: f.title,
              subtitle: f.subtitle,
              bgColor: f.bgColor,
              onTap: () => _navigateTo(context, f.screen),
            ),
          )
          .toList(),
    );
  }

  Widget _buildAICurhatBanner(BuildContext context) {
    final name = _api.userName ?? 'Kamu';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onNavigateToCurhat,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardDecoration(borderRadius: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI Teman Curhat',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryGreen),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: AppTheme.glassDecoration(borderRadius: 20, opacity: 0.05),
                child: Text(
                  'Hai $name.\nAku di sini kalau kamu mau cerita apapun hari ini.',
                  style: const TextStyle(fontSize: 14, color: AppTheme.darkText, height: 1.5),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: AppTheme.glassDecoration(borderRadius: 20, opacity: 0.08),
                      child: const Text(
                        'Cerita sesuatu...',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primaryGreen,
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF003300),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderRow() {
    return Row(
      children: [
        Expanded(child: _ReminderCard('💧', 'Minum Air', 'Setiap 2 jam')),
        const SizedBox(width: 14),
        Expanded(child: _ReminderCard('🌙', 'Tidur Malam', '22:30 WIB')),
      ],
    );
  }
}

// ─── Sub-widget Reminder Card ────────────────────────────────────────────────

class _ReminderCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const _ReminderCard(this.emoji, this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.glassDecoration(borderRadius: 24, opacity: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
