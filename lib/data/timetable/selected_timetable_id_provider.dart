import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:urnicar/data/secure_storage.dart';
import 'package:urnicar/data/timetable/timetables_provider.dart';

part 'selected_timetable_id_provider.g.dart';

@riverpod
class SelectedTimetableId extends _$SelectedTimetableId {
  @override
  String? build() {
    secureStorage.read(key: 'selected_timetable').then((id) {
      if (ref.read(timetablesProvider).containsKey(id)) {
        state = id;
      }
    });
    return null;
  }

  Future<void> set(String? id) async {
    final timetables = ref.read(timetablesProvider);
    if (id == null && timetables.isNotEmpty) {
      id = timetables.values.first.id;
    }
    await secureStorage.write(key: 'selected_timetable', value: id);
    state = id;
  }
}
