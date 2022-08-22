import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/firebase/auth.dart';
import 'package:flutter_time_management_app/widgets/main_text_field.dart';
import 'package:flutter_time_management_app/managers/dialog_manager.dart';
import 'package:flutter_time_management_app/pages/create_account_page.dart';
import 'package:flutter_time_management_app/pages/home_page.dart';
import 'package:flutter_time_management_app/pages/reset_password_page.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';
import 'package:flutter_time_management_app/widgets/main_app_bar.dart';
import 'package:flutter_time_management_app/widgets/main_button.dart';
import 'package:flutter_time_management_app/widgets/no_internet_tile.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    void wrongCredentialsDialog() {
      DialogManager().closeDialog(context);
      // Show wrong credentials dialog
      DialogManager().displayDialog(
        context: context,
        title: "Wrong email or password",
        content: const Text("Please try again"),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK", style: Theme.of(context).textTheme.headline2!.copyWith(color: Colors.white)))
        ],
      );
    }

    void signIn() {
      // Check text values
      if (emailTextEditingController.text.isEmpty || passwordTextEditingController.text.isEmpty) {
        return;
      }

      DialogManager().displayLoadingDialog(context: context);

      // Sign in and continue to app
      Auth().signIn(email: emailTextEditingController.text, password: passwordTextEditingController.text).then((value) {
        if (value) {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(CupertinoPageRoute(builder: (builder) => const HomePage()));
        } else {
          emailTextEditingController.text = "";
          passwordTextEditingController.text = "";
          wrongCredentialsDialog();
        }
      });
    }

    // Open CreateNewAccountPage
    void openCreateNewAccountPage() {
      Navigator.of(context).push(CupertinoPageRoute(builder: (builder) => const CreateAccountPage()));
    }

    // Open ResetPasswordPage
    void openResetPasswordPage() {
      Navigator.of(context).push(CupertinoPageRoute(builder: (builder) => const ResetPasswordPage()));
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const MainAppBar(title: "Login"),
      body: (online)
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Todoable",
                      style:
                          GoogleFonts.greatVibes(color: Theme.of(context).textTheme.headline1!.color, fontSize: 100.0),
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
                    const SizedBox(
                      height: 30.0,
                    ),
                    MainButton(text: "Login", onPressed: signIn),
                    MainButton(
                      text: "Create new account",
                      onPressed: openCreateNewAccountPage,
                    ),
                    MainButton(
                      text: "Forgotten password",
                      onPressed: openResetPasswordPage,
                    ),
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
