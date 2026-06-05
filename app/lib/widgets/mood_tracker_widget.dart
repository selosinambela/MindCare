import 'package:flutter/material.dart';
import '../controllers/mood_controller.dart';
import '../models/mood_model.dart';
import '../theme/app_theme.dart';

/// Widget mood tracker yang berdiri sendiri (self-contained).
/// Mengelola state seleksi mood dan memanggil [MoodController.submitMood].
/// Dapat ditanam di mana saja tanpa bergantung pada parent state.
class MoodTrackerWidget extends StatefulWidget {
  const MoodTrackerWidget({super.key});

  @override
  State<MoodTrackerWidget> createState() => _MoodTrackerWidgetState();
}

class _MoodTrackerWidgetState extends State<MoodTrackerWidget> {
  final _controller = MoodController();

  // Default: mood "Oke" (index 2)
  int _selectedIndex = 2;
  bool _isSubmitting = false;

  /// Dipanggil saat user mengetuk salah satu emoji mood.
  /// Mengubah state lokal, lalu memanggil business logic di [MoodController].
  Future<void> _handleMoodTap(int index) async {
    if (_isSubmitting || _selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
      _isSubmitting = true;
    });

    final mood = MoodType.values[index];
    final success = await _controller.submitMood(mood);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    _showFeedback(success, mood.label);
  }

  void _showFeedback(bool success, String moodLabel) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Mood "$moodLabel" berhasil dicatat 🌿'
              : 'Gagal menyimpan mood. Periksa koneksi.',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor:
            success ? AppTheme.primaryGreen : Colors.redAccent.shade200,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(borderRadius: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header baris
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MOOD HARI INI',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  letterSpacing: 0.8,
                  fontSize: 12,
                ),
              ),
              // Indikator loading saat submit ke backend
              AnimatedOpacity(
                opacity: _isSubmitting ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Deretan tombol emoji
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              MoodType.values.length,
              (index) => _MoodButton(
                emoji: MoodType.values[index].emoji,
                label: MoodType.values[index].label,
                isSelected: _selectedIndex == index,
                isDisabled: _isSubmitting,
                onTap: () => _handleMoodTap(index),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tombol mood individual — dipisahkan agar mudah di-test & diubah style-nya.
class _MoodButton extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _MoodButton({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        width: 62,
        height: 78,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.softGreen : AppTheme.cardDarkAlt,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : Colors.white.withValues(alpha: 0.05),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji dengan efek scale saat aktif
            AnimatedScale(
              scale: isSelected ? 1.25 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppTheme.darkText : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
