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

enum Algorithm {
  minimalOverlap,
  minimalOverlapAndGap
}

class OptimisationOptions {
  Algorithm algorithm;
  DayOfWeek? freeDay;

  OptimisationOptions({required this.algorithm, this.freeDay});
}

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

  OptimisationOptions options = OptimisationOptions(algorithm: Algorithm.minimalOverlap);
  @override
  void initState() {
    super.initState();

    timetable = ref.read(timetablesProvider)[widget.timetableId]!;

    nameController = TextEditingController(text: timetable.name);

    final displayRange = DateTime.now().weekRange();
    final timeOfDayRange = TimeOfDayRange(
      start: const TimeOfDay(hour: 6, minute: 0),
      end: const TimeOfDay(hour: 20, minute: 59),
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

    for (int i = 0; i < timetable.lectures.length; i++) {
      for (int j = 0; j < lectures.length; j++) {
        final testLecture = timetable.lectures[i].copyWith(pinned: false);
        if (testLecture == lectures[j]) {
          lectures[j] = lectures[j].copyWith(pinned: timetable.lectures[i].pinned);
          break;
        }
      }
    }

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
                timetableId: timetable.sourceTimetableId,
                onUpdate: (lecture) {
                  timetable = timetable.copyWith(
                    lectures: timetable.lectures
                        .map((l) => l.id == lecture.id ? lecture : l)
                        .toList(),
                  );
                  loadLectures();
                },
                onReplace: (oldLec, newLec) {
                timetable = timetable.copyWith(
                  lectures: timetable.lectures
                      .map((l) => l.id == oldLec.id ? newLec : l)
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
          multiDayBodyConfiguration: MultiDayBodyConfiguration(
            eventLayoutStrategy: sideBySideLayoutStrategy,
          ),
          multiDayTileComponents: TileComponents(
            tileBuilder: (event, tileRange) =>
                LectureTile(lecture: event.data!, showPin: true),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: StatefulBuilder(
                  builder: (context, setModalState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioGroup<Algorithm>(
                          groupValue: options.algorithm,
                          onChanged: (value) {
                            if (value != null) setModalState(() => options.algorithm = value);
                          },
                          child: Column(
                            children: [
                              ListTile(
                                title: const Text('Minimalno prekrivanje'),
                                trailing: Radio<Algorithm>(value: Algorithm.minimalOverlap),
                              ),
                              ListTile(
                                title: const Text('Minimalno prekrivanje in razmiki'),
                                trailing: Radio<Algorithm>(value: Algorithm.minimalOverlapAndGap),
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                          title: const Text('Prost dan'),
                          trailing: DropdownButton<DayOfWeek>(
                            value: options.freeDay,
                            hint: const Text('-'),
                            items: [
                              DropdownMenuItem(value: null, child: Text('-')),
                              DropdownMenuItem(value: DayOfWeek.monday, child: Text('Pon')),
                              DropdownMenuItem(value: DayOfWeek.tuesday, child: Text('Tor')),
                              DropdownMenuItem(value: DayOfWeek.wednesday, child: Text('Sre')),
                              DropdownMenuItem(value: DayOfWeek.thursday, child: Text('Čet')),
                              DropdownMenuItem(value: DayOfWeek.friday, child: Text('Pet')),
                            ],
                            onChanged: (value) {
                              setModalState(() => options.freeDay = value);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                optimise();
                              },
                              child: const Text('Optimiziraj urnik'),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          );
        },
        child: const Icon(Icons.auto_fix_high),
      ),
    );
  }
}
