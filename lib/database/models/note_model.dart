class Note {
  final String? id;
  final String title;
  final String content;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? themeColor;
  final String? fontColor; // màu chữ (hex string: 'FFFFFFFF')
  final int? fontSize;     // cỡ chữ
  final bool? isHidden;    // ẩn ghi chú

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.themeColor,
    this.fontColor,
    this.fontSize,
    this.isHidden,
  });


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'themeColor': themeColor,
      'fontColor': fontColor,
      'fontSize': fontSize,
      'isHidden': isHidden ?? false,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map, String documentId) {
    return Note(
      id: documentId,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? 'Chưa phân loại',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      themeColor: map['themeColor'],
      fontColor: map['fontColor'],
      fontSize: map['fontSize'],
      isHidden: map['isHidden'] ?? false,
    );
  }

}
