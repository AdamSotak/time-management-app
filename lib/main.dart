import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_time_management_app/app_storage/app_theme_mode_change_notifier.dart';
import 'package:flutter_time_management_app/firebase/auth.dart';
import 'package:flutter_time_management_app/firebase_options.dart';
import 'package:flutter_time_management_app/managers/notification_manager.dart';
import 'package:flutter_time_management_app/pages/home_page.dart';
import 'package:flutter_time_management_app/pages/login_page.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as timezone;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  NotificationManager().firebaseOnBackgroundMessage(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  timezone.initializeTimeZones();
  NotificationManager().initialize();
  GoogleFonts.config.allowRuntimeFetching = false;
  LicenseRegistry.addLicense(() async* {
    final robotoLicense = await rootBundle.loadString('assets/fonts/LICENSE-ROBOTO.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], robotoLicense);
  });
  LicenseRegistry.addLicense(() async* {
    final comfortaaLicense = await rootBundle.loadString('assets/fonts/OFL-Comfortaa.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], comfortaaLicense);
  });
  LicenseRegistry.addLicense(() async* {
    final greatVibesLicense = await rootBundle.loadString('assets/fonts/OFL-GreatVibes.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], greatVibesLicense);
  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return ChangeNotifierProvider(
      create: ((context) => AppThemeModeChangeNotifier()),
      builder: (context, _) {
        Provider.of<AppThemeModeChangeNotifier>(context);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const MainPage(),
          themeMode: AppThemeModeChangeNotifier.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            appBarTheme: AppBarTheme(titleTextStyle: GoogleFonts.comfortaa(color: Colors.black, fontSize: 25.0)),
            scaffoldBackgroundColor: Colors.white,
            bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.white),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: const Color.fromARGB(255, 30, 30, 30),
                elevation: 100.0,
                unselectedLabelStyle: GoogleFonts.comfortaa(color: Colors.white, fontSize: 12.0),
                selectedLabelStyle: GoogleFonts.comfortaa(color: Colors.black),
                unselectedItemColor: Colors.white,
                selectedItemColor: AppStyles.accentColor),
            cardTheme: const CardTheme(elevation: 10.0, color: Colors.white),
            radioTheme: RadioThemeData(fillColor: MaterialStateProperty.all(Colors.black)),
            iconTheme: const IconThemeData(color: Colors.black),
            progressIndicatorTheme: const ProgressIndicatorThemeData(color: Colors.black),
            inputDecorationTheme: InputDecorationTheme(
                contentPadding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0), borderSide: const BorderSide(color: Colors.transparent)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0), borderSide: const BorderSide(color: Colors.transparent)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(50.0)),
                hintStyle: TextStyle(color: Colors.black.withOpacity(0.5))),
            textSelectionTheme: TextSelectionThemeData(
                cursorColor: Colors.black,
                selectionColor: AppStyles.accentColor.withOpacity(0.7),
                selectionHandleColor: AppStyles.accentColor),
            checkboxTheme: CheckboxThemeData(fillColor: MaterialStateProperty.all(AppStyles.accentColor)),
            dividerTheme: DividerThemeData(color: Colors.grey.withOpacity(0.5), thickness: 0.5),
            listTileTheme: const ListTileThemeData(textColor: Colors.black),
            dialogTheme: DialogTheme(
                backgroundColor: const Color.fromARGB(255, 170, 170, 170),
                titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20.0),
                contentTextStyle: const TextStyle(color: Colors.white, fontSize: 15.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppStyles.mainButtonBorderRadius))),
            textButtonTheme: TextButtonThemeData(
                style: ButtonStyle(overlayColor: MaterialStateProperty.all(const Color.fromARGB(255, 200, 200, 200)))),
            textTheme: TextTheme(
              headline1: GoogleFonts.roboto(color: Colors.black, fontSize: 20.0, height: 1.2),
              headline2: GoogleFonts.roboto(color: Colors.black, fontSize: 15.0),
              headline3: GoogleFonts.comfortaa(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold),
              headline4: GoogleFonts.comfortaa(color: Colors.black, fontSize: 20.0),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            appBarTheme: AppBarTheme(titleTextStyle: GoogleFonts.comfortaa(color: Colors.white, fontSize: 25.0)),
            scaffoldBackgroundColor: const Color.fromARGB(255, 50, 47, 51),
            bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Color.fromARGB(255, 27, 25, 27)),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: const Color.fromARGB(255, 30, 30, 30),
                elevation: 100.0,
                unselectedLabelStyle: GoogleFonts.comfortaa(color: Colors.white, fontSize: 12.0),
                selectedLabelStyle: GoogleFonts.comfortaa(color: Colors.white),
                unselectedItemColor: Colors.white,
                selectedItemColor: AppStyles.accentColor),
            cardTheme: const CardTheme(elevation: 10.0, color: AppStyles.listTileBackgroundColor),
            radioTheme: RadioThemeData(fillColor: MaterialStateProperty.all(Colors.white)),
            iconTheme: const IconThemeData(color: Colors.white),
            progressIndicatorTheme: const ProgressIndicatorThemeData(color: Colors.white),
            inputDecorationTheme: InputDecorationTheme(
                contentPadding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0), borderSide: const BorderSide(color: Colors.transparent)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0), borderSide: const BorderSide(color: Colors.transparent)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(50.0)),
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5))),
            textSelectionTheme: TextSelectionThemeData(
                cursorColor: Colors.white,
                selectionColor: AppStyles.accentColor.withOpacity(0.7),
                selectionHandleColor: AppStyles.accentColor),
            checkboxTheme: CheckboxThemeData(fillColor: MaterialStateProperty.all(AppStyles.accentColor)),
            dividerTheme: const DividerThemeData(color: Colors.white, thickness: 0.5),
            listTileTheme: const ListTileThemeData(textColor: Colors.white),
            dialogTheme: DialogTheme(
                backgroundColor: const Color.fromARGB(255, 170, 170, 170),
                titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20.0),
                contentTextStyle: const TextStyle(color: Colors.white, fontSize: 15.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppStyles.mainButtonBorderRadius))),
            textButtonTheme: TextButtonThemeData(
                style: ButtonStyle(overlayColor: MaterialStateProperty.all(const Color.fromARGB(255, 200, 200, 200)))),
            textTheme: TextTheme(
              headline1: GoogleFonts.roboto(color: Colors.white, fontSize: 20.0, height: 1.2),
              headline2: GoogleFonts.roboto(color: Colors.white, fontSize: 15.0),
              headline3: GoogleFonts.comfortaa(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
              headline4: GoogleFonts.comfortaa(color: Colors.white, fontSize: 20.0),
            ),
          ),
        );
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().user,
      builder: ((context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.data?.uid == null) {
            return const LoginPage();
          } else {
            return const HomePage();
          }
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      }),
    );
  }
}
