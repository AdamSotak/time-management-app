import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/firebase/todo_database.dart';
import 'package:flutter_time_management_app/managers/todo_collection_refresh_manager.dart';
import 'package:flutter_time_management_app/models/todos/todo_collection.dart';
import 'package:flutter_time_management_app/pages/todo_pages/add_todo_collection_page.dart';
import 'package:flutter_time_management_app/widgets/main_app_bar.dart';
import 'package:flutter_time_management_app/widgets/main_floating_action_button.dart';
import 'package:flutter_time_management_app/widgets/no_data_tile.dart';
import 'package:flutter_time_management_app/widgets/todos/todo_collection_listview_tile.dart';

class TodoCollectionsPage extends StatefulWidget {
  const TodoCollectionsPage({Key? key}) : super(key: key);

  @override
  State<TodoCollectionsPage> createState() => _TodoCollectionsPageState();
}

class _TodoCollectionsPageState extends State<TodoCollectionsPage> {
  @override
  Widget build(BuildContext context) {
    List<TodoCollection> todoCollections = [];

    // Navigate to AddTodoCollectionPage
    void openAddTodoCollectionPage() {
      Navigator.of(context).push(CupertinoPageRoute(
          builder: (builder) => const AddTodoCollectionPage()));
    }

    return Scaffold(
      appBar: const MainAppBar(title: "To-Do"),
      body: StreamBuilder<QuerySnapshot>(
        stream: TodoDatabase().getTodoCollectionsStream(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // Error and loading checking
          if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong"),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Loading and sorting Todo Collections
          todoCollections.clear();

          todoCollections
              .addAll(snapshot.data!.docs.map((DocumentSnapshot document) {
            var todoCollection = TodoCollection.fromDocumentSnapshot(document);
            return todoCollection;
          }));

          if (todoCollections.isEmpty) {
            return const NoDataTile(
                text: "No To-Do Collections Yet\nLet's Add Some");
          }

          todoCollections
              .sort((a, b) => b.createdDateTime.compareTo(a.createdDateTime));

          // Refreshing Todo Collections
          TodoCollectionRefreshManager()
              .refreshTodoCollections(todoCollections);

          return GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisExtent: 256),
              itemCount: todoCollections.length,
              itemBuilder: (context, index) {
                var todoCollection = todoCollections[index];
                return TodoCollectionListTile(
                  key: UniqueKey(),
                  todoCollection: todoCollection,
                );
              });
        },
      ),
      floatingActionButton: MainFloatingActionButton(
        icon: FluentIcons.add_24_regular,
        onPressed: openAddTodoCollectionPage,
      ),
    );
  }
}
