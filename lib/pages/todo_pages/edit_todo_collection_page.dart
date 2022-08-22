import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/firebase/todo_database.dart';
import 'package:flutter_time_management_app/widgets/main_text_field.dart';
import 'package:flutter_time_management_app/managers/dialog_manager.dart';
import 'package:flutter_time_management_app/models/enums/todo_collection_type.dart';
import 'package:flutter_time_management_app/models/todos/todo_collection.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';
import 'package:flutter_time_management_app/widgets/main_app_bar.dart';
import 'package:flutter_time_management_app/widgets/main_floating_action_button.dart';
import 'package:flutter_time_management_app/widgets/todos/todo_collection_gradient_selector.dart';
import 'package:flutter_time_management_app/widgets/todos/todo_collection_type_selector.dart';

class EditTodoCollectionPage extends StatefulWidget {
  const EditTodoCollectionPage({Key? key, required this.todoCollection})
      : super(key: key);

  final TodoCollection todoCollection;

  @override
  State<EditTodoCollectionPage> createState() => _EditTodoCollectionPageState();
}

class _EditTodoCollectionPageState extends State<EditTodoCollectionPage> {
  final TextEditingController todoCollectionNameTextEditingController =
      TextEditingController();
  TodoCollectionType selectedTodoCollectionType = TodoCollectionType.primary;
  int linearGradientIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Set current values for editing
    var todoCollection = widget.todoCollection;
    setState(() {
      todoCollectionNameTextEditingController.text = todoCollection.name;
      selectedTodoCollectionType = todoCollection.collectionType;
      linearGradientIndex = todoCollection.linearGradientIndex;
    });

    // Edit TodoCollection
    void editTodoCollection() {
      if (AppStyles()
          .checkEmptyString(todoCollectionNameTextEditingController.text)) {
        DialogManager().displaySnackBar(
            context: context,
            text: "Please enter the name of the To-Do Collection");
        return;
      }
      todoCollection.name = todoCollectionNameTextEditingController.text;
      todoCollection.collectionType = selectedTodoCollectionType;
      todoCollection.linearGradientIndex = linearGradientIndex;
      TodoDatabase().updateTodoCollection(todoCollection);
      Navigator.of(context).pop();
    }

    // New TodoCollectionType selected
    void onTodoCollectionTypeChanged(TodoCollectionType todoCollectionType) {
      selectedTodoCollectionType = todoCollectionType;
    }

    // New Gradient for TodoCollection background selected
    void onGradientChanged(LinearGradient linearGradient) {
      linearGradientIndex = AppStyles.linearGradients.indexOf(linearGradient);
    }

    return Scaffold(
      appBar: const MainAppBar(title: "Edit To-Do Collection"),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          MainTextField(
            controller: todoCollectionNameTextEditingController,
            decoration: const InputDecoration(hintText: "Collection name"),
            style: Theme.of(context).textTheme.headline1,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20.0,
                ),
                Text(
                  "Collection type:",
                  style: Theme.of(context).textTheme.headline1,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                TodoCollectionTypeSelector(
                  selectedTodoCollectionType: selectedTodoCollectionType,
                  onTodoCollectionTypeChanged: onTodoCollectionTypeChanged,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Text(
                  "Collection color:",
                  style: Theme.of(context).textTheme.headline1,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                TodoCollectionGradientSelector(
                  selectedGradientIndex: linearGradientIndex,
                  onGradientChanged: onGradientChanged,
                ),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: MainFloatingActionButton(
          icon: Icons.done, onPressed: editTodoCollection),
    );
  }
}
