import 'dart:async' show Completer;
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io' show NetworkInterface, InternetAddressType, Socket;
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Service terpusat untuk semua HTTP requests ke backend API.
/// Menyimpan session user (userId, name, email) di shared_preferences.
class ApiService {
  ApiService._internal();
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  static String _activeBaseUrl = 'http://127.0.0.1:3000';
  static String get baseUrl => _activeBaseUrl;

  /// Melakukan pencarian dynamic IP backend server.
  static Future<void> discoverActiveBaseUrl() async {
    if (kIsWeb) {
      _activeBaseUrl = 'http://127.0.0.1:3000';
      return;
    }

    // Tentukan default platform baseUrl
    String defaultUrl = 'http://127.0.0.1:3000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      defaultUrl = 'http://10.0.2.2:3000';
    }

    final prefs = await SharedPreferences.getInstance();
    final cachedUrl = prefs.getString('backend_base_url');

    // List calon URL untuk dites
    final candidates = <String>[];
    if (cachedUrl != null) candidates.add(cachedUrl);
    candidates.add(defaultUrl);
    candidates.add('http://LAPTOP-1POEBH5S.local:3000');
    candidates.add('http://10.85.86.221:3000');
    candidates.add('http://192.168.110.76:3000');

    final uniqueCandidates = candidates.toSet().toList();
    dev.log('[ApiService] Menguji koneksi kandidat URL: $uniqueCandidates');

    final foundUrl = await _findFirstWorkingUrl(uniqueCandidates);

    if (foundUrl != null) {
      _activeBaseUrl = foundUrl;
      await prefs.setString('backend_base_url', foundUrl);
      dev.log('[ApiService] Berhasil terhubung ke: $_activeBaseUrl');
      return;
    }

    // Jika gagal, scan subnet local Wi-Fi HP (khusus HP fisik)
    dev.log('[ApiService] Kandidat utama gagal. Memulai scan subnet...');
    final subnet = await _getSubnetPrefix();
    if (subnet != null) {
      final discovered = await _scanSubnet(subnet);
      if (discovered != null) {
        _activeBaseUrl = discovered;
        await prefs.setString('backend_base_url', discovered);
        dev.log('[ApiService] Server ditemukan di subnet: $_activeBaseUrl');
        return;
      }
    }

    // Fallback jika tidak menemukan apapun
    _activeBaseUrl = defaultUrl;
    dev.log('[ApiService] Server tidak terdeteksi. Menggunakan fallback: $_activeBaseUrl');
  }

  static Future<String?> _findFirstWorkingUrl(List<String> urls) async {
    final completer = Completer<String?>();
    int completedCount = 0;
    bool resolved = false;

    if (urls.isEmpty) return null;

    for (final url in urls) {
      _verifyUrl(url).then((ok) {
        if (resolved) return;
        if (ok) {
          resolved = true;
          completer.complete(url);
        } else {
          completedCount++;
          if (completedCount == urls.length) {
            completer.complete(null);
          }
        }
      }).catchError((_) {
        if (resolved) return;
        completedCount++;
        if (completedCount == urls.length) {
          completer.complete(null);
        }
      });
    }

    return completer.future;
  }

  static Future<bool> _verifyUrl(String url) async {
    try {
      final uri = Uri.parse('$url/api/health');
      final response = await http.get(uri).timeout(const Duration(milliseconds: 600));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is Map && data['service'] == 'mindcare-backend';
      }
    } catch (_) {}
    return false;
  }

  static Future<String?> _getSubnetPrefix() async {
    try {
      for (final interface in await NetworkInterface.list()) {
        for (final addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            final ip = addr.address;
            final parts = ip.split('.');
            if (parts.length == 4) {
              return '${parts[0]}.${parts[1]}.${parts[2]}';
            }
          }
        }
      }
    } catch (e) {
      dev.log('[ApiService] Gagal mengambil interface network: $e');
    }
    return null;
  }

  static Future<String?> _scanSubnet(String subnetPrefix) async {
    const batchSize = 32;
    for (int batch = 0; batch < 256; batch += batchSize) {
      final List<Future<String?>> tasks = [];
      for (int i = 1; i <= batchSize; i++) {
        final hostId = batch + i;
        if (hostId > 254) break;
        final ip = '$subnetPrefix.$hostId';
        
        tasks.add(() async {
          try {
            final socket = await Socket.connect(ip, 3000, timeout: const Duration(milliseconds: 300));
            socket.destroy();
            
            final url = 'http://$ip:3000';
            if (await _verifyUrl(url)) {
              return url;
            }
          } catch (_) {}
          return null;
        }());
      }

      final results = await Future.wait(tasks);
      for (final res in results) {
        if (res != null) return res;
      }
    }
    return null;
  }

  int? _userId;
  String? _userName;
  String? _userEmail;

  int? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isLoggedIn => _userId != null;

  /// Inisialisasi session dari shared_preferences saat app start.
  Future<void> init() async {
    await discoverActiveBaseUrl();
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('user_id');
    _userName = prefs.getString('user_name');
    _userEmail = prefs.getString('user_email');
    dev.log('[ApiService] Session loaded: userId=$_userId, name=$_userName');
  }


  /// Simpan session setelah login/register.
  Future<void> _saveSession(int id, String name, String email) async {
    _userId = id;
    _userName = name;
    _userEmail = email;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', id);
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
  }

  /// Hapus session saat logout.
  Future<void> clearSession() async {
    _userId = null;
    _userName = null;
    _userEmail = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ── AUTH ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        await _saveSession(data['user']['id'], data['user']['name'], data['user']['email']);
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['error'] ?? 'Registrasi gagal.'};
      }
    } catch (e) {
      dev.log('[ApiService] register ERROR: $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _saveSession(data['user']['id'], data['user']['name'], data['user']['email']);
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['error'] ?? 'Login gagal.'};
      }
    } catch (e) {
      dev.log('[ApiService] login ERROR: $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ── MOODS ───────────────────────────────────────────────────────────────

  Future<bool> submitMood(int moodIndex, String moodName, {String? note}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/moods'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': _userId,
          'mood_index': moodIndex,
          'mood': moodName,
          'note': note,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      dev.log('[ApiService] submitMood ERROR: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchMoodHistory({int days = 7}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/moods/$_userId?days=$days'),
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      dev.log('[ApiService] fetchMoodHistory ERROR: $e');
      return [];
    }
  }

  // ── JOURNALS ────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchJournals() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/journals/$_userId'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      dev.log('[ApiService] fetchJournals ERROR: $e');
      return [];
    }
  }

  Future<bool> createJournal(String title, String content, String moodEmoji) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/journals'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': _userId,
          'title': title,
          'content': content,
          'mood_emoji': moodEmoji,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      dev.log('[ApiService] createJournal ERROR: $e');
      return false;
    }
  }

  Future<bool> updateJournal(int id, String title, String content, String moodEmoji) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/journals/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'content': content,
          'mood_emoji': moodEmoji,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      dev.log('[ApiService] updateJournal ERROR: $e');
      return false;
    }
  }

  Future<bool> deleteJournal(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/api/journals/$id'));
      return response.statusCode == 200;
    } catch (e) {
      dev.log('[ApiService] deleteJournal ERROR: $e');
      return false;
    }
  }

  // ── EXERCISES ───────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchExercises() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/exercises/$_userId'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      dev.log('[ApiService] fetchExercises ERROR: $e');
      return [];
    }
  }

  Future<bool> createExercise(String type, int durationMinutes, {int calories = 0, String? note}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/exercises'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': _userId,
          'exercise_type': type,
          'duration_minutes': durationMinutes,
          'calories': calories,
          'note': note,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      dev.log('[ApiService] createExercise ERROR: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchExerciseStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/exercises/$_userId/stats'));
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }
      return {'total_sessions': 0, 'total_minutes': 0, 'total_calories': 0};
    } catch (e) {
      dev.log('[ApiService] fetchExerciseStats ERROR: $e');
      return {'total_sessions': 0, 'total_minutes': 0, 'total_calories': 0};
    }
  }

  // ── MEDITATIONS ─────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchMeditations() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/meditations/$_userId'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      dev.log('[ApiService] fetchMeditations ERROR: $e');
      return [];
    }
  }

  Future<bool> createMeditation(int durationSeconds, String type, bool completed) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/meditations'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': _userId,
          'duration_seconds': durationSeconds,
          'type': type,
          'completed': completed,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      dev.log('[ApiService] createMeditation ERROR: $e');
      return false;
    }
  }

  // ── USER STATS ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> fetchUserStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/user/$_userId/stats'));
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }
      return {};
    } catch (e) {
      dev.log('[ApiService] fetchUserStats ERROR: $e');
      return {};
    }
  }

  // ── AI COMPANION ─────────────────────────────────────────────────────────

  Future<String> sendChatMessage(List<Map<String, dynamic>> messages) async {
    try {
      final payloadMessages = messages.map((m) => {
        'isUser': m['isUser'],
        'text': m['text'],
      }).toList();

      final response = await http.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': _userId,
          'messages': payloadMessages,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'] ?? 'Aku mendengarkan...';
      } else {
        return 'Maaf, aku sedang tidak bisa merespons saat ini.';
      }
    } catch (e) {
      dev.log('[ApiService] sendChatMessage ERROR: $e');
      return 'Koneksi ke server terputus. Silakan coba lagi.';
    }
  }

  Future<List<Map<String, dynamic>>> fetchChatHistory() async {
    if (_userId == null) return [];
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/chat/$_userId'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      dev.log('[ApiService] fetchChatHistory ERROR: $e');
      return [];
    }
  }

  // ── NOTIFICATIONS ───────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    if (_userId == null) return [];
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/notifications/$_userId'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      dev.log('[ApiService] fetchNotifications ERROR: $e');
      return [];
    }
  }

  Future<bool> createNotification(String title, String bodyText) async {
    if (_userId == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/notifications'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': _userId,
          'title': title,
          'body': bodyText,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      dev.log('[ApiService] createNotification ERROR: $e');
      return false;
    }
  }

  Future<bool> markNotificationRead(int id) async {
    try {
      final response = await http.put(Uri.parse('$baseUrl/api/notifications/$id/read'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ── FAQS ────────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchFaqs() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/faqs'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      dev.log('[ApiService] fetchFaqs ERROR: $e');
      return [];
    }
  }

  // ── SETTINGS ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> fetchSettings() async {
    if (_userId == null) return {};
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/settings/$_userId'));
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }
      return {};
    } catch (e) {
      dev.log('[ApiService] fetchSettings ERROR: $e');
      return {};
    }
  }

  Future<bool> updateSettings(bool allowNotifications, bool isPrivateAccount) async {
    if (_userId == null) return false;
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/settings/$_userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'allow_notifications': allowNotifications,
          'is_private_account': isPrivateAccount,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      dev.log('[ApiService] updateSettings ERROR: $e');
      return false;
    }
  }
}

