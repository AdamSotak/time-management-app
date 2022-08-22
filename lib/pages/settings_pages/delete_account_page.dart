import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/firebase/auth.dart';
import 'package:flutter_time_management_app/widgets/main_text_field.dart';
import 'package:flutter_time_management_app/managers/dialog_manager.dart';
import 'package:flutter_time_management_app/pages/login_page.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';
import 'package:flutter_time_management_app/widgets/main_app_bar.dart';
import 'package:flutter_time_management_app/widgets/no_internet_tile.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({Key? key}) : super(key: key);

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final TextEditingController currentPasswordTextEditingController =
      TextEditingController();
  bool deleteAccountCheckboxValue = false;
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

  // Deletes the account
  void deleteAccount() {
    if (AppStyles()
            .checkEmptyString(currentPasswordTextEditingController.text) ||
        !deleteAccountCheckboxValue) {
      DialogManager().displaySnackBar(
          context: context,
          text: "Please enter the required information and confirm");
      return;
    }

    DialogManager().displayLoadingDialog(context: context);

    Auth()
        .deleteAccount(
            currentPassword: currentPasswordTextEditingController.text)
        .then((value) {
      if (!value) {
        DialogManager().closeDialog(context);
        DialogManager().displayInformationDialog(
          context: context,
          title: "Wrong password",
          description: "Incorrect current password",
        );
      } else {
        DialogManager().closeDialog(context);
        Navigator.of(context).pushReplacement(
            CupertinoPageRoute(builder: (builder) => const LoginPage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: "Delete Account"),
      body: (online)
          ? Column(
              children: [
                MainTextField(
                  controller: currentPasswordTextEditingController,
                  style: Theme.of(context).textTheme.headline1,
                  decoration:
                      const InputDecoration(hintText: "Current Password"),
                  obscureText: true,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Text(
                        "Deleting an account is irreversible - it can't be undone. Please be sure.",
                        textAlign: TextAlign.justify,
                        style: Theme.of(context).textTheme.headline1,
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        children: [
                          Transform.scale(
                            scale: 1.5,
                            child: Checkbox(
                                shape: const CircleBorder(),
                                value: deleteAccountCheckboxValue,
                                onChanged: (bool? value) {
                                  setState(() {
                                    deleteAccountCheckboxValue = value!;
                                  });
                                }),
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          SizedBox(
                            width: 300.0,
                            child: Text(
                              "I am sure that I want to delete my account",
                              style: Theme.of(context).textTheme.headline1,
                              softWrap: true,
                              overflow: TextOverflow.clip,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: AppStyles.accentColor),
                              borderRadius: BorderRadius.circular(15.0)),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15.0),
                              onTap: deleteAccount,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  "Delete Account",
                                  style: Theme.of(context).textTheme.headline1,
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
                )
              ],
            )
          : const NoInternetTile(),
    );
  }
}
