import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:urnicar/data/remote_timetable/timetable_scraper.dart';

class LectureTile extends StatelessWidget {
  const LectureTile({super.key, required this.event});

  final CalendarEvent<Lecture> event;

  @override
  Widget build(BuildContext context) {
    final lecture = event.data!;

    return Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: HSLColor.fromAHSL(
          1,
          lecture.subject.acronym.hashCode % 360,
          0.5,
          0.5,
        ).toColor(),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lecture.subject.acronym,
            maxLines: 1,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            lecture.classroom.name,
            maxLines: 1,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
