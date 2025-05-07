import 'package:en_time/components/colors.dart';
import 'package:en_time/views/widgets/app_bar.dart';
import 'package:flutter/material.dart';

import '../../../database/models/note_model.dart';
import '../../../database/services/note_service.dart';
import 'note_detail_page.dart';
import 'note_style_utils.dart';

class NotePage extends StatefulWidget {
  final Note? note;
  const NotePage({super.key, this.note});

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final NoteService _noteService = NoteService();
  String _selectedCategory = 'Tất cả';
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Bỏ listener tự động để chỉ tìm kiếm khi nhấn nút
  }

  void _performSearch() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase().trim();
      _isSearching = true;
    });
    // Ẩn bàn phím khi tìm kiếm xong
    _searchFocusNode.unfocus();
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _isSearching = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<Note> _filterNotes(List<Note> notes) {
    var filteredNotes = notes.where((note) => note.isHidden != true).toList();
    
    if (_selectedCategory != 'Tất cả') {
      filteredNotes = filteredNotes
          .where((note) => note.category == _selectedCategory)
          .toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filteredNotes = filteredNotes.where((note) {
        final titleMatch = note.title.toLowerCase().contains(_searchQuery);
        final contentMatch = note.content.toLowerCase().contains(_searchQuery);
        return titleMatch || contentMatch;
      }).toList();
    }
    
    return filteredNotes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: BasicAppbar(
        title: Text(
          "Giấy nhớ",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Tìm kiếm ghi chú',
                prefixIcon: IconButton(
                  icon: Icon(Icons.search, color: Colors.grey),
                  onPressed: _performSearch,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey),
                        onPressed: _clearSearch,
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
              style: TextStyle(color: Colors.black54),
              onSubmitted: (_) => _performSearch(),
              textInputAction: TextInputAction.search,
            ),
          ),
          // Hiện thị trạng thái tìm kiếm nếu đang tìm kiếm
          if (_isSearching && _searchQuery.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Kết quả tìm kiếm cho: ',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '"$_searchQuery"',
                      style: TextStyle(
                        color: AppColors.primaryColor1,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: _clearSearch,
                    child: Text('Xóa'),
                    style: TextButton.styleFrom(
                      minimumSize: Size(0, 0),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            height: 40,
            child: StreamBuilder<List<String>>(
              stream: _noteService.getCategories(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox();
                final categories = ['Tất cả', 'Chưa phân loại', ...?snapshot.data];
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category == _selectedCategory;
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[400],
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        backgroundColor: Colors.grey[800],
                        selectedColor: AppColors.primaryColor1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Note>>(
              stream: _noteService.getNotes(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final notes = _filterNotes(snapshot.data!);
                if (notes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty ? Icons.search_off : Icons.note_alt_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Không tìm thấy ghi chú nào'
                              : 'Chưa có ghi chú',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        if (_searchQuery.isNotEmpty)
                          TextButton(
                            onPressed: _clearSearch,
                            child: Text('Xóa tìm kiếm'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryColor1,
                            ),
                          ),
                      ],
                    ),
                  );
                }
                
                // Hiển thị số lượng kết quả tìm được nếu đang tìm kiếm
                return Column(
                  children: [
                    if (_isSearching && _searchQuery.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Tìm thấy ${notes.length} kết quả',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1.1,
                          ),
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            final note = notes[index];
                            final bgColor = NoteStyleUtils.parseColor(note.themeColor, fallback: Colors.white);
                            final textColor = note.fontColor != null 
                                ? NoteStyleUtils.parseColor(note.fontColor)
                                : NoteStyleUtils.getContrastingTextColor(bgColor);
                            final fontSize = note.fontSize?.toDouble() ?? 14.0;

                            return Card(
                              elevation: 1,
                              color: bgColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onLongPress: () => _deleteNote(note),
                                onTap: () => _openNoteDetail(note),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        note.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: fontSize + 2,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Expanded(
                                        child: Text(
                                          note.content,
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: fontSize,
                                            color: textColor.withOpacity(0.85),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatDate(note.updatedAt),
                                            style: TextStyle(
                                              color: textColor.withOpacity(0.7),
                                              fontSize: 12,
                                            ),
                                          ),
                                          if (note.category != 'Chưa phân loại')
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: textColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                note.category,
                                                style: TextStyle(
                                                  color: textColor.withOpacity(0.8),
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNoteDetail(null),
        child: Icon(Icons.add),
        backgroundColor: AppColors.primaryColor1,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  void _openNoteDetail(Note? note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteDetailPage(note: note)),
    );
  }

  Future<void> _deleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Xóa ghi chú',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Text('Bạn có chắc chắn muốn xóa ghi chú này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Xóa',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _noteService.deleteNote(note.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa ghi chú'),
            backgroundColor: Colors.grey,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.all(16),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa ghi chú: $e')),
        );
      }
    }
  }
}
