import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_time_management_app/app_storage/app_storage.dart';

class AppThemeModeChangeNotifier with ChangeNotifier {
  AppThemeModeChangeNotifier() {
    AppStorage().getThemeMode().then((value) {
      themeMode = value;
      notifyListeners();
    });
  }

  static ThemeMode themeMode = ThemeMode.system;

  // Check if app has dark mode enabled
  bool get darkMode {
    if (themeMode == ThemeMode.system) {
      final brightness = SchedulerBinding.instance.window.platformBrightness;
      return brightness == Brightness.dark;
    } else {
      return themeMode == ThemeMode.dark;
    }
  }

  // Set new app ThemeMode and change the UI
  void setTheme(ThemeMode theme) async {
    AppStorage().setThemeMode(theme);
    themeMode = theme;
    notifyListeners();
  }
}
