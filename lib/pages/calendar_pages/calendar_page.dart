import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/app_storage/app_theme_mode_change_notifier.dart';
import 'package:flutter_time_management_app/firebase/calendar_database.dart';
import 'package:flutter_time_management_app/managers/notification_manager.dart';
import 'package:flutter_time_management_app/models/calendar/calendar_event.dart';
import 'package:flutter_time_management_app/models/enums/calendar_event_repetition.dart';
import 'package:flutter_time_management_app/pages/calendar_pages/add_calendar_event_page.dart';
import 'package:flutter_time_management_app/widgets/calendar/calendar_view_carousel.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';
import 'package:flutter_time_management_app/widgets/calendar/calendar_event_tile.dart';
import 'package:flutter_time_management_app/widgets/main_app_bar.dart';
import 'package:flutter_time_management_app/widgets/main_floating_action_button.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final PageController pageViewController =
      PageController(initialPage: AppStyles.calendarViewCarouselInitialPage);
  DateTime selectedDateTime = AppStyles().cleanDateTime(DateTime.now());
  List<CalendarEvent> allCalendarEvents = [];
  List<CalendarEvent> calendarEvents = [];

  @override
  Widget build(BuildContext context) {
    NotificationManager().getAllNotifications();
    calendarEvents.clear();
    // Change the selected day
    void onDaySelected(DateTime selectedDayDateTime) {
      setState(() {
        calendarEvents = allCalendarEvents
            .where((event) => event.day == selectedDayDateTime)
            .toList();
        selectedDateTime = selectedDayDateTime;
        int months = AppStyles()
            .getDifferenceInMonths(DateTime.now(), selectedDayDateTime);
        pageViewController.animateToPage(
            AppStyles.calendarViewCarouselInitialPage - months,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeIn);
      });
    }

    // Navigate to AddCalendarEventPage
    void addCalendarEvent() {
      Navigator.of(context).push(CupertinoPageRoute(
          builder: (builder) => AddCalendarEventPage(
                calendarEventDateTime: selectedDateTime,
              )));
    }

    // Set the selected day to today and change the carousel
    void setToday() {
      onDaySelected(AppStyles().getCalendarEventDateTime());
      pageViewController.animateToPage(
          AppStyles.calendarViewCarouselInitialPage,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn);
    }

    // Set a chosen DateTime
    void setDate() {
      showCupertinoModalPopup(
        context: context,
        builder: (builder) => CupertinoTheme(
          data: CupertinoThemeData(
              textTheme: CupertinoTextThemeData(
                  dateTimePickerTextStyle: TextStyle(
                      fontSize: 25.0,
                      color: (AppThemeModeChangeNotifier().darkMode)
                          ? Colors.white
                          : Colors.black))),
          child: Container(
            height: 250.0,
            width: double.infinity,
            padding: const EdgeInsets.only(top: 10.0),
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: SafeArea(
                top: false,
                child: CupertinoDatePicker(
                  initialDateTime: selectedDateTime,
                  mode: CupertinoDatePickerMode.date,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime dateTime) {
                    setState(() {
                      selectedDateTime = dateTime;
                      calendarEvents = allCalendarEvents
                          .where((event) => event.day == dateTime)
                          .toList();
                      int months = AppStyles().getDifferenceInMonths(
                          DateTime.now(), selectedDateTime);
                      pageViewController.animateToPage(
                          AppStyles.calendarViewCarouselInitialPage - months,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeIn);
                    });
                  },
                )),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: MainAppBar(
        title: "Calendar",
        actionButtons: [
          IconButton(
            onPressed: setDate,
            icon: Icon(
              Icons.edit_calendar_rounded,
              color: Theme.of(context).iconTheme.color,
            ),
            splashRadius: AppStyles.buttonSplashRadius,
            tooltip: "Choose Date",
          ),
          IconButton(
            onPressed: setToday,
            icon: Icon(
              Icons.today,
              color: Theme.of(context).iconTheme.color,
            ),
            splashRadius: AppStyles.buttonSplashRadius,
            tooltip: "Today",
          )
        ],
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (notification) {
          notification.disallowIndicator();
          return true;
        },
        child: LayoutBuilder(builder: ((context, constraints) {
          var parentWidth = constraints.maxWidth;
          var parentHeight = constraints.maxHeight;
          return ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              Center(
                child: SizedBox(
                  width: parentWidth,
                  height: parentHeight * 0.7,
                  child: CalendarViewCarousel(
                    pageViewController: pageViewController,
                    selectedDateTime: selectedDateTime,
                    onDaySelectedFunction: onDaySelected,
                  ),
                ),
              ),
              Divider(
                thickness: Theme.of(context).dividerTheme.thickness,
              ),
              StreamBuilder(
                  stream: CalendarDatabase().getCalendarEventsStream(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    // Loading and error UI
                    if (snapshot.hasError) {
                      return const Center(child: Text("Something went wrong"));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Column(
                          children: const [
                            SizedBox(
                              height: 10.0,
                            ),
                            CircularProgressIndicator(),
                          ],
                        ),
                      );
                    }

                    // Loading and sorting calendar events
                    allCalendarEvents.clear();

                    allCalendarEvents = snapshot.data!.docs
                        .map((DocumentSnapshot documentSnapshot) {
                      var calendarEvent =
                          CalendarEvent.fromDocumentSnapshot(documentSnapshot);
                      return calendarEvent;
                    }).toList();

                    calendarEvents = allCalendarEvents
                        .where((event) =>
                            AppStyles().cleanDateTime(event.day) ==
                            selectedDateTime)
                        .toList();

                    // Checking for repeating calendar events
                    var repeatingCalendarEvents = allCalendarEvents
                        .where((element) =>
                            element.repetition !=
                                CalendarEventRepetition.once &&
                            element.day != selectedDateTime)
                        .toList();
                    for (var calendarEvent in repeatingCalendarEvents) {
                      int daysBetween = AppStyles()
                          .getDifferenceFromSelectedDateTimeInDays(
                              calendarEvent.day, selectedDateTime);
                      switch (calendarEvent.repetition) {
                        case CalendarEventRepetition.once:
                          break;
                        case CalendarEventRepetition.everyDay:
                          if (daysBetween > 0) {
                            calendarEvents.add(calendarEvent);
                          }
                          break;
                        case CalendarEventRepetition.everyWeek:
                          if (daysBetween % 7 == 0) {
                            calendarEvents.add(calendarEvent);
                          }
                          break;
                        case CalendarEventRepetition.everyMonth:
                          if (daysBetween ==
                              AppStyles().getDaysInMonth(selectedDateTime)) {
                            calendarEvents.add(calendarEvent);
                          }
                          break;
                        case CalendarEventRepetition.everyYear:
                          if (daysBetween % 365 == 0) {
                            calendarEvents.add(calendarEvent);
                          }
                          break;
                      }
                    }

                    if (calendarEvents.isEmpty) {
                      return TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: AppStyles.animationDuration,
                        builder: (context, value, _) => Opacity(
                          opacity: value,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Center(
                              child: Text(
                                "No Events",
                                style: Theme.of(context).textTheme.headline1,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: calendarEvents.length,
                        itemBuilder: ((context, index) {
                          return CalendarEventTile(
                            key: UniqueKey(),
                            calendarEvent: calendarEvents[index],
                          );
                        }));
                  })
            ],
          );
        })),
      ),
      floatingActionButton: MainFloatingActionButton(
          icon: FluentIcons.add_24_regular,
          onPressed: () {
            addCalendarEvent();
          }),
    );
  }
}
