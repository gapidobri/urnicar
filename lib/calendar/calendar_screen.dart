import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';

class Event {
  final String title;

  const Event(this.title);
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final eventsController = DefaultEventsController<Event>();
  final calendarController = CalendarController<Event>();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // glavni calendar widget
      body: CalendarView<Event>(
        eventsController: eventsController,
        calendarController: calendarController,
        viewConfiguration: viewConfiguration,
        callbacks: CalendarCallbacks<Event>(
          onEventTapped: (event, _) => calendarController.selectEvent(event),
          onEventCreate: (event) => event,
          onEventCreated: (event) => eventsController.addEvent(event),
        ),
        header: Material(
          child: Column(
            children: [
              topToolbar(),
              _calendarToolbar(),
              const CalendarHeader<Event>(),
            ],
          ),
        ),
        body: const CalendarBody<Event>(),
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
            Expanded(
              flex: 8,
              child: DropdownButton<String>(
                value: selectedOption,
                hint: const Text("Izberi urnik"),
                items: const [
                  DropdownMenuItem(
                    value: "FRI VSŠ 2025/26",
                    child: Text("FRI VSŠ 2025/26"),
                  ),
                  DropdownMenuItem(
                    value: "FRI UNI 2025/26",
                    child: Text("FRI UNI 2025/26"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedOption = value;
                  });
                },
                isExpanded: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () {},
                  child: const Icon(Icons.menu),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
