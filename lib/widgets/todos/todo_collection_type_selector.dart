import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/models/enums/todo_collection_type.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';

class TodoCollectionTypeSelector extends StatefulWidget {
  const TodoCollectionTypeSelector(
      {Key? key, required this.onTodoCollectionTypeChanged, required this.selectedTodoCollectionType})
      : super(key: key);

  final Function onTodoCollectionTypeChanged;
  final TodoCollectionType selectedTodoCollectionType;

  @override
  State<TodoCollectionTypeSelector> createState() => _TodoCollectionTypeSelectorState();
}

class _TodoCollectionTypeSelectorState extends State<TodoCollectionTypeSelector> {
  late TodoCollectionType? todoCollectionTypeValue = widget.selectedTodoCollectionType;

  @override
  Widget build(BuildContext context) {
    var onTodoCollectionTypeChanged = widget.onTodoCollectionTypeChanged;

    // Updates TodoCollectionType value
    void setTodoCollectionTypeValue(TodoCollectionType value) {
      setState(() {
        todoCollectionTypeValue = value;
      });
      onTodoCollectionTypeChanged(value);
    }

    return Column(
      children: [
        ListTile(
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "🔥",
                style: AppStyles.todoCollectionTypeEmojiTextStyle,
              ),
            ],
          ),
          title: Text(
            "Primary",
            style: Theme.of(context).textTheme.headline4,
          ),
          subtitle: Text(
            "Repeats every day",
            style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 15.0),
          ),
          trailing: Radio(
              value: TodoCollectionType.primary,
              groupValue: todoCollectionTypeValue,
              onChanged: (TodoCollectionType? value) {
                setTodoCollectionTypeValue(value!);
              }),
        ),
        ListTile(
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "📈",
                style: AppStyles.todoCollectionTypeEmojiTextStyle,
              ),
            ],
          ),
          title: Text(
            "Complementary",
            style: Theme.of(context).textTheme.headline4,
          ),
          subtitle: Text(
            "Repeats every week",
            style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 15.0),
          ),
          trailing: Radio(
              value: TodoCollectionType.complementary,
              groupValue: todoCollectionTypeValue,
              onChanged: (TodoCollectionType? value) {
                setTodoCollectionTypeValue(value!);
              }),
        ),
        ListTile(
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "🍳",
                style: AppStyles.todoCollectionTypeEmojiTextStyle,
              ),
            ],
          ),
          title: Text(
            "Back-burner",
            style: Theme.of(context).textTheme.headline4,
          ),
          subtitle: Text(
            "Repeats every month",
            style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 15.0),
          ),
          trailing: Radio(
            value: TodoCollectionType.backBurner,
            groupValue: todoCollectionTypeValue,
            onChanged: (TodoCollectionType? value) {
              setTodoCollectionTypeValue(value!);
            },
          ),
        ),
      ],
    );
  }
}
