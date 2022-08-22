import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_time_management_app/firebase/auth.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';

class Storage {
  final storage = FirebaseStorage.instance;

  final storageRef = FirebaseStorage.instance.ref();

  // Upload image to Firebase Storage
  Future<String> uploadImage(String imagePath) async {
    try {
      String imageName = "${Auth().getUserId()}profile";
      File file = File(imagePath);

      final storageImageRef = storageRef.child(imageName);

      await storageImageRef.putFile(file);

      return await storageImageRef.getDownloadURL();
    } catch (error) {
      log(error.toString());
      return "";
    }
  }

  // Delete image from Firebase Storage
  Future<bool> deleteImage(String url) async {
    try {
      final imageRef = storage.refFromURL(url);
      await imageRef.delete();
      await Auth().updatePhotoURL(photoURL: AppStyles.defaultPhotoURLValue);
      return true;
    } catch (error) {
      log(error.toString());
      return false;
    }
  }
}
