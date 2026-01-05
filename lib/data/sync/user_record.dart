import 'package:json_annotation/json_annotation.dart';
import 'package:pocketbase/pocketbase.dart';

part 'user_record.g.dart';

@JsonSerializable()
class UserRecord {
  final String id;
  final String email;
  final String name;
  final String studentId;
  final DateTime created;
  final DateTime updated;

  const UserRecord({
    required this.id,
    required this.email,
    required this.name,
    required this.studentId,
    required this.created,
    required this.updated,
  });

  factory UserRecord.fromJson(Map<String, dynamic> json) =>
      _$UserRecordFromJson(json);

  Map<String, dynamic> toJson() => _$UserRecordToJson(this);

  factory UserRecord.fromRecord(RecordModel record) =>
      UserRecord.fromJson(record.data);
}
