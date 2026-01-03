// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_scraper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Teacher _$TeacherFromJson(Map<String, dynamic> json) =>
    Teacher(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$TeacherToJson(Teacher instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

Classroom _$ClassroomFromJson(Map<String, dynamic> json) =>
    Classroom(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$ClassroomToJson(Classroom instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

Group _$GroupFromJson(Map<String, dynamic> json) =>
    Group(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

Subject _$SubjectFromJson(Map<String, dynamic> json) =>
    Subject(id: json['id'] as String, name: json['name'] as String);

Map<String, dynamic> _$SubjectToJson(Subject instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

HourRange _$HourRangeFromJson(Map<String, dynamic> json) => HourRange(
  start: (json['start'] as num).toInt(),
  end: (json['end'] as num).toInt(),
);

Map<String, dynamic> _$HourRangeToJson(HourRange instance) => <String, dynamic>{
  'start': instance.start,
  'end': instance.end,
};

Lecture _$LectureFromJson(Map<String, dynamic> json) => Lecture(
  id: json['id'] as String,
  day: $enumDecode(_$DayOfWeekEnumMap, json['day']),
  time: HourRange.fromJson(json['time'] as Map<String, dynamic>),
  teachers: (json['teachers'] as List<dynamic>)
      .map((e) => Teacher.fromJson(e as Map<String, dynamic>))
      .toList(),
  classroom: Classroom.fromJson(json['classroom'] as Map<String, dynamic>),
  subject: Subject.fromJson(json['subject'] as Map<String, dynamic>),
  type: $enumDecode(_$LectureTypeEnumMap, json['type']),
);

Map<String, dynamic> _$LectureToJson(Lecture instance) => <String, dynamic>{
  'id': instance.id,
  'day': _$DayOfWeekEnumMap[instance.day]!,
  'time': instance.time,
  'teachers': instance.teachers,
  'classroom': instance.classroom,
  'subject': instance.subject,
  'type': _$LectureTypeEnumMap[instance.type]!,
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
