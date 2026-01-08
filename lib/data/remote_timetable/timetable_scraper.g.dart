// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_scraper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Teacher _$TeacherFromJson(Map json) =>
    Teacher(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$TeacherToJson(Teacher instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

Classroom _$ClassroomFromJson(Map json) =>
    Classroom(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$ClassroomToJson(Classroom instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

Group _$GroupFromJson(Map json) =>
    Group(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

Subject _$SubjectFromJson(Map json) =>
    Subject(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$SubjectToJson(Subject instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

HourRange _$HourRangeFromJson(Map json) => HourRange(
  start: (json['start'] as num).toInt(),
  end: (json['end'] as num).toInt(),
);

Map<String, dynamic> _$HourRangeToJson(HourRange instance) => <String, dynamic>{
  'start': instance.start,
  'end': instance.end,
};

Lecture _$LectureFromJson(Map json) => Lecture(
  id: json['id'] as String,
  day: $enumDecode(_$DayOfWeekEnumMap, json['day']),
  time: HourRange.fromJson(Map<String, dynamic>.from(json['time'] as Map)),
  teachers: (json['teachers'] as List<dynamic>)
      .map((e) => Teacher.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList(),
  classroom: Classroom.fromJson(
    Map<String, dynamic>.from(json['classroom'] as Map),
  ),
  subject: Subject.fromJson(Map<String, dynamic>.from(json['subject'] as Map)),
  type: $enumDecode(_$LectureTypeEnumMap, json['type']),
  ignored: json['ignored'] as bool? ?? false,
  pinned: json['pinned'] as bool? ?? false,
);

Map<String, dynamic> _$LectureToJson(Lecture instance) => <String, dynamic>{
  'id': instance.id,
  'day': _$DayOfWeekEnumMap[instance.day]!,
  'time': instance.time.toJson(),
  'teachers': instance.teachers.map((e) => e.toJson()).toList(),
  'classroom': instance.classroom.toJson(),
  'subject': instance.subject.toJson(),
  'type': _$LectureTypeEnumMap[instance.type]!,
  'ignored': instance.ignored,
  'pinned': instance.pinned,
};

const _$DayOfWeekEnumMap = {
  DayOfWeek.monday: 'monday',
  DayOfWeek.tuesday: 'tuesday',
  DayOfWeek.wednesday: 'wednesday',
  DayOfWeek.thursday: 'thursday',
  DayOfWeek.friday: 'friday',
};

const _$LectureTypeEnumMap = {
  LectureType.lecture: 'lecture',
  LectureType.labExercises: 'labExercises',
  LectureType.auditoryExercises: 'auditoryExercises',
  LectureType.other: 'other',
};
