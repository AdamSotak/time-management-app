import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/models/todos/todo_item.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';

class TodoListTile extends StatefulWidget {
  const TodoListTile(
      {Key? key,
      required this.todoItem,
      this.newTodoItem = false,
      required this.onNewTodoItemEditingDone,
      required this.onNewTodoItemEditingCanceled,
      required this.onTodoItemCompletedValueChanged,
      required this.onRemoveTodoItem,
      required this.listViewAnimation})
      : super(key: key);
  final TodoItem todoItem;
  final bool newTodoItem;
  final Function onNewTodoItemEditingDone;
  final Function onNewTodoItemEditingCanceled;
  final Function onTodoItemCompletedValueChanged;
  final Function onRemoveTodoItem;
  final Animation<double> listViewAnimation;

  @override
  State<TodoListTile> createState() => _TodoListTileState();
}

class _TodoListTileState extends State<TodoListTile> with TickerProviderStateMixin {
  late AnimationController animationController;
  late Animation animation;
  final TextEditingController newTodoItemTextEditingController = TextEditingController();

  // Animation setup
  @override
  void initState() {
    super.initState();

    animationController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);

    final CurvedAnimation animationCurve = CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    animation = Tween(begin: 0.0, end: 1.0).animate(animationCurve)
      ..addListener(() {
        setState(() {});
      });
    animationController.forward(from: 0.0);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var todoItem = widget.todoItem;
    var newTodoItem = widget.newTodoItem;
    var onNewTodoItemEditingDone = widget.onNewTodoItemEditingDone;
    var onNewTodoItemEditingCanceled = widget.onNewTodoItemEditingCanceled;
    var onTodoItemCompletedValueChanged = widget.onTodoItemCompletedValueChanged;
    var onRemoveTodoItem = widget.onRemoveTodoItem;
    var listViewAnimation = widget.listViewAnimation;

    // Updates TodoItem Checkbox value
    void todoItemCheckboxChanged(bool? value) {
      setState(() {
        todoItem.completed = value!;
        animationController.forward(from: 0.0);
      });
      onTodoItemCompletedValueChanged(todoItem);
    }

    // Animated widget for adding a new TodoItem
    if (newTodoItem) {
      return SizeTransition(
        sizeFactor: listViewAnimation,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          margin: const EdgeInsets.all(10.0),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 200.0,
                  margin: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                  child: TextField(
                    controller: newTodoItemTextEditingController,
                    style: Theme.of(context).textTheme.headline1,
                    decoration: const InputDecoration(
                      hintText: "To-Do",
                    ),
                    maxLines: 1,
                    autofocus: true,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        FluentIcons.dismiss_24_regular,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      splashRadius: AppStyles.buttonSplashRadius,
                      onPressed: () {
                        onNewTodoItemEditingCanceled();
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        FluentIcons.checkmark_24_regular,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      splashRadius: AppStyles.buttonSplashRadius,
                      onPressed: () {
                        onNewTodoItemEditingDone(newTodoItemTextEditingController.text);
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(10.0),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
      child: Padding(
        padding: const EdgeInsets.all(12.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
              child: Stack(
                children: [
                  Text(todoItem.text, style: Theme.of(context).textTheme.headline1),
                  Stack(
                    children: [
                      Container(
                        transform: Matrix4.identity()..scale(animation.value, 1.0),
                        child: Text(
                          todoItem.text,
                          style: Theme.of(context).textTheme.headline1!.copyWith(
                                decorationThickness: 1.5,
                                color: Colors.transparent,
                                decorationColor: Theme.of(context).iconTheme.color,
                                decorationStyle: TextDecorationStyle.solid,
                                decoration: todoItem.completed ? TextDecoration.lineThrough : TextDecoration.none,
                              ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    onRemoveTodoItem(todoItem);
                  },
                  icon: Icon(
                    FluentIcons.dismiss_24_regular,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  splashRadius: AppStyles.buttonSplashRadius,
                ),
                Transform.scale(
                  scale: 1.5,
                  child: Checkbox(
                      shape: const CircleBorder(), value: todoItem.completed, onChanged: todoItemCheckboxChanged),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
