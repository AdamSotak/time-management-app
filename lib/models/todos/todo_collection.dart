import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_time_management_app/models/enums/todo_collection_type.dart';
import 'package:flutter_time_management_app/models/todos/todo_item.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';

class TodoCollection {
  String id;
  String userId;
  String name;
  bool today;
  TodoCollectionType collectionType;
  List<TodoItem> todoItems;
  int linearGradientIndex;
  DateTime lastRefreshDateTime;
  DateTime createdDateTime;

  TodoCollection(
      {required this.id,
      required this.userId,
      required this.name,
      this.today = false,
      required this.collectionType,
      required this.todoItems,
      required this.linearGradientIndex,
      required this.lastRefreshDateTime,
      required this.createdDateTime});

  factory TodoCollection.fromDocumentSnapshot(
      DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> data =
        documentSnapshot.data()! as Map<String, dynamic>;
    return TodoCollection(
        id: documentSnapshot.id,
        userId: data['userId'] as String,
        name: data['name'] as String,
        today: data['today'] == true,
        collectionType:
            AppStyles().getTodoCollectionType(data['collectionType']),
        todoItems: (data['todoItems'] as List)
            .map((e) => TodoItem.fromJson(e))
            .toList(),
        linearGradientIndex: data['linearGradientIndex'] as int,
        lastRefreshDateTime: DateTime.fromMillisecondsSinceEpoch(
            data['lastRefreshDateTime'].seconds * 1000),
        createdDateTime: DateTime.fromMillisecondsSinceEpoch(
            data['createdDateTime'].seconds * 1000));
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> todoItemsJsons = [];
    for (var todoItem in todoItems) {
      todoItemsJsons.add(todoItem.toJson());
    }
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'today': today,
      'collectionType': collectionType.toString(),
      'todoItems': FieldValue.arrayUnion(todoItemsJsons),
      'linearGradientIndex': linearGradientIndex,
      'lastRefreshDateTime': lastRefreshDateTime,
      'createdDateTime': createdDateTime
    };
  }
}
