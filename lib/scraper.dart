import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:kalender/kalender.dart';

class TimetableScraper {
  static const _baseUrl = 'https://urnik.fri.uni-lj.si/timetable';

  static Future<List<Timetable>> getTimetables() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to load data');
    }

    final document = parser.parse(response.body);

    final elements = document.querySelectorAll('#body > div a');
    final timetables = elements
        .map(
          (e) => Timetable(
            id: e.attributes['href']!.split('/')[2],
            name: e.text.trim(),
          ),
        )
        .toList();

    return timetables;
  }

  static Future<TimetableData> getTimetableData(String timetableId) async {
    final response = await http.get(Uri.parse('$_baseUrl/$timetableId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load data');
    }

    final document = parser.parse(response.body);

    final elements = document.querySelectorAll('table a');

    final teachers = <Teacher>[];
    final classrooms = <Classroom>[];
    final groups = <Group>[];
    final subjects = <Subject>[];

    final regex = RegExp(r'\?(.*)=(.*)');

    for (final e in elements) {
      final match = regex.allMatches(e.attributes['href']!).first;
      final type = match.group(1)!;
      final id = match.group(2)!;

      switch (type) {
        case 'teacher':
          teachers.add(Teacher(id: id, name: e.text));
          break;
        case 'classroom':
          classrooms.add(Classroom(id: id, name: e.text));
          break;
        case 'group':
          groups.add(Group(id: id, name: e.text));
          break;
        case 'subject':
          subjects.add(Subject(id: id, name: e.text));
          break;
      }
    }

    return TimetableData(
      teachers: teachers,
      classrooms: classrooms,
      groups: groups,
      subjects: subjects,
    );
  }

  static Future<List<Lecture>> getLectures({
    required String timetableId,
    required FilterType filterType,
    required String id,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$timetableId/allocations?${filterType.value}=$id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load data');
    }

    final document = parser.parse(response.body);

    final lectures = document.querySelectorAll('.grid-entry').map((e) {
      final startTimeParts = e.attributes['data-start']!.split(':');
      final startTime = TimeOfDay(
        hour: int.parse(startTimeParts[0]),
        minute: int.parse(startTimeParts[1]),
      );
      final endTime = startTime.replacing(
        hour: startTime.hour + int.parse(e.attributes['data-duration']!),
      );

      final teachers = e
          .querySelectorAll('.link-teacher')
          .map(
            (e) =>
                Teacher(id: e.attributes['href']!.split('=')[1], name: e.text),
          )
          .toList();

      final classroomEl = e.querySelector('.link-classroom')!;
      final classroom = Classroom(
        id: classroomEl.attributes['href']!.split('=')[1],
        name: classroomEl.text,
      );

      final subjectEl = e.querySelector('.link-subject')!;
      final subject = Subject(
        id: subjectEl.attributes['href']!.split('=')[1],
        name: subjectEl.text,
      );

      final type = LectureType.parse(
        e.querySelector('.entry-type')!.text.split('| ')[1],
      );

      return Lecture(
        id: e.attributes['data-allocation-id']!,
        day: DayOfWeek.parse(e.attributes['data-day']!),
        time: TimeOfDayRange(start: startTime, end: endTime),
        teachers: teachers,
        classroom: classroom,
        subject: subject,
        type: type,
      );
    }).toList();

    return lectures;
  }
}

class Timetable {
  final String id;
  final String name;

  const Timetable({required this.id, required this.name});

  @override
  String toString() => 'Timetable(id: $id, name: $name)';
}

class Teacher {
  final String id;
  final String name;

  const Teacher({required this.id, required this.name});

  @override
  String toString() => 'Teacher(id: $id, name: $name)';
}

class Classroom {
  final String id;
  final String name;

  const Classroom({required this.id, required this.name});

  @override
  String toString() => 'Classroom(id: $id, name: $name)';
}

class Group {
  final String id;
  final String name;

  const Group({required this.id, required this.name});

  @override
  String toString() => 'Group(id: $id, name: $name)';
}

class Subject {
  final String id;
  final String name;

  const Subject({required this.id, required this.name});

  @override
  String toString() => 'Subject(id: $id, name: $name)';
}

enum DayOfWeek {
  monday(0),
  tuesday(1),
  wednesday(2),
  thursday(3),
  friday(4);

  final int value;

  const DayOfWeek(this.value);

  static DayOfWeek parse(String value) {
    final map = {
      'MON': DayOfWeek.monday,
      'TUE': DayOfWeek.tuesday,
      'WED': DayOfWeek.wednesday,
      'THU': DayOfWeek.thursday,
      'FRI': DayOfWeek.friday,
    };
    final result = map[value];
    if (result == null) {
      throw Exception('Invalid day of week "$value"');
    }
    return result;
  }
}

class HourRange {
  final int start;
  final int end;

  const HourRange({required this.start, required this.end});

  int get duration => end - start;

  @override
  String toString() =>
      '${start.toString().padLeft(2, '0')} - ${end.toString().padLeft(2, '0')}';
}

enum FilterType {
  teacher('teacher'),
  student('student'),
  subject('subject'),
  classroom('classroom'),
  group('group');

  final String value;

  const FilterType(this.value);
}

class TimetableData {
  final List<Teacher> teachers;
  final List<Classroom> classrooms;
  final List<Group> groups;
  final List<Subject> subjects;

  const TimetableData({
    required this.teachers,
    required this.classrooms,
    required this.groups,
    required this.subjects,
  });
}

enum LectureType {
  lecture,
  labExercises,
  auditoryExercises,
  other;

  static LectureType parse(String value) {
    final map = {
      'P': LectureType.lecture,
      'LV': LectureType.labExercises,
      'AV': LectureType.auditoryExercises,
    };
    return map[value] ?? LectureType.other;
  }
}

class Lecture {
  final String id;
  final DayOfWeek day;
  final HourRange time;
  final List<Teacher> teachers;
  final Classroom classroom;
  final Subject subject;
  final LectureType type;

  const Lecture({
    required this.id,
    required this.day,
    required this.time,
    required this.teachers,
    required this.classroom,
    required this.subject,
    required this.type,
  });

  @override
  String toString() =>
      '''Lecture(
  id: $id
  day: $day
  time: $time
  teachers: $teachers
  classroom: $classroom
  subject: $subject
  type: $type
)''';
}
