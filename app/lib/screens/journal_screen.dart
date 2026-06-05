import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'journal_editor_screen.dart';

/// Halaman Journal — menampilkan daftar entri jurnal dan opsi CRUD.
class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final ApiService _api = ApiService();
  List<Map<String, dynamic>> _journals = [];
  List<Map<String, dynamic>> _filteredJournals = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadJournals();
    _searchController.addListener(_filterJournals);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadJournals() async {
    setState(() => _isLoading = true);
    final data = await _api.fetchJournals();
    if (mounted) {
      setState(() {
        _journals = data;
        _filteredJournals = data;
        _isLoading = false;
      });
    }
  }

  void _filterJournals() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredJournals = _journals.where((journal) {
        final title = (journal['title'] ?? '').toString().toLowerCase();
        final content = (journal['content'] ?? '').toString().toLowerCase();
        return title.contains(query) || content.contains(query);
      }).toList();
    });
  }

  Future<void> _deleteJournal(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Jurnal?'),
        content: const Text('Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _api.deleteJournal(id);
      if (success) {
        _loadJournals();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Jurnal berhasil dihapus 🗑️'),
              backgroundColor: AppTheme.primaryGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  void _openEditor({Map<String, dynamic>? journal}) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => JournalEditorScreen(journal: journal),
      ),
    )
        .then((changed) {
      if (changed == true) {
        _loadJournals();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Refleksi & Jurnal'),
        backgroundColor: AppTheme.background,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary),
            onPressed: _loadJournals,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppTheme.darkText),
              decoration: InputDecoration(
                hintText: 'Cari jurnal...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppTheme.textSecondary),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                fillColor: AppTheme.cardDark,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),

          // Content Area
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryGreen),
                  )
                : _filteredJournals.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadJournals,
                        color: AppTheme.primaryGreen,
                        backgroundColor: AppTheme.cardDark,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                          itemCount: _filteredJournals.length,
                          itemBuilder: (context, index) {
                            final item = _filteredJournals[index];
                            return _buildJournalCard(item);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: const Color(0xFF003300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, size: 30),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📖', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 18),
            const Text(
              'Mulai Menulis Jurnal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tuliskan perasaan, kesuksesan kecil, atau refleksi harimu. Jurnal membantu menenangkan pikiranmu.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _openEditor(),
              icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF003300)),
              label: const Text('Buat Entri Pertama'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalCard(Map<String, dynamic> journal) {
    final int id = journal['id'];
    final String title = journal['title'] ?? 'Tanpa Judul';
    final String content = journal['content'] ?? '';
    final String emoji = journal['mood_emoji'] ?? '😊';
    final DateTime createdAt = journal['created_at'] != null
        ? DateTime.parse(journal['created_at'])
        : DateTime.now();

    final dateStr = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(createdAt);
    final timeStr = DateFormat('HH:mm').format(createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: AppTheme.cardDecoration(borderRadius: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openEditor(journal: journal),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '$dateStr • $timeStr',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textSecondary),
                        color: AppTheme.cardDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onSelected: (val) {
                          if (val == 'edit') {
                            _openEditor(journal: journal);
                          } else if (val == 'delete') {
                            _deleteJournal(id);
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_rounded, size: 18, color: AppTheme.primaryGreen),
                                SizedBox(width: 10),
                                Text('Edit', style: TextStyle(color: AppTheme.darkText)),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_rounded, size: 18, color: Colors.redAccent),
                                SizedBox(width: 10),
                                Text('Hapus', style: TextStyle(color: Colors.redAccent)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.darkText,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
