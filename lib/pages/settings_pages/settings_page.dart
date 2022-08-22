import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/app_storage/app_storage.dart';
import 'package:flutter_time_management_app/app_storage/app_theme_mode_change_notifier.dart';
import 'package:flutter_time_management_app/firebase/auth.dart';
import 'package:flutter_time_management_app/managers/dialog_manager.dart';
import 'package:flutter_time_management_app/managers/notification_manager.dart';
import 'package:flutter_time_management_app/models/users/user_data.dart';
import 'package:flutter_time_management_app/pages/login_page.dart';
import 'package:flutter_time_management_app/pages/settings_pages/change_user_password_page.dart';
import 'package:flutter_time_management_app/pages/settings_pages/delete_account_page.dart';
import 'package:flutter_time_management_app/pages/settings_pages/edit_user_account_page.dart';
import 'package:flutter_time_management_app/pages/settings_pages/logged_in_sessions_page.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';
import 'package:flutter_time_management_app/widgets/main_app_bar.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late ThemeMode themeMode;
  bool enableNotifications = true;
  late Future<UserData> getUserData;

  @override
  void initState() {
    super.initState();
    getUserData = Auth().getUserData();
    AppStorage().getThemeMode().then((value) {
      themeMode = value;
    });
    AppStorage().getEnableNotifications().then((value) {
      enableNotifications = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool photoSet = false;
    UserData userData = UserData(id: "id", displayName: "User", email: "", photoURL: "");
    // Navigate to EditUserAccountPage
    void editUser() {
      Navigator.of(context)
          .push(CupertinoPageRoute(
              builder: (builder) => EditUserAccountPage(
                    userData: userData,
                  )))
          .then((value) {
        setState(() {});
      });
    }

    // Navigate to ChangeUserPasswordPage
    void openChangePasswordPage() {
      Navigator.of(context).push(CupertinoPageRoute(builder: (builder) => const ChangeUserPasswordPage()));
    }

    // Navigate to LoggedInSessionsPage
    void openLoggedInSessionsPage() {
      Navigator.of(context).push(CupertinoPageRoute(builder: (builder) => const LoggedInSessionsPage()));
    }

    // Logout from the app
    void logout() {
      DialogManager().displayConfirmationDialog(
          context: context,
          description: "Logout from the app?",
          onConfirmation: () {
            Auth().signOut().then((value) {
              AppStorage().setLoggedInSessionId("");
              Navigator.of(context).pushReplacement(CupertinoPageRoute(builder: (builder) => const LoginPage()));
            });
          },
          onCancellation: () {});
    }

    // Navigates to DeleteAccountPage
    void openDeleteAccountPage() {
      Navigator.of(context).push(CupertinoPageRoute(builder: (builder) => const DeleteAccountPage()));
    }

    // Set app ThemeMode
    void setThemeMode(ThemeMode newThemeMode) {
      final provider = Provider.of<AppThemeModeChangeNotifier>(context, listen: false);
      provider.setTheme(newThemeMode);
      setState(() {
        themeMode = newThemeMode;
      });
      Navigator.of(context).pop();
    }

    // Set new enabled notifications value
    void setEnabledNotifications(bool value) async {
      AppStorage().setEnableNotifications(value);
      setState(() {
        enableNotifications = value;
      });
      if (value) {
        Map<String, int> result = await NotificationManager().scheduleAllNotifications();
        DialogManager().displaySnackBar(
            context: context,
            text: "Reminders - Scheduled: ${result["scheduled"]} \nNot Scheduled: ${result["notScheduled"]}");
      } else {
        NotificationManager().cancelAllNotifications();
      }
    }

    // Display ModalBottomSheet for choosing AppTheme
    void changeAppThemeModalBottomSheet() {
      DialogManager().displayModalBottomSheet(context: context, title: "App Theme", options: [
        ListTile(
          onTap: () {
            setThemeMode(ThemeMode.system);
          },
          leading: Icon(
            Icons.smartphone,
            color: Theme.of(context).iconTheme.color,
          ),
          title: Text(
            "Device default",
            style: Theme.of(context).textTheme.headline4,
          ),
        ),
        ListTile(
          onTap: () {
            setThemeMode(ThemeMode.dark);
          },
          leading: Icon(
            Icons.dark_mode,
            color: Theme.of(context).iconTheme.color,
          ),
          title: Text(
            "Dark",
            style: Theme.of(context).textTheme.headline4,
          ),
        ),
        ListTile(
          onTap: () {
            setThemeMode(ThemeMode.light);
          },
          leading: Icon(
            Icons.light_mode,
            color: Theme.of(context).iconTheme.color,
          ),
          title: Text(
            "Light",
            style: Theme.of(context).textTheme.headline4,
          ),
        ),
        ListTile(
          onTap: () {
            Navigator.of(context).pop();
          },
          leading: Icon(
            Icons.close,
            color: Theme.of(context).iconTheme.color,
          ),
          title: Text(
            "Close",
            style: Theme.of(context).textTheme.headline4,
          ),
        ),
      ]);
    }

    // Open Open-source page
    void openOpenSourcePage() {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (builder) => Theme(
            data: Theme.of(context).copyWith(
              appBarTheme: AppBarTheme(
                elevation: 0.0,
                iconTheme: Theme.of(context).iconTheme,
                backgroundColor:
                    AppThemeModeChangeNotifier().darkMode ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
                titleTextStyle: Theme.of(context).textTheme.headline1,
              ),
              primaryTextTheme: Theme.of(context).textTheme,
            ),
            child: const LicensePage(
              applicationName: "Todoable",
              applicationVersion: "Version 1.0.0",
              applicationLegalese: "\u00a9 Adam Soták 2022",
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: MainAppBar(title: "Settings", actionButtons: [
        IconButton(
          onPressed: editUser,
          icon: Icon(
            Icons.edit,
            color: Theme.of(context).iconTheme.color,
          ),
          splashRadius: AppStyles.buttonSplashRadius,
          tooltip: "Edit",
        )
      ]),
      body: FutureBuilder<UserData>(
        future: getUserData,
        builder: (BuildContext context, AsyncSnapshot<UserData> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong"),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          userData = snapshot.data!;

          // Check if user has chosen a profile photo
          if (userData.photoURL != AppStyles.defaultPhotoURLValue) {
            photoSet = true;
          }

          return ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(
                height: 10.0,
              ),
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
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
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
                        ))),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Column(
                  children: [
                    Text(
                      userData.displayName,
                      style: Theme.of(context).textTheme.headline1,
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      userData.email,
                      style: Theme.of(context).textTheme.headline1!.copyWith(fontSize: 15.0),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    ListTile(
                      onTap: openChangePasswordPage,
                      title: const Text("Change password"),
                    ),
                    ListTile(
                      onTap: openLoggedInSessionsPage,
                      title: const Text("Logged-in sessions"),
                      subtitle: const Text("Logged-in devices in the past 30 days"),
                    ),
                    SwitchListTile(
                      activeColor: AppStyles.accentColor,
                      activeTrackColor: AppStyles.accentColor.withOpacity(0.5),
                      title: const Text("Notifications"),
                      subtitle: const Text("Show reminders for events in calendar"),
                      value: enableNotifications,
                      onChanged: setEnabledNotifications,
                    ),
                    ListTile(
                      onTap: logout,
                      title: const Text("Logout"),
                      subtitle: const Text("Logout from this device"),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    ListTile(
                      onTap: changeAppThemeModalBottomSheet,
                      title: const Text("App Theme"),
                      subtitle: Text(AppStyles().getThemeModeString(themeMode)),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    ListTile(
                      onTap: openDeleteAccountPage,
                      title: const Text(
                        "Delete Account",
                        style: TextStyle(color: AppStyles.accentColor),
                      ),
                      subtitle: const Text(
                        "Delete account and remove all data",
                        style: TextStyle(color: AppStyles.accentColor),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    ListTile(
                      onTap: openOpenSourcePage,
                      title: const Text("Open-source licenses"),
                      subtitle: const Text("View open-source libraries"),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Text("Todoable v1.0.0", style: Theme.of(context).textTheme.caption),
                    Text("\u00a9 Adam Soták 2022", style: Theme.of(context).textTheme.caption),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
