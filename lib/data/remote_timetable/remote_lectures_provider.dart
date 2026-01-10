import 'dart:isolate';

import 'package:flutter/foundation.dart';
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

  if (kIsWeb) {
    return mapLectures(lectures, timetableData);
  }

  return await Isolate.run(() => mapLectures(lectures, timetableData));
}

List<Lecture> mapLectures(
  List<Lecture> lectures,
  TimetableData timetableData,
) => lectures
    .map(
      (lecture) => lecture.copyWith(
        teachers: lecture.teachers
            .map((teacher) => timetableData.teachers[teacher.id]!)
            .toList(),
        classroom: timetableData.classrooms[lecture.classroom.id],
        subject: timetableData.subjects[lecture.subject.id],
      ),
    )
    .toList();
