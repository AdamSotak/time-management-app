import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_time_management_app/app_storage/app_storage.dart';
import 'package:flutter_time_management_app/firebase/database.dart';
import 'package:flutter_time_management_app/firebase/functions.dart';
import 'package:flutter_time_management_app/models/users/logged_in_session.dart';
import 'package:flutter_time_management_app/models/users/user_data.dart';
import 'package:flutter_time_management_app/pages/login_page.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';

class Auth {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Current user
  Stream<User?> get user {
    return auth.authStateChanges();
  }

  // Returns user id
  String getUserId() {
    return auth.currentUser!.uid;
  }

  // Returns UserData
  Future<UserData> getUserData() async {
    var user = auth.currentUser;
    UserData userData = UserData(
        id: user!.uid,
        displayName: user.displayName!,
        email: user.email!,
        photoURL: user.photoURL!);
    return userData;
  }

  // Create new account
  Future<String> createAccount(
      {required String email,
      required String password,
      required String displayName}) async {
    try {
      await auth
          .createUserWithEmailAndPassword(
              email: email.trim(), password: password)
          .then((value) async {
        await auth.currentUser
            ?.updateDisplayName(displayName)
            .then((value) async {
          await auth.currentUser
              ?.updatePhotoURL(AppStyles.defaultPhotoURLValue);
        });
      });
      return "";
    } on FirebaseAuthException catch (error) {
      return error.code;
    }
  }

  // Sign in
  Future<bool> signIn({required String email, required String password}) async {
    try {
      LoggedInSession loggedInSession = LoggedInSession(
          id: AppStyles().getUniqueKey(),
          deviceOS: AppStyles().getDeviceOS(),
          loggedIn: DateTime.now());
      // Save the LoggedInSession id to app storage
      await auth
          .signInWithEmailAndPassword(email: email.trim(), password: password)
          .then((value) {
        AppStorage().setLoggedInSessionId(loggedInSession.id);
        Database().addLoggedInSession(loggedInSession);
        AppStorage().setLogout(false);
      });
      return true;
    } catch (error) {
      log(error.toString());
      return false;
    }
  }

  // Sign out
  Future<bool> signOut() async {
    try {
      String loggedInSessionId = await AppStorage().getLoggedInSessionId();
      await Database().deleteUserToken(Auth().getUserId());
      AppStorage().setLogout(true);
      await Database().deleteLoggedInSession(loggedInSessionId);
      await auth.signOut();
      return true;
    } catch (error) {
      return false;
    }
  }

  // Change user password
  Future<bool> changePassword(
      {required String currentPassword, required String newPassword}) async {
    try {
      await auth.currentUser?.reauthenticateWithCredential(
          EmailAuthProvider.credential(
              email: auth.currentUser!.email.toString(),
              password: currentPassword));

      await auth.currentUser?.updatePassword(newPassword);
      return true;
    } catch (error) {
      log(error.toString());
      return false;
    }
  }

  // Send a password reset email
  Future<void> resetPassword({required String email}) async {
    await auth.sendPasswordResetEmail(email: email);
  }

  // Update user data
  Future<bool> updateUserData(
      {required String currentPassword, required UserData userData}) async {
    try {
      await auth.currentUser?.reauthenticateWithCredential(
          EmailAuthProvider.credential(
              email: auth.currentUser!.email.toString(),
              password: currentPassword));

      await auth.currentUser?.updateEmail(userData.email);
      await auth.currentUser?.updateDisplayName(userData.displayName);
      await auth.currentUser?.updatePhotoURL(userData.photoURL);
      return true;
    } catch (error) {
      log(error.toString());
      return false;
    }
  }

  // Update user photoURL
  Future<bool> updatePhotoURL({required String photoURL}) async {
    try {
      await auth.currentUser?.updatePhotoURL(photoURL);
      return true;
    } catch (error) {
      log(error.toString());
      return false;
    }
  }

  // Delete user account
  Future<bool> deleteAccount({required String currentPassword}) async {
    try {
      await auth.currentUser?.reauthenticateWithCredential(
          EmailAuthProvider.credential(
              email: auth.currentUser!.email.toString(),
              password: currentPassword));

      AppStorage().setLoggedInSessionId("");
      Functions().deleteUserData();
      return true;
    } catch (error) {
      log(error.toString());
      return false;
    }
  }

  // Check if the user is logged out of the app
  Future<void> checkLogout(BuildContext context) async {
    AppStorage().getLogout().then((value) {
      if (value) {
        Auth().signOut();
        AppStorage().setLogout(false);
        Navigator.of(context).pushReplacement(
            CupertinoPageRoute(builder: (builder) => const LoginPage()));
      }
    });
  }
}
