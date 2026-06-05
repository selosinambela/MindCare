import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

/// Screen editor untuk membuat atau mengubah entri jurnal.
class JournalEditorScreen extends StatefulWidget {
  final Map<String, dynamic>? journal;

  const JournalEditorScreen({super.key, this.journal});

  @override
  State<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends State<JournalEditorScreen> {
  final ApiService _api = ApiService();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool _isLoading = false;
  late String _selectedEmoji;

  // Daftar mood emoji untuk jurnal
  final List<String> _emojis = ['😊', '😇', '😌', '🥰', '😐', '😔', '😢', '😭', '🤯', '😴', '🥱', '🤒'];

  bool get _isEditMode => widget.journal != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: _isEditMode ? widget.journal!['title'] : '',
    );
    _contentController = TextEditingController(
      text: _isEditMode ? widget.journal!['content'] : '',
    );
    _selectedEmoji = _isEditMode ? (widget.journal!['mood_emoji'] ?? '😊') : '😊';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveJournal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    bool success;
    if (_isEditMode) {
      final id = widget.journal!['id'];
      success = await _api.updateJournal(id, title, content, _selectedEmoji);
    } else {
      success = await _api.createJournal(title, content, _selectedEmoji);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pop(true); // Kirim true untuk mengindikasikan data berubah
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode ? 'Gagal mengubah jurnal' : 'Gagal menyimpan jurnal'),
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
        title: Text(_isEditMode ? 'Edit Jurnal' : 'Tulis Jurnal Baru'),
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.check_rounded, color: AppTheme.primaryGreen, size: 28),
              onPressed: _saveJournal,
              tooltip: 'Simpan',
            ),
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul Field
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkText,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Judul Jurnal...',
                      hintStyle: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary.withValues(alpha: 0.6),
                      ),
                      filled: false,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Judul harus diisi';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),
                  const Divider(color: AppTheme.dividerColor),
                  const SizedBox(height: 16),

                  // Mood Selector Label
                  const Text(
                    'Bagaimana suasana hatimu hari ini?',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Emoji list horizontal scroll
                  SizedBox(
                    height: 55,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _emojis.length,
                      itemBuilder: (context, idx) {
                        final emoji = _emojis[idx];
                        final isSelected = emoji == _selectedEmoji;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedEmoji = emoji),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 50,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryGreen.withValues(alpha: 0.15)
                                  : AppTheme.cardDark,
                              border: Border.all(
                                color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Isi Jurnal Field
                  TextFormField(
                    controller: _contentController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.darkText,
                      height: 1.6,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Tuliskan refleksi, rasa syukur, atau perasaanmu di sini...',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary.withValues(alpha: 0.5),
                      ),
                      filled: false,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Isi jurnal tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 120), // Memberi ruang ekstra di bawah
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryGreen),
              ),
            ),
        ],
      ),
    );
  }
}
