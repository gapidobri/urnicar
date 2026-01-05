import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kalender/kalender.dart';
import 'package:urnicar/data/remote_timetable/timetable_scraper.dart';
import 'package:urnicar/data/timetable/timetables_provider.dart';
import 'package:urnicar/ui/widgets/lecture_tile.dart';

class EditScreen extends ConsumerStatefulWidget {
  const EditScreen({super.key, required this.timetableId});

  final String timetableId;

  @override
  ConsumerState<EditScreen> createState() => EditScreenState();
}

class EditScreenState extends ConsumerState<EditScreen> {
  final eventsController = DefaultEventsController<Lecture>();
  final calendarController = CalendarController<Lecture>();

  late final ViewConfiguration viewConfiguration;

  @override
  void initState() {
    super.initState();

    final displayRange = DateTime.now().weekRange();
    final timeOfDayRange = TimeOfDayRange(
      start: const TimeOfDay(hour: 6, minute: 0),
      end: const TimeOfDay(hour: 21, minute: 0),
    );

    viewConfiguration = MultiDayViewConfiguration.workWeek(
      displayRange: displayRange,
      timeOfDayRange: timeOfDayRange,
    );

    loadTimetable();
  }

  void loadTimetable() {
    final timetable = ref
        .read(timetablesProvider)
        .firstWhereOrNull((t) => t.id == widget.timetableId);
    if (timetable == null) return;

    final startOfWeek = DateTime.now().startOfWeek();

    final events = timetable.lectures.map((lecture) {
      final day = startOfWeek.addDays(lecture.day.value);
      return CalendarEvent<Lecture>(
        canModify: true,
        dateTimeRange: DateTimeRange(
          start: day.add(Duration(hours: lecture.time.start)),
          end: day.add(Duration(hours: lecture.time.end)),
        ),
        data: lecture,
      );
    }).toList();

    eventsController.addEvents(events);
  }

  void optimise() {
    // optimisation applied here?
    // final optTimetable = TimetableOptimiser.minimiseOverlapAndGap(timetable.lectures)[0];
    // final events = optTimetable.map((lecture) {
  }

  void saveAndExit() {
    // saving changed calendar here
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Urejanje urnika'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: saveAndExit),
        ],
      ),
      body: CalendarView<Lecture>(
        eventsController: eventsController,
        calendarController: calendarController,
        viewConfiguration: viewConfiguration,
        callbacks: CalendarCallbacks(
          onEventTapped: (event, _) => calendarController.selectEvent(event),
          onEventCreate: (event) => event,
          onEventCreated: (event) => eventsController.addEvent(event),
        ),
        header: const CalendarHeader<Lecture>(
          multiDayHeaderConfiguration: MultiDayHeaderConfiguration(
            showTiles: false,
          ),
        ),
        body: CalendarBody<Lecture>(
          calendarController: calendarController,
          eventsController: eventsController,
          multiDayTileComponents: TileComponents(
            tileBuilder: (event, tileRange) => LectureTile(event: event),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: optimise,
        child: const Icon(Icons.auto_fix_high),
      ),
    );
  }
}
