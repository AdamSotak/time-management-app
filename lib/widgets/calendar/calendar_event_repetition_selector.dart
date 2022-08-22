import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/models/enums/calendar_event_repetition.dart';

class CalendarEventRepetitionSelector extends StatefulWidget {
  const CalendarEventRepetitionSelector(
      {Key? key,
      required this.calendarEventRepetition,
      required this.onCalendarEventRepetitionSelected})
      : super(key: key);

  final CalendarEventRepetition calendarEventRepetition;
  final Function onCalendarEventRepetitionSelected;

  @override
  State<CalendarEventRepetitionSelector> createState() =>
      _CalendarEventRepetitionSelectorState();
}

class _CalendarEventRepetitionSelectorState
    extends State<CalendarEventRepetitionSelector> {
  CalendarEventRepetition? calendarEventRepetitionValue =
      CalendarEventRepetition.once;

  @override
  Widget build(BuildContext context) {
    calendarEventRepetitionValue = widget.calendarEventRepetition;
    var onCalendarEventRepetitionSelected =
        widget.onCalendarEventRepetitionSelected;

    // Updates CalendarEventRepetition Value
    void setCalendarEventRepetitionValue(CalendarEventRepetition value) {
      setState(() {
        calendarEventRepetitionValue = value;
      });
      onCalendarEventRepetitionSelected(value);
    }

    return Column(
      children: [
        ListTile(
          title: Text(
            "Just Once",
            style: Theme.of(context).textTheme.headline4,
          ),
          subtitle: Text(
            "Event will only be added once",
            style:
                Theme.of(context).textTheme.headline4!.copyWith(fontSize: 15.0),
          ),
          trailing: Radio(
              value: CalendarEventRepetition.once,
              groupValue: calendarEventRepetitionValue,
              onChanged: (CalendarEventRepetition? value) {
                setCalendarEventRepetitionValue(value!);
              }),
        ),
        ListTile(
          title: Text(
            "Every Day",
            style: Theme.of(context).textTheme.headline4,
          ),
          subtitle: Text(
            "Repeats every day",
            style:
                Theme.of(context).textTheme.headline4!.copyWith(fontSize: 15.0),
          ),
          trailing: Radio(
              value: CalendarEventRepetition.everyDay,
              groupValue: calendarEventRepetitionValue,
              onChanged: (CalendarEventRepetition? value) {
                setCalendarEventRepetitionValue(value!);
              }),
        ),
        ListTile(
          title: Text(
            "Every Week",
            style: Theme.of(context).textTheme.headline4,
          ),
          subtitle: Text(
            "Repeats every week",
            style:
                Theme.of(context).textTheme.headline4!.copyWith(fontSize: 15.0),
          ),
          trailing: Radio(
              value: CalendarEventRepetition.everyWeek,
              groupValue: calendarEventRepetitionValue,
              onChanged: (CalendarEventRepetition? value) {
                setCalendarEventRepetitionValue(value!);
              }),
        ),
        ListTile(
          title: Text(
            "Every Month",
            style: Theme.of(context).textTheme.headline4,
          ),
          subtitle: Text(
            "Repeats every month",
            style:
                Theme.of(context).textTheme.headline4!.copyWith(fontSize: 15.0),
          ),
          trailing: Radio(
              value: CalendarEventRepetition.everyMonth,
              groupValue: calendarEventRepetitionValue,
              onChanged: (CalendarEventRepetition? value) {
                setCalendarEventRepetitionValue(value!);
              }),
        ),
        ListTile(
          title: Text(
            "Every Year",
            style: Theme.of(context).textTheme.headline4,
          ),
          subtitle: Text(
            "Repeats every year",
            style:
                Theme.of(context).textTheme.headline4!.copyWith(fontSize: 15.0),
          ),
          trailing: Radio(
              value: CalendarEventRepetition.everyYear,
              groupValue: calendarEventRepetitionValue,
              onChanged: (CalendarEventRepetition? value) {
                setCalendarEventRepetitionValue(value!);
              }),
        ),
      ],
    );
  }
}
