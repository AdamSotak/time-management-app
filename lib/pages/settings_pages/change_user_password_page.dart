import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/firebase/auth.dart';
import 'package:flutter_time_management_app/firebase/functions.dart';
import 'package:flutter_time_management_app/widgets/main_text_field.dart';
import 'package:flutter_time_management_app/managers/dialog_manager.dart';
import 'package:flutter_time_management_app/pages/reset_password_page.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';
import 'package:flutter_time_management_app/widgets/main_app_bar.dart';
import 'package:flutter_time_management_app/widgets/main_button.dart';
import 'package:flutter_time_management_app/widgets/main_floating_action_button.dart';
import 'package:flutter_time_management_app/widgets/no_internet_tile.dart';

class ChangeUserPasswordPage extends StatefulWidget {
  const ChangeUserPasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangeUserPasswordPage> createState() => _ChangeUserPasswordPageState();
}

class _ChangeUserPasswordPageState extends State<ChangeUserPasswordPage> {
  final TextEditingController currentPasswordTextEditingController =
      TextEditingController();
  final TextEditingController newPasswordTextEditingController =
      TextEditingController();
  final TextEditingController newPasswordConfirmTextEditingController =
      TextEditingController();
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
    void changeUserPassword() async {
      // Check if TextFields are empty
      if (AppStyles()
              .checkEmptyString(currentPasswordTextEditingController.text) ||
          AppStyles().checkEmptyString(newPasswordTextEditingController.text) ||
          AppStyles()
              .checkEmptyString(newPasswordConfirmTextEditingController.text)) {
        DialogManager().displaySnackBar(
            context: context, text: "Please enter the required information");
        return;
      }

      // Check if new passwords match and prompt the user
      if (newPasswordTextEditingController.text !=
          newPasswordConfirmTextEditingController.text) {
        DialogManager().displayInformationDialog(
          context: context,
          title: "Error",
          description: "New passwords do not match",
        );
        return;
      }

      DialogManager().displayLoadingDialog(context: context);

      // Check current password and change password if allowed or prompt the user
      await Auth()
          .changePassword(
              currentPassword: currentPasswordTextEditingController.text,
              newPassword: newPasswordTextEditingController.text)
          .then((value) {
        if (!value) {
          DialogManager().closeDialog(context);
          DialogManager().displayInformationDialog(
            context: context,
            title: "Wrong password",
            description: "Incorrect current password",
          );
          return;
        } else {
          Functions().revokeTokens();
        }
      });
    }

    // Open ResetPasswordPage
    void openResetPasswordPage() {
      Navigator.of(context).push(
          CupertinoPageRoute(builder: (builder) => const ResetPasswordPage()));
    }

    return Scaffold(
      appBar: const MainAppBar(title: "Change Password"),
      body: (online)
          ? Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MainTextField(
                      controller: currentPasswordTextEditingController,
                      style: Theme.of(context).textTheme.headline1,
                      decoration:
                          const InputDecoration(hintText: "Current Password"),
                      obscureText: true,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    MainTextField(
                      controller: newPasswordTextEditingController,
                      style: Theme.of(context).textTheme.headline1,
                      decoration:
                          const InputDecoration(hintText: "New Password"),
                      obscureText: true,
                    ),
                    MainTextField(
                      controller: newPasswordConfirmTextEditingController,
                      style: Theme.of(context).textTheme.headline1,
                      decoration: const InputDecoration(
                          hintText: "Confirm New Password"),
                      obscureText: true,
                    ),
                    const SizedBox(
                      height: 50.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Text(
                            "You will be signed out after changing your password",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline1,
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            "Don't remember your password?\nPlease reset your password",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline1,
                          ),
                          MainButton(
                            text: "Reset Password",
                            onPressed: openResetPasswordPage,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 50.0,
                    ),
                  ],
                ),
              ),
            )
          : const NoInternetTile(),
      floatingActionButton: MainFloatingActionButton(
          icon: Icons.done, onPressed: changeUserPassword),
    );
  }
}
