import 'package:flutter/material.dart';
import 'package:urnicar/data/remote_timetable/timetable_scraper.dart';

final _lectureTypes = {
  LectureType.lecture: 'P',
  LectureType.labExercises: 'LV',
  LectureType.auditoryExercises: 'AV',
};

class LectureTile extends StatelessWidget {
  const LectureTile({
    super.key,
    required this.lecture,
    this.showPin = false,
    this.longNames = false,
  });

  final Lecture lecture;
  final bool showPin;
  final bool longNames;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: lecture.hidden
            ? Colors.grey
            : HSLColor.fromAHSL(
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
            longNames ? lecture.subject.name : lecture.subject.acronym,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12.0,
            ),
          ),
          Text(
            lecture.classroom.name,
            maxLines: 1,
            style: const TextStyle(color: Colors.white, fontSize: 12.0),
          ),
          if (longNames)
            Text(
              lecture.teachers.map((t) => t.name).join(', '),
              maxLines: 1,
              style: const TextStyle(color: Colors.white, fontSize: 12.0),
            ),
          const Spacer(),
          Row(
            children: [
              Text(
                _lectureTypes[lecture.type]!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (lecture.pinned && showPin) Icon(Icons.push_pin, size: 14.0),
            ],
          ),
        ],
      ),
    );
  }
}
