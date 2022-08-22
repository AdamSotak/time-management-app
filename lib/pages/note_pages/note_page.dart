import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/firebase/note_database.dart';
import 'package:flutter_time_management_app/managers/dialog_manager.dart';
import 'package:flutter_time_management_app/managers/rich_text_editor_manager.dart';
import 'package:flutter_time_management_app/models/enums/text_editing_tool.dart';
import 'package:flutter_time_management_app/models/notes/note.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';
import 'package:flutter_time_management_app/widgets/main_app_bar.dart';
import 'package:flutter_time_management_app/widgets/notes/note_listview_tile.dart';
import 'package:flutter_time_management_app/widgets/notes/note_text_editing_tools.dart';

class NotePage extends StatefulWidget {
  const NotePage({Key? key, required this.note}) : super(key: key);

  final Note note;

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  TextEditingController noteNameTextEditingController = RichTextEditorManager(AppStyles.textFormatting);

  TextEditingController noteTextTextEditingController = RichTextEditorManager(AppStyles.textFormatting);

  @override
  Widget build(BuildContext context) {
    var note = widget.note;

    void replaceText(String textFormatting) {
      int indexName = noteNameTextEditingController.selection.end + 1;
      int indexText = noteTextTextEditingController.selection.end + 1;
      int noteNameStart = noteNameTextEditingController.selection.start;
      int noteNameEnd = noteNameTextEditingController.selection.end;
      int noteTextStart = noteTextTextEditingController.selection.start;
      int noteTextEnd = noteTextTextEditingController.selection.end;
      String noteNameText = noteNameTextEditingController.text;
      String noteTextText = noteTextTextEditingController.text;

      // Check for invalid text selection in note name
      if (noteNameStart != noteNameEnd) {
        var noteNameSelection = noteNameTextEditingController.selection.textInside(noteNameText);
        String noteNameTextFormatting = "$textFormatting$noteNameSelection$textFormatting";

        // Check if String empty
        if (!AppStyles().checkEmptyString(noteNameSelection)) {
          // Format note name
          if (noteNameStart == 0 || noteNameEnd == noteNameText.length) {
            noteNameTextEditingController.text =
                noteNameText.replaceRange(noteNameStart, noteNameEnd, noteNameTextFormatting);
          } else {
            var prevCharacter = noteNameText[noteNameStart - 1];
            var nextCharacter = noteNameText[noteNameEnd];
            if (prevCharacter == " " && nextCharacter == " ") {
              noteNameTextEditingController.text =
                  noteNameText.replaceRange(noteNameStart, noteNameEnd, noteNameTextFormatting);
            } else {
              noteNameTextEditingController.text =
                  noteNameText.replaceRange(noteNameStart - 1, noteNameEnd + 1, noteNameTextFormatting);
            }
          }
        }

        noteNameTextEditingController.selection = TextSelection.collapsed(offset: indexName - 1);
      }

      // Check for invalid text selection in note text
      {
        if (noteTextStart != noteTextEnd) {
          var noteTextSelection = noteTextTextEditingController.selection.textInside(noteTextText);
          String noteTextTextFormatting = "$textFormatting$noteTextSelection$textFormatting";

          // Check if String empty
          if (!AppStyles().checkEmptyString(noteTextSelection)) {
            // Format note text
            if (noteTextStart == 0 || noteTextEnd == noteTextText.length) {
              noteTextTextEditingController.text =
                  noteTextText.replaceRange(noteTextStart, noteTextEnd, noteTextTextFormatting);
            } else {
              var prevCharacter = noteTextText[noteTextStart - 1];
              var nextCharacter = noteTextText[noteTextEnd];
              if (prevCharacter == " " && nextCharacter == " ") {
                noteTextTextEditingController.text =
                    noteTextText.replaceRange(noteTextStart, noteTextEnd, noteTextTextFormatting);
              } else {
                noteTextTextEditingController.text =
                    noteTextText.replaceRange(noteTextStart - 1, noteTextEnd + 1, noteTextTextFormatting);
              }
            }
          }

          noteTextTextEditingController.selection = TextSelection.collapsed(offset: indexText - 1);
        }
      }
    }

    // New TextEditingTool selected
    void onTextEditingToolSelected(TextEditingTool textEditingTool, {int fontSize = 12}) {
      switch (textEditingTool) {
        case TextEditingTool.bold:
          replaceText("*");
          break;
        case TextEditingTool.italic:
          replaceText("_");
          break;
        case TextEditingTool.underline:
          replaceText(";");
          break;
        case TextEditingTool.linethrough:
          replaceText("~");
          break;
        case TextEditingTool.clear:
          replaceText("");
          break;
      }
    }

    // Change name when not name changes
    void onNameChanged(String newName) {
      note.name = newName;
    }

    // Update the Note on back button press
    void onBackButtonPressed() {
      note.name = noteNameTextEditingController.text;
      note.text = noteTextTextEditingController.text;
      note.lastEdited = DateTime.now();
      NoteDatabase().updateNote(note);
      Navigator.of(context).pop();
    }

    // Delete not from the database
    void deleteNote() {
      DialogManager().displayConfirmationDialog(
          context: context,
          title: "Delete Note?",
          description: "Delete ${note.name}?",
          onConfirmation: () {
            NoteDatabase().deleteNote(note);
            Navigator.of(context).pop();
          },
          onCancellation: () {});
    }

    return Scaffold(
      appBar: MainAppBar(
        title: (note.name.isEmpty) ? "Note" : note.name,
        onBackButtonPressed: onBackButtonPressed,
        actionButtons: [
          IconButton(
            onPressed: deleteNote,
            icon: Icon(
              FluentIcons.delete_24_regular,
              color: Theme.of(context).iconTheme.color,
            ),
            splashRadius: AppStyles.buttonSplashRadius,
            tooltip: "Delete",
          )
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          onBackButtonPressed();
          return true;
        },
        child: Column(
          children: [
            NoteTextEditingTools(
              onTextEditingToolSelected: onTextEditingToolSelected,
            ),
            Expanded(
              child: Hero(
                tag: 'heroWidget${note.noteId}',
                child: NoteListViewTile(
                  note: note,
                  edit: true,
                  noteNameTextEditingController: noteNameTextEditingController,
                  noteTextTextEditingController: noteTextTextEditingController,
                  onNameChanged: onNameChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
