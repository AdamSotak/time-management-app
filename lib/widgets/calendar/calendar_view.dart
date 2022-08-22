import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';

class CalendarView extends StatefulWidget {
  const CalendarView(
      {Key? key, required this.dateTime, required this.selectedDateTime, required this.onDaySelectedFunction})
      : super(key: key);

  final DateTime dateTime;
  final DateTime selectedDateTime;
  final Function onDaySelectedFunction;

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  @override
  Widget build(BuildContext context) {
    var dateTime = widget.dateTime;
    int monthDays = AppStyles().getNumberOfDaysInMonth(dateTime);
    int currentDay = 1;
    var onDaySelectedFunction = widget.onDaySelectedFunction;
    var selectedDateTime = widget.selectedDateTime;
    // Updates selected day
    void selectDay(DateTime newSelectedDateTime) {
      onDaySelectedFunction(newSelectedDateTime);
    }

    Widget getDayWidget(int day, int daysInMonth, BoxConstraints constraints) {
      var parentWidth = constraints.maxWidth;
      var width = (parentWidth / 7.0) - 4;
      var height = (parentWidth / 7.0) - 4;
      var fontSize = AppStyles().getScreenWidth(context) / 20.0;
      if (day > 0 && day <= daysInMonth) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 2.0),
          width: width,
          height: height,
          decoration: BoxDecoration(
              color: (currentDay == selectedDateTime.day &&
                      dateTime.month == selectedDateTime.month &&
                      dateTime.year == selectedDateTime.year)
                  ? AppStyles.calendarDaySelectedColor
                  : AppStyles.calendarDayColor,
              borderRadius: BorderRadius.circular(500.0)),
          child: Center(
            child: (currentDay == selectedDateTime.day &&
                    dateTime.month == selectedDateTime.month &&
                    dateTime.year == selectedDateTime.year)
                ? Text(
                    (currentDay).toString(),
                    style: Theme.of(context)
                        .textTheme
                        .headline1!
                        .copyWith(color: AppStyles.accentColor, fontWeight: FontWeight.bold, fontSize: fontSize),
                  )
                : Text(
                    (currentDay).toString(),
                    style: Theme.of(context)
                        .textTheme
                        .headline1!
                        .copyWith(color: const Color.fromARGB(255, 0, 0, 0), fontSize: fontSize),
                  ),
          ),
        );
      } else if (day > daysInMonth) {
        int nextDay = -(daysInMonth - day);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 2.0),
          width: width,
          height: height,
          decoration: BoxDecoration(
              color: (currentDay == selectedDateTime.day &&
                      dateTime.month == selectedDateTime.month &&
                      dateTime.year == selectedDateTime.year)
                  ? AppStyles.calendarDaySelectedColor
                  : const Color.fromARGB(255, 134, 134, 134),
              borderRadius: BorderRadius.circular(500.0)),
          child: Center(
            child: (currentDay == selectedDateTime.day &&
                    dateTime.month == selectedDateTime.month &&
                    dateTime.year == selectedDateTime.year)
                ? Text(
                    (nextDay).toString(),
                    style: Theme.of(context)
                        .textTheme
                        .headline1!
                        .copyWith(color: AppStyles.accentColor, fontWeight: FontWeight.bold, fontSize: fontSize),
                  )
                : Text(
                    (nextDay).toString(),
                    style: Theme.of(context)
                        .textTheme
                        .headline1!
                        .copyWith(color: const Color.fromARGB(255, 255, 255, 255), fontSize: fontSize),
                  ),
          ),
        );
      } else {
        int previousDay = AppStyles().getDaysInMonth(DateTime(dateTime.year, dateTime.month - 1)) + currentDay;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 2.0),
          width: width,
          height: height,
          decoration: BoxDecoration(
              color: (currentDay == selectedDateTime.day &&
                      dateTime.month == selectedDateTime.month &&
                      dateTime.year == selectedDateTime.year)
                  ? AppStyles.calendarDaySelectedColor
                  : const Color.fromARGB(255, 134, 134, 134),
              borderRadius: BorderRadius.circular(500.0)),
          child: Center(
            child: (currentDay == selectedDateTime.day &&
                    dateTime.month == selectedDateTime.month &&
                    dateTime.year == selectedDateTime.year)
                ? Text(
                    (previousDay).toString(),
                    style: Theme.of(context)
                        .textTheme
                        .headline1!
                        .copyWith(color: AppStyles.accentColor, fontWeight: FontWeight.bold, fontSize: fontSize),
                  )
                : Text(
                    (previousDay).toString(),
                    style: Theme.of(context)
                        .textTheme
                        .headline1!
                        .copyWith(color: const Color.fromARGB(255, 255, 255, 255), fontSize: fontSize),
                  ),
          ),
        );
      }
    }

    // Builds CalendarView widget
    List<Widget> buildCalendar({required BoxConstraints constraints}) {
      var lastMonday = AppStyles().getLastMondayInMonth(dateTime);
      var days = lastMonday.difference(DateTime(dateTime.year, dateTime.month, 0)).inDays;
      currentDay = days;
      if (currentDay <= -5) {
        currentDay = 1;
      }
      List<Widget> calendar = [];
      for (int i = 0; i < 5; i++) {
        List<Widget> calendarWeekRow = [];
        for (int day = 0; day < 7; day++) {
          if (currentDay > 35) {
            break;
          }
          int currentDayId = currentDay;
          calendarWeekRow.add(GestureDetector(
              onTap: () {
                DateTime currentDateTime = DateTime(dateTime.year, dateTime.month, currentDayId);
                selectDay(currentDateTime);
              },
              child: getDayWidget(currentDay, monthDays, constraints)));
          currentDay++;
        }
        calendar.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Row(
            mainAxisAlignment: (i == 4) ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: calendarWeekRow,
          ),
        ));
      }
      return calendar;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment:
            (AppStyles().checkLandscapeMode(context)) ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            "${AppStyles().getMonthName(dateTime)} ${dateTime.year}",
            style: Theme.of(context).textTheme.headline3!.copyWith(fontSize: 25.0),
          ),
          const Padding(padding: EdgeInsets.all(5.0)),
          AnimatedOpacity(
            opacity: (selectedDateTime.month == dateTime.month) ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Text(AppStyles().getDayOfWeekName(selectedDateTime), style: Theme.of(context).textTheme.headline3),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: LayoutBuilder(
              builder: ((context, constraints) {
                return Column(
                  children: buildCalendar(constraints: constraints),
                );
              }),
            ),
          )
        ],
      ),
    );
  }
}
