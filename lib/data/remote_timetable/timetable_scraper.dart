import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

part 'timetable_scraper.g.dart';

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

    final teachers = <String, Teacher>{};
    final classrooms = <String, Classroom>{};
    final groups = <String, Group>{};
    final subjects = <String, Subject>{};

    final regex = RegExp(r'\?(.*)=(.*)');

    for (final e in elements) {
      final match = regex.allMatches(e.attributes['href']!).first;
      final type = match.group(1)!;
      final id = match.group(2)!;

      switch (type) {
        case 'teacher':
          teachers[id] = Teacher(
            id: id,
            name: e.text.split(', ').reversed.join(' '),
          );
          break;
        case 'classroom':
          classrooms[id] = Classroom(id: id, name: e.text);
          break;
        case 'group':
          groups[id] = Group(id: id, name: e.text);
          break;
        case 'subject':
          subjects[id] = Subject(
            id: id,
            name: e.text.replaceFirst(RegExp(r'\(.*\)'), '').trim(),
          );
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
      final startTime = int.parse(e.attributes['data-start']!.split(':')[0]);
      final endTime = startTime + int.parse(e.attributes['data-duration']!);

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
        time: HourRange(start: startTime, end: endTime),
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
}

@JsonSerializable()
class Teacher {
  final String id;
  final String name;

  const Teacher({required this.id, required this.name});

  Teacher copyWith({String? id, String? name}) =>
      Teacher(id: id ?? this.id, name: name ?? this.name);

  factory Teacher.fromJson(Map<String, dynamic> json) =>
      _$TeacherFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherToJson(this);
}

@JsonSerializable()
class Classroom {
  final String id;
  final String name;

  const Classroom({required this.id, required this.name});

  Classroom copyWith({String? id, String? name}) =>
      Classroom(id: id ?? this.id, name: name ?? this.name);

  factory Classroom.fromJson(Map<String, dynamic> json) =>
      _$ClassroomFromJson(json);

  Map<String, dynamic> toJson() => _$ClassroomToJson(this);
}

@JsonSerializable()
class Group {
  final String id;
  final String name;

  const Group({required this.id, required this.name});

  Group copyWith({String? id, String? name}) =>
      Group(id: id ?? this.id, name: name ?? this.name);

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);

  Map<String, dynamic> toJson() => _$GroupToJson(this);
}

@JsonSerializable()
class Subject {
  final String id;
  final String name;

  const Subject({required this.id, required this.name});

  String get acronym {
    if (name.contains('DevOps')) {
      return 'DevOps';
    }

    final excludedWords = ['in'];
    return name
        .split(' ')
        .where((p) => !excludedWords.contains(p))
        .map((p) => p.substring(0, 1).toUpperCase())
        .join();
  }

  Subject copyWith({String? id, String? name}) =>
      Subject(id: id ?? this.id, name: name ?? this.name);

  factory Subject.fromJson(Map<String, dynamic> json) =>
      _$SubjectFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectToJson(this);
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

@JsonSerializable()
class HourRange {
  final int start;
  final int end;

  const HourRange({required this.start, required this.end});

  int get duration => end - start;

  factory HourRange.fromJson(Map<String, dynamic> json) =>
      _$HourRangeFromJson(json);

  Map<String, dynamic> toJson() => _$HourRangeToJson(this);
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
  final Map<String, Teacher> teachers;
  final Map<String, Classroom> classrooms;
  final Map<String, Group> groups;
  final Map<String, Subject> subjects;

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

@JsonSerializable()
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

  Lecture copyWith({
    String? id,
    DayOfWeek? day,
    HourRange? time,
    List<Teacher>? teachers,
    Classroom? classroom,
    Subject? subject,
    LectureType? type,
  }) => Lecture(
    id: id ?? this.id,
    day: day ?? this.day,
    time: time ?? this.time,
    teachers: teachers ?? this.teachers,
    classroom: classroom ?? this.classroom,
    subject: subject ?? this.subject,
    type: type ?? this.type,
  );

  factory Lecture.fromJson(Map<String, dynamic> json) =>
      _$LectureFromJson(json);

  Map<String, dynamic> toJson() => _$LectureToJson(this);
}
