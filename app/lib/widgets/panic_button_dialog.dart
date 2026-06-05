import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

/// Crisis Hub Darurat yang muncul saat tombol SOS ditekan.
/// Memiliki 3 aksi nyata: Panggil Bantuan (119 ext 8), Chat Darurat, dan Pernapasan.
class PanicButtonDialog extends StatelessWidget {
  final VoidCallback onNavigateToCurhat;

  const PanicButtonDialog({super.key, required this.onNavigateToCurhat});

  /// Menampilkan dialog dengan efek masuk dari bawah.
  static Future<void> show(BuildContext context, VoidCallback onNavigateToCurhat) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PanicButtonDialog(onNavigateToCurhat: onNavigateToCurhat),
    );
  }

  Future<void> _launchDialer() async {
    final Uri url = Uri.parse('tel:119'); // 119 ekstensi 8 (Layanan SEJIWA)
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _openEmergencyChat(BuildContext context) {
    // Navigasi ke halaman curhat dengan tab index switch
    Navigator.pop(context);
    onNavigateToCurhat();
    
    // Beri tahu user bahwa ini membuka chat darurat. 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Silakan ceritakan apa yang mengganggumu. AI Companion siaga untukmu.'),
        backgroundColor: AppTheme.primaryGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startBreathing(BuildContext context) {
    Navigator.pop(context);
    _BreathingExerciseDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppTheme.dividerColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(Icons.warning_rounded, color: Color(0xFFE05757), size: 48),
            const SizedBox(height: 16),
            const Text(
              'Butuh Bantuan Segera?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.darkText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Kamu tidak sendirian. Pilih salah satu opsi di bawah ini untuk mendapatkan bantuan.',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Opsi 1: Pernapasan (Relaksasi - FITUR UTAMA)
            _EmergencyOptionCard(
              icon: Icons.air_rounded,
              title: 'Tenangkan Diri (Latihan Napas)',
              subtitle: 'Mulai pernapasan 4-7-8 untuk segera meredakan kepanikan.',
              color: AppTheme.primaryGreen,
              onTap: () => _startBreathing(context),
            ),
            const SizedBox(height: 14),

            // Opsi 2: Panggil Bantuan Profesional
            _EmergencyOptionCard(
              icon: Icons.phone_in_talk_rounded,
              title: 'Hubungi Layanan Darurat',
              subtitle: 'Panggilan darurat ke Hotline SEJIWA (119 ext 8).',
              color: const Color(0xFFE05757),
              onTap: _launchDialer,
            ),
            const SizedBox(height: 14),

            // Opsi 3: Chat AI Darurat
            _EmergencyOptionCard(
              icon: Icons.chat_bubble_rounded,
              title: 'Chat AI Pendamping',
              subtitle: 'Ceritakan apa yang mengganggumu sekarang juga.',
              color: AppTheme.accentBlue,
              onTap: () => _openEmergencyChat(context),
            ),

            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _EmergencyOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}


// ════════════════════════════════════════════════════════════════════════════
// Animasi Latihan Pernapasan (Fitur Lama yang Dipertahankan)
// ════════════════════════════════════════════════════════════════════════════

class _BreathingExerciseDialog extends StatefulWidget {
  const _BreathingExerciseDialog();

  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (ctx, _, __) => const _BreathingExerciseDialog(),
      transitionBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.88, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<_BreathingExerciseDialog> createState() => _BreathingExerciseDialogState();
}

class _BreathingExerciseDialogState extends State<_BreathingExerciseDialog> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _circleScale; 
  late final Animation<Color?> _circleColor;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 19));

    _circleScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 4.0),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 7.0),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5).chain(CurveTween(curve: Curves.easeInOut)), weight: 8.0),
    ]).animate(_controller);

    _circleColor = TweenSequence<Color?>([
      TweenSequenceItem(tween: ColorTween(begin: AppTheme.primaryGreen.withValues(alpha: 0.25), end: AppTheme.primaryGreen.withValues(alpha: 0.45)), weight: 4.0),
      TweenSequenceItem(tween: ConstantTween(AppTheme.primaryGreen.withValues(alpha: 0.45)), weight: 7.0),
      TweenSequenceItem(tween: ColorTween(begin: const Color(0xFF4A90D9).withValues(alpha: 0.35), end: const Color(0xFF4A90D9).withValues(alpha: 0.15)), weight: 8.0),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _closeDialog() {
    _controller.stop();
    Navigator.of(context).pop();
  }

  String get _phaseLabel {
    final v = _controller.value;
    if (v < 4.0 / 19.0) return 'Tarik Napas';
    if (v < 11.0 / 19.0) return 'Tahan';
    return 'Hembuskan';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1F28),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: _closeDialog,
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tenangkan Diri 🌿', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('Latihan pernapasan 4 – 7 – 8', style: TextStyle(color: Colors.white54, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 2),
              Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) {
                    final size = 200.0 * _circleScale.value;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(width: size + 40, height: size + 40, decoration: BoxDecoration(shape: BoxShape.circle, color: (_circleColor.value ?? Colors.transparent).withValues(alpha: 0.2))),
                        Container(
                          width: size, height: size,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: _circleColor.value, border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.6), width: 2)),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_isRunning ? '😮‍💨' : '🌿', style: const TextStyle(fontSize: 36)),
                                if (_isRunning) ...[
                                  const SizedBox(height: 8),
                                  Text(_phaseLabel, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const Spacer(flex: 2),
              FilledButton(
                onPressed: () {
                  setState(() => _isRunning = !_isRunning);
                  if (_isRunning) _controller.repeat(); else _controller.stop();
                },
                style: FilledButton.styleFrom(backgroundColor: _isRunning ? Colors.white.withValues(alpha: 0.15) : AppTheme.primaryGreen, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                child: Text(_isRunning ? 'Jeda Latihan' : 'Mulai Latihan', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
