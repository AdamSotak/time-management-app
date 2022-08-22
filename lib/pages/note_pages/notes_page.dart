import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/firebase/auth.dart';
import 'package:flutter_time_management_app/firebase/note_database.dart';
import 'package:flutter_time_management_app/models/notes/note.dart';
import 'package:flutter_time_management_app/pages/note_pages/note_page.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';
import 'package:flutter_time_management_app/widgets/column_view.dart';
import 'package:flutter_time_management_app/widgets/main_app_bar.dart';
import 'package:flutter_time_management_app/widgets/main_floating_action_button.dart';
import 'package:flutter_time_management_app/widgets/no_data_tile.dart';
import 'package:flutter_time_management_app/widgets/notes/note_listview_tile.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  Widget build(BuildContext context) {
    List<Note> notes = [];

    // Navigate to AddNotePage and add Note
    void openAddNotePage() {
      Note note = Note(
          noteId: AppStyles().getUniqueKey(),
          userId: Auth().getUserId(),
          name: '',
          text: '',
          lastEdited: DateTime.now(),
          created: DateTime.now());
      NoteDatabase().addNote(note);
      Navigator.of(context)
          .push(CupertinoPageRoute(builder: (builder) => NotePage(note: note)));
    }

    return Scaffold(
      appBar: const MainAppBar(title: "Notes"),
      body: StreamBuilder(
          stream: NoteDatabase().getNotesStream(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            // Loading and error UI
            if (snapshot.hasError) {
              return const Center(child: Text("Something went wrong"));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      height: 10.0,
                    ),
                    CircularProgressIndicator(),
                  ],
                ),
              );
            }

            notes.clear();

            notes.addAll(snapshot.data!.docs.map((DocumentSnapshot document) {
              var todoCollection = Note.fromDocumentSnapshot(document);
              return todoCollection;
            }));

            if (notes.isEmpty) {
              return const NoDataTile(text: "No Notes Yet\nLet's Add Some");
            }

            return ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                ColumnView(
                    columns: 2,
                    widgets: List.generate(
                        notes.length,
                        (index) => Hero(
                            tag: 'heroWidget${notes[index].noteId}',
                            child: NoteListViewTile(
                              key: UniqueKey(),
                              note: notes[index],
                              noteNameTextEditingController:
                                  TextEditingController(),
                              noteTextTextEditingController:
                                  TextEditingController(),
                              onNoteDeleted: () {
                                setState(() {});
                              },
                            ))))
              ],
            );
          }),
      floatingActionButton: MainFloatingActionButton(
          icon: FluentIcons.add_24_regular, onPressed: openAddNotePage),
    );
  }
}
