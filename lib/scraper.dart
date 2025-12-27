import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

// dobi vse ucitelje, ucilnice, skupine in predmete iz https://urnik.fri.uni-lj.si/timetable/fri-2025_2026-zimski/
class TableScraper {
  Future<TableScraperResults> fetchSite() async {
    final response = await http.get(Uri.parse('https://urnik.fri.uni-lj.si/timetable/fri-2025_2026-zimski/'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load data');
    }
    var document = parser.parse(response.body);
    var elements = document.querySelectorAll('table td a');

    List<Entity> entities = [];

    for (var element in elements) {
      var href = element.attributes['href'];
      if (href == null) continue;

      var uri = Uri.parse(href);
      if (uri.queryParameters.isEmpty) continue;

      var type = uri.queryParameters.keys.first;
      var id = uri.queryParameters[type];
      var name = element.text.trim();

      entities.add(Entity(type, id!, name));
    }
    List<Entity> teachers = entities.where((e) => e.type == "teacher").toList();
    List<Entity> classrooms = entities.where((e) => e.type == "classroom").toList();
    List<Entity> groups = entities.where((e) => e.type == "groups").toList();
    List<Entity> subjects = entities.where((e) => e.type == "subjects").toList();
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

  TableScraperResults(this.teachers, this.classrooms, this.groups, this.subjects);
}


class UrnikScraper {
  // type je lahko teacher, student, subject, classroom, group
  Future<List<Ura>> fetchSite({required String id, required String type}) async {
    List<Ura> ure = [];
    String url = "https://urnik.fri.uni-lj.si/timetable/fri-2025_2026-zimski/allocations?$type=$id";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load data');
    }
    var document = parser.parse(response.body);
    var elements = document.querySelectorAll('div.grid-entry');
    for (var element in elements) {
      List<String> teacherName = [];
      List<String> teacherId = [];
      var teachers = element.querySelectorAll('a.link-teacher');
      for (var teacher in teachers){
        var tid = teacher.attributes['href']?.split('=').last;
        teacherName.add(teacher.text);
        if (tid != null) {
          teacherId.add(tid);
        }
      }

      var c = element.querySelector('a.link-classroom');
      var classroomId = c?.attributes['href']?.split('=').last;

      var s = element.querySelector('a.link-subject');
      var subjectId = s?.attributes['href']?.split('=').last;

      var hover = element.querySelector('div.entry-hover');
      if (hover == null) continue;

      //0 = day starttime - endtime, 1 = classroom, 3 = subject + type, 4 = teacher, 5 -> groups
      var l = hover.text.trim().split("\n");
      if (l.length < 5) continue;

      var dayTimeSplit = l[0].trim().split(" ");
      var day = dayTimeSplit[0];
      var startTime = dayTimeSplit[1];
      var endTime = dayTimeSplit[3];
      var classroom = l[1].trim();
      var subjectSplit = l[3].trim().split("_");
      var subject = subjectSplit[0];
      var classType = subjectSplit[1];

      if (classroomId == null || subjectId == null) continue;

      ure.add(Ura(day, startTime, endTime, teacherName, teacherId, classroom, classroomId, subject, subjectId, classType));
    }
    return ure;
  }
}

class Ura {
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

  Ura(this.day, this.startTime, this.endTime, this.teacherName, this.teacherId, this.classroom, this.classroomId, this.subjectName, this.subjectId, this.type);
}