import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_time_management_app/firebase/auth.dart';
import 'package:flutter_time_management_app/models/users/logged_in_session.dart';
import 'package:flutter_time_management_app/models/users/user_token.dart';

class Database {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final String firestoreCollectionName = 'logged_in_sessions';
  final String firestoreUserTokenCollectionName = 'user_fcm_tokens';
  final String firestoreLoggedOutUsers = 'logged_out_users';

  // Get LoggedInSession Stream for loading LoggedInSessions
  Stream<QuerySnapshot> getLoggedInSessionsStream() {
    return firestore
        .collection(firestoreCollectionName)
        .doc(Auth().getUserId())
        .collection(firestoreCollectionName)
        .snapshots();
  }

  // Add a new LoggedInSession
  Future<void> addLoggedInSession(LoggedInSession loggedInSession) async {
    try {
      await firestore
          .collection(firestoreCollectionName)
          .doc(Auth().getUserId())
          .collection(firestoreCollectionName)
          .doc(loggedInSession.id)
          .set(loggedInSession.toJson());
    } catch (error) {
      log("Add LoggedInSession Error: $error");
    }
  }

  // Update an existing LoggedInSession
  Future<void> updateLoggedInSession(LoggedInSession loggedInSession) async {
    try {
      await firestore
          .collection(firestoreCollectionName)
          .doc(Auth().getUserId())
          .collection(firestoreCollectionName)
          .doc(loggedInSession.id)
          .set(loggedInSession.toJson());
    } catch (error) {
      log("Update LoggedInSession Error: $error");
    }
  }

  // Delete LoggedInSession
  Future<void> deleteLoggedInSession(String loggedInSessionId) async {
    try {
      await firestore
          .collection(firestoreCollectionName)
          .doc(Auth().getUserId())
          .collection(firestoreCollectionName)
          .doc(loggedInSessionId)
          .delete();
    } catch (error) {
      log("Remove LoggedInSession Error: $error");
    }
  }

  // Add a new UserToken
  Future<void> addUserToken(UserToken userToken) async {
    try {
      await firestore
          .collection(firestoreUserTokenCollectionName)
          .doc(Auth().getUserId())
          .collection(firestoreUserTokenCollectionName)
          .doc(userToken.fcmToken)
          .set(userToken.toJson());
    } catch (error) {
      log("Add UserToken Error: $error");
    }
  }

  // Update an existing UserToken
  Future<void> updateUserToken(UserToken userToken) async {
    try {
      await firestore
          .collection(firestoreUserTokenCollectionName)
          .doc(Auth().getUserId())
          .collection(firestoreUserTokenCollectionName)
          .doc(userToken.fcmToken)
          .set(userToken.toJson());
    } catch (error) {
      log("Update UserToken Error: $error");
    }
  }

  // Delete UserToken
  Future<void> deleteUserToken(String userId) async {
    try {
      await firestore
          .collection(firestoreUserTokenCollectionName)
          .doc(Auth().getUserId())
          .collection(firestoreUserTokenCollectionName)
          .doc(await FirebaseMessaging.instance.getToken())
          .delete();
    } catch (error) {
      log("Remove UserToken Error: $error");
    }
  }

  Future<void> userLoggedIn() async {
    try {
      await firestore
          .collection(firestoreLoggedOutUsers)
          .doc(Auth().getUserId())
          .set({"loggedOut": false});
    } catch (error) {
      log("User Logged In Error: $error");
    }
  }
}
