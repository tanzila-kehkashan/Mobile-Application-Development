import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String tag;
  final DateTime createdAt;
  final DateTime? lastEdited;
  final String? imageUrl;
  final String? extractedText;

  Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.tag,
    required this.createdAt,
    this.lastEdited,
    this.imageUrl,
    this.extractedText,
  });

  factory Note.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Note(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      tag: data['tag'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastEdited: data['lastEdited'] != null
          ? (data['lastEdited'] as Timestamp).toDate()
          : null,
      imageUrl: data['imageUrl'],
      extractedText: data['extractedText'],
    );
  }

  factory Note.fromMap(Map<String, dynamic> data, String id) {
    return Note(
      id: id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      tag: data['tag'] ?? '',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(data['createdAt'].toString()) ?? DateTime.now(),
      lastEdited: data['lastEdited'] != null
          ? (data['lastEdited'] is Timestamp
              ? (data['lastEdited'] as Timestamp).toDate()
              : DateTime.tryParse(data['lastEdited'].toString()))
          : null,
      imageUrl: data['imageUrl'],
      extractedText: data['extractedText'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'tag': tag,
      'createdAt': createdAt,
      'lastEdited': lastEdited,
      'imageUrl': imageUrl,
      'extractedText': extractedText,
    };
  }
}
