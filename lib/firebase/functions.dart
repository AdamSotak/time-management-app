import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_time_management_app/firebase/auth.dart';

class Functions {
  final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

  // Revoke user tokens
  Future<void> revokeTokens() async {
    await functions.httpsCallable('revokeTokens').call();
  }

  // Delete user data when user deletes their account
  Future<void> deleteUserData() async {
    await functions.httpsCallable('deleteUserData').call();
    Auth().signOut();
  }
}
