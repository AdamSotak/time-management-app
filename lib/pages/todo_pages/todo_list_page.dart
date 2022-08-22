import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/firebase/todo_database.dart';
import 'package:flutter_time_management_app/models/todos/todo_collection.dart';
import 'package:flutter_time_management_app/models/todos/todo_item.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';
import 'package:flutter_time_management_app/widgets/main_app_bar.dart';
import 'package:flutter_time_management_app/widgets/main_floating_action_button.dart';
import 'package:flutter_time_management_app/widgets/no_data_tile.dart';
import 'package:flutter_time_management_app/widgets/todos/todo_listview_tile.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key, required this.todoCollection})
      : super(key: key);

  final TodoCollection todoCollection;

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  bool newTodoItemAdding = false;
  late BuildContext animatedListBuildContext;
  final TextEditingController todoItemTextEditingController =
      TextEditingController();
  final _animatedListKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    var todoCollection = widget.todoCollection;
    todoCollection.todoItems;

    // Build a TodoListTile when an item is removed from AnimatedList
    Widget removeTodoItemBuilder(
        TodoItem todoItem, Animation<double> animation) {
      return TodoListTile(
        listViewAnimation: animation,
        todoItem: todoItem,
        onNewTodoItemEditingDone: (String newTodoItemText) {},
        onNewTodoItemEditingCanceled: () {},
        onTodoItemCompletedValueChanged: () {},
        onRemoveTodoItem: () {},
      );
    }

    // Add a new TodoItem to AnimatedList
    void addTodoItem() {
      if (newTodoItemAdding) return;
      setState(() {
        newTodoItemAdding = true;
      });
      int newTodoItemIndex = todoCollection.todoItems.length;
      TodoItem newTodoItem = TodoItem(
          id: AppStyles().getUniqueKey(),
          text: "",
          completed: false,
          newTodoItem: true,
          collectionId: todoCollection.id,
          createdDateTime: DateTime.now());
      todoCollection.todoItems.add(newTodoItem);
      _animatedListKey.currentState!.insertItem(newTodoItemIndex);
    }

    // When new TodoItem has been completed, save it to the database
    void onNewTodoItemEditingDone(String newTodoItemText) {
      var newTodoItem = todoCollection.todoItems.last;
      newTodoItem.text = newTodoItemText;
      newTodoItem.newTodoItem = false;
      TodoDatabase().updateTodoCollection(todoCollection);
    }

    // Update the TodoItem in the database with new completed value
    void onTodoItemCompletedValueChanged(TodoItem newTodoItem) {
      var todoItemIndex = todoCollection.todoItems.indexOf(newTodoItem);
      todoCollection.todoItems[todoItemIndex].completed = newTodoItem.completed;
      TodoDatabase().updateTodoCollection(todoCollection);
    }

    // Remove a TodoItem from AnimatedList and from the database
    void onRemoveTodoItem(TodoItem todoItem) {
      var index = todoCollection.todoItems.indexOf(todoItem);
      _animatedListKey.currentState!.removeItem(index, (context, animation) {
        return SizeTransition(
            sizeFactor: animation,
            child: removeTodoItemBuilder(todoItem, animation));
      });
      todoCollection.todoItems.remove(todoItem);
      TodoDatabase().updateTodoCollection(todoCollection);
      Future.delayed(const Duration(milliseconds: 300)).then((value) {
        setState(() {});
      });
    }

    return Scaffold(
      appBar: MainAppBar(title: todoCollection.name),
      body: Stack(
        children: [
          Visibility(
              visible: todoCollection.todoItems.isEmpty,
              child:
                  const NoDataTile(text: "No To-Do Tasks Yet\nLet's Add Some")),
          AnimatedList(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 100.0),
              key: _animatedListKey,
              initialItemCount: todoCollection.todoItems.length,
              itemBuilder: ((context, index, animation) {
                animatedListBuildContext = context;
                var todoItem = todoCollection.todoItems[index];
                return TodoListTile(
                  listViewAnimation: animation,
                  todoItem: todoItem,
                  newTodoItem: todoItem.newTodoItem,
                  onNewTodoItemEditingDone: (String newTodoItemText) {
                    newTodoItemAdding = false;
                    setState(() {
                      todoItem.text = newTodoItemText;
                      todoItem.newTodoItem = false;
                    });
                    onNewTodoItemEditingDone(newTodoItemText);
                  },
                  onNewTodoItemEditingCanceled: () {
                    AnimatedList.of(context).removeItem(index,
                        ((context, animation) {
                      return SizeTransition(
                          sizeFactor: animation,
                          child: removeTodoItemBuilder(todoItem, animation));
                    }));
                    Future.delayed(const Duration(milliseconds: 300))
                        .then((value) {
                      todoCollection.todoItems.removeAt(index);
                      setState(() {
                        newTodoItemAdding = false;
                      });
                    });
                  },
                  onTodoItemCompletedValueChanged:
                      onTodoItemCompletedValueChanged,
                  onRemoveTodoItem: onRemoveTodoItem,
                );
              })),
        ],
      ),
      floatingActionButton: MainFloatingActionButton(
        icon: FluentIcons.add_24_regular,
        onPressed: addTodoItem,
        scale: (newTodoItemAdding) ? 0.0 : 1.0,
      ),
    );
  }
}
