import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:urnicar/data/remote_timetable/timetable_scraper.dart';

part 'remote_timetable_data_provider.g.dart';

@riverpod
Future<TimetableData> remoteTimetableData(Ref ref, String timetableId) async {
  return TimetableScraper.getTimetableData(timetableId);
}
