import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

/// Screen dummy generik yang dipakai sebagai placeholder untuk
/// setiap fitur yang belum diimplementasi penuh.
///
/// Menerima [title], [icon], dan [description] sehingga bisa dipakai ulang
/// tanpa perlu membuat class baru untuk setiap fitur.
class FeatureScreen extends StatelessWidget {
  final String title;
  final String icon;
  final String description;
  final Color? accentColor;

  const FeatureScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppTheme.primaryGreen;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: AppTheme.darkText,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Kembali',
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppTheme.darkText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ikon fitur
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                description,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Badge "Coming Soon"
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '🚧  Fitur dalam pengembangan',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Tombol kembali yang sangat mudah dijangkau
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Kembali ke Beranda'),
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shortcut factories untuk setiap fitur ──────────────────────────────────
// Ini memungkinkan kita melakukan push dengan satu baris:
//   Navigator.push(context, MaterialPageRoute(builder: (_) => MeditasiScreen()))

class MeditasiScreen extends StatelessWidget {
  const MeditasiScreen({super.key});

  @override
  Widget build(BuildContext context) => const FeatureScreen(
        title: 'Meditasi',
        icon: '🧘',
        description:
            'Sesi relaksasi terpandu 5 menit untuk menenangkan pikiran dan '
            'mengurangi kecemasan. Tersedia panduan audio dan visual.',
        accentColor: Color(0xFF7BAE7F),
      );
}

class OlahragaScreen extends StatelessWidget {
  const OlahragaScreen({super.key});

  @override
  Widget build(BuildContext context) => const FeatureScreen(
        title: 'Olahraga',
        icon: '🏃',
        description:
            'Tracking aktivitas fisik harian. Gerak tubuh terbukti secara '
            'ilmiah dapat meningkatkan mood dan mengurangi stres.',
        accentColor: Color(0xFF4A90D9),
      );
}

class JurnalFeatureScreen extends StatelessWidget {
  const JurnalFeatureScreen({super.key});

  @override
  Widget build(BuildContext context) => const FeatureScreen(
        title: 'Journal',
        icon: '📖',
        description:
            'Tulis rasa syukur dan refleksi harian. Journaling membantu '
            'memproses emosi dan membangun pola pikir positif.',
        accentColor: Color(0xFFE8A84C),
      );
}

class PolaEmosiScreen extends StatelessWidget {
  const PolaEmosiScreen({super.key});

  @override
  Widget build(BuildContext context) => const FeatureScreen(
        title: 'Pola Emosi',
        icon: '📊',
        description:
            'Visualisasi grafik mood mingguan. Kenali pola emosi kamu dan '
            'temukan trigger stres lebih awal.',
        accentColor: Color(0xFF9B8EC4),
      );
}

class AICurhatScreen extends StatelessWidget {
  const AICurhatScreen({super.key});

  @override
  Widget build(BuildContext context) => const FeatureScreen(
        title: 'AI Teman Curhat',
        icon: '🟢',
        description:
            'Ceritakan hari kamu kepada AI companion yang selalu siap '
            'mendengarkan tanpa menghakimi, 24 jam sehari.',
        accentColor: Color(0xFF7BAE7F),
      );
}

// ── FULL SCREENS UNTUK FITUR PROFIL (TERINTEGRASI DATABASE) ────────────────

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> _notifs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifs();
  }

  Future<void> _loadNotifs() async {
    final data = await ApiService().fetchNotifications();
    setState(() {
      _notifs = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi & Pengingat')),
      backgroundColor: AppTheme.background,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifs.isEmpty
              ? const Center(child: Text('Belum ada notifikasi.', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: _notifs.length,
                  itemBuilder: (context, index) {
                    final n = _notifs[index];
                    final isRead = n['is_read'] == 1;
                    return ListTile(
                      leading: Icon(Icons.notifications_active, color: isRead ? Colors.grey : AppTheme.primaryGreen),
                      title: Text(n['title'], style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
                      subtitle: Text(n['body']),
                      onTap: () async {
                        if (!isRead) {
                          await ApiService().markNotificationRead(n['id']);
                          _loadNotifs();
                        }
                      },
                    );
                  },
                ),
    );
  }
}

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _allowNotif = true;
  bool _isPrivate = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final s = await ApiService().fetchSettings();
    if (s.isNotEmpty && mounted) {
      setState(() {
        _allowNotif = s['allow_notifications'] == 1;
        _isPrivate = s['is_private_account'] == 1;
        _loading = false;
      });
    }
  }

  Future<void> _save(bool allowN, bool isPriv) async {
    setState(() {
      _allowNotif = allowN;
      _isPrivate = isPriv;
    });
    await ApiService().updateSettings(allowN, isPriv);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privasi & Keamanan')),
      backgroundColor: AppTheme.background,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SwitchListTile(
                  title: const Text('Izinkan Notifikasi Push'),
                  subtitle: const Text('Terima pengingat harian dan notifikasi sistem.'),
                  activeColor: AppTheme.primaryGreen,
                  value: _allowNotif,
                  onChanged: (val) => _save(val, _isPrivate),
                ),
                SwitchListTile(
                  title: const Text('Akun Privat'),
                  subtitle: const Text('Data aktivitasmu hanya bisa dilihat olehmu.'),
                  activeColor: AppTheme.primaryGreen,
                  value: _isPrivate,
                  onChanged: (val) => _save(_allowNotif, val),
                ),
              ],
            ),
    );
  }
}

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  List<Map<String, dynamic>> _faqs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ApiService().fetchFaqs();
    setState(() {
      _faqs = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pusat Bantuan (FAQ)')),
      backgroundColor: AppTheme.background,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _faqs.isEmpty
              ? const Center(child: Text('FAQ kosong.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _faqs.length,
                  itemBuilder: (context, index) {
                    final f = _faqs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ExpansionTile(
                        title: Text(f['question'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(f['answer'], style: const TextStyle(height: 1.5)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
