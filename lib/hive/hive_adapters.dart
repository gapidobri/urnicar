import 'package:hive_ce/hive.dart';
import 'package:urnicar/data/timetable/timetable_record.dart';
import 'package:urnicar/data/timetable/timetable_scraper.dart';

@GenerateAdapters([AdapterSpec<TimetableRecord>(), AdapterSpec<Lecture>()])
part 'hive_adapters.g.dart';
