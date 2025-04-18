import 'package:en_time/components/colors.dart';
import 'package:en_time/views/widgets/app_bar.dart';
import 'package:flutter/material.dart';

import '../../../database/models/note_model.dart';
import '../../../database/services/note_service.dart';
import 'note_detail_page.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Note> _filterNotes(List<Note> notes) {
    if (_selectedCategory == 'Tất cả') {
      return notes;
    }
    return notes.where((note) => note.category == _selectedCategory).toList();
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
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: 'Tìm kiếm ghi chú',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                //fillColor: Colors.grey[800],
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
              style: TextStyle(color: Colors.black54),
            ),
          ),
          Container(
            height: 40,
            child: StreamBuilder<List<String>>(
              stream: _noteService.getCategories(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox();
                }
                final categories = [
                  'Tất cả',
                  'Chưa phân loại',
                  ...?snapshot.data
                ];
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category ==
                        _selectedCategory; //ktra xem cate co = voi selected khong, bang thi ís = true

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
                        onSelected: (selected) {
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
                  return Center(child: Text(
                    'Chưa có ghi chú',
                    style: TextStyle(color: Colors.grey[400]),
                  ));
                }
                return Padding(
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
                      return Card(
                        elevation: 1,
                        color: Colors.grey[800],
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
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Expanded(
                                  child: Text(
                                    note.content,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _formatDate(note.updatedAt),
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
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
            onPressed: (){
              Navigator.pop(context, true);
              },
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
            content: Text('Đã xóa báo ghi chú'),
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
