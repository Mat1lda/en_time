import 'package:flutter/material.dart';
import 'dart:ui';

import '../../../components/colors.dart';
import '../../../database/models/note_model.dart';
import '../../../database/services/note_service.dart';

class ThemeStyle {
  final Color backgroundColor;
  final Color textColor;
  final double titleFontSize;
  final double contentFontSize;

  ThemeStyle({
    required this.backgroundColor,
    required this.textColor,
    required this.titleFontSize,
    required this.contentFontSize,
  });
}

class NoteDetailPage extends StatefulWidget {
  final Note? note;

  const NoteDetailPage({Key? key, this.note}) : super(key: key);

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _noteService = NoteService();

  bool _isLoading = false;
  String _currentCategory = 'Chưa phân loại';
  Color _selectedThemeColor = Colors.white;
  late ThemeStyle _themeStyle;

  final List<Color> _themeColors = [
    Colors.white,
    Colors.yellow[100]!,   // ✅ Giữ lại
    Colors.blue[100]!,     // ✅ Giữ lại
    Colors.green[100]!,    // ✅ Giữ lại
    Colors.pink[100]!,     // ✅ Giữ lại
    Colors.purple[100]!,   // ✅ Giữ lại
    Colors.orange[100]!,   // ✅ Giữ lại
    Colors.grey[300]!,     // ✅ Giữ lại
  ];


  final Color yellow100 = Colors.yellow[100]!;
  final Color blue100 = Colors.blue[100]!;
  final Color green100 = Colors.green[100]!;
  final Color pink100 = Colors.pink[100]!;
  final Color purple100 = Colors.purple[100]!;
  final Color orange100 = Colors.orange[100]!;
  final Color grey300 = Colors.grey[300]!;


  final Map<Color, ThemeStyle> _themeStyleMap = {
    Colors.white: ThemeStyle(
      backgroundColor: Colors.white,
      textColor: Colors.black,
      titleFontSize: 20,
      contentFontSize: 16,
    ),
    Colors.yellow[100]!: ThemeStyle(
      backgroundColor: Colors.yellow[100]!,
      textColor: Colors.brown,
      titleFontSize: 20,
      contentFontSize: 16,
    ),
    Colors.blue[100]!: ThemeStyle(
      backgroundColor: Colors.blue[100]!,
      textColor: Colors.black,
      titleFontSize: 20,
      contentFontSize: 16,
    ),
    Colors.green[100]!: ThemeStyle(
      backgroundColor: Colors.green[100]!,
      textColor: Colors.black,
      titleFontSize: 20,
      contentFontSize: 16,
    ),
    Colors.pink[100]!: ThemeStyle(
      backgroundColor: Colors.pink[100]!,
      textColor: Colors.deepPurple,
      titleFontSize: 20,
      contentFontSize: 16,
    ),
    Colors.purple[100]!: ThemeStyle(
      backgroundColor: Colors.purple[100]!,
      textColor: Colors.white,
      titleFontSize: 20,
      contentFontSize: 16,
    ),
    Colors.orange[100]!: ThemeStyle(
      backgroundColor: Colors.orange[100]!,
      textColor: Colors.black,
      titleFontSize: 20,
      contentFontSize: 16,
    ),
    Colors.grey[300]!: ThemeStyle(
      backgroundColor: Colors.grey[300]!,
      textColor: Colors.black87,
      titleFontSize: 20,
      contentFontSize: 16,
    ),
  };

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _currentCategory = widget.note!.category;
      if (widget.note!.themeColor != null) {
        _selectedThemeColor = Color(int.parse(widget.note!.themeColor!, radix: 16));
      }
    }
    _updateThemeStyle();
  }

  void _updateThemeStyle() {
    _themeStyle = _themeStyleMap[_selectedThemeColor] ??
        ThemeStyle(
          backgroundColor: Colors.white,
          textColor: Colors.black,
          titleFontSize: 20,
          contentFontSize: 16,
        );
    setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _showThemeSelector() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Chọn màu chủ đề', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _themeColors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      _selectedThemeColor = color;
                      _updateThemeStyle();
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedThemeColor == color ? Colors.black : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCategoryDialog() async {
    final newCategoryController = TextEditingController();

    final selectedCategory = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chọn danh mục', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          content: StreamBuilder<List<String>>(
            stream: _noteService.getCategories(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();

              final existingCategories = snapshot.data!;
              final categories = existingCategories.contains('Chưa phân loại')
                  ? existingCategories
                  : ['Chưa phân loại', ...existingCategories];

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...categories.map((cat) => RadioListTile<String>(
                    title: Text(cat),
                    value: cat,
                    groupValue: _currentCategory,
                    onChanged: (val) {
                      Navigator.pop(context, val);
                    },
                  )),
                  const Divider(),
                  TextField(
                    controller: newCategoryController,
                    decoration: InputDecoration(
                      hintText: 'Thêm danh mục mới',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () async {
                          final newCat = newCategoryController.text.trim();
                          if (newCat.isNotEmpty) {
                            await _noteService.addCategory(newCat);
                            Navigator.pop(context, newCat);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ],
        );
      },
    );

    if (selectedCategory != null && selectedCategory.isNotEmpty) {
      setState(() => _currentCategory = selectedCategory);
    }
  }

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.note == null) {
        await _noteService.createNote(
          _titleController.text,
          _contentController.text,
          category: _currentCategory,
          themeColor: _selectedThemeColor.value.toRadixString(16),
        );
      } else {
        await _noteService.updateNote(
          widget.note!.id!,
          _titleController.text,
          _contentController.text,
          category: _currentCategory,
          themeColor: _selectedThemeColor.value.toRadixString(16),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi lưu ghi chú: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _hideNote() async {
    if (widget.note == null) return;

    setState(() => _isLoading = true);

    try {
      await _noteService.updateNote(
        widget.note!.id!,
        _titleController.text,
        _contentController.text,
        category: _currentCategory,
        themeColor: _selectedThemeColor.value.toRadixString(16),
        isHidden: true,
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi ẩn ghi chú: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteNote() async {
    if (widget.note == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa ghi chú', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Bạn có chắc chắn muốn xóa ghi chú này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await _noteService.deleteNote(widget.note!.id!);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi xóa ghi chú: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themeStyle.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.note == null ? 'Ghi chú mới' : 'Chỉnh sửa ghi chú',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.checkroom_outlined, color: AppColors.primaryColor1),
            tooltip: 'Chọn màu chủ đề',
            onPressed: _showThemeSelector,
          ),
          TextButton.icon(
            onPressed: _showCategoryDialog,
            icon: Icon(Icons.folder_outlined, color: AppColors.primaryColor1),
            label: Text(_currentCategory, style: TextStyle(color: AppColors.primaryColor1)),
          ),
          IconButton(
            icon: Icon(Icons.save_outlined, color: AppColors.primaryColor1),
            onPressed: _isLoading ? null : _saveNote,
            tooltip: 'Lưu ghi chú',
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.primaryColor1),
            onSelected: (value) {
              if (value == 'delete') {
                _deleteNote();
              } else if (value == 'hide') {
                _hideNote();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'delete', child: Text('Xóa')),
              PopupMenuItem(value: 'hide', child: Text('Ẩn')),
              PopupMenuItem(value: 'move', child: Text('Chuyển tới')),
              PopupMenuItem(value: 'remind', child: Text('Nhắc nhở')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor1))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(
                fontSize: _themeStyle.titleFontSize,
                color: _themeStyle.textColor,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Nhập tiêu đề...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: _themeStyle.titleFontSize),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.note != null
                  ? '${widget.note!.updatedAt.day} tháng ${widget.note!.updatedAt.month} ${widget.note!.updatedAt.hour}:${widget.note!.updatedAt.minute}'
                  : '${DateTime.now().day} tháng ${DateTime.now().month} ${DateTime.now().hour}:${DateTime.now().minute}',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              style: TextStyle(
                fontSize: _themeStyle.contentFontSize,
                color: _themeStyle.textColor,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Bắt đầu viết...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: _themeStyle.contentFontSize),
              ),
              maxLines: null,
            ),
          ],
        ),
      ),
    );
  }
}
