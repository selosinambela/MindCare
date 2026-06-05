import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
// DATA: Guided Workout definitions
// ═══════════════════════════════════════════════════════════════════════════

class WorkoutStep {
  final String name;
  final String instruction;
  final int durationSeconds;

  const WorkoutStep({
    required this.name,
    required this.instruction,
    required this.durationSeconds,
  });
}

class GuidedWorkout {
  final String id;
  final String emoji;
  final String title;
  final String subtitle;
  final Color accentColor;
  final List<WorkoutStep> steps;
  final String exerciseType; // untuk disimpan ke DB

  const GuidedWorkout({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.steps,
    required this.exerciseType,
  });

  int get totalDurationSeconds =>
      steps.fold(0, (sum, s) => sum + s.durationSeconds);

  String get totalDurationFormatted {
    final m = totalDurationSeconds ~/ 60;
    final s = totalDurationSeconds % 60;
    return s > 0 ? '$m menit $s detik' : '$m menit';
  }
}

final List<GuidedWorkout> _guidedWorkouts = [
  GuidedWorkout(
    id: 'breathing',
    emoji: '🌬️',
    title: 'Latihan Pernapasan',
    subtitle: 'Teknik 4-7-8 untuk menenangkan pikiran',
    accentColor: const Color(0xFF7BAED9),
    exerciseType: 'Pernapasan',
    steps: [
      const WorkoutStep(name: 'Persiapan', instruction: 'Duduk nyaman, tutup mata, dan rilekskan bahu. Fokuskan perhatianmu pada napas.', durationSeconds: 5),
      const WorkoutStep(name: 'Tarik Napas', instruction: 'Tarik napas perlahan melalui hidung selama 4 detik...', durationSeconds: 4),
      const WorkoutStep(name: 'Tahan Napas', instruction: 'Tahan napas selama 7 detik. Rasakan ketenangan...', durationSeconds: 7),
      const WorkoutStep(name: 'Buang Napas', instruction: 'Buang napas perlahan melalui mulut selama 8 detik...', durationSeconds: 8),
      const WorkoutStep(name: 'Tarik Napas', instruction: 'Ulangi — tarik napas perlahan melalui hidung...', durationSeconds: 4),
      const WorkoutStep(name: 'Tahan Napas', instruction: 'Tahan napas... rasakan ketenangan mengisi tubuhmu...', durationSeconds: 7),
      const WorkoutStep(name: 'Buang Napas', instruction: 'Buang napas perlahan... lepaskan semua ketegangan...', durationSeconds: 8),
      const WorkoutStep(name: 'Tarik Napas', instruction: 'Siklus terakhir — tarik napas dalam-dalam...', durationSeconds: 4),
      const WorkoutStep(name: 'Tahan Napas', instruction: 'Tahan... kamu sudah sangat hebat melakukan ini...', durationSeconds: 7),
      const WorkoutStep(name: 'Buang Napas', instruction: 'Buang napas perlahan... rileks...', durationSeconds: 8),
      const WorkoutStep(name: 'Selesai ✨', instruction: 'Bagus sekali! Buka matamu perlahan. Rasakan betapa lebih tenangnya dirimu sekarang.', durationSeconds: 5),
    ],
  ),
  GuidedWorkout(
    id: 'stretch',
    emoji: '🧘',
    title: 'Peregangan Ringan',
    subtitle: 'Lepas ketegangan otot dalam 5 menit',
    accentColor: const Color(0xFF9E8EC4),
    exerciseType: 'Peregangan',
    steps: [
      const WorkoutStep(name: 'Peregangan Leher', instruction: 'Miringkan kepala ke kanan, tahan. Rasakan tarikan di sisi kiri leher.', durationSeconds: 15),
      const WorkoutStep(name: 'Peregangan Leher', instruction: 'Miringkan kepala ke kiri, tahan. Rasakan tarikan di sisi kanan leher.', durationSeconds: 15),
      const WorkoutStep(name: 'Rotasi Bahu', instruction: 'Putar kedua bahu ke depan dengan gerakan melingkar perlahan.', durationSeconds: 15),
      const WorkoutStep(name: 'Rotasi Bahu', instruction: 'Sekarang putar kedua bahu ke belakang. Lepaskan ketegangan.', durationSeconds: 15),
      const WorkoutStep(name: 'Peregangan Dada', instruction: 'Kaitkan kedua tangan di belakang punggung, tarik ke bawah dan buka dada lebar-lebar.', durationSeconds: 20),
      const WorkoutStep(name: 'Twist Badan', instruction: 'Duduk tegak, putar badan ke kanan. Tangan kiri di lutut kanan. Tahan.', durationSeconds: 15),
      const WorkoutStep(name: 'Twist Badan', instruction: 'Putar badan ke kiri. Tangan kanan di lutut kiri. Tahan.', durationSeconds: 15),
      const WorkoutStep(name: 'Peregangan Tangan', instruction: 'Luruskan tangan kanan ke depan, tarik jari-jari ke arah tubuh dengan tangan kiri.', durationSeconds: 15),
      const WorkoutStep(name: 'Peregangan Tangan', instruction: 'Ganti — luruskan tangan kiri, tarik jari dengan tangan kanan.', durationSeconds: 15),
      const WorkoutStep(name: 'Relaksasi', instruction: 'Tutup mata, tarik napas dalam, dan rasakan tubuhmu yang lebih ringan. Kerja bagus! 💪', durationSeconds: 10),
    ],
  ),
  GuidedWorkout(
    id: 'walking',
    emoji: '🚶',
    title: 'Jalan Santai Mindful',
    subtitle: 'Jalan kaki 5 menit dengan kesadaran penuh',
    accentColor: const Color(0xFF4C8C6C),
    exerciseType: 'Jalan Kaki',
    steps: [
      const WorkoutStep(name: 'Mulai Berjalan', instruction: 'Mulailah berjalan perlahan. Perhatikan setiap langkah kakimu menyentuh lantai.', durationSeconds: 30),
      const WorkoutStep(name: 'Fokus Kaki', instruction: 'Rasakan telapak kakimu — tumit, telapak, jari kaki. Satu langkah demi satu langkah.', durationSeconds: 30),
      const WorkoutStep(name: 'Perhatikan Napas', instruction: 'Sambil berjalan, sadari napasmu. Tarik napas 3 langkah, buang napas 3 langkah.', durationSeconds: 45),
      const WorkoutStep(name: 'Lihat Sekitar', instruction: 'Perhatikan 3 hal yang kamu lihat saat ini. Warna, bentuk, cahaya...', durationSeconds: 30),
      const WorkoutStep(name: 'Dengarkan', instruction: 'Dengarkan 2 suara di sekitarmu. Tanpa menilai, hanya mendengar.', durationSeconds: 30),
      const WorkoutStep(name: 'Rasakan', instruction: 'Rasakan udara menyentuh kulitmu. Suhu, hembusan angin, kelembapan.', durationSeconds: 30),
      const WorkoutStep(name: 'Percepat Langkah', instruction: 'Sedikit percepat langkahmu. Rasakan energi mengalir ke seluruh tubuh.', durationSeconds: 45),
      const WorkoutStep(name: 'Perlambat', instruction: 'Perlambat kembali. Tarik napas dalam-dalam sambil berjalan.', durationSeconds: 30),
      const WorkoutStep(name: 'Berhenti', instruction: 'Berhenti perlahan. Berdiri tegak, pejamkan mata. Rasakan ketenangan. 🌿', durationSeconds: 10),
    ],
  ),
  GuidedWorkout(
    id: 'cardio',
    emoji: '🏃',
    title: 'Cardio Ringan',
    subtitle: 'Gerakan sederhana untuk naikkan mood',
    accentColor: const Color(0xFFE8A864),
    exerciseType: 'Cardio Ringan',
    steps: [
      const WorkoutStep(name: 'Pemanasan', instruction: 'Jalan di tempat dengan santai. Ayunkan tangan secara alami.', durationSeconds: 20),
      const WorkoutStep(name: 'Jumping Jacks', instruction: 'Lompat sambil buka tangan dan kaki ke samping. Kembali ke posisi awal. Ulangi!', durationSeconds: 25),
      const WorkoutStep(name: 'Istirahat', instruction: 'Jalan di tempat perlahan. Atur napas. 💨', durationSeconds: 10),
      const WorkoutStep(name: 'High Knees', instruction: 'Angkat lutut bergantian setinggi mungkin. Seperti lari di tempat dengan lutut tinggi!', durationSeconds: 25),
      const WorkoutStep(name: 'Istirahat', instruction: 'Bernapas... tarik napas dalam, buang perlahan.', durationSeconds: 10),
      const WorkoutStep(name: 'Squat Ringan', instruction: 'Berdiri selebar bahu, turunkan badan seperti duduk di kursi. Naik kembali. Ulangi!', durationSeconds: 25),
      const WorkoutStep(name: 'Istirahat', instruction: 'Istirahat sejenak. Kamu melakukannya dengan luar biasa! 🔥', durationSeconds: 10),
      const WorkoutStep(name: 'Jumping Jacks', instruction: 'Ronde terakhir jumping jacks! Kerahkan semangatmu!', durationSeconds: 25),
      const WorkoutStep(name: 'Pendinginan', instruction: 'Jalan di tempat perlahan... tarik napas... rilekskan otot-otot. Selesai! 🎉', durationSeconds: 20),
    ],
  ),
];

// ═══════════════════════════════════════════════════════════════════════════
// MAIN SCREEN: Wellness Workout Hub
// ═══════════════════════════════════════════════════════════════════════════

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  final ApiService _api = ApiService();
  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = true;

  int _totalSessions = 0;
  int _totalMinutes = 0;
  int _totalCalories = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final logsData = await _api.fetchExercises();
    final statsData = await _api.fetchExerciseStats();

    if (mounted) {
      setState(() {
        _logs = logsData;
        _totalSessions = int.tryParse(statsData['total_sessions']?.toString() ?? '0') ?? 0;
        _totalMinutes = int.tryParse(statsData['total_minutes']?.toString() ?? '0') ?? 0;
        _totalCalories = int.tryParse(statsData['total_calories']?.toString() ?? '0') ?? 0;
        _isLoading = false;
      });
    }
  }

  void _openWorkoutPlayer(GuidedWorkout workout) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _WorkoutPlayerScreen(workout: workout)),
    ).then((_) => _loadData());
  }

  void _openManualLog() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _ManualLogScreen()),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Wellness Workout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.darkText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppTheme.primaryGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Weekly Stats ──────────────────────────────────────
                    const Text('Ringkasan 7 Hari',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _StatCard(label: 'Sesi', value: '$_totalSessions', unit: 'aktivitas', color: AppTheme.accentBlue)),
                        const SizedBox(width: 10),
                        Expanded(child: _StatCard(label: 'Durasi', value: '$_totalMinutes', unit: 'menit', color: AppTheme.primaryGreen)),
                        const SizedBox(width: 10),
                        Expanded(child: _StatCard(label: 'Kalori', value: '$_totalCalories', unit: 'kkal', color: AppTheme.accentPink)),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Guided Workouts Grid ─────────────────────────────
                    const Text('Pilih Aktivitas',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
                    const SizedBox(height: 6),
                    const Text('Gerakan ringan yang terbukti membantu kesehatan mental',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    const SizedBox(height: 14),

                    GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.88,
                      children: _guidedWorkouts.map((w) => _WorkoutCard(
                        workout: w,
                        onTap: () => _openWorkoutPlayer(w),
                      )).toList(),
                    ),

                    const SizedBox(height: 12),

                    // ── Manual Log Button ────────────────────────────────
                    Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: _openManualLog,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: AppTheme.cardDecoration(borderRadius: 20),
                          child: const Row(
                            children: [
                              Text('📝', style: TextStyle(fontSize: 24)),
                              SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Catat Manual',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.darkText)),
                                    SizedBox(height: 2),
                                    Text('Catat aktivitas olahraga lainnya secara manual',
                                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Activity History ──────────────────────────────────
                    const Text('Riwayat Aktivitas',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
                    const SizedBox(height: 12),
                    _logs.isEmpty ? _buildEmptyLogs() : _buildLogsList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyLogs() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: AppTheme.glassDecoration(opacity: 0.04),
      child: const Column(
        children: [
          Text('🏃', style: TextStyle(fontSize: 32)),
          SizedBox(height: 12),
          Text('Belum ada catatan aktivitas', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkText)),
          SizedBox(height: 4),
          Text('Yuk, mulai gerakkan tubuhmu hari ini!', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLogsList() {
    final displayLogs = _logs.length > 10 ? _logs.sublist(0, 10) : _logs;
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: displayLogs.length,
      itemBuilder: (context, index) {
        final item = displayLogs[index];
        final String type = item['exercise_type'] ?? 'Lainnya';
        final int duration = item['duration_minutes'] ?? 0;
        final int calories = item['calories'] ?? 0;
        final String? note = item['note'];
        final DateTime createdAt = item['created_at'] != null ? DateTime.parse(item['created_at']) : DateTime.now();

        String emoji = '💪';
        for (final w in _guidedWorkouts) {
          if (w.exerciseType == type) { emoji = w.emoji; break; }
        }
        if (type == 'Jalan Kaki') emoji = '🚶';
        if (type == 'Lari') emoji = '🏃';
        if (type == 'Yoga') emoji = '🧘';
        if (type == 'Bersepeda') emoji = '🚴';

        final dateStr = DateFormat('d MMM yyyy', 'id_ID').format(createdAt);
        final timeStr = DateFormat('HH:mm').format(createdAt);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: AppTheme.glassDecoration(opacity: 0.04),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.softGreen,
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(type, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.darkText)),
                Text('$duration m', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryGreen)),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$dateStr • $timeStr', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    Text('$calories kkal', style: const TextStyle(fontSize: 11, color: AppTheme.accentPink, fontWeight: FontWeight.bold)),
                  ],
                ),
                if (note != null && note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('"$note"', style: const TextStyle(fontSize: 11, color: AppTheme.darkText, fontStyle: FontStyle.italic)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SUB-WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final String label, value, unit;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: AppTheme.cardDecoration(borderRadius: 18),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(unit, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final GuidedWorkout workout;
  final VoidCallback onTap;
  const _WorkoutCard({required this.workout, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        splashColor: workout.accentColor.withValues(alpha: 0.12),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: AppTheme.cardDecoration(borderRadius: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: workout.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(workout.emoji, style: const TextStyle(fontSize: 24)),
              ),
              const Spacer(),
              Text(workout.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
              const SizedBox(height: 4),
              Text(workout.subtitle,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 13, color: workout.accentColor),
                  const SizedBox(width: 4),
                  Text(workout.totalDurationFormatted,
                      style: TextStyle(fontSize: 11, color: workout.accentColor, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WORKOUT PLAYER SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class _WorkoutPlayerScreen extends StatefulWidget {
  final GuidedWorkout workout;
  const _WorkoutPlayerScreen({required this.workout});

  @override
  State<_WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends State<_WorkoutPlayerScreen> with TickerProviderStateMixin {
  int _currentStepIndex = 0;
  int _secondsRemaining = 0;
  Timer? _timer;
  bool _isRunning = false;
  bool _isCompleted = false;
  bool _isSaving = false;

  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.workout.steps[0].durationSeconds;
    _progressController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  WorkoutStep get _currentStep => widget.workout.steps[_currentStepIndex];

  double get _stepProgress {
    final total = _currentStep.durationSeconds;
    if (total == 0) return 1.0;
    return 1.0 - (_secondsRemaining / total);
  }

  double get _overallProgress {
    final totalSteps = widget.workout.steps.length;
    return (_currentStepIndex + _stepProgress) / totalSteps;
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
      } else {
        _nextStep();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _nextStep() {
    _timer?.cancel();
    if (_currentStepIndex < widget.workout.steps.length - 1) {
      setState(() {
        _currentStepIndex++;
        _secondsRemaining = widget.workout.steps[_currentStepIndex].durationSeconds;
        _isRunning = true;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_secondsRemaining > 1) {
          setState(() => _secondsRemaining--);
        } else {
          _nextStep();
        }
      });
    } else {
      // Workout selesai
      setState(() {
        _isRunning = false;
        _isCompleted = true;
      });
      _saveWorkout();
    }
  }

  Future<void> _saveWorkout() async {
    setState(() => _isSaving = true);
    final durationMinutes = (widget.workout.totalDurationSeconds / 60).ceil();
    final met = widget.workout.id == 'cardio' ? 5.0 : widget.workout.id == 'walking' ? 3.5 : 2.0;
    final calories = (met * 3.5 * 65 / 200 * durationMinutes).round();

    await ApiService().createExercise(
      widget.workout.exerciseType,
      durationMinutes,
      calories: calories,
      note: 'Sesi guided: ${widget.workout.title}',
    );

    if (mounted) setState(() => _isSaving = false);
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return m > 0 ? '$m:${s.toString().padLeft(2, '0')}' : '$s';
  }

  @override
  Widget build(BuildContext context) {
    final workout = widget.workout;

    if (_isCompleted) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Text('🎉', style: TextStyle(fontSize: 56)),
                  ),
                  const SizedBox(height: 28),
                  const Text('Luar Biasa!',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
                  const SizedBox(height: 8),
                  Text('Kamu berhasil menyelesaikan ${workout.title}!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary, height: 1.5)),
                  const SizedBox(height: 12),
                  Text(workout.totalDurationFormatted,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: workout.accentColor)),
                  const SizedBox(height: 8),
                  if (_isSaving)
                    const Text('Menyimpan...', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary))
                  else
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen, size: 16),
                        SizedBox(width: 6),
                        Text('Tersimpan otomatis', style: TextStyle(fontSize: 12, color: AppTheme.primaryGreen)),
                      ],
                    ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Kembali'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(workout.title),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppTheme.darkText),
          onPressed: () {
            _pauseTimer();
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Text('Batalkan Sesi?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                content: const Text('Progressmu tidak akan disimpan.', style: TextStyle(fontSize: 13)),
                actions: [
                  TextButton(onPressed: () { Navigator.pop(ctx); _startTimer(); },
                      child: const Text('Lanjutkan', style: TextStyle(color: AppTheme.primaryGreen))),
                  TextButton(onPressed: () { 
                    Navigator.pop(ctx); 
                    Navigator.pop(context); 
                    ApiService().createNotification(
                      'Aktivitas Belum Tuntas 🏃', 
                      'Sesi ${workout.title} tadi belum selesai. Tidak apa-apa, kamu bisa melanjutkannya nanti saat sudah siap! 💪'
                    );
                  },
                      child: const Text('Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                ],
              ),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          children: [
            // Overall progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _overallProgress,
                backgroundColor: AppTheme.dividerColor,
                valueColor: AlwaysStoppedAnimation<Color>(workout.accentColor),
                minHeight: 6,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text('Step ${_currentStepIndex + 1} / ${workout.steps.length}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ),

            const Spacer(flex: 1),

            // Timer circle
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200, height: 200,
                    child: CircularProgressIndicator(
                      value: _stepProgress,
                      strokeWidth: 8,
                      backgroundColor: AppTheme.dividerColor,
                      valueColor: AlwaysStoppedAnimation<Color>(workout.accentColor),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_formatTime(_secondsRemaining),
                          style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: workout.accentColor)),
                      const Text('detik', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(flex: 1),

            // Step info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: AppTheme.cardDecoration(borderRadius: 24),
              child: Column(
                children: [
                  Text(_currentStep.name,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: workout.accentColor)),
                  const SizedBox(height: 10),
                  Text(_currentStep.instruction,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: AppTheme.darkText, height: 1.6)),
                ],
              ),
            ),

            const Spacer(flex: 1),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Skip step
                if (_currentStepIndex < workout.steps.length - 1)
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded, size: 32, color: AppTheme.textSecondary),
                    onPressed: _nextStep,
                    tooltip: 'Lewati',
                  ),
                const SizedBox(width: 16),
                // Play/Pause
                GestureDetector(
                  onTap: _isRunning ? _pauseTimer : _startTimer,
                  child: Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: workout.accentColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: workout.accentColor.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Icon(
                      _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MANUAL LOG SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class _ManualLogScreen extends StatefulWidget {
  const _ManualLogScreen();

  @override
  State<_ManualLogScreen> createState() => _ManualLogScreenState();
}

class _ManualLogScreenState extends State<_ManualLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  String _selectedType = 'Jalan Kaki';
  final _durationCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _isSubmitting = false;

  final _types = [
    {'type': 'Jalan Kaki', 'emoji': '🚶', 'met': 3.5},
    {'type': 'Lari', 'emoji': '🏃', 'met': 8.0},
    {'type': 'Yoga', 'emoji': '🧘', 'met': 2.5},
    {'type': 'Bersepeda', 'emoji': '🚴', 'met': 6.0},
    {'type': 'Lainnya', 'emoji': '💪', 'met': 4.0},
  ];

  @override
  void initState() {
    super.initState();
    _durationCtrl.addListener(_autoCalc);
  }

  @override
  void dispose() {
    _durationCtrl.removeListener(_autoCalc);
    _durationCtrl.dispose();
    _caloriesCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _autoCalc() {
    final m = int.tryParse(_durationCtrl.text);
    if (m == null || m <= 0) return;
    final typeObj = _types.firstWhere((t) => t['type'] == _selectedType, orElse: () => {'met': 4.0});
    final cal = ((typeObj['met'] as double) * 3.5 * 65 / 200 * m).round();
    _caloriesCtrl.text = '$cal';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final ok = await _api.createExercise(
      _selectedType,
      int.parse(_durationCtrl.text),
      calories: int.tryParse(_caloriesCtrl.text) ?? 0,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Aktivitas berhasil dicatat! 🏃💨'),
          backgroundColor: AppTheme.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal menyimpan aktivitas.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Catat Aktivitas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.darkText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardDecoration(borderRadius: 22),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Jenis Olahraga',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedType,
                      dropdownColor: AppTheme.cardDark,
                      isExpanded: true,
                      style: const TextStyle(color: AppTheme.darkText, fontSize: 15),
                      onChanged: (val) {
                        if (val != null) { setState(() => _selectedType = val); _autoCalc(); }
                      },
                      items: _types.map((t) => DropdownMenuItem<String>(
                        value: t['type'] as String,
                        child: Row(children: [
                          Text(t['emoji'] as String, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 12),
                          Text(t['type'] as String),
                        ]),
                      )).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Durasi (Menit)',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _durationCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppTheme.darkText),
                          decoration: const InputDecoration(hintText: '30', prefixIcon: Icon(Icons.timer_outlined, color: AppTheme.textSecondary)),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Harus diisi';
                            if (int.tryParse(v) == null || int.parse(v) <= 0) return 'Tidak valid';
                            return null;
                          },
                        ),
                      ]),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Kalori (Kkal)',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _caloriesCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppTheme.darkText),
                          decoration: const InputDecoration(hintText: '150', prefixIcon: Icon(Icons.local_fire_department_outlined, color: AppTheme.textSecondary)),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Harus diisi';
                            if (int.tryParse(v) == null || int.parse(v) < 0) return 'Tidak valid';
                            return null;
                          },
                        ),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Catatan',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteCtrl,
                  style: const TextStyle(color: AppTheme.darkText),
                  decoration: const InputDecoration(
                    hintText: 'Bagaimana perasaanmu setelah berolahraga?',
                    prefixIcon: Icon(Icons.edit_note_rounded, color: AppTheme.textSecondary),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Simpan Aktivitas'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
