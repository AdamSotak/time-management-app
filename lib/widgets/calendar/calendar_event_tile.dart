import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/firebase/calendar_database.dart';
import 'package:flutter_time_management_app/models/calendar/calendar_event.dart';
import 'package:flutter_time_management_app/pages/calendar_pages/edit_calendar_event_page.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';

class CalendarEventTile extends StatefulWidget {
  const CalendarEventTile({Key? key, required this.calendarEvent})
      : super(key: key);

  final CalendarEvent calendarEvent;

  @override
  State<CalendarEventTile> createState() => _CalendarEventTileState();
}

class _CalendarEventTileState extends State<CalendarEventTile>
    with TickerProviderStateMixin {
  late final AnimationController animationController =
      AnimationController(duration: AppStyles.animationDuration, vsync: this)
        ..forward();
  late final Animation<double> animationOpacity =
      CurvedAnimation(parent: animationController, curve: Curves.easeIn);

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var calendarEvent = widget.calendarEvent;

    // Navigates to EditCalendarEventPage
    void openCalendarEventEditPage() async {
      await Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (builder) => EditCalendarEventPage(
            calendarEvent: calendarEvent,
          ),
        ),
      ).then((value) {
        // Delete CalendarEvent and fade out list tile
        if (value != null) {
          if (value) {
            animationController.reverse();
            Future.delayed(AppStyles.animationDuration).then((value) {
              CalendarDatabase().deleteCalendarEvent(calendarEvent);
            });
          }
        }
      });
    }

    return FadeTransition(
      opacity: animationOpacity,
      child: ListTile(
        onTap: openCalendarEventEditPage,
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (!calendarEvent.remind)
                ? Icon(
                    FluentIcons.calendar_agenda_24_regular,
                    color: Theme.of(context).iconTheme.color,
                    size: 30.0,
                  )
                : Icon(
                    FluentIcons.note_24_regular,
                    color: Theme.of(context).iconTheme.color,
                    size: 30.0,
                  ),
          ],
        ),
        title: Text(
          calendarEvent.text,
          style: Theme.of(context).textTheme.headline1,
        ),
        subtitle: Text(
          AppStyles().getFormattedTimeString(calendarEvent.day),
          style: Theme.of(context).textTheme.headline2,
        ),
      ),
    );
  }
}
