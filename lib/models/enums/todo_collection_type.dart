enum TodoCollectionType { primary, complementary, backBurner }

class TodoCollectionTypeResolver {
  String getTodoCollectionTypeText(TodoCollectionType todoCollectionType) {
    switch (todoCollectionType) {
      case TodoCollectionType.primary:
        return "🔥";
      case TodoCollectionType.complementary:
        return "📈";
      case TodoCollectionType.backBurner:
        return "🍳";
    }
  }
}
