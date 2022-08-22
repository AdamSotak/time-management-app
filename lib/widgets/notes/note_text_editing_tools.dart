import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/models/enums/text_editing_tool.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';

class NoteTextEditingTools extends StatefulWidget {
  const NoteTextEditingTools(
      {Key? key, required this.onTextEditingToolSelected})
      : super(key: key);

  final Function onTextEditingToolSelected;

  @override
  State<NoteTextEditingTools> createState() => _NoteTextEditingToolsState();
}

class _NoteTextEditingToolsState extends State<NoteTextEditingTools> {
  int fontSizeValue = 15;

  // Displays a NoteTextEditingTools menu
  @override
  Widget build(BuildContext context) {
    var onTextEditingToolSelected = widget.onTextEditingToolSelected;

    return Row(
      children: [
        IconButton(
          splashRadius: AppStyles.buttonSplashRadius,
          onPressed: () {
            onTextEditingToolSelected(TextEditingTool.bold);
          },
          icon: const Icon(FluentIcons.text_bold_24_regular),
          tooltip: "Bold",
        ),
        IconButton(
          splashRadius: AppStyles.buttonSplashRadius,
          onPressed: () {
            onTextEditingToolSelected(TextEditingTool.italic);
          },
          icon: const Icon(FluentIcons.text_italic_24_regular),
          tooltip: "Italic",
        ),
        IconButton(
          splashRadius: AppStyles.buttonSplashRadius,
          onPressed: () {
            onTextEditingToolSelected(TextEditingTool.underline);
          },
          icon: const Icon(FluentIcons.text_underline_24_regular),
          tooltip: "Underline",
        ),
        IconButton(
          splashRadius: AppStyles.buttonSplashRadius,
          onPressed: () {
            onTextEditingToolSelected(TextEditingTool.linethrough);
          },
          icon: const Icon(FluentIcons.text_strikethrough_24_regular),
          tooltip: "Linethrough",
        ),
        IconButton(
          splashRadius: AppStyles.buttonSplashRadius,
          onPressed: () {
            onTextEditingToolSelected(TextEditingTool.clear);
          },
          icon: const Icon(FluentIcons.clear_formatting_24_regular),
          tooltip: "Todo List",
        ),
      ],
    );
  }
}
