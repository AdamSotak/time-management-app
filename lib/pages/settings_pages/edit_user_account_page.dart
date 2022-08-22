import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/firebase/auth.dart';
import 'package:flutter_time_management_app/firebase/storage.dart';
import 'package:flutter_time_management_app/widgets/main_text_field.dart';
import 'package:flutter_time_management_app/managers/dialog_manager.dart';
import 'package:flutter_time_management_app/models/users/user_data.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';
import 'package:flutter_time_management_app/widgets/main_app_bar.dart';
import 'package:flutter_time_management_app/widgets/main_button.dart';
import 'package:flutter_time_management_app/widgets/main_floating_action_button.dart';
import 'package:flutter_time_management_app/widgets/no_internet_tile.dart';
import 'package:image_picker/image_picker.dart';

class EditUserAccountPage extends StatefulWidget {
  const EditUserAccountPage({Key? key, required this.userData}) : super(key: key);

  final UserData userData;

  @override
  State<EditUserAccountPage> createState() => _EditUserAccountPageState();
}

class _EditUserAccountPageState extends State<EditUserAccountPage> {
  final TextEditingController displayNameTextEditingController = TextEditingController();
  final TextEditingController emailTextEditingController = TextEditingController();
  final TextEditingController passwordTextEditingController = TextEditingController();

  bool online = false;
  ConnectivityResult result = ConnectivityResult.none;

  @override
  void initState() {
    super.initState();
    Connectivity().checkConnectivity().then((value) {
      setState(() {
        online = value != ConnectivityResult.none;
      });
    });
    Connectivity().onConnectivityChanged.listen((event) {
      setState(() {
        online = event != ConnectivityResult.none;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool photoSet = false;
    UserData userData = widget.userData;
    displayNameTextEditingController.text = userData.displayName;
    emailTextEditingController.text = userData.email;

    // Check if user has chosen a profile photo
    if (userData.photoURL != AppStyles.defaultPhotoURLValue) {
      photoSet = true;
    }

    void editUserAccount() {
      // Check for empty values
      if (AppStyles().checkEmptyString(displayNameTextEditingController.text) ||
          AppStyles().checkEmptyString(emailTextEditingController.text) ||
          AppStyles().checkEmptyString(passwordTextEditingController.text)) {
        DialogManager().displaySnackBar(context: context, text: "Please enter the required information");
        return;
      }

      // Check email validity
      if (!AppStyles().checkEmailValidity(emailTextEditingController.text)) {
        DialogManager().displayDialog(
            context: context,
            title: "Email not valid",
            content: const Text("The entered email is not valid"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK", style: Theme.of(context).textTheme.headline2!.copyWith(color: Colors.white)))
            ]);
        return;
      }

      DialogManager().displayLoadingDialog(context: context);

      userData.displayName = displayNameTextEditingController.text;
      userData.email = emailTextEditingController.text;
      Auth().updateUserData(currentPassword: passwordTextEditingController.text, userData: userData).then((value) {
        if (!value) {
          DialogManager().closeDialog(context);

          passwordTextEditingController.text = "";
          DialogManager().displayInformationDialog(
            context: context,
            title: "Wrong password",
            description: "Incorrect current password",
          );
          return;
        }
        DialogManager().closeDialog(context);
        Navigator.of(context).pop();
      });
    }

    void closeLoadingDialog() {
      DialogManager().closeDialog(context);
    }

    // Choose an image, upload it to Firebase Storage and update user profile photo URL
    void editProfileImage() async {
      final ImagePicker imagePicker = ImagePicker();
      final XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      DialogManager().displayLoadingDialog(context: context);
      String photoURL = await Storage().uploadImage(image.path);
      userData.photoURL = photoURL;
      await Auth().updatePhotoURL(photoURL: photoURL);
      closeLoadingDialog();
      setState(() {});
    }

    // Delete the profile image from Firebase Storage and set user profile photo URL to default
    void deleteProfileImage() async {
      DialogManager().displayLoadingDialog(context: context);

      if (userData.photoURL == AppStyles.defaultPhotoURLValue) {
        closeLoadingDialog();
        return;
      }
      await Storage().deleteImage(userData.photoURL);
      closeLoadingDialog();
      setState(() {
        userData.photoURL = AppStyles.defaultPhotoURLValue;
      });
    }

    return Scaffold(
      appBar: const MainAppBar(title: "Edit Account"),
      body: (online)
          ? SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 70.0,
                    backgroundColor: AppStyles.circleAvatarBackgroundColor,
                    child: (photoSet)
                        ? ClipOval(
                            child: Image.network(
                            userData.photoURL,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress != null) {
                                return const Center(
                                  child: CircularProgressIndicator(color: Colors.white),
                                );
                              }
                              return child;
                            },
                            fit: BoxFit.cover,
                            width: 140.0,
                          ))
                        : ClipOval(
                            child: Image.asset(
                            AppStyles.defaultPhotoURLValue,
                            fit: BoxFit.cover,
                            width: 140.0,
                          )),
                  ),
                  Column(
                    children: [
                      Center(
                        child: MainButton(
                          text: "Change Profile Image",
                          margin: const EdgeInsets.all(20.0),
                          onPressed: editProfileImage,
                        ),
                      ),
                      Center(
                        child: MainButton(
                            text: "Delete Profile Image",
                            margin: const EdgeInsets.only(bottom: 20.0),
                            onPressed: deleteProfileImage),
                      ),
                      MainTextField(
                        controller: displayNameTextEditingController,
                        style: Theme.of(context).textTheme.headline1,
                        decoration: const InputDecoration(hintText: "Username"),
                      ),
                      MainTextField(
                        controller: emailTextEditingController,
                        style: Theme.of(context).textTheme.headline1,
                        decoration: const InputDecoration(hintText: "Email"),
                      ),
                      MainTextField(
                        controller: passwordTextEditingController,
                        style: Theme.of(context).textTheme.headline1,
                        decoration: const InputDecoration(hintText: "Password for confirmation"),
                        obscureText: true,
                      ),
                    ],
                  ),
                ],
              ),
            )
          : const NoInternetTile(),
      floatingActionButton: MainFloatingActionButton(icon: Icons.done, onPressed: editUserAccount),
    );
  }
}
