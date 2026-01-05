// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRecord _$UserRecordFromJson(Map json) => UserRecord(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String,
  studentId: json['studentId'] as String,
  created: DateTime.parse(json['created'] as String),
  updated: DateTime.parse(json['updated'] as String),
);

Map<String, dynamic> _$UserRecordToJson(UserRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'studentId': instance.studentId,
      'created': instance.created.toIso8601String(),
      'updated': instance.updated.toIso8601String(),
    };
