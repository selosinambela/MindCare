import '../models/mood_model.dart';
import '../services/api_service.dart';

/// Business logic layer untuk fitur Mood Tracker.
/// Mendelegasikan network calls ke ApiService untuk menjaga konsistensi session & base URL.
class MoodController {
  MoodController._internal();
  static final MoodController _instance = MoodController._internal();
  factory MoodController() => _instance;

  MoodEntry? _lastSubmittedMood;

  /// Entry mood terakhir yang berhasil dikirim.
  MoodEntry? get lastSubmittedMood => _lastSubmittedMood;

  /// Mengirim data mood ke backend API via ApiService.
  Future<bool> submitMood(MoodType mood, {String? note}) async {
    final entry = MoodEntry(
      mood: mood,
      timestamp: DateTime.now(),
      note: note,
    );

    final success = await ApiService().submitMood(
      mood.index,
      mood.name,
      note: note,
    );

    if (success) {
      _lastSubmittedMood = entry;
      return true;
    }
    return false;
  }

  /// Mengambil riwayat mood dari backend via ApiService.
  Future<List<MoodEntry>> fetchMoodHistory() async {
    final data = await ApiService().fetchMoodHistory(days: 7);
    return data.map((json) {
      final int index = json['mood_index'] ?? 2;
      return MoodEntry(
        mood: MoodType.values[index],
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'])
            : DateTime.now(),
        note: json['note'],
      );
    }).toList();
  }
}
