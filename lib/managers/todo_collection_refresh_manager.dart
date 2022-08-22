import 'package:flutter_time_management_app/firebase/todo_database.dart';
import 'package:flutter_time_management_app/models/enums/todo_collection_type.dart';
import 'package:flutter_time_management_app/models/todos/todo_collection.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';

class TodoCollectionRefreshManager {
  // Check if todo collection needs updating
  void checkAndUpdateTodoCollection(
      TodoCollection todoCollection, int dayTreshold) {
    var lastRefresh = todoCollection.lastRefreshDateTime;
    if (AppStyles().getDifferenceFromTodayInDays(lastRefresh) >= dayTreshold) {
      for (var todoItem in todoCollection.todoItems) {
        todoItem.completed = false;
      }
      todoCollection.lastRefreshDateTime = DateTime.now();
      TodoDatabase().updateTodoCollection(todoCollection);
    }
  }

  // Main switch statement for refreshing todo collections
  void refreshTodoCollections(List<TodoCollection> todoCollections) {
    for (var todoCollection in todoCollections) {
      switch (todoCollection.collectionType) {
        case TodoCollectionType.primary:
          checkAndUpdateTodoCollection(todoCollection, 1);
          break;
        case TodoCollectionType.complementary:
          checkAndUpdateTodoCollection(todoCollection, 7);
          break;
        case TodoCollectionType.backBurner:
          checkAndUpdateTodoCollection(todoCollection, 30);
          break;
      }
    }
  }
}
