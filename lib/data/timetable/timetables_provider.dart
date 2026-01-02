import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:urnicar/data/timetable/timetable_record.dart';
import 'package:urnicar/hive/boxes.dart';

part 'timetables_provider.g.dart';

@riverpod
class Timetables extends _$Timetables {
  @override
  List<TimetableRecord> build() {
    return timetablesBox.values.toList();
  }

  Future<void> createTimetable(TimetableRecord timetable) async {
    await timetablesBox.put(timetable.id, timetable);
    state = timetablesBox.values.toList();
  }

  void updateTimetable(TimetableRecord timetable) async {
    await timetablesBox.put(timetable.id, timetable);
    state = timetablesBox.values.toList();
  }

  void deleteTimetable(String id) async {
    await timetablesBox.delete(id);
    state = timetablesBox.values.toList();
  }
}
