import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/firebase/todo_database.dart';
import 'package:flutter_time_management_app/managers/dialog_manager.dart';
import 'package:flutter_time_management_app/models/enums/todo_collection_type.dart';
import 'package:flutter_time_management_app/models/todos/todo_collection.dart';
import 'package:flutter_time_management_app/pages/todo_pages/edit_todo_collection_page.dart';
import 'package:flutter_time_management_app/pages/todo_pages/todo_list_page.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';

class TodoCollectionListTile extends StatefulWidget {
  const TodoCollectionListTile({Key? key, required this.todoCollection}) : super(key: key);

  final TodoCollection todoCollection;

  @override
  State<TodoCollectionListTile> createState() => _TodoCollectionListTileState();
}

class _TodoCollectionListTileState extends State<TodoCollectionListTile> {
  double todoCollectionListTileOpacity = 1.0;
  bool animate = false;
  static bool start = true;

  @override
  void initState() {
    super.initState();
    start
        ? Future.delayed(Duration(milliseconds: AppStyles.animationDuration.inMilliseconds)).then((value) {
            setState(() {
              animate = true;
              start = false;
            });
          })
        : animate = true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var todoCollection = widget.todoCollection;
    var today = todoCollection.today;

    // Navigates to TodoListPage
    void openTodoListPage() {
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (builder) => TodoListPage(
            todoCollection: todoCollection,
          ),
        ),
      );
    }

    // Navigates to EditTodoCollectionPage
    void editTodoCollection() {
      Navigator.of(context).pop();
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (builder) => EditTodoCollectionPage(
            todoCollection: todoCollection,
          ),
        ),
      );
    }

    // Removes TodoCollection
    void removeTodoCollection() {
      Navigator.of(context).pop();
      DialogManager().displayConfirmationDialog(
          context: context,
          title: "Delete To-Do Collection?",
          description: "Delete ${todoCollection.name}?",
          onConfirmation: () {
            setState(() {
              todoCollectionListTileOpacity = 0.0;
            });
            Future.delayed(AppStyles.animationDuration).then((value) {
              TodoDatabase().deleteTodoCollection(todoCollection);
            });
          },
          onCancellation: () {});
    }

    // Displays ModalBottomSheet with TodoCollection options
    void openTodoCollectionOptions() {
      DialogManager().displayModalBottomSheet(
        context: context,
        title: "Options",
        options: [
          ListTile(
            leading: Icon(
              Icons.search,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text(
              "View",
              style: Theme.of(context).textTheme.headline4,
            ),
            onTap: () {
              Navigator.of(context).pop();
              openTodoListPage();
            },
          ),
          ListTile(
            leading: Icon(
              Icons.edit,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text(
              "Edit",
              style: Theme.of(context).textTheme.headline4,
            ),
            onTap: editTodoCollection,
          ),
          ListTile(
            leading: Icon(
              Icons.delete,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text(
              "Remove",
              style: Theme.of(context).textTheme.headline4,
            ),
            onTap: removeTodoCollection,
          ),
          ListTile(
            leading: Icon(
              Icons.close,
              color: Theme.of(context).iconTheme.color,
            ),
            title: Text(
              "Close",
              style: Theme.of(context).textTheme.headline4,
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
    }

    return AnimatedOpacity(
      duration: AppStyles.animationDuration,
      opacity: animate ? todoCollectionListTileOpacity : 0.0,
      child: Material(
        elevation: 10.0,
        color: Colors.transparent,
        shadowColor: Colors.grey.withOpacity(0.2),
        child: GestureDetector(
          onTap: openTodoListPage,
          child: Container(
            height: 150.0,
            margin: const EdgeInsets.all(10.0),
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                gradient: AppStyles.linearGradients[todoCollection.linearGradientIndex],
                borderRadius: const BorderRadius.all(Radius.circular(10.0))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todoCollection.name,
                      style: Theme.of(context).textTheme.headline1!.copyWith(fontSize: 25.0, color: Colors.white),
                    ),
                    const Padding(padding: EdgeInsets.all(5.0)),
                    Text(
                      (todoCollection.todoItems.length != 1)
                          ? "${TodoCollectionTypeResolver().getTodoCollectionTypeText(todoCollection.collectionType)} ${todoCollection.todoItems.length} To-Dos"
                          : "${TodoCollectionTypeResolver().getTodoCollectionTypeText(todoCollection.collectionType)} ${todoCollection.todoItems.length} To-Do",
                      style: Theme.of(context).textTheme.headline1!.copyWith(fontSize: 15.0, color: Colors.white),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    (!today)
                        ? IconButton(
                            alignment: Alignment.bottomLeft,
                            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 3.0),
                            icon: const Icon(
                              FluentIcons.more_vertical_24_regular,
                              color: Colors.white,
                            ),
                            splashRadius: AppStyles.buttonSplashRadius,
                            onPressed: openTodoCollectionOptions,
                          )
                        : const SizedBox(),
                    const IconButton(
                      alignment: Alignment.bottomRight,
                      padding: EdgeInsets.zero,
                      disabledColor: Colors.white,
                      splashRadius: AppStyles.buttonSplashRadius,
                      icon: Icon(
                        FluentIcons.arrow_right_24_regular,
                        size: 30.0,
                      ),
                      onPressed: null,
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
