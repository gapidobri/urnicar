import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kalender/kalender.dart';
import 'package:urnicar/data/timetable/timetables_provider.dart';

class Event {
  final String title;

  const Event(this.title);
}

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  final eventsController = DefaultEventsController<Event>();
  final calendarController = CalendarController<Event>();

  bool editMode = false;

  final now = DateTime.now();
  late final displayRange = DateTimeRange(
    start: now.subtract(const Duration(days: 363)),
    end: now.add(const Duration(days: 365)),
  );

  late ViewConfiguration viewConfiguration;
  late final List<ViewConfiguration> viewConfigurations;
  String? selectedOption;

  @override
  void initState() {
    super.initState();

    // mozni prikazi urnika
    viewConfigurations = [
      MultiDayViewConfiguration.singleDay(
        displayRange: displayRange,
        initialTimeOfDay: const TimeOfDay(hour: 6, minute: 0),
      ),
      MultiDayViewConfiguration.workWeek(
        displayRange: displayRange,
        initialTimeOfDay: const TimeOfDay(hour: 6, minute: 0),
      ),
    ];

    // default je prikaz tedenskega urnika
    viewConfiguration = viewConfigurations[1];

    // za dodajanje eventov debugging purposes
    // eventsController.addEvents([]);
  }

  void handleTimetableChange(String? value) {
    if (value == null) return;
    if (value == 'import') {
      context.push('/import');
      return;
    }
    setState(() => selectedOption = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: editMode
          ? FloatingActionButton(
        onPressed: () {
          setState(() {
            editMode = false;
          });
        },
        child: const Icon(Icons.check),
      )
          : null,
      // glavni calendar widget
      body: CalendarView<Event>(
        eventsController: eventsController,
        calendarController: calendarController,
        viewConfiguration: viewConfiguration,
        callbacks: CalendarCallbacks<Event>(
          onEventTapped: (event, _) =>
              calendarController.selectEvent(event),
          onEventCreate: editMode ? (event) => event : null,
          onEventCreated: editMode
              ? (event) => eventsController.addEvent(event)
              : null,
        ),
        header: Material(
          child: Column(
            children: [
              topToolbar(),
              _calendarToolbar(),
              if (editMode)
                const Padding(
                  padding: EdgeInsets.all(4),
                  child: Text(
                    "Urejanje urnika",
                    style: TextStyle(
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              const CalendarHeader<Event>(),
            ],
          ),
        ),
        body: CalendarBody<Event>(
          calendarController: calendarController,
          eventsController: eventsController,
          multiDayTileComponents: TileComponents<Event>(
            tileBuilder: (event, tileRange) {
              return Container(
                margin: const EdgeInsets.all(2),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  event.data!.title,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // dropdown za menjavo pogleda + ikonca za vračanje na trenuten dan
  Widget _calendarToolbar() {
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
          // klik na ikono skoci na danasnji datum
          IconButton(
            onPressed: () => calendarController.animateToDate(DateTime.now()),
            icon: const Icon(Icons.today),
          ),
        ],
      ),
    );
  }

  // zgornji toolbar za izbiro urnika + menu
  Widget topToolbar() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            PopupMenuButton<String>(
              icon: const CircleAvatar(
                child: Icon(Icons.person, size: 18),
              ),
              onSelected: (value) {
                if (value == "login") {
                  context.push('/login');
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: "login",
                  child: Text("Vpis"),
                ),
              ],
            ),
            Expanded(
              flex: 8,
              child: DropdownButton<String>(
                value: selectedOption,
                hint: const Text("Izberi urnik"),
                items: [
                  for (final timetable in ref.watch(timetablesProvider))
                    DropdownMenuItem(
                      value: timetable.id,
                      child: Text(timetable.name),
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
                  if (value == "edit") {
                    setState(() {
                      editMode = true;
                    });
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: "edit",
                    child: Text("Uredi"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
