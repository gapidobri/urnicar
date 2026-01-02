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

class FilterTypeAdapter extends TypeAdapter<FilterType> {
  @override
  final typeId = 3;

  @override
  FilterType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FilterType.teacher;
      case 1:
        return FilterType.student;
      case 2:
        return FilterType.subject;
      case 3:
        return FilterType.classroom;
      case 4:
        return FilterType.group;
      default:
        return FilterType.teacher;
    }
  }

  @override
  void write(BinaryWriter writer, FilterType obj) {
    switch (obj) {
      case FilterType.teacher:
        writer.writeByte(0);
      case FilterType.student:
        writer.writeByte(1);
      case FilterType.subject:
        writer.writeByte(2);
      case FilterType.classroom:
        writer.writeByte(3);
      case FilterType.group:
        writer.writeByte(4);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DayOfWeekAdapter extends TypeAdapter<DayOfWeek> {
  @override
  final typeId = 4;

  @override
  DayOfWeek read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DayOfWeek.monday;
      case 1:
        return DayOfWeek.tuesday;
      case 2:
        return DayOfWeek.wednesday;
      case 3:
        return DayOfWeek.thursday;
      case 4:
        return DayOfWeek.friday;
      default:
        return DayOfWeek.monday;
    }
  }

  @override
  void write(BinaryWriter writer, DayOfWeek obj) {
    switch (obj) {
      case DayOfWeek.monday:
        writer.writeByte(0);
      case DayOfWeek.tuesday:
        writer.writeByte(1);
      case DayOfWeek.wednesday:
        writer.writeByte(2);
      case DayOfWeek.thursday:
        writer.writeByte(3);
      case DayOfWeek.friday:
        writer.writeByte(4);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayOfWeekAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HourRangeAdapter extends TypeAdapter<HourRange> {
  @override
  final typeId = 5;

  @override
  HourRange read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HourRange(
      start: (fields[0] as num).toInt(),
      end: (fields[1] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, HourRange obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.start)
      ..writeByte(1)
      ..write(obj.end);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HourRangeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TeacherAdapter extends TypeAdapter<Teacher> {
  @override
  final typeId = 6;

  @override
  Teacher read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Teacher(id: fields[0] as String, name: fields[1] as String);
  }

  @override
  void write(BinaryWriter writer, Teacher obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeacherAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubjectAdapter extends TypeAdapter<Subject> {
  @override
  final typeId = 7;

  @override
  Subject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Subject(id: fields[0] as String, name: fields[1] as String);
  }

  @override
  void write(BinaryWriter writer, Subject obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ClassroomAdapter extends TypeAdapter<Classroom> {
  @override
  final typeId = 8;

  @override
  Classroom read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Classroom(id: fields[0] as String, name: fields[1] as String);
  }

  @override
  void write(BinaryWriter writer, Classroom obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassroomAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GroupAdapter extends TypeAdapter<Group> {
  @override
  final typeId = 9;

  @override
  Group read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Group(id: fields[0] as String, name: fields[1] as String);
  }

  @override
  void write(BinaryWriter writer, Group obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LectureTypeAdapter extends TypeAdapter<LectureType> {
  @override
  final typeId = 10;

  @override
  LectureType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LectureType.lecture;
      case 1:
        return LectureType.labExercises;
      case 2:
        return LectureType.auditoryExercises;
      case 3:
        return LectureType.other;
      default:
        return LectureType.lecture;
    }
  }

  @override
  void write(BinaryWriter writer, LectureType obj) {
    switch (obj) {
      case LectureType.lecture:
        writer.writeByte(0);
      case LectureType.labExercises:
        writer.writeByte(1);
      case LectureType.auditoryExercises:
        writer.writeByte(2);
      case LectureType.other:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LectureTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
