import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/models/enums/calendar_event_repetition.dart';
import 'package:flutter_time_management_app/models/enums/todo_collection_type.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AppStyles {
  // Values
  static const double buttonSplashRadius = 20.0;
  static const double gradientSelectorStartWidth = 2.0;
  static const double gradientSelectorEndWidth = 5.0;
  static const int calendarViewCarouselInitialPage = 1500;
  static const double mainButtonBorderRadius = 15.0;
  static const String defaultPhotoURLValue = "assets/images/profile_image.jpg";
  static const Duration animationDuration = Duration(milliseconds: 200);
  static const double maxTextFieldWidth = 500.0;

  // Colors
  static const Color accentColor = Colors.pinkAccent;
  static const Color splashColor = Color.fromARGB(255, 255, 255, 255);
  static const Color todoListTileBackgroundColor =
      Color.fromARGB(255, 102, 97, 104);
  static const Color listTileBackgroundColor =
      Color.fromARGB(255, 102, 97, 104);
  static const Color dropdownMenuColor = Color.fromARGB(255, 102, 97, 104);
  static const Color calendarDayColor = Color.fromARGB(255, 225, 225, 225);
  static const Color calendarDaySelectedColor =
      Color.fromARGB(255, 255, 255, 255);
  static const Color circleAvatarBackgroundColor =
      Color.fromARGB(255, 120, 120, 120);
  static const Color loadingOverlayBackgroundColor =
      Color.fromARGB(150, 0, 0, 0);

  // Styles
  static const dropdownMenuTextStyle =
      TextStyle(color: Colors.white, fontSize: 15.0);

  static const todoCollectionTypeEmojiTextStyle = TextStyle(fontSize: 25.0);

  // Text Formatting
  static const Map<String, TextStyle> textFormatting = {
    r'_(.*?)\_': TextStyle(fontStyle: FontStyle.italic),
    '~(.*?)~': TextStyle(decoration: TextDecoration.lineThrough),
    r'\*(.*?)\*': TextStyle(fontWeight: FontWeight.bold),
    r';(.*?);': TextStyle(decoration: TextDecoration.underline),
  };

  // Gradients
  static const LinearGradient mainAppBarLinearGradient = LinearGradient(
      colors: [
        Color.fromARGB(255, 161, 196, 253),
        Color.fromARGB(255, 194, 233, 251)
      ]);

  static const List<LinearGradient> linearGradients = [
    LinearGradient(colors: [
      Color.fromARGB(255, 242, 112, 155),
      Color.fromARGB(255, 255, 148, 114)
    ], begin: Alignment.topLeft, end: Alignment.bottomCenter),
    LinearGradient(colors: [
      Color.fromARGB(255, 161, 196, 253),
      Color.fromARGB(255, 194, 233, 251)
    ], begin: Alignment.topLeft, end: Alignment.bottomCenter),
    LinearGradient(colors: [
      Color.fromARGB(255, 247, 148, 165),
      Color.fromARGB(255, 253, 213, 189)
    ], begin: Alignment.topLeft, end: Alignment.bottomCenter),
    LinearGradient(colors: [
      Color.fromARGB(255, 185, 33, 255),
      Color.fromARGB(255, 33, 213, 253)
    ], begin: Alignment.topLeft, end: Alignment.bottomCenter),
    LinearGradient(colors: [
      Color.fromARGB(255, 161, 140, 209),
      Color.fromARGB(255, 251, 194, 235)
    ], begin: Alignment.topLeft, end: Alignment.bottomCenter),
    LinearGradient(colors: [
      Color.fromARGB(255, 251, 194, 235),
      Color.fromARGB(255, 166, 192, 238)
    ], begin: Alignment.topLeft, end: Alignment.bottomCenter),
  ];

  // BoxShadows
  static final BoxShadow boxShadow = BoxShadow(
      color: Colors.grey.withOpacity(0.2),
      blurRadius: 10,
      spreadRadius: 7,
      offset: const Offset(0.0, 3.0));

  // Enum Functions
  // Get TodoCollectionType from String
  TodoCollectionType getTodoCollectionType(String todoCollectionTypeString) {
    return TodoCollectionType.values.firstWhere(
        (element) => element.toString() == todoCollectionTypeString);
  }

  // Get CalendarEventRepetition from String
  CalendarEventRepetition getCalendarEventRepetition(
      String calendarEventRepetitionString) {
    return CalendarEventRepetition.values.firstWhere(
        (element) => element.toString() == calendarEventRepetitionString);
  }

  // Get ThemeMode from String
  ThemeMode getThemeMode(String themeModeString) {
    return ThemeMode.values
        .firstWhere((element) => element.toString() == themeModeString);
  }

  // Returns a coresponding String to CalendarEventRepetition value
  String getCalendarEventRepetitionString(
      CalendarEventRepetition calendarEventRepetition) {
    switch (calendarEventRepetition) {
      case CalendarEventRepetition.once:
        return "Once";
      case CalendarEventRepetition.everyDay:
        return "Every Day";
      case CalendarEventRepetition.everyWeek:
        return "Every Week";
      case CalendarEventRepetition.everyMonth:
        return "Every Month";
      case CalendarEventRepetition.everyYear:
        return "Every Year";
    }
  }

  // Returns a coresponding String to ThemeMode value
  String getThemeModeString(ThemeMode themeModeString) {
    switch (themeModeString) {
      case ThemeMode.system:
        return "Device default";
      case ThemeMode.dark:
        return "Dark";
      case ThemeMode.light:
        return "Light";
    }
  }

  // Functions
  // Convert Color to HEX String
  String toHex(Color color) {
    return '#${(color.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  // Returns a Date String formatted with / delimiter
  String getFormattedDateString(DateTime dateTime) {
    return DateFormat("dd/MM/yyyy").format(dateTime);
  }

  // Returns a Time String formatted with : delimiter
  String getFormattedTimeString(DateTime dateTime) {
    return DateFormat("HH:mm").format(dateTime);
  }

  // Returns a DateTime String formatted with / and : delimiters
  String getFormattedDateTimeString(DateTime dateTime) {
    return DateFormat("dd/MM/yyyy HH:mm").format(dateTime);
  }

  // Returns a month calendar name from DateTime
  String getMonthName(DateTime dateTime) {
    return DateFormat("MMMM").format(dateTime);
  }

  // Returns a week day name from DateTime
  String getDayOfWeekName(DateTime dateTime) {
    return DateFormat("EEEE").format(dateTime);
  }

  // Returns number of days in a month
  int getNumberOfDaysInMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month + 1, 0).day;
  }

  // Returns a cleaned DateTime
  DateTime cleanDateTime(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  // Returns a cleaned CalendarEvent DateTime
  DateTime getCalendarEventDateTime() {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // Checks if String contains empty characters after trimming
  bool checkEmptyStringTrim(String text) {
    if (text.isEmpty) {
      return true;
    }
    for (var character in text.split('')) {
      if (character == ' ') {
        return true;
      }
    }
    return false;
  }

  // Checks if String contains empty characters
  bool checkEmptyString(String text) {
    if (text.isEmpty) {
      return true;
    }
    for (var character in text.split('')) {
      if (character != ' ') {
        return false;
      }
    }
    return true;
  }

  // Returns device screen width in pixels
  double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // Returns device screen height in pixels
  double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Returns device SafeArea screen height
  double getScreenHeightSafeArea(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;
    return height - padding.top - padding.bottom;
  }

  // Checks if email matches a validation Regex
  bool checkEmailValidity(String email) {
    return RegExp(
            r'''(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])''')
        .hasMatch(email);
  }

  // Checks if device is in landscape mode
  bool checkLandscapeMode(BuildContext context) {
    return getScreenWidth(context) > getScreenHeight(context);
  }

  // Returns a unique UUID
  String getUniqueKey() {
    return const Uuid().v4();
  }

  // Get the difference between today and todo collection last refresh in days
  int getDifferenceFromTodayInDays(DateTime dateTime) {
    return DateTime.now().difference(dateTime).inDays;
  }

  // Get the difference between two datetimes
  int getDifferenceFromSelectedDateTimeInDays(
      DateTime dateTime, DateTime selectedDateTime) {
    return selectedDateTime.difference(dateTime).inDays;
  }

  // Get the number of days in a month
  int getDaysInMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month + 1, 0).day;
  }

  String getDeviceOS() {
    return "${Platform.operatingSystem} ${Platform.operatingSystemVersion}";
  }

  // Returns the DateTime of the last Monday in a month
  DateTime getLastMondayInMonth(DateTime dateTime) {
    var previousMonth = DateTime(dateTime.year, dateTime.month - 1);
    int days = getDaysInMonth(previousMonth);
    DateTime lastDateTime = DateTime.now();
    for (int i = 1; i <= days; i++) {
      if (getDayOfWeekName(
              DateTime(previousMonth.year, previousMonth.month, i)) ==
          "Monday") {
        lastDateTime = DateTime(previousMonth.year, previousMonth.month, i);
      }
    }
    return lastDateTime;
  }

  // Returns the DateTime difference in months
  int getDifferenceInMonths(DateTime now, DateTime selectedDateTime) {
    return (now.month -
        selectedDateTime.month +
        (12 * (now.year - selectedDateTime.year)));
  }
}
