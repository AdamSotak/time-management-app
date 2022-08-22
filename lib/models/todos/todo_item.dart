class TodoItem {
  String id;
  String text;
  bool completed;
  bool newTodoItem;
  String collectionId;
  DateTime createdDateTime;

  TodoItem(
      {required this.id,
      required this.text,
      required this.completed,
      this.newTodoItem = false,
      required this.collectionId,
      required this.createdDateTime});

  TodoItem.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        text = json['text'],
        completed = json['completed'],
        newTodoItem = json['newTodoItem'],
        collectionId = json['collectionId'],
        createdDateTime = DateTime.fromMillisecondsSinceEpoch(
            json['createdDateTime'].seconds * 1000);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'completed': completed,
      'newTodoItem': newTodoItem,
      'collectionId': collectionId,
      'createdDateTime': createdDateTime
    };
  }
}
