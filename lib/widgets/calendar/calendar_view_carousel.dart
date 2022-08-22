import 'package:flutter/material.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';
import 'package:flutter_time_management_app/widgets/calendar/calendar_view.dart';

class CalendarViewCarousel extends StatefulWidget {
  const CalendarViewCarousel(
      {Key? key, required this.pageViewController, required this.selectedDateTime, required this.onDaySelectedFunction})
      : super(key: key);

  final PageController pageViewController;
  final DateTime selectedDateTime;
  final Function onDaySelectedFunction;

  @override
  State<CalendarViewCarousel> createState() => _CalendarViewCarouselState();
}

class _CalendarViewCarouselState extends State<CalendarViewCarousel> {
  DateTime currentPageDateTime = DateTime.now();

  // Displays CalendarViewCarousel widget
  @override
  Widget build(BuildContext context) {
    var pageViewController = widget.pageViewController;
    var onDaySelectedFunction = widget.onDaySelectedFunction;
    var selectedDateTime = widget.selectedDateTime;
    return PageView.builder(
      controller: pageViewController,
      pageSnapping: true,
      itemBuilder: ((context, index) {
        var dateTime = DateTime(currentPageDateTime.year,
            currentPageDateTime.month + (index - AppStyles.calendarViewCarouselInitialPage), currentPageDateTime.day);
        return CalendarView(
            dateTime: dateTime, selectedDateTime: selectedDateTime, onDaySelectedFunction: onDaySelectedFunction);
      }),
    );
  }
}
