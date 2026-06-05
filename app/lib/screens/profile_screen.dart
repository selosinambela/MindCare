import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'welcome_screen.dart';
import 'exercise_screen.dart';
import 'feature_screens.dart';

/// Halaman Profile — menampilkan data pengguna, statistik aktivitas, dan opsi logout.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService _api = ApiService();
  int _streak = 0;
  int _journals = 0;
  int _meditations = 0;
  int _exercises = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final stats = await _api.fetchUserStats();
    if (mounted) {
      setState(() {
        _streak = stats['streak'] ?? 0;
        _journals = stats['journal_entries'] ?? 0;
        _meditations = stats['meditation_sessions'] ?? 0;
        _exercises = stats['exercise_sessions'] ?? 0;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar Aplikasi?'),
        content: const Text('Apakah kamu yakin ingin keluar dari akunmu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _api.clearSession();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _api.userName ?? 'User';
    final email = _api.userEmail ?? 'user@mindcare.id';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: AppTheme.background,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary),
            onPressed: _loadStats,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : RefreshIndicator(
              onRefresh: _loadStats,
              color: AppTheme.primaryGreen,
              backgroundColor: AppTheme.cardDark,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Avatar
                    const CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.transparent,
                      backgroundImage: AssetImage('assets/images/logo.jpg'),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                    ),

                    const SizedBox(height: 32),

                    // Stat cards
                    Row(
                      children: [
                        Expanded(child: _StatCard('$_streak', 'Streak', Icons.local_fire_department_rounded, AppTheme.pastelYellow)),
                        const SizedBox(width: 10),
                        Expanded(child: _StatCard('$_meditations', 'Meditasi', Icons.self_improvement_rounded, AppTheme.softGreen)),
                        const SizedBox(width: 10),
                        Expanded(child: _StatCard('$_journals', 'Jurnal', Icons.book_rounded, AppTheme.softGreen)),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Menu items
                    _MenuItem(
                      icon: Icons.directions_run_rounded,
                      label: 'Total Olahraga: $_exercises Sesi',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExerciseScreen())),
                    ),
                    _MenuItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notifikasi & Pengingat',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
                    ),
                    _MenuItem(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Privasi & Keamanan',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyScreen())),
                    ),
                    _MenuItem(
                      icon: Icons.help_outline_rounded,
                      label: 'Bantuan & FAQ',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen())),
                    ),

                    const SizedBox(height: 32),

                    OutlinedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                      label: const Text(
                        'Keluar dari Akun',
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent, width: 1.5),
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color? bgColor;
  const _StatCard(this.value, this.label, this.icon, this.bgColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: AppTheme.cardDecoration(borderRadius: 20, color: bgColor),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryGreen, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.glassDecoration(opacity: 0.04, borderRadius: 18),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryGreen),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.darkText, fontSize: 14)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
