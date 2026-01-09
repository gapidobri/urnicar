import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kalender/kalender.dart';
import 'package:urnicar/data/remote_timetable/timetable_scraper.dart';
import 'package:urnicar/data/sync/pocketbase.dart';
import 'package:urnicar/data/timetable/selected_timetable_id_provider.dart';
import 'package:urnicar/data/timetable/timetables_provider.dart';
import 'package:urnicar/ui/remote_timetable_screen.dart';
import 'package:urnicar/ui/widgets/calendar_components.dart';
import 'package:urnicar/ui/widgets/lecture_info_dialog.dart';
import 'package:urnicar/ui/widgets/lecture_tile.dart';
import 'package:urnicar/ui/widgets/profile_dialog.dart';

const _days = ["Ponedeljek", "Torek", "Sreda", "Četrtek", "Petek"];

const _lectureTypes = {
  LectureType.lecture: 'Predavanje',
  LectureType.labExercises: 'Laboratorijske vaje',
  LectureType.auditoryExercises: 'Avditorne vaje',
};

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  final eventsController = DefaultEventsController<Lecture>();
  final calendarController = CalendarController<Lecture>();

  late ViewConfiguration viewConfiguration;
  late final List<ViewConfiguration> viewConfigurations;

  @override
  void initState() {
    super.initState();

    final displayRange = DateTime.now().weekRange();
    final timeOfDayRange = TimeOfDayRange(
      start: TimeOfDay(hour: 6, minute: 0),
      end: TimeOfDay(hour: 20, minute: 59),
    );
    viewConfigurations = [
      MultiDayViewConfiguration.singleDay(
        displayRange: displayRange,
        timeOfDayRange: timeOfDayRange,
      ),
      MultiDayViewConfiguration.workWeek(
        displayRange: displayRange,
        timeOfDayRange: timeOfDayRange,
      ),
    ];
    viewConfiguration = viewConfigurations[1];
  }

  void loadLectures() {
    final selectedTimetableId = ref.read(selectedTimetableIdProvider);
    if (selectedTimetableId == null) return;

    final selectedTimetable = ref.read(timetablesProvider)[selectedTimetableId];
    if (selectedTimetable == null) return;

    final startOfWeek = DateTime.now().startOfWeek();
    final events = selectedTimetable.lectures
        .where((lecture) => !lecture.hidden)
        .map((lecture) {
          final day = startOfWeek.addDays(lecture.day.value);
          return CalendarEvent<Lecture>(
            canModify: false,
            dateTimeRange: DateTimeRange(
              start: day.add(Duration(hours: lecture.time.start)),
              end: day.add(Duration(hours: lecture.time.end)),
            ),
            data: lecture,
          );
        })
        .toList();

    eventsController.clearEvents();
    eventsController.addEvents(events);
  }

  void handleTimetableChange(String? value) {
    ref.read(selectedTimetableIdProvider.notifier).set(value);

    if (value == null) {
      eventsController.clearEvents();
      return;
    }
    if (value == 'import') {
      context.push('/import');
      return;
    }

    loadLectures();
  }

  void openTemporaryCalendar({
    required BuildContext context,
    required WidgetRef ref,
    required String selectedTimetableId,
    required FilterType filterType,
    required String filterId,
    required String title,
  }) {
    final timetable = ref.read(timetablesProvider)[selectedTimetableId]!;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RemoteTimetableScreen(
          timetableId: timetable.sourceTimetableId,
          filterType: filterType,
          filterId: filterId,
          title: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(timetablesProvider, (prev, curr) => loadLectures());
    ref.listen(selectedTimetableIdProvider, (prev, curr) => loadLectures());

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (viewConfiguration == viewConfigurations[0]) {
              viewConfiguration = viewConfigurations[1];
            } else {
              viewConfiguration = viewConfigurations[0];
            }
          });
        },
        child: Icon(
          viewConfiguration == viewConfigurations[0]
              ? Icons.calendar_view_week
              : Icons.calendar_view_day,
        ),
      ),

      body: CalendarView<Lecture>(
        eventsController: eventsController,
        calendarController: calendarController,
        viewConfiguration: viewConfiguration,
        components: calendarComponents,
        callbacks: CalendarCallbacks(
          onEventTapped: (event, _) {
            final lecture = event.data;
            if (lecture == null) return;

            showDialog(
              context: context,
              builder: (_) => LectureInfoDialog(lecture: lecture),
            );
          },
        ),
        header: Column(
          children: [
            topToolbar(),
            const CalendarHeader<Lecture>(
              multiDayHeaderConfiguration: MultiDayHeaderConfiguration(
                showTiles: false,
              ),
            ),
          ],
        ),
        body: CalendarBody<Lecture>(
          calendarController: calendarController,
          eventsController: eventsController,
          multiDayBodyConfiguration: MultiDayBodyConfiguration(
            eventLayoutStrategy: sideBySideLayoutStrategy,
          ),
          multiDayTileComponents: TileComponents(
            tileBuilder: (event, tileRange) => LectureTile(
              lecture: event.data!,
              longNames: viewConfiguration.name == 'Day',
            ),
          ),
        ),
      ),
    );
  }

  Widget topToolbar() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                if (pb.authStore.isValid) {
                  showDialog(
                    context: context,
                    builder: (context) => ProfileDialog(),
                  );
                } else {
                  context.push('/login');
                }
              },
              icon: const CircleAvatar(child: Icon(Icons.person, size: 18)),
            ),
            SizedBox(width: 2.0),
            Expanded(
              flex: 8,
              child: DropdownButton<String>(
                // to prevent crash on last delete
                value: () {
                  final timetables = ref
                      .watch(timetablesProvider)
                      .values
                      .toList();
                  final selectedId = ref.watch(selectedTimetableIdProvider);

                  // if valid, return selected
                  if (selectedId != null &&
                      timetables.any((t) => t.id == selectedId)) {
                    return selectedId;
                  }

                  // If invalid, return next
                  if (timetables.isNotEmpty) {
                    final nextId = timetables.first.id;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ref
                          .read(selectedTimetableIdProvider.notifier)
                          .set(nextId);
                    });

                    return nextId;
                  }

                  // If no left, return null
                  return null;
                }(),

                hint: const Text("Izberi urnik"),
                items: [
                  for (final timetable in ref.watch(timetablesProvider).values)
                    DropdownMenuItem(
                      value: timetable.id,
                      child: Text(
                        timetable.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  DropdownMenuItem(
                    value: 'import',
                    child: Row(
                      spacing: 8.0,
                      children: [
                        Icon(Icons.add, size: 24.0),
                        Text('Uvozi urnik'),
                      ],
                    ),
                  ),
                ],
                onChanged: handleTimetableChange,
                isExpanded: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.menu),
                onSelected: (value) {
                  final selectedTimetableId = ref.read(
                    selectedTimetableIdProvider,
                  );
                  switch (value) {
                    case 'edit':
                      if (selectedTimetableId != null) {
                        context.push('/edit/$selectedTimetableId');
                      }
                      break;
                    case 'delete':
                      if (selectedTimetableId != null) {
                        showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Odstranitev urnika'),
                            content: const Text(
                              'Ali si prepričan, da želiš odstraniti urnik?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Ne'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Da'),
                              ),
                            ],
                          ),
                        ).then((deleteBool) {
                          if (deleteBool == true) {
                            ref
                                .read(timetablesProvider.notifier)
                                .deleteTimetable(selectedTimetableId);
                            eventsController.clearEvents();
                          }
                        });
                      }
                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Uredi')),
                  PopupMenuItem(value: 'delete', child: Text('Izbriši')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
