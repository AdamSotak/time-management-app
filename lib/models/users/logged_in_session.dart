import 'package:cloud_firestore/cloud_firestore.dart';

class LoggedInSession {
  String id;
  String deviceOS;
  DateTime loggedIn;

  LoggedInSession(
      {required this.id, required this.deviceOS, required this.loggedIn});

  factory LoggedInSession.fromDocumentSnapshot(
      DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> data =
        documentSnapshot.data()! as Map<String, dynamic>;
    return LoggedInSession(
        id: documentSnapshot.id,
        deviceOS: data['deviceOS'],
        loggedIn: DateTime.fromMillisecondsSinceEpoch(
            data['loggedIn'].seconds * 1000));
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'deviceOS': deviceOS, 'loggedIn': loggedIn};
  }
}
