import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/app_storage/app_theme_mode_change_notifier.dart';
import 'package:flutter_time_management_app/firebase/auth.dart';
import 'package:flutter_time_management_app/firebase/calendar_database.dart';
import 'package:flutter_time_management_app/widgets/main_text_field.dart';
import 'package:flutter_time_management_app/managers/dialog_manager.dart';
import 'package:flutter_time_management_app/managers/notification_manager.dart';
import 'package:flutter_time_management_app/models/calendar/calendar_event.dart';
import 'package:flutter_time_management_app/models/enums/calendar_event_repetition.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';
import 'package:flutter_time_management_app/widgets/calendar/calendar_event_repetition_selector.dart';
import 'package:flutter_time_management_app/widgets/main_app_bar.dart';
import 'package:flutter_time_management_app/widgets/main_floating_action_button.dart';

class AddCalendarEventPage extends StatefulWidget {
  const AddCalendarEventPage({Key? key, required this.calendarEventDateTime})
      : super(key: key);

  final DateTime calendarEventDateTime;

  @override
  State<AddCalendarEventPage> createState() => _AddCalendarEventPageState();
}

class _AddCalendarEventPageState extends State<AddCalendarEventPage> {
  final TextEditingController calendarEventNameTextEditingController =
      TextEditingController();
  CalendarEventRepetition selectedCalendarEventRepetition =
      CalendarEventRepetition.once;
  DateTime eventTime = DateTime.now();
  bool remindCalendarEvent = true;
  DateTime now = DateTime.now();
  late DateTime currentReminderDateTime = DateTime(
      widget.calendarEventDateTime.year,
      widget.calendarEventDateTime.month,
      widget.calendarEventDateTime.day - 1,
      now.hour,
      now.minute + 2);

  @override
  void initState() {
    super.initState();
    if (currentReminderDateTime.isBefore(DateTime.now())) {
      remindCalendarEvent = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var calendarEventDateTime = widget.calendarEventDateTime;

    // Add a new Calendar Event
    void addCalendarEvent() async {
      if (AppStyles()
          .checkEmptyString(calendarEventNameTextEditingController.text)) {
        DialogManager().displaySnackBar(
            context: context, text: "Please enter the name of the event");
        return;
      }

      DateTime cleanDateTime = AppStyles().cleanDateTime(calendarEventDateTime);

      CalendarEvent calendarEvent = CalendarEvent(
          id: AppStyles().getUniqueKey(),
          userId: Auth().getUserId(),
          text: calendarEventNameTextEditingController.text,
          day: DateTime(cleanDateTime.year, cleanDateTime.month,
              cleanDateTime.day, eventTime.hour, eventTime.minute),
          repetition: selectedCalendarEventRepetition,
          remind: remindCalendarEvent,
          remindTime: currentReminderDateTime,
          created: DateTime.now());

      if (calendarEvent.remind &&
          calendarEvent.remindTime.isBefore(DateTime.now()) &&
          calendarEvent.repetition == CalendarEventRepetition.once) {
        DialogManager().displayInformationDialog(
            context: context,
            title: "Can't remind in the past",
            description:
                "Reminder time set in the past. Please set a time in the future or turn off reminder.");
        return;
      }

      if (calendarEvent.remind) {
        NotificationManager().scheduleNotification(calendarEvent);
      }

      CalendarDatabase().addCalendarEvent(calendarEvent);
      Navigator.of(context).pop();
    }

    // setState when new CalendarEventRepetition selected
    void onCalendarEventRepetitionSelected(
        CalendarEventRepetition calendarEventRepetition) {
      setState(() {
        selectedCalendarEventRepetition = calendarEventRepetition;
      });
    }

    return Scaffold(
      appBar: const MainAppBar(title: "Add Event"),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100.0),
        physics: const BouncingScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              AppStyles().getFormattedDateString(calendarEventDateTime),
              style: Theme.of(context)
                  .textTheme
                  .headline1!
                  .copyWith(fontSize: 25.0),
            ),
          ),
          MainTextField(
            controller: calendarEventNameTextEditingController,
            decoration: const InputDecoration(hintText: "Event"),
            style: Theme.of(context).textTheme.headline1,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: const Text("Choose Event Time"),
                  subtitle: Text(AppStyles().getFormattedTimeString(eventTime)),
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    Future.delayed(const Duration(milliseconds: 200), () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (builder) => CupertinoTheme(
                          data: CupertinoThemeData(
                              textTheme: CupertinoTextThemeData(
                                  dateTimePickerTextStyle: TextStyle(
                                      color: (AppThemeModeChangeNotifier()
                                              .darkMode)
                                          ? Colors.white
                                          : Colors.black))),
                          child: Container(
                            height: 250.0,
                            padding: const EdgeInsets.only(top: 6.0),
                            margin: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            color: CupertinoColors.systemBackground
                                .resolveFrom(context),
                            child: SafeArea(
                                top: false,
                                child: CupertinoDatePicker(
                                  initialDateTime: eventTime,
                                  mode: CupertinoDatePickerMode.dateAndTime,
                                  use24hFormat: true,
                                  onDateTimeChanged: (DateTime dateTime) {
                                    setState(() {
                                      eventTime = dateTime;
                                    });
                                  },
                                )),
                          ),
                        ),
                      );
                    });
                  },
                ),
                Text(
                  "Reminder",
                  style: Theme.of(context).textTheme.headline1,
                ),
                SwitchListTile(
                    activeColor: AppStyles.accentColor,
                    activeTrackColor: AppStyles.accentColor.withOpacity(0.5),
                    title: const Text("Remind Event"),
                    subtitle:
                        const Text("Schedule reminder at the selected time"),
                    value: remindCalendarEvent,
                    onChanged: (bool value) {
                      setState(() {
                        remindCalendarEvent = value;
                      });
                    }),
                ListTile(
                  title: const Text("Choose Reminder Time"),
                  subtitle: Text(AppStyles()
                      .getFormattedDateTimeString(currentReminderDateTime)),
                  enabled: remindCalendarEvent,
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    Future.delayed(const Duration(milliseconds: 200), () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (builder) => CupertinoTheme(
                          data: CupertinoThemeData(
                              textTheme: CupertinoTextThemeData(
                                  dateTimePickerTextStyle: TextStyle(
                                      color: (AppThemeModeChangeNotifier()
                                              .darkMode)
                                          ? Colors.white
                                          : Colors.black))),
                          child: Container(
                            height: 250.0,
                            padding: const EdgeInsets.only(top: 6.0),
                            margin: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            color: CupertinoColors.systemBackground
                                .resolveFrom(context),
                            child: SafeArea(
                                top: false,
                                child: CupertinoDatePicker(
                                  initialDateTime: currentReminderDateTime,
                                  mode: CupertinoDatePickerMode.dateAndTime,
                                  use24hFormat: true,
                                  onDateTimeChanged: (DateTime dateTime) {
                                    setState(() {
                                      currentReminderDateTime = dateTime;
                                    });
                                  },
                                )),
                          ),
                        ),
                      );
                    });
                  },
                ),
                Text(
                  "Repeat",
                  style: Theme.of(context).textTheme.headline1,
                ),
                CalendarEventRepetitionSelector(
                    calendarEventRepetition: selectedCalendarEventRepetition,
                    onCalendarEventRepetitionSelected:
                        onCalendarEventRepetitionSelected),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: MainFloatingActionButton(
          icon: Icons.done, onPressed: addCalendarEvent),
    );
  }
}
