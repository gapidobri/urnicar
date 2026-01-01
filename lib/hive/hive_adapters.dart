import 'package:hive_ce/hive.dart';
import 'package:urnicar/scraper.dart' hide Timetable;
import 'package:urnicar/timetable/timetable.dart';

@GenerateAdapters([AdapterSpec<Timetable>(), AdapterSpec<Lecture>()])
part 'hive_adapters.g.dart';
