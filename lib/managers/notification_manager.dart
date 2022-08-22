import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_time_management_app/app_storage/app_storage.dart';
import 'package:flutter_time_management_app/firebase/auth.dart';
import 'package:flutter_time_management_app/firebase/calendar_database.dart';
import 'package:flutter_time_management_app/firebase/database.dart';
import 'package:flutter_time_management_app/models/calendar/calendar_event.dart';
import 'package:flutter_time_management_app/models/enums/calendar_event_repetition.dart';
import 'package:flutter_time_management_app/models/users/user_token.dart';
import 'package:flutter_time_management_app/pages/login_page.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';
import 'package:timezone/timezone.dart' as timezone;
import 'package:timezone/data/latest.dart' as timezone_latest;

class NotificationManager {
  static final notifications = FlutterLocalNotificationsPlugin();
  static const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
          "flutter_time_management_app", "Calendar Reminders",
          channelDescription: "Reminders for events added to calendar");
  static const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);

  // Schedule a notification when the app is not in the foreground
  void notificationsMessage(RemoteMessage message) {
    timezone_latest.initializeTimeZones();
    var data = message.data;
    var action = data['action'];
    var calendarEventJson = data['calendarEvent'];
    var calendarEventMap = json.decode(calendarEventJson);
    CalendarEvent calendarEvent = CalendarEvent.fromJson(calendarEventMap);

    switch (action) {
      case "create":
        scheduleNotification(calendarEvent);
        break;
      case "update":
        cancelNotification(calendarEvent.id);
        scheduleNotification(calendarEvent);
        break;
      case "delete":
        cancelNotification(calendarEvent.id);
        break;
      default:
        return;
    }
  }

  // Handle background Firebase message
  void firebaseOnBackgroundMessage(RemoteMessage message) {
    var data = message.data;
    var action = data['action'];
    if (action == "logout") {
      AppStorage().setLogout(true).then((value) {
        Auth().signOut();
      });
      return;
    }
    notificationsMessage(message);
  }

  // Handle foreground Firebase message
  void firebaseOnMessage(RemoteMessage message, BuildContext context) {
    var data = message.data;
    var action = data['action'];
    if (action == "logout") {
      Auth().signOut().then((value) {
        Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute(builder: (builder) => const LoginPage()),
            (route) => false);
      });
      return;
    }
    notificationsMessage(message);
  }

  // Reminders synchronization
  void firebaseMessaging(BuildContext context) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    UserToken userToken = UserToken(fcmToken: fcmToken.toString());
    Database().addUserToken(userToken);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppStorage().getLoggedInSessionId().then((value) {
        if (!AppStyles().checkEmptyString(value)) {
          firebaseOnMessage(message, context);
        }
      });
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      UserToken newUserToken = UserToken(fcmToken: token);
      Database().updateUserToken(newUserToken);
    });
  }

  // Initialize flutter_local_notifications
  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = IOSInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: iOS);

    await notifications.initialize(settings);
  }

  // Get list of all pending notifications
  Future<List<PendingNotificationRequest>> getAllNotifications() async {
    List<PendingNotificationRequest> allNotifications =
        await notifications.pendingNotificationRequests();
    return allNotifications;
  }

  // Check if a notification has been already set
  Future<bool> checkIfNotificationSet(CalendarEvent calendarEvent) async {
    var allNotifications = await getAllNotifications();
    if (allNotifications
        .where((element) => element.id == calendarEvent.id.hashCode)
        .toList()
        .isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  // Schedule all notifications
  Future<Map<String, int>> scheduleAllNotifications() async {
    int scheduledNotifications = 0;
    int notScheduledNotifications = 0;
    List<CalendarEvent> calendarEvents =
        await CalendarDatabase().getCalendarEvents();
    for (var calendarEvent in calendarEvents) {
      if (calendarEvent.remindTime.isBefore(DateTime.now())) {
        notScheduledNotifications++;
        continue;
      }

      if (calendarEvent.repetition == CalendarEventRepetition.once) {
        scheduledNotifications++;
        NotificationManager().scheduleNotificationOnce(calendarEvent);
      } else {
        scheduledNotifications++;
        NotificationManager().scheduleRepeatingNotification(calendarEvent);
      }
    }
    return {
      "scheduled": scheduledNotifications,
      "notScheduled": notScheduledNotifications
    };
  }

  // Remove a scheduled notification only if it has been already set
  Future<void> removeNotificationIfSet(CalendarEvent calendarEvent) async {
    bool notificationSet = await checkIfNotificationSet(calendarEvent);
    if (notificationSet) {
      cancelNotification(calendarEvent.id);
    }
  }

  // Cancel notification by id
  Future<bool> cancelNotification(String calendarEventId) async {
    try {
      await notifications.cancel(calendarEventId.hashCode);
      return true;
    } catch (error) {
      return false;
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await notifications.cancelAll();
  }

  // Schedule a notification for CalendarEvent
  Future<void> scheduleNotification(CalendarEvent calendarEvent) async {
    if (calendarEvent.repetition == CalendarEventRepetition.once) {
      scheduleNotificationOnce(calendarEvent);
    } else {
      scheduleRepeatingNotification(calendarEvent);
    }
  }

  // Schedule a one-time notfication
  Future<bool> scheduleNotificationOnce(CalendarEvent calendarEvent) async {
    if (calendarEvent.remindTime.isBefore(DateTime.now())) return false;

    if (!await AppStorage().getEnableNotifications()) return false;

    await notifications.zonedSchedule(
        calendarEvent.id.hashCode,
        calendarEvent.text,
        AppStyles().getCalendarEventRepetitionString(calendarEvent.repetition),
        timezone.TZDateTime.from(calendarEvent.remindTime, timezone.local).add(
          const Duration(seconds: 5),
        ),
        notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true);

    return true;
  }

  // Schedule a repeating notification
  Future<bool> scheduleRepeatingNotification(
      CalendarEvent calendarEvent) async {
    RepeatInterval repeatInterval;

    if (!await AppStorage().getEnableNotifications()) return false;

    switch (calendarEvent.repetition) {
      case CalendarEventRepetition.once:
        return false;
      case CalendarEventRepetition.everyDay:
        repeatInterval = RepeatInterval.daily;
        break;
      case CalendarEventRepetition.everyWeek:
        repeatInterval = RepeatInterval.weekly;
        break;
      case CalendarEventRepetition.everyMonth:
        return false;
      case CalendarEventRepetition.everyYear:
        return false;
    }

    scheduleNotificationOnce(calendarEvent);

    await notifications.periodicallyShow(
        calendarEvent.id.hashCode,
        calendarEvent.text,
        AppStyles().getCalendarEventRepetitionString(calendarEvent.repetition),
        repeatInterval,
        notificationDetails,
        androidAllowWhileIdle: true);

    return true;
  }
}
