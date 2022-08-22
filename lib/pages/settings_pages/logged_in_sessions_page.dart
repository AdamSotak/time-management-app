import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/firebase/database.dart';
import 'package:flutter_time_management_app/models/users/logged_in_session.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';
import 'package:flutter_time_management_app/widgets/main_app_bar.dart';
import 'package:flutter_time_management_app/widgets/users/logged_in_session_listview_tile.dart';

class LoggedInSessionsPage extends StatefulWidget {
  const LoggedInSessionsPage({Key? key}) : super(key: key);

  @override
  State<LoggedInSessionsPage> createState() => _LoggedInSessionsPageState();
}

class _LoggedInSessionsPageState extends State<LoggedInSessionsPage> {
  @override
  Widget build(BuildContext context) {
    List<LoggedInSession> loggedInSessions = [];
    return Scaffold(
      appBar: const MainAppBar(title: "Logged-In Sessions"),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: Database().getLoggedInSessionsStream(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              // Error and loading checking
              if (snapshot.hasError) {
                return const Center(
                  child: Text("Something went wrong"),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              loggedInSessions.clear();

              loggedInSessions.addAll(
                snapshot.data!.docs.map((DocumentSnapshot document) {
                  var loggedInSession =
                      LoggedInSession.fromDocumentSnapshot(document);

                  return loggedInSession;
                }),
              );

              for (var loggedInSession in loggedInSessions) {
                if (AppStyles().getDifferenceFromTodayInDays(
                        loggedInSession.loggedIn) >
                    30) {
                  Database().deleteLoggedInSession(loggedInSession.id);
                }
              }

              return Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: loggedInSessions.length,
                  itemBuilder: ((context, index) {
                    return LoggedInSessionListViewTile(
                      loggedInSession: loggedInSessions[index],
                    );
                  }),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: Text(
                "If you don't recognise a device, change your password.",
                style: Theme.of(context).textTheme.headline2,
              ),
            ),
          )
        ],
      ),
    );
  }
}
