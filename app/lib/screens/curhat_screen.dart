import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

/// Halaman AI Teman Curhat — ruang interaktif yang aman untuk mencurahkan perasaan.
/// Mendukung: markdown bold/italic, chat history, sesi percakapan tersimpan.
class CurhatPage extends StatefulWidget {
  const CurhatPage({super.key});

  @override
  State<CurhatPage> createState() => _CurhatPageState();
}

class _CurhatPageState extends State<CurhatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  // Chat history management
  Map<String, List<Map<String, dynamic>>> _groupedMessages = {};
  String? _currentSessionId;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Chat History Persistence ────────────────────────────────────────────

  Future<void> _loadChatHistory() async {
    final history = await ApiService().fetchChatHistory();
    
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    if (history.isNotEmpty) {
      for (var m in history) {
        final dt = DateTime.parse(m['timestamp']).toLocal();
        final dateKey = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
        
        if (!grouped.containsKey(dateKey)) {
          grouped[dateKey] = [];
        }
        grouped[dateKey]!.add({
          'isUser': m['role'] == 'user',
          'text': m['text'],
          'time': m['timestamp'],
        });
      }
    }

    final todayDt = DateTime.now();
    final todayKey = '${todayDt.year}-${todayDt.month.toString().padLeft(2, '0')}-${todayDt.day.toString().padLeft(2, '0')}';

    if (!grouped.containsKey(todayKey)) {
      final name = ApiService().userName ?? 'Kamu';
      grouped[todayKey] = [{
        'isUser': false,
        'text': 'Halo $name.\nAku di sini untuk mendengarkan ceritamu tanpa menghakimi. Bagaimana perasaanmu hari ini?',
        'time': todayDt.toIso8601String(),
      }];
    }

    setState(() {
      _groupedMessages = grouped;
      _currentSessionId = todayKey; // Default to today
      _messages = List.from(_groupedMessages[_currentSessionId]!);
    });

    _scrollToBottom();
  }

  void _switchSession(String dateKey) {
    setState(() {
      _currentSessionId = dateKey;
      _messages = List.from(_groupedMessages[dateKey]!);
    });
    Navigator.pop(context); // Close drawer
    _scrollToBottom();
  }

  // ── Chat Logic ─────────────────────────────────────────────────────────

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    
    // Auto switch to today if typing in an old session
    final dt = DateTime.now();
    final todayKey = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    if (_currentSessionId != todayKey) {
      _switchSession(todayKey);
    }

    setState(() {
      final newMsg = {
        'isUser': true,
        'text': text,
        'time': DateTime.now().toIso8601String(),
      };
      _messages.add(newMsg);
      _groupedMessages[todayKey]!.add(newMsg);
      _isTyping = true;
    });
    _scrollToBottom();

    final aiReply = await ApiService().sendChatMessage(_messages);

    if (!mounted) return;

    setState(() {
      _isTyping = false;
      final aiMsg = {
        'isUser': false,
        'text': aiReply,
        'time': DateTime.now().toIso8601String(),
      };
      _messages.add(aiMsg);
      _groupedMessages[_currentSessionId!]!.add(aiMsg);
    });
    _scrollToBottom();
  }

  // ── Markdown Parsing ───────────────────────────────────────────────────

  List<TextSpan> _parseMarkdown(String text, Color textColor) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*');
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }

      if (match.group(1) != null) {
        spans.add(TextSpan(
          text: match.group(1),
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ));
      } else if (match.group(2) != null) {
        spans.add(TextSpan(
          text: match.group(2),
          style: TextStyle(fontStyle: FontStyle.italic, color: textColor),
        ));
      }

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    if (spans.isEmpty) {
      spans.add(TextSpan(text: text));
    }

    return spans;
  }

  // ── Build Methods ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('AI Teman Curhat'),
        backgroundColor: AppTheme.background,
        centerTitle: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: _buildHistoryDrawer(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildChatBubble(_messages[index]),
            ),
          ),
          if (_messages.length == 1 && !_isTyping) _buildSuggestionChips(),
          if (_isTyping) _buildTypingIndicator(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: AppTheme.glassDecoration(borderRadius: 16, opacity: 0.1, color: Colors.white),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 12, height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Companion sedang berpikir...',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryDrawer() {
    final sortedKeys = _groupedMessages.keys.toList()..sort((a, b) => b.compareTo(a));

    return Drawer(
      backgroundColor: AppTheme.cardDark,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                'Riwayat Curhat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText),
              ),
            ),
            const Divider(color: AppTheme.dividerColor),
            Expanded(
              child: ListView.builder(
                itemCount: sortedKeys.length,
                itemBuilder: (context, index) {
                  final key = sortedKeys[index];
                  final isSelected = key == _currentSessionId;
                  
                  // Beautify label
                  final now = DateTime.now();
                  final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                  final yesterday = now.subtract(const Duration(days: 1));
                  final yesterdayStr = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
                  
                  String label = key;
                  if (key == todayStr) label = 'Hari ini';
                  else if (key == yesterdayStr) label = 'Kemarin';

                  return ListTile(
                    leading: Icon(Icons.chat_bubble_outline_rounded, 
                      color: isSelected ? AppTheme.primaryGreen : AppTheme.textSecondary),
                    title: Text(label, style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppTheme.primaryGreen : AppTheme.darkText,
                    )),
                    selected: isSelected,
                    selectedTileColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    onTap: () => _switchSession(key),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChips() {
    final suggestions = [
      'Saya merasa cemas & overthinking...',
      'Butuh saran untuk relaksasi',
      'Cerita tentang hari buruk saya',
      'Bagaimana cara memotivasi diri?',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text('Rekomendasi topik cerita:',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary.withValues(alpha: 0.8))),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((text) {
              return ActionChip(
                label: Text(text,
                    style: const TextStyle(color: AppTheme.primaryGreen, fontSize: 12.5, fontWeight: FontWeight.w500)),
                backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.06),
                side: BorderSide(color: AppTheme.primaryGreen.withValues(alpha: 0.15)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onPressed: () {
                  _messageController.text = text;
                  _sendMessage();
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> msg) {
    final bool isUser = msg['isUser'];
    final String text = msg['text'];
    final Color textColor = isUser ? Colors.white : AppTheme.darkText;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: isUser
            ? BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              )
            : AppTheme.glassDecoration(borderRadius: 20, opacity: 0.15, color: Colors.white),
        child: RichText(
          text: TextSpan(
            style: TextStyle(color: textColor, fontSize: 14.5, height: 1.5, fontFamily: 'Poppins'),
            children: _parseMarkdown(text, textColor),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2EBE6), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: AppTheme.darkText),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Tulis ceritamu di sini...',
                fillColor: AppTheme.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: const CircleAvatar(
              radius: 26,
              backgroundColor: AppTheme.primaryGreen,
              child: Icon(Icons.send_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
