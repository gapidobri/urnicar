import 'package:urnicar/data/remote_timetable/timetable_scraper.dart';

class TimetableRecord {
  final String sourceTimetableId;
  final String studentId;
  final String id;
  final String name;
  final List<Lecture> lectures;

  const TimetableRecord({
    required this.sourceTimetableId,
    required this.studentId,
    required this.id,
    required this.name,
    required this.lectures,
  });
}
