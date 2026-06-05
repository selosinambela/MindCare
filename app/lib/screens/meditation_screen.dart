import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

/// Halaman Meditasi fungsional dengan Pemilih Tipe Meditasi,
/// Timer Animasi Immersive, dan Riwayat Sesi dari Database.
class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  final ApiService _api = ApiService();
  List<Map<String, dynamic>> _history = [];
  bool _isLoadingHistory = true;

  // Tipe meditasi yang didukung
  final List<Map<String, dynamic>> _meditationTypes = [
    {
      'id': 'breathing',
      'title': 'Pernapasan Tenang',
      'emoji': '🌬️',
      'duration': 300, // 5 menit
      'desc': 'Fokus pada napas untuk menjernihkan pikiran dan menenangkan detak jantung.',
      'color': AppTheme.primaryGreen
    },
    {
      'id': 'body_scan',
      'title': 'Body Scan Relaksasi',
      'emoji': '🧘',
      'duration': 600, // 10 menit
      'desc': 'Rasakan sensasi tubuh dari kepala hingga kaki untuk melepas ketegangan otot.',
      'color': AppTheme.accentPurple
    },
    {
      'id': 'gratitude',
      'title': 'Afirmasi Rasa Syukur',
      'emoji': '💚',
      'duration': 420, // 7 menit
      'desc': 'Merenungkan hal-hal positif hari ini untuk memupuk kebahagiaan batin.',
      'color': AppTheme.accentOrange
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoadingHistory = true);
    final data = await _api.fetchMeditations();
    if (mounted) {
      setState(() {
        _history = data;
        _isLoadingHistory = false;
      });
    }
  }

  void _startSession(Map<String, dynamic> type) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => MeditationTimerScreen(
          typeId: type['id'],
          title: type['title'],
          emoji: type['emoji'],
          durationSeconds: type['duration'],
          accentColor: type['color'],
        ),
      ),
    )
        .then((completed) {
      if (completed == true) {
        _loadHistory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Meditasi Terpandu'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.darkText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Sesi Meditasi',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 14),

            // Tipe Meditasi Cards
            Column(
              children: _meditationTypes.map((type) => _buildTypeCard(type)).toList(),
            ),

            const SizedBox(height: 28),

            const Text(
              'Riwayat Meditasi Kamu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 12),

            _isLoadingHistory
                ? const Center(child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: AppTheme.primaryGreen),
                  ))
                : _history.isEmpty
                    ? _buildEmptyHistory()
                    : _buildHistoryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard(Map<String, dynamic> type) {
    final color = type['color'] as Color;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.cardDecoration(borderRadius: 22),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _startSession(type),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        type['emoji'],
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(type['duration'] / 60).round()} menit',
                          style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          type['desc'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.play_circle_fill_rounded,
                    color: color,
                    size: 32,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassDecoration(opacity: 0.04),
      child: const Column(
        children: [
          Text('🧘‍♀️', style: TextStyle(fontSize: 32)),
          SizedBox(height: 12),
          Text(
            'Belum ada riwayat meditasi',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkText),
          ),
          SizedBox(height: 4),
          Text(
            'Mulailah dengan sesi 5 menit hari ini.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _history.length > 5 ? 5 : _history.length, // Tampilkan 5 entri terakhir
      itemBuilder: (context, index) {
        final item = _history[index];
        final typeId = item['type'] ?? 'breathing';
        final duration = item['duration_seconds'] ?? 0;
        final createdAt = item['created_at'] != null ? DateTime.parse(item['created_at']) : DateTime.now();

        // Cari info tipe meditasi
        final typeInfo = _meditationTypes.firstWhere(
          (t) => t['id'] == typeId,
          orElse: () => {'title': 'Meditasi', 'emoji': '🧘', 'color': AppTheme.primaryGreen},
        );

        final dateStr = DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(createdAt);
        final minStr = '${(duration / 60).floor()}m ${duration % 60}s';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: AppTheme.glassDecoration(opacity: 0.04),
          child: ListTile(
            leading: Text(
              typeInfo['emoji'],
              style: const TextStyle(fontSize: 24),
            ),
            title: Text(
              typeInfo['title'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.darkText),
            ),
            subtitle: Text(
              dateStr,
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (typeInfo['color'] as Color).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                minStr,
                style: TextStyle(
                  fontSize: 12,
                  color: typeInfo['color'] as Color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Screen Timer Meditasi dengan panduan visual bernapas.
class MeditationTimerScreen extends StatefulWidget {
  final String typeId;
  final String title;
  final String emoji;
  final int durationSeconds;
  final Color accentColor;

  const MeditationTimerScreen({
    super.key,
    required this.typeId,
    required this.title,
    required this.emoji,
    required this.durationSeconds,
    required this.accentColor,
  });

  @override
  State<MeditationTimerScreen> createState() => _MeditationTimerScreenState();
}

class _MeditationTimerScreenState extends State<MeditationTimerScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  late int _timeLeft;
  Timer? _timer;
  bool _isRunning = true;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  // Fase latihan pernapasan
  // Tarik napas 4s, tahan 4s, hembuskan 4s
  String _breathInstruction = 'Tarik napas...';
  int _breathTick = 0;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.durationSeconds;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.5, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 4.0,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 4.0,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.5).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 4.0,
      ),
    ]).animate(_pulseController);

    _pulseController.repeat();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
          _breathTick = (_breathTick + 1) % 12;
          if (_breathTick < 4) {
            _breathInstruction = 'Tarik Napas...';
          } else if (_breathTick < 8) {
            _breathInstruction = 'Tahan...';
          } else {
            _breathInstruction = 'Hembuskan Napas...';
          }
        } else {
          _timer?.cancel();
          _finishSession();
        }
      });
    });
  }

  void _togglePause() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _startTimer();
        _pulseController.repeat();
      } else {
        _timer?.cancel();
        _pulseController.stop();
      }
    });
  }

  Future<void> _finishSession() async {
    _pulseController.stop();
    // Simpan ke database
    final success = await _api.createMeditation(widget.durationSeconds, widget.typeId, true);

    if (!mounted) return;

    if (success) {
      // Tampilkan congratulation bottom sheet / dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 50)),
              const SizedBox(height: 16),
              const Text(
                'Sesi Selesai!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Kamu telah menyelesaikan sesi ${widget.title} selama ${(widget.durationSeconds / 60).round()} menit. Pikiranmu berterima kasih padamu.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx); // Tutup dialog
                  Navigator.pop(context, true); // Kembali ke MeditationScreen dengan nilai true
                },
                child: const Text('Selesai'),
              ),
            ],
          ),
        ),
      );
    } else {
      // Jika error, langsung return
      Navigator.pop(context, true);
    }
  }

  String _formatTime(int totalSeconds) {
    final m = (totalSeconds / 60).floor();
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppTheme.darkText),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppTheme.cardDark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text('Akhiri Sesi?'),
                          content: const Text('Sesi ini tidak akan tercatat dalam riwayat jika kamu keluar sekarang.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Lanjutkan', style: TextStyle(color: AppTheme.primaryGreen)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                Navigator.pop(context, false);
                              },
                              child: const Text('Keluar', style: TextStyle(color: Colors.redAccent)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Text(
                    widget.title,
                    style: const TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 48), // Spacer
                ],
              ),

              const Spacer(),

              // Breathing guide animation
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  final size = 220.0 * _pulseAnimation.value;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: size + 50,
                        height: size + 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.accentColor.withValues(alpha: 0.08),
                        ),
                      ),
                      Container(
                        width: size + 20,
                        height: size + 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.accentColor.withValues(alpha: 0.15),
                        ),
                      ),
                      Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.accentColor.withValues(alpha: 0.3),
                          border: Border.all(color: widget.accentColor, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            widget.emoji,
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 40),

              // Timer text
              Text(
                _formatTime(_timeLeft),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 8),

              // Breathing instruction text
              Text(
                _breathInstruction,
                style: TextStyle(
                  fontSize: 16,
                  color: widget.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Spacer(),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _togglePause,
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: widget.accentColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
