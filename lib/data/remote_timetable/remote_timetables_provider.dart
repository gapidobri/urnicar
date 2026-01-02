import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:urnicar/data/timetable/timetable_scraper.dart';

part 'remote_timetables_provider.g.dart';

@riverpod
Future<List<Timetable>> remoteTimetables(Ref ref) async {
  return TimetableScraper.getTimetables();
}
