import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_time_management_app/firebase/auth.dart';
import 'package:flutter_time_management_app/models/notes/note.dart';

class NoteDatabase {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final String firestoreCollectionName = 'notes';

  // Get Note Stream for loading Notes
  Stream<QuerySnapshot> getNotesStream() {
    return firestore
        .collection(firestoreCollectionName)
        .doc(Auth().getUserId())
        .collection(firestoreCollectionName)
        .where('userId', isEqualTo: Auth().getUserId())
        .snapshots();
  }

  // Add a new Note
  Future<void> addNote(Note note) async {
    try {
      await firestore
          .collection(firestoreCollectionName)
          .doc(Auth().getUserId())
          .collection(firestoreCollectionName)
          .doc(note.noteId)
          .set(note.toJson());
    } catch (error) {
      log("Add Todo Collection Error: $error");
    }
  }

  // Update an existing Note
  Future<void> updateNote(Note note) async {
    try {
      await firestore
          .collection(firestoreCollectionName)
          .doc(Auth().getUserId())
          .collection(firestoreCollectionName)
          .doc(note.noteId)
          .set(note.toJson());
    } catch (error) {
      log("Update Todo Collection Error: $error");
    }
  }

  // Delete Note
  Future<void> deleteNote(Note note) async {
    try {
      await firestore
          .collection(firestoreCollectionName)
          .doc(Auth().getUserId())
          .collection(firestoreCollectionName)
          .doc(note.noteId)
          .delete();
    } catch (error) {
      log("Remove Todo Collection Error: $error");
    }
  }
}
