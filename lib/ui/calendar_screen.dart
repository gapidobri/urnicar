import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kalender/kalender.dart';
import 'package:urnicar/data/remote_timetable/timetable_scraper.dart';
import 'package:urnicar/data/sync/pocketbase.dart';
import 'package:urnicar/data/timetable/timetables_provider.dart';
import 'package:urnicar/ui/temporary_calendar_screen.dart';
import 'package:urnicar/ui/widgets/calendar_components.dart';
import 'package:urnicar/ui/widgets/lecture_tile.dart';
import 'package:urnicar/ui/widgets/profile_dialog.dart';

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

  String? selectedTimetableId;

  @override
  void initState() {
    super.initState();

    final displayRange = DateTime.now().weekRange();
    final timeOfDayRange = TimeOfDayRange(
      start: TimeOfDay(hour: 6, minute: 0),
      end: TimeOfDay(hour: 21, minute: 0),
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
    final timetable = ref.read(timetablesProvider)[selectedTimetableId];
    if (timetable == null) return;

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

  void handleTimetableChange(String? value) {
    if (value == null) {
      eventsController.clearEvents();
      return;
    }
    if (value == 'import') {
      context.push('/import');
      return;
    }
    setState(() => selectedTimetableId = value);

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
        builder: (_) => TemporaryCalendarScreen(
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
    ref.listen(timetablesProvider, (prev, curr) {
      if (prev?[selectedTimetableId] != curr[selectedTimetableId]) {
        loadLectures();
      }
    });

    return Scaffold(
      body: CalendarView<Lecture>(
        eventsController: eventsController,
        calendarController: calendarController,
        viewConfiguration: viewConfiguration,
        components: calendarComponents,
        callbacks: CalendarCallbacks(
          onEventTapped: (event, _) {
            final lecture = event.data;
            if (lecture == null) return;

            final lectureType = lecture.type.name.toString() == "lecture"
                ? "Predavanje"
                : "Vaje";
            final days = ["Ponedeljek", "Torek", "Sreda", "Četrtek", "Petek"];
            final lectureDay = days[lecture.day.index];
            final timeStr =
                "$lectureDay ${lecture.time.start.toString().padLeft(2, '0')}:00 - ${lecture.time.end.toString().padLeft(2, '0')}:00";

            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: InkWell(
                  child: Text("${lecture.subject.name} - $lectureType"),
                  onTap: () {
                    Navigator.pop(context);
                    openTemporaryCalendar(
                      context: context,
                      ref: ref,
                      selectedTimetableId: selectedTimetableId!,
                      filterType: FilterType.subject,
                      filterId: lecture.subject.id,
                      title: lecture.subject.name,
                    );
                  },
                ),

                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(timeStr),
                    InkWell(
                      child: Text(lecture.classroom.name),
                      onTap: () {
                        Navigator.pop(context);
                        openTemporaryCalendar(
                          context: context,
                          ref: ref,
                          selectedTimetableId: selectedTimetableId!,
                          filterType: FilterType.classroom,
                          filterId: lecture.classroom.id,
                          title: lecture.classroom.name,
                        );
                      },
                    ),

                    for (final teacher in lecture.teachers)
                      InkWell(
                        child: Text(teacher.name),
                        onTap: () {
                          Navigator.pop(context);
                          openTemporaryCalendar(
                            context: context,
                            ref: ref,
                            selectedTimetableId: selectedTimetableId!,
                            filterType: FilterType.teacher,
                            filterId: teacher.id,
                            title: teacher.name,
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        header: Column(
          children: [
            topToolbar(),
            calendarToolbar(),
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
          multiDayTileComponents: TileComponents(
            tileBuilder: (event, tileRange) => LectureTile(event: event),
          ),
        ),
      ),
    );
  }

  Widget calendarToolbar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<ViewConfiguration>(
              value: viewConfiguration,
              items: viewConfigurations
                  .map((v) => DropdownMenuItem(value: v, child: Text(v.name)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => viewConfiguration = v);
              },
            ),
          ),
        ],
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
                value: selectedTimetableId,
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
                  switch (value) {
                    case 'edit':
                      if (selectedTimetableId != null) {
                        context.push('/edit/$selectedTimetableId');
                      }
                      break;
                    case 'delete':
                      if (selectedTimetableId != null) {
                        ref
                            .read(timetablesProvider.notifier)
                            .deleteTimetable(selectedTimetableId!);
                        eventsController.clearEvents();
                        setState(() => selectedTimetableId = null);
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
