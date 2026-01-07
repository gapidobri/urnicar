import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:urnicar/data/remote_timetable/timetable_scraper.dart';

final _weekNames = ['Pon', 'Tor', 'Sre', 'Čet', 'Pet', 'Sob', 'Ned'];

final calendarComponents = CalendarComponents<Lecture>(
  multiDayComponents: MultiDayComponents(
    headerComponents: MultiDayHeaderComponents(
      weekNumberBuilder: (date, _) => SizedBox(),
      dayHeaderBuilder: (date, _) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(_weekNames[date.weekday - 1]),
      ),
    ),
  ),
);
