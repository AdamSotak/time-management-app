import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  String noteId;
  String userId;
  String name;
  String text;
  DateTime lastEdited;
  DateTime created;

  Note(
      {required this.noteId,
      required this.userId,
      required this.name,
      required this.text,
      required this.lastEdited,
      required this.created});

  factory Note.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> data =
        documentSnapshot.data()! as Map<String, dynamic>;
    return Note(
        noteId: documentSnapshot.id,
        userId: data['userId'] as String,
        name: data['name'] as String,
        text: data['text'] as String,
        lastEdited: DateTime.fromMillisecondsSinceEpoch(
            data['lastEdited'].seconds * 1000),
        created: DateTime.fromMillisecondsSinceEpoch(
            data['created'].seconds * 1000));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': noteId,
      'userId': userId,
      'name': name,
      'text': text,
      'lastEdited': lastEdited,
      'created': created
    };
  }
}
