import 'package:flutter/material.dart';
import '../../../database/models/note_model.dart';
import '../../../database/services/note_service.dart';
import '../../../components/colors.dart';

class NoteDetailPage extends StatefulWidget {
  final Note? note;

  const NoteDetailPage({Key? key, this.note}) : super(key: key);

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _noteService = NoteService();
  bool _isLoading = false;
  String _currentCategory = 'Chưa phân loại';

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _currentCategory = widget.note!.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _showCategoryDialog() async {
    final TextEditingController newCategoryController = TextEditingController();

    String? selectedCategory = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                'Chọn danh mục',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19),
              ),
              content: StreamBuilder<List<String>>(
                stream: _noteService.getCategories(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  final categories = ['Chưa phân loại', ...snapshot.data!];

                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...categories.map(
                          (category) => RadioListTile<String>(
                            title: Text(category),
                            value: category,
                            groupValue: _currentCategory,
                            onChanged: (value) {
                              Navigator.of(context).pop(value);
                            },
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: newCategoryController,
                            decoration: InputDecoration(
                              hintText: 'Thêm danh mục mới',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  if (newCategoryController.text.isNotEmpty) {
                                    Navigator.of(
                                      context,
                                    ).pop(newCategoryController.text);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Hủy'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selectedCategory != null && selectedCategory.isNotEmpty) {
      setState(() {
        _currentCategory = selectedCategory;
      });
    }
  }

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.note == null) {
        await _noteService.createNote(
          _titleController.text,
          _contentController.text,
          category: _currentCategory,
        );
      } else {
        await _noteService.updateNote(
          widget.note!.id!,
          _titleController.text,
          _contentController.text,
          category: _currentCategory,
        );
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi lưu ghi chú: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteNote() async {
    if (widget.note == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text('Xóa ghi chú', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),),
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
      setState(() => _isLoading = true);
      try {
        await _noteService.deleteNote(widget.note!.id!);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi xóa ghi chú: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: Text(
          widget.note == null ? "Ghi chú mới" : "Chỉnh sửa ghi chú",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _showCategoryDialog,
            icon: Icon(Icons.folder_outlined, color: AppColors.primaryColor1),
            label: Text(
              _currentCategory,
              style: TextStyle(color: AppColors.primaryColor1),
            ),
          ),
          IconButton(
            icon: Icon(Icons.save_outlined, color: AppColors.primaryColor1),
            onPressed: _isLoading ? null : _saveNote,
            tooltip: 'Lưu ghi chú',
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.primaryColor1),
            onPressed: _isLoading || widget.note == null ? null : _deleteNote,
            tooltip: 'Xóa ghi chú',
          ),
          SizedBox(width: 8),
        ],
        backgroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor1,
                ),
              )
              : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintText: 'Nhập tiêu đề...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        widget.note != null
                            ? '${widget.note!.updatedAt.day} tháng ${widget.note!.updatedAt.month} ${widget.note!.updatedAt.hour}:${widget.note!.updatedAt.minute}'
                            : '${DateTime.now().day} tháng ${DateTime.now().month} ${DateTime.now().hour}:${DateTime.now().minute}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintText: 'Bắt đầu viết...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                        maxLines: null,
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
