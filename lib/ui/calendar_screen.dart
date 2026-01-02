import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kalender/kalender.dart';
import 'package:urnicar/data/remote_timetable/timetable_scraper.dart';
import 'package:urnicar/data/timetable/optimiser.dart';
import 'package:urnicar/data/timetable/timetables_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  final eventsController = DefaultEventsController<Lecture>();
  final calendarController = CalendarController<Lecture>();

  bool editMode = false;

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

  void handleTimetableChange(String? value) {
    if (value == null) return;
    if (value == 'import') {
      context.push('/import');
      return;
    }
    setState(() => selectedTimetableId = value);

    eventsController.clearEvents();

    final timetable = ref
        .read(timetablesProvider)
        .firstWhereOrNull((t) => t.id == selectedTimetableId);
    if (timetable == null) return;

    // for testing purposes (to get different optimised timetable change the index)
    // final optTimetable = TimetableOptimiser.minimiseOverlapAndGap(timetable.lectures)[0]; 
    
    final startOfWeek = DateTime.now().startOfWeek();
    // final events = optTimetable.map((lecture) {
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

    eventsController.addEvents(events);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: editMode
          ? FloatingActionButton(
              onPressed: () => setState(() => editMode = false),
              child: const Icon(Icons.check),
            )
          : null,

      body: CalendarView<Lecture>(
        eventsController: eventsController,
        calendarController: calendarController,
        viewConfiguration: viewConfiguration,
        callbacks: CalendarCallbacks(
          onEventTapped: (event, _) => calendarController.selectEvent(event),
          onEventCreate: editMode ? (event) => event : null,
          onEventCreated: editMode
              ? (event) => eventsController.addEvent(event)
              : null,
        ),
        header: Column(
          children: [
            topToolbar(),
            calendarToolbar(),
            if (editMode)
              const Padding(
                padding: EdgeInsets.all(4),
                child: Text(
                  'Urejanje urnika',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
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
            tileBuilder: (event, tileRange) {
              final lecture = event.data!;
              return Container(
                margin: const EdgeInsets.all(2),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: HSLColor.fromAHSL(
                    1,
                    lecture.subject.acronym.hashCode % 360,
                    0.5,
                    0.5,
                  ).toColor(),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lecture.subject.acronym,
                      overflow: TextOverflow.clip,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                      ),
                    ),
                    Text(
                      lecture.classroom.name,
                      overflow: TextOverflow.clip,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                      ),
                    ),
                    if (viewConfiguration.name == 'Day')
                      for (final teacher in lecture.teachers)
                        Text(
                          teacher.name,
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                          ),
                        ),
                  ],
                ),
              );
            },
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
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            PopupMenuButton<String>(
              icon: const CircleAvatar(child: Icon(Icons.person, size: 18)),
              onSelected: (value) {
                if (value == "login") {
                  context.push('/login');
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: "login", child: Text("Vpis")),
              ],
            ),
            Expanded(
              flex: 8,
              child: DropdownButton<String>(
                value: selectedTimetableId,
                hint: const Text("Izberi urnik"),
                items: [
                  for (final timetable in ref.watch(timetablesProvider))
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
                // isExpanded: true,
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
                      setState(() => editMode = true);
                      break;
                    case 'delete':
                      if (selectedTimetableId != null) {
                        ref
                            .read(timetablesProvider.notifier)
                            .deleteTimetable(selectedTimetableId!);
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
