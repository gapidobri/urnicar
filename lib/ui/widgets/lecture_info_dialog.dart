import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:urnicar/data/remote_timetable/timetable_scraper.dart';
import 'package:urnicar/data/timetable/selected_timetable_id_provider.dart';
import 'package:urnicar/data/timetable/timetables_provider.dart';
import 'package:urnicar/ui/remote_timetable_screen.dart';

const _days = ['Ponedeljek', 'Torek', 'Sreda', 'Četrtek', 'Petek'];

const _lectureTypes = {
  LectureType.lecture: 'Predavanje',
  LectureType.labExercises: 'Laboratorijske vaje',
  LectureType.auditoryExercises: 'Avditorne vaje',
};

class LectureInfoDialog extends ConsumerWidget {
  const LectureInfoDialog({super.key, required this.lecture});

  final Lecture lecture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void showTimetable({
      required FilterType filterType,
      required String filterId,
      required String title,
    }) {
      final timetableId = ref
          .read(timetablesProvider)[ref.read(selectedTimetableIdProvider)]
          ?.sourceTimetableId;
      if (timetableId == null) return;

      context.push(
        '/remoteTimetable/$timetableId',
        extra: RemoteTimetableScreenParams(
          filterType: filterType,
          filterId: filterId,
          title: title,
        ),
      );
    }

    final dayString = _days[lecture.day.value];
    final startString = '${lecture.time.start.toString().padLeft(2, '0')}:00';
    final endString = '${lecture.time.end.toString().padLeft(2, '0')}:00';
    final timeString = '$dayString, $startString - $endString';

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 4.0,
          children: [
            InkWell(
              onTap: () => showTimetable(
                filterType: FilterType.subject,
                filterId: lecture.subject.id,
                title: lecture.subject.name,
              ),
              borderRadius: BorderRadius.circular(8.0),
              child: Text(
                lecture.subject.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Text(
              _lectureTypes[lecture.type] ?? 'Drugo',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Divider(height: 24.0),
            Text(timeString),
            InkWell(
              onTap: () => showTimetable(
                filterType: FilterType.classroom,
                filterId: lecture.classroom.id,
                title: lecture.classroom.name,
              ),
              borderRadius: BorderRadius.circular(8.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(lecture.classroom.name),
              ),
            ),
            for (final teacher in lecture.teachers)
              InkWell(
                onTap: () => showTimetable(
                  filterType: FilterType.teacher,
                  filterId: teacher.id,
                  title: teacher.name,
                ),
                borderRadius: BorderRadius.circular(8.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(teacher.name),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
