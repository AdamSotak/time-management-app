import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  final String appThemeModeKey = "app_theme_mode";
  final String loggedInSessionIdKey = "logged_in_session_id";
  final String enableNotificationsKey = "enable_notifications";
  final String logoutKey = "logout";

  // Save app theme mode to local storage
  Future<void> setThemeMode(ThemeMode appTheme) async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setString(appThemeModeKey, appTheme.toString());
  }

  // Get app theme mode from local storage
  Future<ThemeMode> getThemeMode() async {
    final preferences = await SharedPreferences.getInstance();
    try {
      return AppStyles()
          .getThemeMode(preferences.getString(appThemeModeKey).toString());
    } catch (error) {
      setThemeMode(ThemeMode.system);
      return ThemeMode.system;
    }
  }

  // Save current logged in session id to local storage
  Future<void> setLoggedInSessionId(String loggedInSessionId) async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setString(loggedInSessionIdKey, loggedInSessionId);
  }

  // Get current logged in session id from local storage
  Future<String> getLoggedInSessionId() async {
    final preferences = await SharedPreferences.getInstance();
    try {
      return preferences.getString(loggedInSessionIdKey).toString();
    } catch (error) {
      log(error.toString());
      return "";
    }
  }

  // Save enable notifications bool to local storage
  Future<void> setEnableNotifications(bool enableNotifications) async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setBool(enableNotificationsKey, enableNotifications);
  }

  // Get enable notifications bool from local storage
  Future<bool> getEnableNotifications() async {
    final preferences = await SharedPreferences.getInstance();
    try {
      return preferences.getBool(enableNotificationsKey)!;
    } catch (error) {
      setEnableNotifications(true);
      return true;
    }
  }

  // Save logout bool to local storage
  Future<void> setLogout(bool logout) async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setBool(logoutKey, logout);
  }

  // Get logout bool from local storage
  Future<bool> getLogout() async {
    final preferences = await SharedPreferences.getInstance();
    try {
      await preferences.reload();
      return preferences.getBool(logoutKey)!;
    } catch (error) {
      setEnableNotifications(false);
      return false;
    }
  }
}
