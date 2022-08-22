import 'package:animations/animations.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/app_storage/app_storage.dart';
import 'package:flutter_time_management_app/firebase/auth.dart';
import 'package:flutter_time_management_app/firebase/database.dart';
import 'package:flutter_time_management_app/managers/notification_manager.dart';
import 'package:flutter_time_management_app/models/users/logged_in_session.dart';
import 'package:flutter_time_management_app/pages/calendar_pages/calendar_page.dart';
import 'package:flutter_time_management_app/pages/note_pages/notes_page.dart';
import 'package:flutter_time_management_app/pages/settings_pages/settings_page.dart';
import 'package:flutter_time_management_app/pages/todo_pages/todo_collections_page.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  static int currentBottomNavigationBarIndex = 0;
  late PageController _pageController;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await Auth().checkLogout(context);
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _pageController = PageController();

    Auth().checkLogout(context);

    Future.delayed(const Duration(seconds: 3), () {
      // Firebase Cloud Messaging for reminders synchronization
      NotificationManager().firebaseMessaging(context);

      // Update LoggedInSession with new loggedIn DateTime
      AppStorage().getLoggedInSessionId().then((value) {
        if (AppStyles().checkEmptyString(value)) return;
        LoggedInSession loggedInSession = LoggedInSession(
            id: value,
            deviceOS: AppStyles().getDeviceOS(),
            loggedIn: DateTime.now());
        Database().updateLoggedInSession(loggedInSession);
        // Schedule notifications on app startup
        NotificationManager().scheduleAllNotifications();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // List of main pages
    List<Widget> pages = const [
      TodoCollectionsPage(),
      NotesPage(),
      CalendarPage(),
      SettingsPage()
    ];

    return Scaffold(
      body: PageTransitionSwitcher(
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) =>
            FadeThroughTransition(
                animation: primaryAnimation,
                secondaryAnimation: secondaryAnimation,
                fillColor: const Color.fromARGB(255, 51, 55, 55),
                child: child),
        child: pages[currentBottomNavigationBarIndex],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(boxShadow: [AppStyles.boxShadow]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                setState(() {
                  currentBottomNavigationBarIndex = index;
                });
              },
              currentIndex: currentBottomNavigationBarIndex,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(FluentIcons.list_24_regular), label: "To-Do"),
                BottomNavigationBarItem(
                    icon: Icon(FluentIcons.note_24_regular), label: "Notes"),
                BottomNavigationBarItem(
                    icon: Icon(FluentIcons.calendar_month_24_regular),
                    label: "Calendar"),
                BottomNavigationBarItem(
                    icon: Icon(FluentIcons.settings_24_regular),
                    label: "Settings"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
