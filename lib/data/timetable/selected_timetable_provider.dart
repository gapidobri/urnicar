import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:urnicar/data/secure_storage.dart';
import 'package:urnicar/data/timetable/timetable_record.dart';
import 'package:urnicar/data/timetable/timetables_provider.dart';

part 'selected_timetable_provider.g.dart';

@riverpod
class SelectedTimetable extends _$SelectedTimetable {
  @override
  TimetableRecord? build() {
    secureStorage
        .read(key: 'selected_timetable')
        .then((id) => state = ref.read(timetablesProvider)[id]);
    return null;
  }

  Future<void> set(String? id) async {
    final timetables = ref.read(timetablesProvider);
    if (id == null && timetables.isNotEmpty) {
      id = timetables.values.first.id;
    }
    await secureStorage.write(key: 'selected_timetable', value: id);
    state = timetables[id];
  }
}
