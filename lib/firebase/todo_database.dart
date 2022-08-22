import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_time_management_app/firebase/auth.dart';
import 'package:flutter_time_management_app/models/todos/todo_collection.dart';

class TodoDatabase {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final String firestoreCollectionName = 'todo_collections';

  // Get TodoCollection Stream for loading Todo Collections
  Stream<QuerySnapshot> getTodoCollectionsStream() {
    return firestore
        .collection(firestoreCollectionName)
        .doc(Auth().getUserId())
        .collection(firestoreCollectionName)
        .where('userId', isEqualTo: Auth().getUserId())
        .snapshots();
  }

  // Add a new TodoCollection
  Future<void> addTodoCollection(TodoCollection todoCollection) async {
    try {
      await firestore
          .collection(firestoreCollectionName)
          .doc(Auth().getUserId())
          .collection(firestoreCollectionName)
          .doc(todoCollection.id)
          .set(todoCollection.toJson());
    } catch (error) {
      log("Add Todo Collection Error: $error");
    }
  }

  // Update an existing TodoCollection
  Future<void> updateTodoCollection(TodoCollection todoCollection) async {
    try {
      await firestore
          .collection(firestoreCollectionName)
          .doc(Auth().getUserId())
          .collection(firestoreCollectionName)
          .doc(todoCollection.id)
          .set(todoCollection.toJson());
    } catch (error) {
      log("Update Todo Collection Error: $error");
    }
  }

  // Delete TodoCollection
  Future<void> deleteTodoCollection(TodoCollection todoCollection) async {
    try {
      await firestore
          .collection(firestoreCollectionName)
          .doc(Auth().getUserId())
          .collection(firestoreCollectionName)
          .doc(todoCollection.id)
          .delete();
    } catch (error) {
      log("Remove Todo Collection Error: $error");
    }
  }
}
