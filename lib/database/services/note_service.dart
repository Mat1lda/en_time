import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note_model.dart';

class NoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'notes';

  String get _currentUserId => _auth.currentUser?.uid ?? '';

  Future<void> addCategory(String category) async {
    final doc = await _firestore
        .collection('categories')
        .where('name', isEqualTo: category)
        .get();

    if (doc.docs.isEmpty) {
      await _firestore.collection('categories').add({
        'name': category,
        'userId': _currentUserId,
      });
    }
  }

  // Get all notes
  Stream<List<Note>> getNotes() {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: _currentUserId)
        .snapshots()
        .map((snapshot) {
      final notes = snapshot.docs
          .map((doc) => Note.fromMap(doc.data(), doc.id))
          .toList();
      notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return notes;
    });
  }

  // Get all categories
  Stream<List<String>> getCategories() {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: _currentUserId)
        .snapshots()
        .map((snapshot) {
      final categories = snapshot.docs
          .map((doc) => doc.data()['category'] as String?)
          .where((category) => category != null && category.isNotEmpty)
          .map((category) => category!)
          .toSet()
          .toList();
      return categories;
    });
  }

  // Get a single note
  Future<Note?> getNote(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists && doc.data()?['userId'] == _currentUserId) {
      return Note.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // ✅ Create a new note (support themeColor, fontColor, fontSize, isHidden)
  Future<String> createNote(
      String title,
      String content, {
        String? category,
        String? themeColor,
        String? fontColor,
        int? fontSize,
        bool isHidden = false,
      }) async {
    final now = DateTime.now();
    final noteData = {
      ...Note(
        title: title,
        content: content,
        category: category ?? 'Chưa phân loại',
        createdAt: now,
        updatedAt: now,
        themeColor: themeColor,
        fontColor: fontColor,
        fontSize: fontSize,
        isHidden: isHidden,
      ).toMap(),
      'userId': _currentUserId,
    };

    final docRef = await _firestore.collection(_collection).add(noteData);
    return docRef.id;
  }

  // ✅ Update a note (support themeColor, fontColor, fontSize, isHidden)
  Future<void> updateNote(
      String id,
      String title,
      String content, {
        String? category,
        String? themeColor,
        String? fontColor,
        double? fontSize,
        bool? isHidden,
      }) async {
    final updateData = {
      'title': title,
      'content': content,
      'updatedAt': DateTime.now().toIso8601String(),
      'userId': _currentUserId,
      if (category != null) 'category': category,
      if (themeColor != null) 'themeColor': themeColor,
      if (fontColor != null) 'fontColor': fontColor,
      if (fontSize != null) 'fontSize': fontSize,
      if (isHidden != null) 'isHidden': isHidden,
    };

    await _firestore.collection(_collection).doc(id).update(updateData);
  }

  // Update note category
  Future<void> updateNoteCategory(String id, String category) async {
    await _firestore.collection(_collection).doc(id).update({
      'category': category,
      'updatedAt': DateTime.now().toIso8601String(),
      'userId': _currentUserId,
    });
  }

  // Delete a note
  Future<void> deleteNote(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
