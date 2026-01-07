import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:urnicar/data/sync/pocketbase.dart';
import 'package:urnicar/data/timetable/selected_timetable_provider.dart';
import 'package:urnicar/data/timetable/timetable_record.dart';
import 'package:urnicar/hive/boxes.dart';

part 'timetables_provider.g.dart';

@riverpod
class Timetables extends _$Timetables {
  @override
  Map<String, TimetableRecord> build() {
    return Map.from(timetablesBox.toMap());
  }

  void _updateState() {
    state = Map.from(timetablesBox.toMap());
  }

  Future<void> createTimetable(TimetableRecord timetable) async {
    if (pb.authStore.isValid) {
      timetable = timetable.copyWith(user: pb.authStore.record!.id);
    }

    await timetablesBox.put(timetable.id, timetable);
    _updateState();
    ref.read(selectedTimetableProvider.notifier).set(timetable.id);

    if (pb.authStore.isValid) {
      await pb
          .collection('timetables')
          .create(
            body: {...timetable.toJson(), 'user': pb.authStore.record!.id},
          );
    }
  }

  Future<void> updateTimetable(TimetableRecord timetable) async {
    if (pb.authStore.isValid) {
      timetable = timetable.copyWith(user: pb.authStore.record!.id);
    }

    await timetablesBox.put(timetable.id, timetable);
    _updateState();

    if (pb.authStore.isValid) {
      await pb
          .collection('timetables')
          .update(timetable.id, body: timetable.toJson());
    }
  }

  Future<void> syncTimetables() async {
    if (!pb.authStore.isValid) return;

    final remoteTimetables = await pb
        .collection('timetables')
        .getFullList()
        .then((t) => t.map((t) => TimetableRecord.fromJson(t.data)).toList());

    final updateLocal = <String, TimetableRecord>{};
    final createRemote = <TimetableRecord>[];
    final updateRemote = <TimetableRecord>[];

    for (final remoteTimetable in remoteTimetables) {
      final localTimetable = state[remoteTimetable.id];
      if (localTimetable == null ||
          remoteTimetable.updated.isAfter(localTimetable.updated)) {
        updateLocal[remoteTimetable.id] = remoteTimetable;
      } else {
        updateRemote.add(localTimetable);
      }
    }
    for (final localTimetable in state.values) {
      final remoteTimetable = remoteTimetables.firstWhereOrNull(
        (t) => t.id == localTimetable.id,
      );
      if (remoteTimetable == null) {
        createRemote.add(localTimetable);
      }
    }

    if (kDebugMode) {
      print(
        'syncing timetables - updateLocal: ${updateLocal.length}, createRemote: ${createRemote.length}, updateRemote: ${updateRemote.length}',
      );
    }

    await Future.wait([
      timetablesBox.putAll(updateLocal),
      ...createRemote.map(
        (t) => pb
            .collection('timetables')
            .create(body: {...t.toJson(), 'user': pb.authStore.record!.id}),
      ),
      ...updateRemote.map(
        (t) => pb.collection('timetables').update(t.id, body: t.toJson()),
      ),
    ]);

    _updateState();
  }

  void deleteTimetable(String id) async {
    await ref.read(selectedTimetableProvider.notifier).set(null);
    await timetablesBox.delete(id);
    _updateState();

    if (pb.authStore.isValid) {
      await pb.collection('timetables').delete(id);
    }
  }

  Future<void> clearLocal() async {
    await timetablesBox.clear();
    state = {};
  }
}
