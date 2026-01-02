import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:urnicar/data/remote_timetable/remote_timetable_data_provider.dart';
import 'package:urnicar/data/remote_timetable/timetable_scraper.dart';

part 'remote_lectures_provider.g.dart';

@riverpod
Future<List<Lecture>> remoteLectures(
  Ref ref,
  String timetableId,
  FilterType filterType,
  String id,
) async {
  final timetableData = await ref.read(
    remoteTimetableDataProvider.call(timetableId).future,
  );

  final lectures = await TimetableScraper.getLectures(
    timetableId: timetableId,
    filterType: filterType,
    id: id,
  );

  return await Isolate.run(
    () => lectures
        .map(
          (lecture) => lecture.copyWith(
            teachers: lecture.teachers
                .map(
                  (teacher) => teacher.copyWith(
                    name: timetableData.teachers
                        .firstWhereOrNull((t) => t.id == teacher.id)
                        ?.name,
                  ),
                )
                .toList(),
            classroom: timetableData.classrooms.firstWhereOrNull(
              (c) => c.id == lecture.classroom.id,
            ),
            subject: timetableData.subjects.firstWhereOrNull(
              (s) => s.id == lecture.subject.id,
            ),
          ),
        )
        .toList(),
  );
}
