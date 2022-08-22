import 'package:cloud_firestore/cloud_firestore.dart';

class UserToken {
  String fcmToken;

  UserToken({required this.fcmToken});

  factory UserToken.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> data =
        documentSnapshot.data()! as Map<String, dynamic>;
    return UserToken(fcmToken: data['fcm_token']);
  }

  Map<String, dynamic> toJson() {
    return {'fcm_token': fcmToken};
  }
}
