// Model layer — murni Dart, tidak bergantung pada Flutter/UI.
// Mudah di-serialize untuk HTTP request ke backend API.

/// Enum representasi mood pengguna (skala 0–4).
enum MoodType {
  sedih,   // index 0
  biasa,   // index 1
  oke,     // index 2
  senang,  // index 3
  hebat,   // index 4
}

extension MoodTypeExtension on MoodType {
  String get emoji {
    const emojis = ['😔', '😐', '😊', '😄', '🤩'];
    return emojis[index];
  }

  String get label {
    const labels = ['Sedih', 'Biasa', 'Oke', 'Senang', 'Hebat'];
    return labels[index];
  }
}

class MoodEntry {
  final MoodType mood;
  final DateTime timestamp;
  final String? note;

  const MoodEntry({
    required this.mood,
    required this.timestamp,
    this.note,
  });

  /// Siap dikirim ke endpoint POST /api/moods
  Map<String, dynamic> toJson() => {
        'mood': mood.name,
        'mood_index': mood.index,
        'timestamp': timestamp.toIso8601String(),
        if (note != null) 'note': note,
      };

  @override
  String toString() => 'MoodEntry(mood: ${mood.name}, at: $timestamp)';
}
