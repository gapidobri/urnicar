import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urnicar/data/remote_timetable/timetable_scraper.dart';

import '../remote_timetable_screen.dart';

final _lectureTypes = {
  LectureType.lecture: 'Predavanje',
  LectureType.labExercises: 'Laboratorijske vaje',
  LectureType.auditoryExercises: 'Avditorne vaje',
};

class EditLectureBottomSheet extends ConsumerStatefulWidget {
  const EditLectureBottomSheet({
    super.key,
    required this.lecture,
    required this.onUpdate,
    required this.onReplace,
    required this.timetableId,
  });

  final Lecture lecture;
  final void Function(Lecture) onUpdate;

  final String timetableId;

  final void Function(Lecture, Lecture) onReplace;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditLectureBottomSheetState();
}

class _EditLectureBottomSheetState
    extends ConsumerState<EditLectureBottomSheet> {
  late bool hidden;
  late bool pinned;

  @override
  void initState() {
    hidden = widget.lecture.hidden;
    pinned = widget.lecture.pinned;
    super.initState();
  }

  void updateLecture() {
    widget.onUpdate(widget.lecture.copyWith(hidden: hidden, pinned: pinned));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.lecture.subject.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 2.0),
              Text(
                _lectureTypes[widget.lecture.type] ?? 'Ostalo',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: hidden,
                        onChanged: (value) {
                          setState(() => hidden = value ?? false);
                          updateLecture();
                        },
                      ),
                      Text('Skrij uro'),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: pinned,
                        onChanged: (value) {
                          setState(() => pinned = value ?? false);
                          updateLecture();
                        },
                      ),
                      Text('Pripni uro'),
                    ],
                  ),
                ],
              ),
              if (widget.lecture.type == LectureType.labExercises ||
                  widget.lecture.type == LectureType.auditoryExercises)
                ElevatedButton(
                  onPressed: () async {
                    final chosen = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RemoteTimetableScreen(
                          timetableId: widget.timetableId,
                          filterType: FilterType.subject,
                          filterId: widget.lecture.subject.id,
                          title: "Izberite nov termin",
                          selectionMode: true,
                        ),
                      ),
                    );

                    if (chosen is Lecture) {
                      widget.onReplace(widget.lecture, chosen);
                      Navigator.pop(context);
                    }
                  },
                  style: ButtonStyle(
                    padding: WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8.0,
                    children: [Icon(Icons.sync), Text('Zamenjaj termin')],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
