import 'package:urnicar/data/remote_timetable/timetable_scraper.dart';

class TimetableRecord {
  final String sourceTimetableId;
  final FilterType sourceFilterType;
  final String sourceId;
  final String id;
  final String name;
  final List<Lecture> lectures;

  const TimetableRecord({
    required this.sourceTimetableId,
    required this.sourceFilterType,
    required this.sourceId,
    required this.id,
    required this.name,
    required this.lectures,
  });
}
