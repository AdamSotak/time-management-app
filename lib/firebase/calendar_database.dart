import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_time_management_app/firebase/auth.dart';
import 'package:flutter_time_management_app/models/calendar/calendar_event.dart';

class CalendarDatabase {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final String firestoreCollectionName = "calendar_events";

  // Get the CalendarEvent Stream for loading calendar events
  Stream<QuerySnapshot> getCalendarEventsStream() {
    return firestore
        .collection(firestoreCollectionName)
        .doc(Auth().getUserId())
        .collection(firestoreCollectionName)
        .where('userId', isEqualTo: Auth().getUserId())
        .snapshots();
  }

  // Get CalendarEvent data once
  Future<List<CalendarEvent>> getCalendarEvents() async {
    var calendarEventsFirebase = await firestore
        .collection(firestoreCollectionName)
        .doc(Auth().getUserId())
        .collection(firestoreCollectionName)
        .where('userId', isEqualTo: Auth().getUserId())
        .get();

    return calendarEventsFirebase.docs.map((DocumentSnapshot documentSnapshot) {
      var calendarEvent = CalendarEvent.fromDocumentSnapshot(documentSnapshot);
      return calendarEvent;
    }).toList();
  }

  // Add a new CalendarEvent
  Future<void> addCalendarEvent(CalendarEvent calendarEvent) async {
    try {
      await firestore
          .collection(firestoreCollectionName)
          .doc(Auth().getUserId())
          .collection(firestoreCollectionName)
          .doc(calendarEvent.id)
          .set(calendarEvent.toJson());
    } catch (error) {
      log(error.toString());
    }
  }

  // Update an existing CalendarEvent
  Future<void> updateCalendarEvent(CalendarEvent calendarEvent) async {
    try {
      await firestore
          .collection(firestoreCollectionName)
          .doc(Auth().getUserId())
          .collection(firestoreCollectionName)
          .doc(calendarEvent.id)
          .set(calendarEvent.toJson());
    } catch (error) {
      log(error.toString());
    }
  }

  // Delete CalendarEvent
  Future<void> deleteCalendarEvent(CalendarEvent calendarEvent) async {
    try {
      await firestore
          .collection(firestoreCollectionName)
          .doc(Auth().getUserId())
          .collection(firestoreCollectionName)
          .doc(calendarEvent.id)
          .delete();
    } catch (error) {
      log(error.toString());
    }
  }
}
