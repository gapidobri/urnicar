import 'package:hive_ce/hive.dart';
import 'package:urnicar/timetable/timetable.dart';

class TimetableRepository {
  static late final Box<Timetable> _box;

  static Future<void> openBox() async {
    _box = await Hive.openBox<Timetable>('timetables');
  }

  List<Timetable> getTimetables() {
    return _box.values.toList();
  }

  Timetable? getTimetable(String id) {
    return _box.get(id);
  }

  Future<void> updateTimetable(Timetable timetable) async {
    await _box.put(timetable.id, timetable);
  }

  Future<void> deleteTimetable(String id) async {
    await _box.delete(id);
  }
}
