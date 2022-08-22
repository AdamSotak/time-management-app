import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/firebase/note_database.dart';
import 'package:flutter_time_management_app/managers/dialog_manager.dart';
import 'package:flutter_time_management_app/models/notes/note.dart';
import 'package:flutter_time_management_app/pages/note_pages/note_page.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';

class NoteListViewTile extends StatefulWidget {
  const NoteListViewTile(
      {Key? key,
      required this.note,
      this.edit = false,
      required this.noteNameTextEditingController,
      required this.noteTextTextEditingController,
      this.onNameChanged,
      this.onNoteDeleted})
      : super(key: key);

  final Note note;
  final bool edit;
  final TextEditingController noteNameTextEditingController;
  final TextEditingController noteTextTextEditingController;
  final Function? onNameChanged;
  final Function? onNoteDeleted;

  @override
  State<NoteListViewTile> createState() => _NoteListViewTileState();
}

class _NoteListViewTileState extends State<NoteListViewTile> {
  ScrollController scrollController = ScrollController();
  double noteListViewTileOpacity = 1.0;
  bool animate = false;
  static bool start = true;

  @override
  void initState() {
    super.initState();
    // Wait for the animation to finish
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
    var note = widget.note;
    var edit = widget.edit;
    var noteNameTextEditingController = widget.noteNameTextEditingController;
    var noteTextTextEditingController = widget.noteTextTextEditingController;
    var onNameChanged = widget.onNameChanged;
    var onNoteDeleted = widget.onNoteDeleted;

    // Navigates to NotePage
    void openNotePage() {
      if (edit) return;
      Navigator.of(context).push(CupertinoPageRoute(builder: (builder) => NotePage(note: note)));
    }

    void deleteNote() {
      DialogManager().displayConfirmationDialog(
          context: context,
          title: "Delete Note?",
          description: "Delete ${note.name}?",
          onConfirmation: () {
            setState(() {
              noteListViewTileOpacity = 0.0;
            });
            Future.delayed(const Duration(milliseconds: 300)).then((value) {
              NoteDatabase().deleteNote(note);
              if (onNoteDeleted != null) {
                onNoteDeleted();
              }
            });
          },
          onCancellation: () {});
    }

    // Displays ModalBottomSheet with Note options
    void openNoteOptions() {
      showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
          builder: (context) {
            return SizedBox(
              height: 210.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Options",
                      style: Theme.of(context).textTheme.headline3,
                    ),
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
                    onTap: () {
                      Navigator.of(context).pop();
                      openNotePage();
                    },
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
                    onTap: () {
                      Navigator.of(context).pop();
                      deleteNote();
                    },
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
              ),
            );
          });
    }

    // Setting values for editing
    noteNameTextEditingController.text = note.name;
    noteTextTextEditingController.text = note.text;

    return AnimatedOpacity(
      duration: AppStyles.animationDuration,
      opacity: (animate) ? noteListViewTileOpacity : 0.0,
      child: SingleChildScrollView(
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: (edit) ? null : openNotePage,
            onLongPress: (edit) ? null : openNoteOptions,
            child: Card(
              margin: const EdgeInsets.all(10.0),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        (edit)
                            ? TextField(
                                controller: noteNameTextEditingController,
                                style: Theme.of(context).textTheme.headline1,
                                maxLines: 1,
                                decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.all(5.0),
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    border: InputBorder.none,
                                    hintText: "Title"),
                                onTap: () {
                                  noteTextTextEditingController.selection =
                                      TextSelection.collapsed(offset: noteTextTextEditingController.text.length);
                                },
                                onChanged: (String value) {
                                  if (onNameChanged != null) {
                                    onNameChanged(value);
                                  }
                                },
                              )
                            : Text(
                                note.name,
                                style: Theme.of(context).textTheme.headline1,
                              ),
                        (!edit)
                            ? const Padding(padding: EdgeInsets.all(5.0))
                            : const Padding(padding: EdgeInsets.all(0.0)),
                        (edit)
                            ? SizedBox(
                                height: AppStyles().getScreenHeight(context) - 210.0,
                                child: Scrollbar(
                                  controller: scrollController,
                                  child: TextField(
                                    textAlign: TextAlign.justify,
                                    controller: noteTextTextEditingController,
                                    scrollController: scrollController,
                                    style: Theme.of(context).textTheme.headline2,
                                    maxLines: null,
                                    decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.all(5.0),
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        border: InputBorder.none,
                                        hintText: "..."),
                                    onTap: () {
                                      noteNameTextEditingController.selection =
                                          TextSelection.collapsed(offset: noteNameTextEditingController.text.length);
                                    },
                                  ),
                                ),
                              )
                            : Text(note.text, style: Theme.of(context).textTheme.headline1)
                      ],
                    ),
                    (!edit)
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                FluentIcons.arrow_right_24_regular,
                                size: 30.0,
                                color: Theme.of(context).iconTheme.color,
                              )
                            ],
                          )
                        : Row()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
