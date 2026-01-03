import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalender/kalender.dart';
import '../data/remote_timetable/remote_lectures_provider.dart';
import '../data/remote_timetable/timetable_scraper.dart';
import 'lecture_tile.dart';

class TemporaryCalendarScreen extends ConsumerStatefulWidget {
  final String timetableId;
  final FilterType filterType;
  final String filterId;
  final String title;

  const TemporaryCalendarScreen({
    super.key,
    required this.timetableId,
    required this.filterType,
    required this.filterId,
    required this.title,
  });

  @override
  ConsumerState createState() => _TemporaryCalendarScreenState();
}

class _TemporaryCalendarScreenState
    extends ConsumerState<TemporaryCalendarScreen> {
  final eventsController = DefaultEventsController<Lecture>();
  final calendarController = CalendarController<Lecture>();

  late final Future<List<Lecture>> _futureLectures;
  late final ViewConfiguration viewConfiguration;



  //for ontap in lecture detail popup, selectedTimetableId replaced by timetableId
  void openTemporaryCalendar({
    required BuildContext context,
    required WidgetRef ref,
    required String timetableId,
    required FilterType filterType,
    required String filterId,
    required String title,
  }) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TemporaryCalendarScreen(
          timetableId: timetableId,
          filterType: filterType,
          filterId: filterId,
          title: title,
        ),
      ),
    );
  }
  @override
  void initState() {
    super.initState();

    final displayRange = DateTime.now().weekRange();
    final timeOfDayRange = TimeOfDayRange(
      start: TimeOfDay(hour: 6, minute: 0),
      end: TimeOfDay(hour: 21, minute: 0),
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

          final lectures = snapshot.data!;
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
            callbacks: CalendarCallbacks(
              onEventTapped: (event, _) {
                final lecture = event.data;
                if (lecture == null) return;
                print(lecture.type.toString());
                String lectureType =
                lecture.type.name.toString() == "lecture" ? "Predavanje" : "Vaje";
                List<String> days = ["Ponedeljek", "Torek", "Sreda", "Četrtek", "Petek"];
                String lectureDay = days[lecture.day.index];
                String timestr = "$lectureDay ${lecture.time.start.toString().padLeft(2, '0')}:00 - ${lecture.time.end.toString().padLeft(2, '0')}:00";

                showDialog(context: context, builder: (_) => AlertDialog(
                  title:
                  InkWell(
                      child: Text("${lecture.subject.name} - $lectureType"),
                      onTap: () {
                        Navigator.pop(context);
                        openTemporaryCalendar(
                          context: context,
                          ref: ref,
                          filterType: FilterType.subject,
                          filterId: lecture.subject.id,
                          title: lecture.subject.name,
                          timetableId: widget.timetableId,
                        );
                      }

                  ),

                  content: Column (
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      Text(timestr),
                      InkWell(
                          child: Text(lecture.classroom.name),
                          onTap: () {
                            Navigator.pop(context);
                            openTemporaryCalendar(
                              context: context,
                              ref: ref,
                              filterType: FilterType.classroom,
                              filterId: lecture.classroom.id,
                              title: lecture.classroom.name,
                              timetableId: widget.timetableId,
                            );
                          }
                      ),

                      for (final teacher in lecture.teachers)
                        InkWell(
                            child: Text(teacher.name),
                            onTap: () {
                              Navigator.pop(context);
                              openTemporaryCalendar(
                                context: context,
                                ref: ref,
                                filterType: FilterType.teacher,
                                filterId: teacher.id,
                                title: teacher.name,
                                timetableId: widget.timetableId,
                              );
                            }
                        )
                    ],
                  ),
                ));
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
                    LectureTile(event: event),
              ),
            ),
          );
        },
      ),
    );
  }
}