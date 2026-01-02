import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:urnicar/data/remote_timetable/timetable_scraper.dart';

part 'remote_timetables_provider.g.dart';

@riverpod
Future<List<Timetable>> remoteTimetables(Ref ref) async {
  return await TimetableScraper.getTimetables().then(
    (t) => t.sortedBy((t) => t.name).reversed.toList(),
  );
}
