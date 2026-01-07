import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kalender/kalender.dart';
import 'package:urnicar/data/remote_timetable/remote_lectures_provider.dart';
import 'package:urnicar/data/remote_timetable/timetable_scraper.dart';
import 'package:urnicar/data/timetable/optimiser.dart';
import 'package:urnicar/data/timetable/timetable_record.dart';
import 'package:urnicar/data/timetable/timetables_provider.dart';
import 'package:urnicar/ui/widgets/calendar_components.dart';
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

  late TimetableRecord timetable;
  late final ViewConfiguration viewConfiguration;

  @override
  void initState() {
    super.initState();

    timetable = ref.read(timetablesProvider)[widget.timetableId]!;

    final displayRange = DateTime.now().weekRange();
    final timeOfDayRange = TimeOfDayRange(
      start: const TimeOfDay(hour: 6, minute: 0),
      end: const TimeOfDay(hour: 21, minute: 0),
    );

    viewConfiguration = MultiDayViewConfiguration.workWeek(
      displayRange: displayRange,
      timeOfDayRange: timeOfDayRange,
    );

    loadLectures();
  }

  void loadLectures() {
    final startOfWeek = DateTime.now().startOfWeek();

    final events = timetable.lectures.map((lecture) {
      final day = startOfWeek.addDays(lecture.day.value);
      return CalendarEvent<Lecture>(
        canModify: false,
        dateTimeRange: DateTimeRange(
          start: day.add(Duration(hours: lecture.time.start)),
          end: day.add(Duration(hours: lecture.time.end)),
        ),
        data: lecture,
      );
    }).toList();

    eventsController.clearEvents();
    eventsController.addEvents(events);
  }

  void optimise() async {
    final lectures = <Lecture>[];
    await Future.wait(
      timetable.subjects.map(
        (s) => ref.read(
          remoteLecturesProvider
              .call(timetable.sourceTimetableId, FilterType.subject, s.id)
              .future,
        ),
      ),
    ).then((t) => t.forEach(lectures.addAll));

    final result = TimetableOptimiser.minimiseOverlapAndGap(lectures);

    timetable = timetable.copyWith(lectures: result[0]);
    loadLectures();
  }

  void saveAndExit() async {
    await ref.read(timetablesProvider.notifier).updateTimetable(timetable);
    if (mounted) {
      context.pop();
    }
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
        components: calendarComponents,
        callbacks: CalendarCallbacks(
          onEventTapped: (event, _) {
            showModalBottomSheet(
              context: context,
              builder: (context) => Container(
                width: double.infinity,
                color: Theme.of(context).primaryColor,
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [Text(event.data?.subject.name ?? '')],
                  ),
                ),
              ),
            );
          },
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
