import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_time_management_app/models/enums/calendar_event_repetition.dart';
import 'package:flutter_time_management_app/styling/app_styles.dart';

class CalendarEvent {
  String id;
  String userId;
  String text;
  DateTime day;
  CalendarEventRepetition repetition;
  bool remind;
  DateTime remindTime;
  DateTime created;

  CalendarEvent(
      {required this.id,
      required this.userId,
      required this.text,
      required this.day,
      required this.repetition,
      required this.remind,
      required this.remindTime,
      required this.created});

  factory CalendarEvent.fromDocumentSnapshot(
      DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> data =
        documentSnapshot.data()! as Map<String, dynamic>;
    return CalendarEvent(
        id: documentSnapshot.id,
        userId: data['userId'] as String,
        text: data['text'] as String,
        day: DateTime.fromMillisecondsSinceEpoch(data['day'].seconds * 1000),
        repetition: AppStyles().getCalendarEventRepetition(data['repetition']),
        remind: data['remind'] == true,
        remindTime: DateTime.fromMillisecondsSinceEpoch(
            data['remindTime'].seconds * 1000),
        created: DateTime.fromMillisecondsSinceEpoch(
            data['created'].seconds * 1000));
  }

  CalendarEvent.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['userId'],
        text = json['text'],
        day = DateTime.fromMillisecondsSinceEpoch(json['day']['_seconds'] * 1000),
        repetition = AppStyles().getCalendarEventRepetition(json['repetition']),
        remind = json['remind'] == true,
        remindTime = DateTime.fromMillisecondsSinceEpoch(
            json['remindTime']['_seconds'] * 1000),
        created =
            DateTime.fromMillisecondsSinceEpoch(json['created']['_seconds'] * 1000);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'text': text,
      'day': day,
      'repetition': repetition.toString(),
      'remind': remind,
      'remindTime': remindTime,
      'created': created
    };
  }
}
