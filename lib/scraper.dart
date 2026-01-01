import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

// dobi vse ucitelje, ucilnice, skupine in predmete iz https://urnik.fri.uni-lj.si/timetable/fri-2025_2026-zimski/
class TableScraper {
  Future<TableScraperResults> fetchSite() async {
    final response = await http.get(
      Uri.parse('https://urnik.fri.uni-lj.si/timetable/fri-2025_2026-zimski/'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load data');
    }
    final document = parser.parse(response.body);
    final elements = document.querySelectorAll('table td a');

    List<Entity> entities = [];

    for (var element in elements) {
      final href = element.attributes['href'];
      if (href == null) continue;

      final uri = Uri.parse(href);
      if (uri.queryParameters.isEmpty) continue;

      final type = uri.queryParameters.keys.first;
      final id = uri.queryParameters[type];
      final name = element.text.trim();

      entities.add(Entity(type, id!, name));
    }
    List<Entity> teachers = entities.where((e) => e.type == "teacher").toList();
    List<Entity> classrooms = entities
        .where((e) => e.type == "classroom")
        .toList();
    List<Entity> groups = entities.where((e) => e.type == "groups").toList();
    List<Entity> subjects = entities
        .where((e) => e.type == "subjects")
        .toList();
    return TableScraperResults(teachers, classrooms, groups, subjects);
  }
}

class Entity {
  final String type;
  final String id;
  final String name;

  Entity(this.type, this.id, this.name);
}

class TableScraperResults {
  final List<Entity> teachers;
  final List<Entity> classrooms;
  final List<Entity> groups;
  final List<Entity> subjects;

  TableScraperResults(
    this.teachers,
    this.classrooms,
    this.groups,
    this.subjects,
  );
}

class TimetableScraper {
  // type je lahko teacher, student, subject, classroom, group
  Future<List<Lecture>> fetchSite({
    required String id,
    required String type,
  }) async {
    List<Lecture> lectures = [];
    String url =
        "https://urnik.fri.uni-lj.si/timetable/fri-2025_2026-zimski/allocations?$type=$id";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load data');
    }
    final document = parser.parse(response.body);
    final elements = document.querySelectorAll('div.grid-entry');
    for (var element in elements) {
      List<String> teacherName = [];
      List<String> teacherId = [];
      final teachers = element.querySelectorAll('a.link-teacher');
      for (var teacher in teachers) {
        final tid = teacher.attributes['href']?.split('=').last;
        teacherName.add(teacher.text);
        if (tid != null) {
          teacherId.add(tid);
        }
      }

      final c = element.querySelector('a.link-classroom');
      final classroomId = c?.attributes['href']?.split('=').last;

      final s = element.querySelector('a.link-subject');
      final subjectId = s?.attributes['href']?.split('=').last;

      final hover = element.querySelector('div.entry-hover');
      if (hover == null) continue;

      //0 = day starttime - endtime, 1 = classroom, 3 = subject + type, 4 = teacher, 5 -> groups
      final l = hover.text.trim().split("\n");
      if (l.length < 5) continue;

      final dayTimeSplit = l[0].trim().split(" ");
      final day = dayTimeSplit[0];
      final startTime = dayTimeSplit[1];
      final endTime = dayTimeSplit[3];
      final classroom = l[1].trim();
      final subjectSplit = l[3].trim().split("_");
      final subject = subjectSplit[0];
      final classType = subjectSplit[1];

      if (classroomId == null || subjectId == null) continue;

      lectures.add(
        Lecture(
          day: day,
          startTime: startTime,
          endTime: endTime,
          teacherName: teacherName,
          teacherId: teacherId,
          classroom: classroom,
          classroomId: classroomId,
          subjectName: subject,
          subjectId: subjectId,
          type: classType,
        ),
      );
    }
    return lectures;
  }
}

class Lecture {
  final String day;
  final String startTime;
  final String endTime;

  // mora biti seznam, ker je lahko vec izvajalcev
  final List<String> teacherName;
  final List<String> teacherId;
  final String classroom;
  final String classroomId;
  final String subjectName;
  final String subjectId;
  final String type;

  const Lecture({
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.teacherName,
    required this.teacherId,
    required this.classroom,
    required this.classroomId,
    required this.subjectName,
    required this.subjectId,
    required this.type,
  });
}
