import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/firebase/auth.dart';
import 'package:flutter_time_management_app/firebase/functions.dart';
import 'package:flutter_time_management_app/widgets/main_text_field.dart';
import 'package:flutter_time_management_app/managers/dialog_manager.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';
import 'package:flutter_time_management_app/widgets/main_app_bar.dart';
import 'package:flutter_time_management_app/widgets/main_button.dart';
import 'package:flutter_time_management_app/widgets/no_internet_tile.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController emailTextEditingController =
      TextEditingController();
  bool online = false;
  ConnectivityResult result = ConnectivityResult.none;

  @override
  void initState() {
    super.initState();
    // Check internet connection
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

  // Send a reset password email
  void sendResetPasswordRequest() {
    if (AppStyles().checkEmptyString(emailTextEditingController.text)) {
      DialogManager()
          .displaySnackBar(context: context, text: "Please enter your email");
      return;
    }
    DialogManager().displayLoadingDialog(context: context);
    Auth().resetPassword(email: emailTextEditingController.text);
    DialogManager().closeDialog(context);
    Navigator.of(context).pop();
    Functions().revokeTokens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const MainAppBar(title: "Reset Password"),
      body: (online)
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: AppStyles.maxTextFieldWidth,
                      child: MainTextField(
                        style: Theme.of(context).textTheme.headline1,
                        controller: emailTextEditingController,
                        decoration: const InputDecoration(hintText: "Email"),
                      ),
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    MainButton(
                        text: "Send Reset Password Email",
                        onPressed: sendResetPasswordRequest),
                    const SizedBox(
                      height: 100.0,
                    )
                  ],
                ),
              ),
            )
          : const NoInternetTile(),
    );
  }
}
