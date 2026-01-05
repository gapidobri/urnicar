import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:urnicar/data/sync/pocketbase.dart';
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
    if (pb.authStore.isValid) {
      timetable = timetable.copyWith(user: pb.authStore.record!.id);
    }

    await timetablesBox.put(timetable.id, timetable);
    state = timetablesBox.values.toList();

    if (pb.authStore.isValid) {
      await pb
          .collection('timetables')
          .create(
            body: {...timetable.toJson(), 'user': pb.authStore.record!.id},
          );
    }
  }

  void updateTimetable(TimetableRecord timetable) async {
    if (pb.authStore.isValid) {
      timetable = timetable.copyWith(user: pb.authStore.record!.id);
    }

    await timetablesBox.put(timetable.id, timetable);
    state = timetablesBox.values.toList();

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
      final localTimetable = state.firstWhereOrNull(
        (t) => t.id == remoteTimetable.id,
      );
      if (localTimetable == null ||
          remoteTimetable.updated.isAfter(localTimetable.updated)) {
        updateLocal[remoteTimetable.id] = remoteTimetable;
      } else {
        updateRemote.add(localTimetable);
      }
    }
    for (final localTimetable in state) {
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

    state = timetablesBox.values.toList();
  }

  void deleteTimetable(String id) async {
    await timetablesBox.delete(id);
    state = timetablesBox.values.toList();

    if (pb.authStore.isValid) {
      await pb.collection('timetables').delete(id);
    }
  }

  Future<void> clearLocal() async {
    await timetablesBox.clear();
    state = [];
  }
}
