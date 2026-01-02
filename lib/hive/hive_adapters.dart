import 'package:hive_ce/hive.dart';
import 'package:urnicar/data/remote_timetable/timetable_scraper.dart';
import 'package:urnicar/data/timetable/timetable_record.dart';

@GenerateAdapters([
  AdapterSpec<TimetableRecord>(),
  AdapterSpec<Lecture>(),
  AdapterSpec<LectureType>(),
  AdapterSpec<FilterType>(),
  AdapterSpec<DayOfWeek>(),
  AdapterSpec<HourRange>(),
  AdapterSpec<Teacher>(),
  AdapterSpec<Subject>(),
  AdapterSpec<Classroom>(),
  AdapterSpec<Group>(),
])
part 'hive_adapters.g.dart';
