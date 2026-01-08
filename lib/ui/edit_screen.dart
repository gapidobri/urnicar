import 'package:collection/collection.dart';
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
import 'package:urnicar/ui/widgets/edit_lecture_bottom_sheet.dart';
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

  late final TextEditingController nameController;

  @override
  void initState() {
    super.initState();

    timetable = ref.read(timetablesProvider)[widget.timetableId]!;

    nameController = TextEditingController(text: timetable.name);

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
    final hiddenLectures = timetable.lectures.where((l) => l.hidden);
    final hiddenSubjectMap = <String, Set<LectureType>>{};
    for (final hiddenLecture in hiddenLectures) {
      final subjectId = hiddenLecture.subject.id;
      if (!hiddenSubjectMap.containsKey(subjectId)) {
        hiddenSubjectMap[subjectId] = {};
      }
      hiddenSubjectMap[subjectId]?.add(hiddenLecture.type);
    }

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

    final filteredLectures = lectures
        .whereNot(
          (l) => hiddenSubjectMap[l.subject.id]?.contains(l.type) ?? false,
        )
        .toList();

    final result = TimetableOptimiser.minimiseOverlapAndGap(filteredLectures);

    final selectedResult = result[0];

    selectedResult.addAll(hiddenLectures);

    timetable = timetable.copyWith(lectures: selectedResult);
    loadLectures();
  }

  void saveAndExit() async {
    timetable = timetable.copyWith(name: nameController.text);

    await ref.read(timetablesProvider.notifier).updateTimetable(timetable);
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: UnderlineInputBorder(),
          ),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
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
              barrierColor: Colors.transparent,
              builder: (context) => EditLectureBottomSheet(
                lecture: event.data!,
                onUpdate: (lecture) {
                  timetable = timetable.copyWith(
                    lectures: timetable.lectures
                        .map((l) => l.id == lecture.id ? lecture : l)
                        .toList(),
                  );
                  loadLectures();
                },
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
            tileBuilder: (event, tileRange) =>
                LectureTile(lecture: event.data!, showPin: true),
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
