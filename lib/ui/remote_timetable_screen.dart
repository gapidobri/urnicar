import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalender/kalender.dart';
import 'package:urnicar/ui/widgets/calendar_components.dart';
import 'package:urnicar/ui/widgets/lecture_info_dialog.dart';

import '../data/remote_timetable/remote_lectures_provider.dart';
import '../data/remote_timetable/timetable_scraper.dart';
import 'widgets/lecture_tile.dart';

class RemoteTimetableScreenParams {
  final FilterType filterType;
  final String filterId;
  final String title;
  final bool selectionMode;

  const RemoteTimetableScreenParams({
    required this.filterType,
    required this.filterId,
    required this.title,
    this.selectionMode = false,
  });
}

class RemoteTimetableScreen extends ConsumerStatefulWidget {
  final String timetableId;
  final FilterType filterType;
  final String filterId;
  final String title;
  final bool selectionMode;

  const RemoteTimetableScreen({
    super.key,
    required this.timetableId,
    required this.filterType,
    required this.filterId,
    required this.title,
    this.selectionMode = false,
  });

  @override
  ConsumerState createState() => _TemporaryCalendarScreenState();
}

class _TemporaryCalendarScreenState
    extends ConsumerState<RemoteTimetableScreen> {
  final eventsController = DefaultEventsController<Lecture>();
  final calendarController = CalendarController<Lecture>();

  late final Future<List<Lecture>> _futureLectures;
  late final ViewConfiguration viewConfiguration;

  @override
  void initState() {
    super.initState();

    final displayRange = DateTime.now().weekRange();
    final timeOfDayRange = TimeOfDayRange(
      start: TimeOfDay(hour: 6, minute: 0),
      end: TimeOfDay(hour: 20, minute: 59),
    );

    viewConfiguration = MultiDayViewConfiguration.workWeek(
      displayRange: displayRange,
      timeOfDayRange: timeOfDayRange,
    );

    _futureLectures = ref.read(
      remoteLecturesProvider(
        widget.timetableId,
        widget.filterType,
        widget.filterId,
      ).future,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<Lecture>>(
        future: _futureLectures,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final lectures = widget.selectionMode
              ? snapshot.data!.where((lecture) =>
          lecture.type == LectureType.labExercises ||
              lecture.type == LectureType.auditoryExercises
          ).toList()
              : snapshot.data!;

          final startOfWeek = DateTime.now().startOfWeek();
          final events = lectures.map((lecture) {
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

          WidgetsBinding.instance.addPostFrameCallback((_) {
            eventsController.clearEvents();
            eventsController.addEvents(events);
          });

          return CalendarView<Lecture>(
            eventsController: eventsController,
            calendarController: calendarController,
            viewConfiguration: viewConfiguration,
            components: calendarComponents,
            callbacks: CalendarCallbacks(
              onEventTapped: (event, _) {
                final lecture = event.data;
                if (lecture == null) return;

                if (widget.selectionMode) {
                  Navigator.pop(context, lecture);
                } else {
                showDialog(
                  context: context,
                  builder: (_) => LectureInfoDialog(lecture: lecture),
                );
                }
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
                tileBuilder: (event, range) =>
                    LectureTile(lecture: event.data!),
              ),
            ),
          );
        },
      ),
    );
  }
}
