import 'package:urnicar/scraper.dart';

class Timetable {
  final String sourceTimetableId;
  final FilterType sourceFilterType;
  final String sourceId;
  final String id;
  final String name;
  final List<Lecture> lectures;

  const Timetable({
    required this.sourceTimetableId,
    required this.sourceFilterType,
    required this.sourceId,
    required this.id,
    required this.name,
    required this.lectures,
  });
}
