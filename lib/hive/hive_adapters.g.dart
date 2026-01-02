// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class LectureAdapter extends TypeAdapter<Lecture> {
  @override
  final typeId = 1;

  @override
  Lecture read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Lecture(
      id: fields[0] as String,
      day: fields[1] as DayOfWeek,
      time: fields[2] as HourRange,
      teachers: (fields[3] as List).cast<Teacher>(),
      classroom: fields[4] as Classroom,
      subject: fields[5] as Subject,
      type: fields[6] as LectureType,
    );
  }

  @override
  void write(BinaryWriter writer, Lecture obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.day)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(3)
      ..write(obj.teachers)
      ..writeByte(4)
      ..write(obj.classroom)
      ..writeByte(5)
      ..write(obj.subject)
      ..writeByte(6)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LectureAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TimetableRecordAdapter extends TypeAdapter<TimetableRecord> {
  @override
  final typeId = 2;

  @override
  TimetableRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimetableRecord(
      sourceTimetableId: fields[0] as String,
      sourceFilterType: fields[1] as FilterType,
      sourceId: fields[2] as String,
      id: fields[3] as String,
      name: fields[4] as String,
      lectures: (fields[5] as List).cast<Lecture>(),
    );
  }

  @override
  void write(BinaryWriter writer, TimetableRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.sourceTimetableId)
      ..writeByte(1)
      ..write(obj.sourceFilterType)
      ..writeByte(2)
      ..write(obj.sourceId)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.name)
      ..writeByte(5)
      ..write(obj.lectures);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimetableRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
