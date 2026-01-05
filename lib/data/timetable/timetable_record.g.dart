// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimetableRecord _$TimetableRecordFromJson(Map json) => TimetableRecord(
  sourceTimetableId: json['sourceTimetableId'] as String,
  studentId: json['studentId'] as String,
  id: json['id'] as String,
  name: json['name'] as String,
  lectures: (json['lectures'] as List<dynamic>)
      .map((e) => Lecture.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList(),
  updated: DateTime.parse(json['updated'] as String),
);

Map<String, dynamic> _$TimetableRecordToJson(TimetableRecord instance) =>
    <String, dynamic>{
      'sourceTimetableId': instance.sourceTimetableId,
      'studentId': instance.studentId,
      'id': instance.id,
      'name': instance.name,
      'lectures': instance.lectures.map((e) => e.toJson()).toList(),
      'updated': instance.updated.toIso8601String(),
    };
