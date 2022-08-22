import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/firebase/auth.dart';
import 'package:flutter_time_management_app/widgets/main_text_field.dart';
import 'package:flutter_time_management_app/managers/dialog_manager.dart';
import 'package:flutter_time_management_app/pages/home_page.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';
import 'package:flutter_time_management_app/widgets/main_app_bar.dart';
import 'package:flutter_time_management_app/widgets/main_button.dart';
import 'package:flutter_time_management_app/widgets/no_internet_tile.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({Key? key}) : super(key: key);

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController displayNameTextEditingController = TextEditingController();
  final TextEditingController emailTextEditingController = TextEditingController();
  final TextEditingController passwordTextEditingController = TextEditingController();
  final TextEditingController passwordConfirmTextEditingController = TextEditingController();
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

  void createAccount() async {
    // Check text values
    if (AppStyles().checkEmptyString(displayNameTextEditingController.text) ||
        AppStyles().checkEmptyString(emailTextEditingController.text) ||
        AppStyles().checkEmptyString(passwordTextEditingController.text) ||
        AppStyles().checkEmptyString(passwordConfirmTextEditingController.text)) {
      return;
    }

    // Check if email valid
    if (!AppStyles().checkEmailValidity(emailTextEditingController.text)) {
      emailTextEditingController.text = "";
      passwordTextEditingController.text = "";
      passwordConfirmTextEditingController.text = "";
      DialogManager().displayInformationDialog(
          context: context, title: "Email not valid", description: "The entered email is not valid");
      return;
    }

    // Check if new passwords match and prompt the user
    if (passwordTextEditingController.text != passwordConfirmTextEditingController.text) {
      passwordTextEditingController.text = "";
      passwordConfirmTextEditingController.text = "";
      DialogManager().displayInformationDialog(
        context: context,
        title: "Error",
        description: "New passwords do not match",
      );
      return;
    }

    DialogManager().displayLoadingDialog(context: context);

    // Create a new account and continue to app
    await Auth()
        .createAccount(
            email: emailTextEditingController.text,
            password: passwordTextEditingController.text,
            displayName: displayNameTextEditingController.text)
        .then((value) async {
      if (value != "") {
        emailTextEditingController.text = "";
        passwordTextEditingController.text = "";
        passwordConfirmTextEditingController.text = "";
      }

      if (value == "email-already-in-use") {
        DialogManager().displayInformationDialog(
          context: context,
          title: "Error",
          description: "Email is already in use by another account",
        );
        DialogManager().closeDialog(context);
        return;
      } else if (value == "invalid-email") {
        DialogManager().displayInformationDialog(
            context: context, title: "Email not valid", description: "The entered email is not valid");
        DialogManager().closeDialog(context);
        return;
      } else if (value == "weak-password") {
        DialogManager().displayInformationDialog(
          context: context,
          title: "Error",
          description: "New password is too weak",
        );
        DialogManager().closeDialog(context);
        return;
      }

      await Auth()
          .signIn(email: emailTextEditingController.text, password: passwordTextEditingController.text)
          .then((value) {
        if (value) {
          Navigator.of(context).pushReplacement(CupertinoPageRoute(builder: (builder) => const HomePage()));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: "Create new account"),
      body: (online)
          ? Center(
              child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: AppStyles.maxTextFieldWidth,
                          child: MainTextField(
                            style: Theme.of(context).textTheme.headline1,
                            controller: displayNameTextEditingController,
                            decoration: const InputDecoration(hintText: "Display Name"),
                          ),
                        ),
                        SizedBox(
                          width: AppStyles.maxTextFieldWidth,
                          child: MainTextField(
                            style: Theme.of(context).textTheme.headline1,
                            controller: emailTextEditingController,
                            decoration: const InputDecoration(hintText: "Email"),
                          ),
                        ),
                        SizedBox(
                          width: AppStyles.maxTextFieldWidth,
                          child: MainTextField(
                            style: Theme.of(context).textTheme.headline1,
                            controller: passwordTextEditingController,
                            obscureText: true,
                            decoration: const InputDecoration(hintText: "Password"),
                          ),
                        ),
                        SizedBox(
                          width: AppStyles.maxTextFieldWidth,
                          child: MainTextField(
                            style: Theme.of(context).textTheme.headline1,
                            controller: passwordConfirmTextEditingController,
                            obscureText: true,
                            decoration: const InputDecoration(hintText: "Confirm Password"),
                          ),
                        ),
                        const SizedBox(
                          height: 30.0,
                        ),
                        MainButton(text: "Create account", onPressed: createAccount)
                      ],
                    )),
              ),
            )
          : const NoInternetTile(),
    );
  }
}
