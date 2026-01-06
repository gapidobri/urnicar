import 'package:json_annotation/json_annotation.dart';
import 'package:urnicar/data/remote_timetable/timetable_scraper.dart';

part 'timetable_record.g.dart';

@JsonSerializable()
class TimetableRecord {
  final String sourceTimetableId;
  final String studentId;
  final String id;
  final String name;
  final List<Lecture> lectures;
  final DateTime updated;

  const TimetableRecord({
    required this.sourceTimetableId,
    required this.studentId,
    required this.id,
    required this.name,
    required this.lectures,
    required this.updated,
  });

  Set<Subject> get subjects {
    final subjects = <Subject>{};
    for (final lecture in lectures) {
      subjects.add(lecture.subject);
    }

    return subjects;
  }

  TimetableRecord copyWith({
    String? sourceTimetableId,
    String? studentId,
    String? id,
    String? name,
    List<Lecture>? lectures,
    DateTime? updated,
    String? user,
  }) => TimetableRecord(
    sourceTimetableId: sourceTimetableId ?? this.sourceTimetableId,
    studentId: studentId ?? this.studentId,
    id: id ?? this.id,
    name: name ?? this.name,
    lectures: lectures ?? this.lectures,
    updated: updated ?? this.updated,
  );

  factory TimetableRecord.fromJson(Map<String, dynamic> json) =>
      _$TimetableRecordFromJson(json);

  Map<String, dynamic> toJson() => _$TimetableRecordToJson(this);
}
